# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"

inherit autotools pax-utils java-pkg-2 java-vm-2

DESCRIPTION="A harness to build the OpenJDK using Free Software build tools and dependencies"
OPENJDK_BUILD="12"
OPENJDK_DATE="28_aug_2008"
OPENJDK_TARBALL="openjdk-6-src-b${OPENJDK_BUILD}-${OPENJDK_DATE}.tar.gz"
CACAO_TARBALL="cacao-0.99.3.tar.gz"
SRC_URI="http://icedtea.classpath.org/download/source/${P}.tar.gz
		 http://download.java.net/openjdk/jdk6/promoted/b${OPENJDK_BUILD}/${OPENJDK_TARBALL}
		 cacao? ( http://www.complang.tuwien.ac.at/cacaojvm/download/cacao-0.99.3/${CACAO_TARBALL} )"
HOMEPAGE="http://icedtea.classpath.org"

IUSE="cacao debug doc examples javascript nsplugin pulseaudio shark zero"
# JTReg doesn't pass at present
RESTRICT="test"

LICENSE="GPL-2-with-linking-exception"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~sparc ~x86"

RDEPEND=">=net-print/cups-1.2.12
	 >=x11-libs/libX11-1.1.3
	 >=media-libs/freetype-2.3.5
	 >=media-libs/alsa-lib-1.0
	 >=x11-libs/gtk+-2.8
	 >=x11-libs/libXinerama-1.0.2
	 >=x11-libs/libXp-1.0.0
	 >=media-libs/jpeg-6b
	 >=media-libs/libpng-1.2
	 >=media-libs/giflib-4.1.6
	 >=sys-libs/zlib-1.2.3
	 x11-proto/inputproto
	 x11-proto/xineramaproto
	 nsplugin? ( || (
		>=www-client/mozilla-firefox-3.0.0
		>=net-libs/xulrunner-1.9
	 ) )
	 pulseaudio?  ( >=media-sound/pulseaudio-0.9.11 )"

# Additional dependencies for building:
#   unzip: extract OpenJDK tarball
#   xalan/xerces: automatic code generation
#   ant, ecj, jdk: required to build Java code

# NOTE: we depend directly on dev-java/icedtea6 instead of virtual/icedtea-jdk
#       because if the virtual is not installed, portage will try to satisfy
#       gnu-classpath-jdk instead
#       it would be possible if the order was reversed but then there are
#       circular deps instead...
# NOTE: we need to depend also on virtual/jdk unless the eclass won't switch VM
DEPEND="${RDEPEND}
	|| ( >=virtual/gnu-classpath-jdk-1.5
		 dev-java/icedtea6 )
	>=virtual/jdk-1.5
	>=app-arch/unzip-5.52
	>=dev-java/xalan-2.7.0
	>=dev-java/xerces-2.9.1
	>=dev-java/ant-core-1.7.0-r3
	javascript? ( dev-java/rhino:1.6 )"

pkg_setup() {
	if use zero && ! built_with_use sys-devel/gcc libffi; then
		eerror "Using the zero assembler port requires libffi. Please rebuild sys-devel/gcc"
		eerror "with USE=\"libffi\" or turn off the zero USE flag on ${PN}."
		die "Rebuild sys-devel/gcc with libffi support"
	fi

	if use shark ; then
	  if ( ! use x86 && ! use sparc && ! use ppc ) ; then
		eerror "The Shark JIT has known issues on 64-bit platforms.  Please rebuild"
		errror "without the shark USE flag turned on."
		die "Rebuild without the shark USE flag on."
	  fi
	  if ( ! use zero ) ; then
		eerror "The use of the Shark JIT is only applicable when used with the zero assembler port.";
		die "Rebuild without the shark USE flag on or with the zero USE flag turned on."
	  fi
	fi

	# quite a hack since java-config does not provide a way for a package
	# to limit supported VM's for building and their preferred order
	if has_version dev-java/icedtea6; then
		JAVA_PKG_FORCE_VM="icedtea6"
	elif has_version dev-java/icedtea; then
		JAVA_PKG_FORCE_VM="icedtea"
	elif has_version dev-java/gcj-jdk; then
		JAVA_PKG_FORCE_VM="gcj-jdk"
	elif has_version dev-java/cacao; then
		JAVA_PKG_FORCE_VM="cacao"
	elif has_version dev-java/jamvm; then
		JAVA_PKG_FORCE_VM="jamvm"
	else
		die "Unable to find supported VM for building"
	fi

	einfo "Forced vm ${JAVA_PKG_FORCE_VM}"
	java-vm-2_pkg_setup
	java-pkg-2_pkg_setup
}

src_unpack() {
	unpack ${P}.tar.gz
	cd "${S}" || die

	# Don't hide the HotSpot build number
	# (http://icedtea.classpath.org/hg/icedtea6/rev/6816e84bfc28)
	epatch "${FILESDIR}/hotspot-${PV}.patch"

	eautoreconf || die "failed to regenerate autoconf infrastructure"
}

src_compile() {
	local config procs rhino_jar
	local vm=$(java-pkg_get-current-vm)
	local vmhome="/usr/lib/jvm/${vm}"

	if [[ "${vm}" == "icedtea6" || "${vm}" == "icedtea" ]] ; then
		# If we are upgrading icedtea, then we don't need to bootstrap.
		config="${config} --with-icedtea"
		config="${config} --with-icedtea-home=$(java-config -O)"
	elif [[ "${vm}" == "gcj-jdk" || "${vm}" == "cacao" || "${vm}" == "jamvm" ]] ; then
		# For other 1.5 JDKs e.g. GCJ, CACAO, JamVM.
		config="${config} --with-ecj-jar=$(java-pkg_getjar eclipse-ecj:3.3 ecj.jar)" \
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

	if use_cacao ; then
		config="${config} --enable-cacao"
	else
		config="${config} --disable-cacao"
	fi

	if use javascript ; then
		rhino_jar=$(java-pkg_getjar --build-only rhino:1.6 js.jar);
	fi

	unset JAVA_HOME JDK_HOME CLASSPATH JAVAC JAVACFLAGS

	econf ${config} \
		--with-openjdk-src-zip="${DISTDIR}/${OPENJDK_TARBALL}" \
		--with-cacao-src-zip="${DISTDIR}/${CACAO_TARBALL}" \
		--with-java="${vmhome}/bin/java" \
		--with-javac="${vmhome}/bin/javac" \
		--with-javah="${vmhome}/bin/javah" \
		--with-pkgversion="Gentoo" \
		$(use_enable !debug optimizations) \
		$(use_enable doc docs) \
		$(use_enable nsplugin liveconnect) \
		$(use_with javascript rhino ${rhino_jar}) \
		$(use_enable zero) \
		$(use_enable shark) \
		$(use_enable pulseaudio pulse-java) \
		|| die "configure failed"

	emake -j 1  || die "make failed"
}

src_install() {
	local dest="/usr/$(get_libdir)/${PN}"
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
