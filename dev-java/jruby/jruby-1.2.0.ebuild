# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"
JAVA_PKG_IUSE="doc source test"
inherit java-pkg-2 java-ant-2

DESCRIPTION="Java-based Ruby interpreter implementation"
HOMEPAGE="http://jruby.codehaus.org/"
SRC_URI="http://dist.codehaus.org/${PN}/${PV}/${PN}-src-${PV}.tar.gz"
LICENSE="|| ( CPL-1.0 GPL-2 LGPL-2.1 )"
SLOT="0"
KEYWORDS="~amd64"
IUSE="bsf java6 ssl"

CDEPEND=">=dev-java/bytelist-1.0.2
	>=dev-java/constantine-0.5
	>=dev-java/jline-0.9.94
	>=dev-java/joni-1.1.3
	>=dev-java/jna-posix-1.0
	>=dev-java/jvyamlb-0.2.5
	dev-java/asm:3
	dev-java/jcodings
	dev-java/jffi
	dev-java/jna
	dev-java/joda-time
	dev-util/jay
	!java6? ( dev-java/backport-util-concurrent )"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.5"

DEPEND="${CDEPEND}
	>=virtual/jdk-1.5
	bsf? ( >=dev-java/bsf-2.3 )
	test? (
		dev-java/ant-junit
		dev-java/ant-trax
	)"

PDEPEND="dev-ruby/rubygems
	>=dev-ruby/rake-0.7.3
	>=dev-ruby/rspec-1.0.4
	ssl? ( dev-ruby/jruby-openssl )"

RUBY_HOME=/usr/share/${PN}/lib/ruby
SITE_RUBY=${RUBY_HOME}/site_ruby
GEMS=${RUBY_HOME}/gems

JAVA_ANT_REWRITE_CLASSPATH="true"
EANT_GENTOO_CLASSPATH="asm-3 bytelist constantine jay jcodings jffi jline joda-time joni jna jna-posix jvyamlb"
EANT_NEEDS_TOOLS="true"

pkg_setup() {
	java-pkg-2_pkg_setup
	use java6 || EANT_GENTOO_CLASSPATH="${EANT_GENTOO_CLASSPATH} backport-util-concurrent"

	if [[ -d "${GEMS}" && ! -L "${GEMS}" ]]; then
		ewarn "dev-java/jruby now uses dev-lang/ruby's gems directory by creating symlinks."
		ewarn "${GEMS} is a directory right now, which will cause problems when being merged onto the filesystem."
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# We don't need to use Retroweaver. There is a jarjar and a regular jar
	# target but even with jarjarclean, both are a pain. The latter target
	# is slightly easier so go with this one.
	sed -r -i \
		-e "/RetroWeaverTask/d" \
		-e "/<zipfileset .+\/>/d" \
		build.xml || die

	# Search only lib, kills jdk1.5+ property, which we set manually.
	java-ant_ignore-system-classes

	# Delete the bundled JARs but keep invokedynamic.jar.
	# No source is available and it's only a dummy anyway.
	find build_lib lib -name "*.jar" ! -name "invokedynamic.jar" -delete || die

	if ! use bsf; then
		# Remove BSF test cases.
		cd "${S}/test/org/jruby"
		rm -f test/TestAdoptedThreading.java || die
		rm -f javasupport/test/TestBSF.java || die
		sed -i '/TestBSF.class/d' javasupport/test/JavaSupportTestSuite.java || die
		sed -i '/TestAdoptedThreading.class/d' test/MainTestSuite.java || die
	fi
}

src_compile() {
	eant jar `use_doc create-apidocs` -Djdk1.5+=true
}

src_test() {
	if [ ${UID} == 0 ] ; then
		ewarn 'The tests will fail if run as root so skipping them.'
		ewarn 'Enable FEATURES="userpriv" if you want to run them.'
		return
	fi

	# BSF is a compile-time only dependency because it's just the adapter
	# classes and they won't be used unless invoked from BSF itself.
	use bsf && java-pkg_jar-from --into build_lib --with-dependencies bsf-2.3

	# Our jruby.jar is unbundled so we need to add the classpath to this test.
	sed -i "s:java -jar:java -Xbootclasspath/a\:#{ENV['JRUBY_CP']} -jar:g" test/test_load_compiled_ruby_class_from_classpath.rb || die

	ANT_TASKS="ant-junit ant-trax" JRUBY_CP=`java-pkg_getjars ${EANT_GENTOO_CLASSPATH// /,}` JRUBY_OPTS="" eant test -Djdk1.5+=true
}

src_install() {
	local bin

	java-pkg_dojar lib/${PN}.jar
	dodoc README docs/{*.txt,README.*} || die

	use doc && java-pkg_dojavadoc docs/api
	use source && java-pkg_dosrc src/org

	dobin "${FILESDIR}/jruby" || die
	exeinto "/usr/share/${PN}/bin"
	doexe "${S}/bin/jruby" || die

	# Install some jruby tools.
	dobin "${S}"/bin/j{gem,irb{,_swing},rubyc} || die

	# Symlink some common tools so that jruby can launch them internally.
	for bin in {j,}gem jirb jrubyc rake rdoc ri spec{,_translator} ; do
		dosym "/usr/bin/${bin}" "/usr/share/${PN}/bin/${bin}" || die
	done

	insinto "${RUBY_HOME}"
	doins -r "${S}/lib/ruby/1.8" || die
	doins -r "${S}/lib/ruby/site_ruby" || die

	# Share gems with regular Ruby.
	dosym /usr/$(get_libdir)/ruby/gems "${GEMS}" || die

	# Autoload rubygems and append regular site_ruby to $LOAD_PATH.
	# Unfortunately the -I option prepends instead.
	insinto "${SITE_RUBY}"
	doins "${FILESDIR}/gentoo.rb" || die
	doenvd "${FILESDIR}/10jruby" || die
}

pkg_preinst() {
	if [[ -d "${GEMS}" && ! -L "${GEMS}" ]]; then
		eerror "${GEMS} is a directory. Please move this directory out of the way, and then emerge --resume."
		die "Please address the above errors, then emerge --resume."
	fi

	# Delete site_ruby if it is a symlink.
	[[ -L "${SITE_RUBY}" ]] && rm -f "${SITE_RUBY}"
}