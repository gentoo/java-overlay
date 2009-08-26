# Copyright 1999-2009 Gentoo Foundation
# Build written by Andrew John Hughes
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools pax-utils java-pkg-2 java-vm-2 flag-o-matic

DESCRIPTION="A harness to build OpenJDK using Free Software build tools and dependencies"
OPENJDK_TARBALL="e7eeeda332ec.tar.gz"
LANGTOOLS_TARBALL="634f519d6f9a.tar.gz"
JAXP_TARBALL="b3d2bf4c255d.tar.gz"
JAXWS_TARBALL="c37936a72332.tar.gz"
CORBA_TARBALL="1741ea5cb854.tar.gz"
JDK_TARBALL="51fcc41d8b24.tar.gz"
HOTSPOT_TARBALL="945fcffdbcab.tar.gz"
CACAO_TARBALL="cacao-0.99.4.tar.gz"
SRC_URI="http://icedtea.classpath.org/download/source/${P}.tar.gz
		 http://hg.openjdk.java.net/icedtea/jdk7/archive/${OPENJDK_TARBALL}
		 http://hg.openjdk.java.net/icedtea/jdk7/corba/archive/${CORBA_TARBALL}
		 http://hg.openjdk.java.net/icedtea/jdk7/jaxp/archive/${JAXP_TARBALL}
		 http://hg.openjdk.java.net/icedtea/jdk7/jaxws/archive/${JAXWS_TARBALL}
		 http://hg.openjdk.java.net/icedtea/jdk7/jdk/archive/${JDK_TARBALL}
		 http://hg.openjdk.java.net/icedtea/jdk7/hotspot/archive/${HOTSPOT_TARBALL}
		 http://hg.openjdk.java.net/icedtea/jdk7/langtools/archive/${LANGTOOLS_TARBALL}
		 cacao? ( http://www.complang.tuwien.ac.at/cacaojvm/download/cacao-0.99.4/${CACAO_TARBALL} )"
HOMEPAGE="http://icedtea.classpath.org"

# Missing options:
# shark - still experimental, requires llvm which is not yet packaged
# visualvm - requries netbeans which would cause major bootstrap issues
IUSE="cacao debug doc examples javascript nsplugin pulseaudio systemtap xrender zero"

# JTReg doesn't pass at present
RESTRICT="test"

LICENSE="GPL-2-with-linking-exception"
SLOT="0"
#KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"

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
	 >=x11-libs/libXtst-1.0.3
	 >=media-libs/jpeg-6b
	 >=media-libs/libpng-1.2
	 >=media-libs/giflib-4.1.6
	 >=sys-libs/zlib-1.2.3
	 x11-proto/inputproto
	 x11-proto/xineramaproto
	 nsplugin? ( >=net-libs/xulrunner-1.9 )
	 pulseaudio?  ( >=media-sound/pulseaudio-0.9.11 )
	 javascript? ( dev-java/rhino:1.6 )
	 zero? ( sys-devel/gcc[libffi] )
	 xrender? ( >=x11-libs/libXrender-0.9.4 )
	 systemtap? ( >=dev-util/systemtap-0.9.5 ) "

# Additional dependencies for building:
#   unzip: extract OpenJDK tarball
#   xalan/xerces: automatic code generation
#   ant, ecj, jdk: required to build Java code
# Only ant-core-1.7.0-r3 in java-overlay contains
# a version of Ant that properly respects environment
# variables.  1.7.1-r2 and on will work if the build
# sets some environment variables.
DEPEND="${RDEPEND}
	|| ( >=virtual/gnu-classpath-jdk-1.5
		 dev-java/icedtea6
		 dev-java/icedtea6-bin
	)
	>=virtual/jdk-1.5
	>=app-arch/unzip-5.52
	>=dev-java/xalan-2.7.0:0
	>=dev-java/xerces-2.9.1:2
	|| (
	  =dev-java/ant-core-1.7.0-r3
	  >=dev-java/ant-core-1.7.1-r2
	)"

pkg_setup() {
# Shark support disabled for now - still experimental and needs sys-devel/llvm
#	if use shark ; then
#	  if ( ! use x86 && ! use sparc && ! use ppc ) ; then
#		eerror "The Shark JIT has known issues on 64-bit platforms.  Please rebuild"
#		errror "without the shark USE flag turned on."
#		die "Rebuild without the shark USE flag on."
#	  fi
#	  if ( ! use zero ) ; then
#		eerror "The use of the Shark JIT is only applicable when used with the zero assembler port.";
#		die "Rebuild without the shark USE flag on or with the zero USE flag turned on."
#	  fi
#	fi

	# quite a hack since java-config does not provide a way for a package
	# to limit supported VM's for building and their preferred order
	if has_version dev-java/icedtea6; then
		JAVA_PKG_FORCE_VM="icedtea6"
	elif has_version dev-java/icedtea6-bin; then
		JAVA_PKG_FORCE_VM="icedtea6-bin"
	elif has_version dev-java/icedtea; then
		JAVA_PKG_FORCE_VM="icedtea"
	elif has_version dev-java/gcj-jdk; then
		JAVA_PKG_FORCE_VM="gcj-jdk"
	elif has_version dev-java/cacao; then
		JAVA_PKG_FORCE_VM="cacao"
	else
		die "Unable to find a supported VM for building"
	fi

	einfo "Forced vm ${JAVA_PKG_FORCE_VM}"
	java-vm-2_pkg_setup
	java-pkg-2_pkg_setup
}

src_unpack() {
	unpack ${P}.tar.gz
}

unset_vars() {
	unset JAVA_HOME JDK_HOME CLASSPATH JAVAC JAVACFLAGS
}

src_prepare() {
	# Fix build issue with optimisation and GCC >= 4.3
	epatch "${FILESDIR}/gccopt-${PV}.patch"
	eautoreconf || die "failed to regenerate autoconf infrastructure"
}

src_configure() {
	local config procs rhino_jar
	local vm=$(java-pkg_get-current-vm)

	if [[ "${vm}" == "icedtea6" || "${vm}" == "icedtea" ]] || [[ "${vm}" == "icedtea6-bin" ]] ; then
		# We can't currently bootstrap with a Sun-based JVM :(
		config="${config} --disable-bootstrap"
	elif [[ "${vm}" != "gcj-jdk" && "${vm}" != "cacao" ]] ; then
		eerror "IcedTea must be built with either a JDK based on GNU Classpath or an existing build of IcedTea."
		die "Install a GNU Classpath JDK (gcj-jdk, cacao)"
	fi

	# OpenJDK-specific parallelism support.
	procs=$(echo ${MAKEOPTS} | sed -r 's/.*-j\W*([0-9]+).*/\1/')
	if [[ -n ${procs} ]] ; then
		config="${config} --with-parallel-jobs=${procs}";
		einfo "Configuring using --with-parallel-jobs=${procs}"
	fi

	if use_cacao ; then
		config="${config} --enable-cacao"
	else
		config="${config} --disable-cacao"
	fi

	if use javascript ; then
		rhino_jar=$(java-pkg_getjar rhino:1.6 js.jar);
	fi

	unset_vars

	econf ${config} \
		--with-openjdk-src-zip="${DISTDIR}/${OPENJDK_TARBALL}" \
		--with-corba-src-zip="${DISTDIR}/${CORBA_TARBALL}" \
		--with-jaxp-src-zip="${DISTDIR}/${JAXP_TARBALL}" \
		--with-jaxws-src-zip="${DISTDIR}/${JAXWS_TARBALL}" \
		--with-jdk-src-zip="${DISTDIR}/${JDK_TARBALL}" \
		--with-hotspot-src-zip="${DISTDIR}/${HOTSPOT_TARBALL}" \
		--with-langtools-src-zip="${DISTDIR}/${LANGTOOLS_TARBALL}" \
		--with-cacao-src-zip="${DISTDIR}/${CACAO_TARBALL}" \
		--with-jdk-home="$(java-config -O)" \
		--with-pkgversion="Gentoo" \
		--with-abs-install-dir=/usr/$(get_libdir)/${PN} \
		$(use_enable !debug optimizations) \
		$(use_enable doc docs) \
		$(use_enable nsplugin plugin) \
		$(use_with javascript rhino ${rhino_jar}) \
		$(use_enable zero) \
		$(use_enable pulseaudio pulse-java) \
		$(use_enable xrender) \
		$(use_enable systemtap) \
		|| die "configure failed"
}

src_compile() {
	# Newer versions of Gentoo's ant add
	# an environment variable so it works properly...
	export ANT_RESPECT_JAVA_HOME=TRUE
	# Also make sure we don't bring in additional tasks
	export ANT_TASKS=none

	# Paludis does not respect unset from src_configure
	unset_vars
	emake -j 1  || die "make failed"
}

src_install() {
	local dest="/usr/$(get_libdir)/${PN}"
	local ddest="${D}/${dest}"
	dodir "${dest}" || die

	local arch=${ARCH}
	use x86 && arch=i586

	cd "${S}/openjdk/build/linux-${arch}/j2sdk-image" || die

	if use doc ; then
		dohtml -r ../docs/* || die "Failed to install documentation"
	fi

	# doins can't handle symlinks.
	cp -vRP bin include jre lib man "${ddest}" || die "failed to copy"

	# Set PaX markings on all JDK/JRE executables to allow code-generation on
	# the heap by the JIT compiler.
	pax-mark m $(list-paxables "${ddest}"{,/jre}/bin/*)

	dodoc ASSEMBLY_EXCEPTION THIRD_PARTY_README || die

	if use examples; then
		dodir "${dest}/share";
		cp -vRP demo sample "${ddest}/share/" || die
	fi

	cp src.zip "${ddest}" || die

	# Fix the permissions.
	find "${ddest}" \! -type l \( -perm /111 -exec chmod 755 {} \; -o -exec chmod 644 {} \; \) || die

	if use nsplugin; then
		use x86 && arch=i386;
		install_mozilla_plugin "${dest}/jre/lib/${arch}/IcedTeaPlugin.so";
	fi

	set_java_env
}

use_cacao() {
	use cacao || ( ! use amd64 && ! use x86 && ! use sparc )
}

pkg_postinst() {
	# Set as default VM if none exists
	java-vm-2_pkg_postinst
}
