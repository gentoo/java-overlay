# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"

ECJ_SLOT="3.3"
OJDK_TARBALL="openjdk-6-src-b09-11_apr_2008.tar.gz"

inherit autotools pax-utils java-pkg-2 java-vm-2

DESCRIPTION="A harness to build the OpenJDK using Free Software build tools and dependencies"
SRC_URI="http://icedtea.classpath.org/download/source/icedtea6-1.2.tar.gz
	 http://download.java.net/openjdk/jdk6/promoted/b09/${OJDK_TARBALL}"
HOMEPAGE="http://icedtea.classpath.org"

IUSE="doc examples nsplugin zero"

LICENSE="GPL-2-with-linking-exception"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"

RDEPEND=">=net-print/cups-1.2.12
	 >=x11-libs/libX11-1.1.3
	 >=x11-libs/openmotif-2.3.0
	 >=media-libs/freetype-2.3.5
	 >=media-libs/alsa-lib-1.0
	 >=x11-libs/gtk+-2.8
	 >=x11-libs/libXinerama-1.0.2
	 >=media-libs/jpeg-6b
	 >=media-libs/libpng-1.2
	 >=media-libs/giflib-4.1.6
	 >=sys-libs/zlib-1.2.3
	 nsplugin? ( || (
		www-client/mozilla-firefox
		net-libs/xulrunner
		www-client/seamonkey
	 ) )"

DEPEND="${RDEPEND}
	>=virtual/jdk-1.5
	>=app-arch/unzip-5.52
	>=dev-java/xalan-2.7.0
	>=dev-java/xerces-2.9.1
	>=dev-java/ant-core-1.7.0-r3
	dev-java/eclipse-ecj:${ECJ_SLOT}"

src_unpack() {
	unpack ${P}.tar.gz
	cd "${S}" || die

	# Fix use of --enable-plugin (http://icedtea.classpath.org/hg/icedtea6/rev/1c580400c8d9)
	epatch "${FILESDIR}/enable_fix-${PV}.patch"
	# Fix use of jar cfm0@ (http://icedtea.classpath.org/hg/icedtea6/rev/cebc828cf765)
	epatch "${FILESDIR}/gjar-${PV}.patch"
	# Use Classpath's JAVAC and JAVA tests
	epatch "${FILESDIR}/javac_fix-${PV}.patch"
	# Use @JAVAC_MEM_OPT@ in javac.in
	epatch "${FILESDIR}/javac.in.patch"

	eautoreconf -I m4 || die "failed to reautoconf"
}

pkg_setup() {
	if use_zero && ! built_with_use sys-devel/gcc libffi; then
		eerror "Using the zero assembler port requires libffi. Please rebuild sys-devel/gcc"
		eerror "with USE=\"libffi\" or turn off the zero USE flag on ${PN}."
		die "Rebuild sys-devel/gcc with libffi support"
	fi

	java-vm-2_pkg_setup
	java-pkg-2_pkg_setup
}

src_compile() {
	local config env procs

	if [[ "$(java-pkg_get-current-vm)" == "icedtea6" ]] ; then
		# If we already have icedtea6 then we can build it much faster
		# by not having to bootstrap. You can also give sun-jdk-1.6 here
		# but you don't get a clean build.
		config="${config} --with-icedtea"
		config="${config} --with-icedtea-home=$(java-config -O)"
	else
		# Any 1.6 JDK can be given in place of GCJ here.
		config="${config} --with-ecj-jar=/usr/share/eclipse-ecj-${ECJ_SLOT}/lib/ecj.jar"
		config="${config} --with-libgcj-jar=$(java-config -O)/jre/lib/rt.jar"
		config="${config} --with-gcj-home=$(java-config -O)"

		# We need to force ecj-3.3 but only during configure. JAVAC must
		# not be set during make because it causes problems.
		env="JAVAC='/usr/bin/ecj-${ECJ_SLOT}'"
	fi

	# OpenJDK-specific parallelism support.
	procs=$(echo ${MAKEOPTS} | sed -r 's/.*-j\W*([0-9]+).*/\1/')
	if [[ -n ${procs} ]] ; then
		config="${config} --with-parallel-jobs=${procs}";
		einfo "Configuring using --with-parallel-jobs=${procs}"
	fi

	if use_zero ; then
		zero="${config} --enable-zero"
	else
		zero="${config} --disable-zero"
	fi

	unset JAVA_HOME JDK_HOME CLASSPATH JAVAC JAVACFLAGS

	eval ${env} econf ${config} \
		--with-openjdk-src-zip="${DISTDIR}/${OJDK_TARBALL}" \
		$(use_enable nsplugin gcjwebplugin) \
		$(use_enable doc docs) \
		|| die "configure failed"

	emake -j 1  || die "make failed"
}

src_install() {
	local dest="/usr/$(get_libdir)/${P}"
	local ddest="${D}/${dest}"
	dodir "${dest}" || die

	local arch=${ARCH}
	use x86 && arch=i586

	cd "${S}/openjdk/control/build/linux-${arch}/j2sdk-image" || die

	if use doc ; then
		dohtml -r ../docs/* || die
	fi

	# doins can't handle symlinks.
	cp -vRP bin include jre lib man "${ddest}" || die "failed to copy"

	# Set PaX markings on all JDK/JRE executables to allow code-generation on
	# the heap by the JIT compiler.
	pax-mark m $(list-paxables "${ddest}"{,/jre}/bin/*)

	dodoc ASSEMBLY_EXCEPTION THIRD_PARTY_README || die
	dohtml README.html || die

	if use examples; then
		cp -vRP demo sample "${ddest}/share/" || die
	fi

	cp src.zip "${ddest}" || die

	# Fix the permissions.
	find "${ddest}" -perm +111 -exec chmod 755 {} \; -o -exec chmod 644 {} \; || die

	if use nsplugin; then
		use x86 && arch=i386
		install_mozilla_plugin "${dest}/jre/lib/${arch}/gcjwebplugin.so"
	fi

	set_java_env
}

use_zero() {
	use zero || ( ! use amd64 && ! use x86 )
}
