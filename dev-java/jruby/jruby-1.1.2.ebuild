# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source test"
inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Java-based Ruby interpreter implementation"
HOMEPAGE="http://jruby.codehaus.org/"
SRC_URI="http://dist.codehaus.org/${PN}/${PN}-src-${PV}.tar.gz"
LICENSE="|| ( CPL-1.0 GPL-2 LGPL-2.1 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="bsf"

CDEPEND=">=dev-java/jline-0.9.91
	dev-java/asm:3
	dev-java/backport-util-concurrent
	dev-java/bytelist
	dev-java/jna
	dev-java/jna-posix
	dev-java/joda-time
	dev-java/joni
	dev-java/jvyamlb"

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
	>=dev-ruby/rspec-1.0.4"

RUBY_HOME=/usr/share/${PN}/lib/ruby
SITE_RUBY=${RUBY_HOME}/site_ruby
GEMS=${RUBY_HOME}/gems

JAVA_ANT_REWRITE_CLASSPATH="true"

pkg_setup() {
	java-pkg-2_pkg_setup

	if [[ -d "${SITE_RUBY}" && ! -L "${SITE_RUBY}" ]]; then
		ewarn "dev-java/jruby now uses dev-lang/ruby's site_ruby directory by creating symlinks."
		ewarn "${SITE_RUBY} is a directory right now, which will cause problems when being merged onto the filesystem."
	fi
	
	if [[ -d "${GEMS}" && ! -L "${GEMS}" ]]; then
		ewarn "dev-java/jruby now uses dev-lang/ruby's gems directory by creating symlinks."
		ewarn "${GEMS} is a directory right now, which will cause problems when being merged onto the filesystem."
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# We don't need to use Retroweaver.
	sed -i "/RetroWeaverTask/d" build.xml
	
	# Remove jarjar stuff.
	jarjarclean || die

	# Search only lib, kills jdk1.5+ property, which we set manually.
	java-ant_ignore-system-classes

	cd "${S}/build_lib" || die
	rm -vf *.jar || die
	
	# tools.jar must be symlinked manually.
	ln -s `java-config --tools` || die
	
	# This must be named anything but joni.jar because it is excluded from the tests.
	java-pkg_jar-from joni joni.jar joni_.jar
	
	# Collect the other JARs.
	java-pkg_jar-from asm-3,backport-util-concurrent,bytelist,jline,joda-time,jna,jna-posix,jvyamlb
	
	cd "${S}/lib" || die
	rm -vf *.jar || die
	
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
	# Tests will fail if this isn't present.
	mkdir -p spec
	
	# BSF is a compile-time only dependency because it's just the adapter
	# classes and they won't be used unless invoked from BSF itself.
	use bsf && java-pkg_jar-from --into build_lib --with-dependencies bsf-2.3

	ANT_TASKS="ant-junit ant-trax" eant test -Djdk1.5+=true
}

src_install() {
	java-pkg_dojar lib/${PN}.jar
	use source && java-pkg_dosrc src/org
	dodoc README docs/{*.txt,README.*} || die

	if use doc; then
		java-pkg_dojavadoc docs/api
	fi
	
	java-pkg_dolauncher ${PN} \
		--main 'org.jruby.Main' \
		--java_args '-Djruby.base=/usr/share/jruby -Djruby.home=/usr/share/jruby -Djruby.lib=/usr/share/jruby/lib -Djruby.script=jruby -Djruby.shell=/bin/sh'
	
	dobin "${S}"/bin/jirb
	dodir "/usr/share/${PN}/lib"
	insinto "/usr/share/${PN}/lib"
	doins -r "${S}/lib/ruby"

	# Share gems with regular Ruby.
	rm -r "${D}"/usr/share/${PN}/lib/ruby/gems || die
	dosym /usr/lib/ruby/gems /usr/share/${PN}/lib/ruby/gems || die

	# Share site_ruby with regular Ruby.
	rm -r "${D}"/usr/share/${PN}/lib/ruby/site_ruby || die
	dosym /usr/lib/ruby/site_ruby /usr/share/${PN}/lib/ruby/site_ruby || die
}

pkg_preinst() {
	local bad_directory=0

	if [[ -d "${SITE_RUBY}" && ! -L "${SITE_RUBY}" ]]; then
		eerror "${SITE_RUBY} is a directory. Please move this directory out of the way, and then emerge --resume."
		bad_directory=1
	fi

	if [[ -d "${GEMS}" && ! -L "${GEMS}" ]]; then
		eerror "${GEMS} is a directory. Please move this directory out of the way, and then emerge --resume."
		bad_directory=1
	fi

	if [[ ! "${bad_directory}" ]]; then
		die "Please address the above errors, then emerge --resume."
	fi
}
