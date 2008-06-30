# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit autotools pax-utils java-vm-2 java-pkg-2

DESCRIPTION="A harness to build the OpenJDK using Free Software build tools and dependencies."
SRC_URI="http://icedtea.classpath.org/download/source/icedtea6-1.1.tar.gz
	 http://download.java.net/openjdk/jdk6/promoted/b08/openjdk-6-src-b08-26_mar_2008.tar.gz"
HOMEPAGE="http://icedtea.classpath.org/wiki/Main_Page"

IUSE="nsplugin debug doc examples zero"

LICENSE="GPL-2-with-linking-exception"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"

RDEPEND=">=net-print/cups-1.2.12
	 >=x11-libs/libX11-1.1.3
	 >=x11-libs/openmotif-2.3.0
	 >=media-libs/freetype-2.3.5
	 >=media-libs/alsa-lib-1.0
	 >=x11-libs/gtk+-2.8
	 nsplugin? ( || (
		www-client/mozilla-firefox
		net-libs/xulrunner
		www-client/seamonkey
	 ) )
	 >=x11-libs/libXinerama-1.0.2
	 >=media-libs/jpeg-6b
	 >=media-libs/libpng-1.2
	 >=media-libs/giflib-4.1.6
	 >=sys-libs/zlib-1.2.3"

# Additional dependencies for building:
#   unzip: extract OpenJDK tarball
#   xalan/xerces: automatic code generation
#   ant, ecj, jdk: required to build Java code
DEPEND=">=virtual/jdk-1.5
	>=dev-java/eclipse-ecj-3.2.1
	>=app-arch/unzip-5.52
	>=dev-java/xalan-2.7.0
	>=dev-java/xerces-2.9.1
	>=dev-java/ant-core-1.7.0
	${RDEPEND}"

pkg_setup() {
	if use zero && ! built_with_use sys-devel/gcc libffi; then
		eerror "Using the zero assembler port requires libffi.";
		eerror "Please rebuild sys-devel/gcc with USE=\"libffi\" or"
		eerror "turn off the zero use flag on ${PN}"
		die "Rebuild sys-devel/gcc with libffi support"
	fi
	if [ ${ARCH} != x86 -a ${ARCH} != amd64 ] && ! built_with_use sys-devel/gcc libffi; then
		eerror "Building on a non-x86 or non-x86_64";
		eerror "architecture requires using the zero";
		eerror "assembler port, which requires libffi.";
		eerror "Please rebuild sys-devel/gcc with USE=\"libffi\""
		die "Rebuild sys-devel/gcc with libffi support"
	fi
	java-vm-2_pkg_setup
	java-pkg-2_pkg_setup
}

src_unpack() {
	unpack ${P}.tar.gz
	cd "${S}"
	# Add --enable/disable-docs option (http://icedtea.classpath.org/hg/icedtea6/rev/ff3d152968b5)
	epatch "${FILESDIR}/docs.patch"
	# Add --with-parallel-jobs option (http://icedtea.classpath.org/hg/icedtea6/rev/9cd18444aa30)
	epatch "${FILESDIR}/parallel_jobs.patch"
	# Add true disable-zero support (http://icedtea.classpath.org/hg/icedtea6/rev/edf310873bf7)
	epatch "${FILESDIR}/zero.patch"
	# Fix use of --enable-plugin (http://icedtea.classpath.org/hg/icedtea6/rev/1c580400c8d9)
	epatch "${FILESDIR}/enable_fix-${PV}.patch"
	# Fix use of jar cfm0@ (http://icedtea.classpath.org/hg/icedtea6/rev/cebc828cf765)
	epatch "${FILESDIR}/gjar-${PV}.patch"
	# Use Classpath's JAVAC and JAVA tests
	epatch "${FILESDIR}/javac_fix-${PV}.patch"
	# Use @JAVAC_MEM_OPT@ in javac.in
	epatch "${FILESDIR}/javac.in.patch"
	eautoreconf || die "failed to reautoconf"
}

src_compile() {
	unset JAVA_HOME JDK_HOME CLASSPATH JAVAC JAVACFLAGS
	local parallel

	# OpenJDK-specific parallelism support
	PROCS=$(echo ${MAKEOPTS}|sed -r 's/.*-j\W*([0-9]+).*/\1/')
	if [ x${PROCS} != x ]; then
		parallel="--with-parallel-jobs=${PROCS}";
		einfo "Configuring using ${parallel}"
	else
		parallel="";
	fi

	econf \
		--with-gcj-home=$(java-config -O) \
		--with-libgcj-jar=$(java-config -O)/jre/lib/rt.jar \
		--with-openjdk-src-zip="${DISTDIR}"/openjdk-6-src-b08-26_mar_2008.tar.gz \
		--with-ecj-jar=$(ls -r /usr/share/eclipse-ecj-3.*/lib/ecj.jar|head -n 1) \
		${parallel} \
		$(use_enable nsplugin gcjwebplugin) \
		$(use_enable debug fast-build) \
		$(use_enable doc docs) \
		$(use_enable zero) \
		|| die "configure failed"

	emake -j 1 || die "make failed"
}

src_install() {
	local dest=/usr/lib/${P}
	local ddest="${D}/${dest}"
	dodir ${dest}

	local arch=${ARCH}
	[[ ${ARCH} = x86 ]] && arch=i586

	cd "${S}"/openjdk/control/build/linux-${arch}/

	if use doc ; then
		dohtml -r docs/* || die;
	fi

	cd j2sdk-image

	# For some people the files got 600 so doing it manually
	# should be investigated why this happened
	if is-java-strict; then
		if [[ $(find . -perm 600) ]]; then
			eerror "OpenJDK built with permission mask 600"
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
		eerror "Files with permission set to 600 found in the image"
		eerror "please report this to java@gentoo.org"
	fi

	# Set PaX markings on all JDK/JRE executables to allow code-generation on
	# the heap by the JIT compiler.
	pax-mark m $(list-paxables ${ddest}{,/jre}/bin/*)

	dodoc ASSEMBLY_EXCEPTION THIRD_PARTY_README || die
	dohtml README.html || die

	if use examples; then
		cp -pPR demo sample "${ddest}/share/"
	fi

	cp src.zip "${ddest}" || die

	if use nsplugin; then
		install_mozilla_plugin ${dest}/jre/lib/${arch}/gcjwebplugin.so
	fi

	set_java_env
}

pkg_postinst() {
	# Set as default VM if none exists
	java-vm-2_pkg_postinst
}
