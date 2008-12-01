# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"

inherit autotools pax-utils java-pkg-2 java-vm-2

DESCRIPTION="A harness to build the OpenJDK using Free Software build tools and dependencies"
OPENJDK_TARBALL="openjdk-6-src-b09-11_apr_2008.tar.gz"
SRC_URI="http://icedtea.classpath.org/download/source/${P}.tar.gz
	 http://download.java.net/openjdk/jdk6/promoted/b09/${OPENJDK_TARBALL}"
HOMEPAGE="http://icedtea.classpath.org"

IUSE="debug doc examples nsplugin zero"

LICENSE="GPL-2-with-linking-exception"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"

RDEPEND=">=net-print/cups-1.2.12
	 >=x11-libs/libX11-1.1.3
	 >=media-libs/freetype-2.3.5
	 >=media-libs/alsa-lib-1.0
	 >=x11-libs/gtk+-2.8
	 >=x11-libs/libXinerama-1.0.2
	 >=x11-libs/libXp-1.0.0
	 >=x11-libs/libXi-1.1.3
	 >=x11-libs/libXau-1.0.3
	 >=x11-libs/libXdmcp-1.0.2
	 >=media-libs/jpeg-6b
	 >=media-libs/libpng-1.2
	 >=media-libs/giflib-4.1.6
	 >=sys-libs/zlib-1.2.3
	 x11-proto/inputproto
	 x11-proto/xineramaproto
	 nsplugin? ( || (
		www-client/mozilla-firefox
		net-libs/xulrunner
		www-client/seamonkey
	 ) )"

# Additional dependencies for building:
#   unzip: extract OpenJDK tarball
#   xalan/xerces: automatic code generation
#   ant, ecj, jdk: required to build Java code
DEPEND="${RDEPEND}
	|| ( >=virtual/gnu-classpath-jdk-1.5
		 >=dev-java/icedtea-jdk-1.6 )
	>=app-arch/unzip-5.52
	>=dev-java/xalan-2.7.0
	>=dev-java/xerces-2.9.1
	>=dev-java/ant-core-1.7.0-r3
	|| (	>=dev-java/eclipse-ecj-3.2.1:3.2
		dev-java/eclipse-ecj:3.3 )"

pkg_setup() {
	if use_zero && ! built_with_use sys-devel/gcc libffi; then
		eerror "Using the zero assembler port requires libffi. Please rebuild sys-devel/gcc"
		eerror "with USE=\"libffi\" or turn off the zero USE flag on ${PN}."
		die "Rebuild sys-devel/gcc with libffi support"
	fi

	java-vm-2_pkg_setup
	java-pkg-2_pkg_setup
}

src_unpack() {
	unpack ${P}.tar.gz
	cd "${S}" || die

	# Fix use of --enable-plugin (http://icedtea.classpath.org/hg/icedtea6/rev/1c580400c8d9)
	epatch "${FILESDIR}/enable_fix-${PV}.patch"
	# Fix use of jar cfm0@ (http://icedtea.classpath.org/hg/icedtea6/rev/cebc828cf765)
	epatch "${FILESDIR}/gjar-${PV}.patch"
	# Remove motif dependency
	epatch "${FILESDIR}/motif.patch"
	epatch "${FILESDIR}/motif-config.patch"
	epatch "${FILESDIR}/motif-make.patch"
	# Backport security and versioning fixes
	epatch "${FILESDIR}/security_and_versioning.patch"

	eautoreconf || die "failed to regenerate autoconf infrastructure"
}

src_compile() {
	local config procs
	local vm=$(java-pkg_get-current-vm)
	local vmhome="/usr/lib/jvm/${vm}"

	if [[ "${vm}" == "icedtea6" || "${vm}" == "icedtea" ]] ; then
		# If we are upgrading icedtea, then we don't need to bootstrap.
		config="${config} --with-icedtea"
		config="${config} --with-icedtea-home=$(java-config -O)"
	elif [[ "${vm}" == "gcj-jdk" || "${vm}" == "cacao" ]] ; then
		# For other 1.5 JDKs e.g. GCJ, CACAO, JamVM.
		config="${config} --with-ecj-jar=$(ls -1r /usr/share/eclipse-ecj-3.[23]/lib/ecj.jar|head -n 1)" \
		config="${config} --with-libgcj-jar=${vmhome}/jre/lib/rt.jar"
		config="${config} --with-gcj-home=${vmhome}"
	else
		eerror "IcedTea must be built with either a JDK based on GNU Classpath or an existing build of IcedTea."
		die "Install a GNU Classpath JDK (gcj-jdk, cacao)"
	fi

	# OpenJDK-specific parallelism support.
	procs=$(echo ${MAKEOPTS} | sed -r 's/.*-j\W*([0-9]+).*/\1/')
	if [[ -n ${procs} ]] ; then
		config="${config} --with-parallel-jobs=${procs}";
		einfo "Configuring using --with-parallel-jobs=${procs}"
	fi

	if use_zero ; then
		config="${config} --enable-zero"
	else
		config="${config} --disable-zero"
	fi

	unset JAVA_HOME JDK_HOME CLASSPATH JAVAC JAVACFLAGS

	econf ${config} \
		--with-openjdk-src-zip="${DISTDIR}/${OPENJDK_TARBALL}" \
		--with-version-suffix="gentoo" \
		--with-java="${vmhome}/bin/java" \
		--with-javac="${vmhome}/bin/javac" \
		--with-javah="${vmhome}/bin/javah" \
		$(use_enable !debug optimizations) \
		$(use_enable doc docs) \
		$(use_enable nsplugin gcjwebplugin) \
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
		dohtml -r ../docs/* || die "Failed to install documentation"
	fi

	# doins can't handle symlinks.
	cp -vRP bin include jre lib man "${ddest}" || die "failed to copy"

	# Set PaX markings on all JDK/JRE executables to allow code-generation on
	# the heap by the JIT compiler.
	pax-mark m $(list-paxables "${ddest}"{,/jre}/bin/*)

	dodoc ASSEMBLY_EXCEPTION THIRD_PARTY_README || die
	dohtml README.html || die

	if use examples; then
		dodir "${dest}/share";
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
	use zero || ( ! use amd64 && ! use x86 && ! use sparc )
}

pkg_postinst() {
	# Set as default VM if none exists
	java-vm-2_pkg_postinst
}
