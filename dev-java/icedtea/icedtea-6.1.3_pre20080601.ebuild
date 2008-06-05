# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=1

inherit autotools pax-utils java-vm-2 java-pkg-2

icedtea="37c853f39fe3"
openjdk="openjdk-6-src-b10_30_may_2008.tar.gz"

DESCRIPTION="Free Software build environment for OpenJDK using GNU Classpath plugs"
HOMEPAGE="http://icedtea.classpath.org/wiki/Main_Page"
SRC_URI="http://icedtea.classpath.org/hg/icedtea6/archive/${icedtea}.tar.bz2
	 http://download.java.net/openjdk/jdk6/promoted/b10/${openjdk}"

LICENSE="GPL-2-with-linking-exception"
SLOT="6"
KEYWORDS=""
IUSE="debug doc examples nsplugin zero"

RDEPEND=">=net-print/cups-1.2.12
	>=x11-libs/libX11-1.1.3
	>=x11-libs/openmotif-2.3.0
	>=media-libs/freetype-2.3.5
	>=media-libs/alsa-lib-1.0
	>=x11-libs/gtk+-2.8
	nsplugin? ( net-libs/xulrunner )
	>=x11-libs/libXinerama-1.0.2
	>=media-libs/jpeg-6b
	>=media-libs/libpng-1.2
	>=media-libs/giflib-4.1.6"
DEPEND=">=app-arch/zip-2.32
	>=app-arch/unzip-5.52
	>=virtual/jdk-1.5
	dev-java/eclipse-ecj:3.3
	>=dev-java/xalan-2.7.0
	>=dev-java/xerces-2.9.1
	>=dev-java/ant-core-1.7.0
	${RDEPEND}"
S="${WORKDIR}/${PN}${SLOT}-${icedtea}"

pkg_setup() {
	if [ ${ARCH} != x86 -a ${ARCH} != amd64 -a ${ARCH} != sparc ]; then
		local zero_err=
		ewarn "Building on a non-x86/sparc-based architecture requires"
		ewarn "the zero assembler port, which requires libffi from gcc."
		if ! use zero; then
			eerror "USE [zero] not set!"
			zero_err=1
		fi
		if ! built_with_use sys-devel/gcc libffi; then
			eerror "gcc built without libffi support!"
			eerror "USE=\"libffi\" emerge gcc"
			zero_err=1
		fi
		[ $zero_err ] && die "bad luck"
	fi

	java-vm-2_pkg_setup
	java-pkg-2_pkg_setup
}

src_unpack() {
	unpack ${icedtea}.tar.bz2
	cd "${S}"
	epatch "${FILESDIR}/bootstrap_fix-heapsize.diff"
	eautoreconf
}

src_compile() {
	unset JAVA_HOME JDK_HOME CLASSPATH JAVAC JAVACFLAGS

	# alternative: ${MAKEOPTS/-j}
	# -- no need for echo|sed magic, even '-j X' does fine with bash-3
	econf --with-openjdk-src-zip=${DISTDIR}/${openjdk} \
		--with-parallel-jobs=$(grep -s -c ^processor /proc/cpuinfo) \
		--with-gcj-home=$(java-config --jdk-home) \
		--with-libgcj-jar=$(java-config --jdk-home)/jre/lib/rt.jar \
		--with-ecj-jar=$(java-pkg_getjars eclipse-ecj-3.3) --with-ecj=ecj-3.3 \
		$(use_enable !debug optimizations) \
		$(use_enable doc docs) \
		$(use_enable nsplugin gcjwebplugin) \
		$(use_enable zero) \
		|| die "configure failed"
	emake -j1 || die "make failed"
}

src_install() {
	local dest="/usr/lib/${P}"
	local ddest="${D}/${dest}"
	dodir ${dest}

	local arch=${ARCH}
	[[ ${ARCH} = x86 ]] && arch=i586
	cd ${S}/openjdk/control/build/linux-${arch}/

	if use doc; then
		dohtml -r docs/* || die
	fi

	cd j2sdk-image
	# For some people the files got 600 so doing it manually
	# should be investigated why this happened
	if is-java-strict; then
		if [[ $(find . -perm 600) ]]; then
			eerror "OpenJDK built with bad permission(600)"
			eerror "report this on #gentoo-java on freenode"
		fi
	fi

	# doins can't handle symlinks
	cp -vRP bin include jre lib man "${ddest}" || die "failed to copy"
	find "${ddest}" -type f -exec chmod 644 {} +
	find "${ddest}" -type d -exec chmod 755 {} +
	chmod 755 ${ddest}/bin/* \
		${ddest}/jre/bin/* \
		${ddest}/jre/lib/*/*.{so,cfg} \
		${ddest}/jre/lib/*/*/*.so \
		${ddest}/jre/lib/jexec \
		${ddest}/lib/jexec || die

	if [[ $(find "${ddest}" -perm 600) ]]; then
		eerror "Files with bad permission(600) found in the image"
		eerror "report this on #gentoo-java on freenode"
	fi

	# Set PaX markings on all JDK/JRE executables to allow code-generation on
	# the heap by the JIT compiler.
	pax-mark m $(list-paxables ${ddest}{,/jre}/bin/*)

	dodoc LICENSE ASSEMBLY_EXCEPTION THIRD_PARTY_README || die
	dohtml README.html || die
	use examples && cp -pPR demo sample "${ddest}/share/"
	cp src.zip "${ddest}" || die

	use nsplugin && install_mozilla_plugin ${dest}/jre/lib/${arch}/gcjwebplugin.so

	set_java_env
}

pkg_postinst() {
	# Set as default VM if none exists
	java-vm-2_pkg_postinst
}
