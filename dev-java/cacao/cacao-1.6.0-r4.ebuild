# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
AUTOTOOLS_AUTO_DEPEND="no"

inherit autotools eutils flag-o-matic java-pkg-2 java-vm-2

DESCRIPTION="Cacao Java Virtual Machine"
HOMEPAGE="http://www.cacaojvm.org/"
SRC_URI="http://www.complang.tuwien.ac.at/cacaojvm/download/${P}/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
COMMON_DEPEND="
	dev-java/gnu-classpath:0
	|| ( dev-java/eclipse-ecj:* dev-java/ecj-gcj:* )
	>=dev-libs/boehm-gc-7.2d
"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}
	test? (
		dev-java/junit:4
		${AUTOTOOLS_DEPEND}
	)
"

src_prepare() {
	if use test; then
		sed -ie "s:/usr/share/java/junit4.jar:$(java-config -p junit-4):" \
			./tests/regression/bugzilla/Makefile.am \
			./tests/regression/base/Makefile.am || die "sed failed"
	fi
	epatch "${FILESDIR}/system-boehm-gc.patch"
	epatch "${FILESDIR}/support-7.patch"
	eautoreconf
}

src_configure() {
	# A compiler can be forced with the JAVAC variable if needed
	unset JAVAC
	append-flags -fno-strict-aliasing
	econf --bindir=/usr/libexec/${PN} \
		--libdir="${EPREFIX}"/usr/$(get_libdir)/${PN} \
		--datarootdir="${EPREFIX}"/usr/share/${PN} \
		--disable-dependency-tracking \
		--with-java-runtime-library-prefix="${EPREFIX}"/usr \
		--with-jni_h="${EPREFIX}"/usr/include/classpath \
		--with-jni_md_h="${EPREFIX}"/usr/include/classpath
}

src_compile() {
	default
}

src_install() {
	local libdir=$(get_libdir)
	local CLASSPATH_DIR=/usr/libexec/gnu-classpath
	local JDK_DIR=/usr/${libdir}/${PN}-jdk

	emake DESTDIR="${D}" install || die "make install failed"
	dodir /usr/bin
	dosym ../libexec/${PN}/cacao /usr/bin/cacao || die
	dodoc AUTHORS ChangeLog* NEWS README || die "failed to install docs"

	dodir ${JDK_DIR}/bin
	dosym ../../../libexec/${PN}/cacao ${JDK_DIR}/bin/java

	dodir ${JDK_DIR}/jre/lib
	dosym ../../../../share/classpath/glibj.zip ${JDK_DIR}/jre/lib/rt.jar
	dodir ${JDK_DIR}/lib
	dosym ../../../share/classpath/tools.zip ${JDK_DIR}/lib/tools.jar

	exeinto ${JDK_DIR}/bin
	for files in ${CLASSPATH_DIR}/g*; do
		# Need to alter scripts to make sure our VM is invoked
		if [ $files = "${CLASSPATH_DIR}/bin/gjdoc" ] ; then
			dest=javadoc
		else
			dest=$(echo $files|sed "s#$(dirname $files)/g##")
		fi
		cat ${files} | \
			sed -e "s#/usr/bin/java#/usr/libexec/${PN}/cacao#" | \
			newexe - ${dest}
	done

	local ecj_jar="$(readlink "${EPREFIX}"/usr/share/eclipse-ecj/ecj.jar)"
	cat "${FILESDIR}"/javac.in | sed -e "s#@JAVA@#/usr/libexec/${PN}/cacao#" \
		-e "s#@ECJ_JAR@#${ecj_jar}#" \
		-e "s#@RT_JAR@#/usr/share/classpath/glibj.zip#" \
		-e "s#@TOOLS_JAR@#/usr/share/classpath/tools.zip#" \
	| newexe - javac

	local libarch="${ARCH}"
	[ ${ARCH} == x86 ] && libarch="i386"
	[ ${ARCH} == x86_64 ] && libarch="amd64"
	dodir ${JDK_DIR}/jre/lib/${libarch}/client
	dodir ${JDK_DIR}/jre/lib/${libarch}/server
	dosym ../../../../../../${libdir}/${PN}/libjvm.so ${JDK_DIR}/jre/lib/${libarch}/client/libjvm.so
	dosym ../../../../../../${libdir}/${PN}/libjvm.so ${JDK_DIR}/jre/lib/${libarch}/server/libjvm.so
	dosym ../../../../../${libdir}/classpath/libjawt.so ${JDK_DIR}/jre/lib/${libarch}/libjawt.so
	set_java_env

	# Can't use java-vm_set-pax-markings as doesn't work with symbolic links
	# Ensure a PaX header is created.
	local pax_markings="C"
	# Usually dislabeling MPROTECT is sufficent.
	local pax_markings+="m"
	# On x86 for heap sizes over 700MB disable SEGMEXEC and PAGEEXEC as well.
	use x86 && pax_markings+="sp"

	pax-mark ${pax_markings} "${ED}"/usr/libexec/${PN}/cacao
}
