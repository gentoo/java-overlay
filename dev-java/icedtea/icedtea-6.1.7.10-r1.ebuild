# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# Build written by Andrew John Hughes (gnu_andrew@member.fsf.org)

# *********************************************************
# * IF YOU CHANGE THIS EBUILD, CHANGE ICEDTEA-7.* AS WELL *
# *********************************************************

EAPI="2"

inherit pax-utils java-pkg-2 java-vm-2 versionator

LICENSE="Apache-1.1 Apache-2.0 GPL-1 GPL-2 GPL-2-with-linking-exception LGPL-2 MPL-1.0 MPL-1.1 public-domain W3C"
SLOT="6"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"

DESCRIPTION="A harness to build the OpenJDK using Free Software build tools and dependencies"
ICEDTEA_VER="$(get_version_component_range 2-4)"
ICEDTEA_PKG=icedtea${SLOT}-${ICEDTEA_VER}
OPENJDK_BUILD="17"
OPENJDK_DATE="14_oct_2009"
OPENJDK_TARBALL="openjdk-6-src-b${OPENJDK_BUILD}-${OPENJDK_DATE}.tar.gz"
HOTSPOT_TARBALL="62926c7f67a3.tar.gz"
CACAO_TARBALL="cacao-0.99.4.tar.gz"
SRC_URI="http://icedtea.classpath.org/download/source/${ICEDTEA_PKG}.tar.gz
		 http://download.java.net/openjdk/jdk6/promoted/b${OPENJDK_BUILD}/${OPENJDK_TARBALL}
		 http://hg.openjdk.java.net/hsx/hsx16/master/archive/${HOTSPOT_TARBALL}
		 cacao? ( http://www.complang.tuwien.ac.at/cacaojvm/download/cacao-0.99.4/${CACAO_TARBALL} )"
HOMEPAGE="http://icedtea.classpath.org"
S=${WORKDIR}/${ICEDTEA_PKG}

# Missing options:
# shark - still experimental, requires llvm which is not yet packaged
# visualvm - requries netbeans which would cause major bootstrap issues
IUSE="cacao debug doc examples +hs16 javascript nio2 +nsplugin +nss pulseaudio systemtap +webstart +xrender zero"

# JTReg doesn't pass at present
RESTRICT="test"

RDEPEND=">=net-print/cups-1.2.12
	 >=x11-libs/libX11-1.1.3
	 >=media-libs/freetype-2.3.5
	 >=media-libs/alsa-lib-1.0
	 >=x11-libs/gtk+-2.8:2
	 >=x11-libs/libXinerama-1.0.2
	 >=x11-libs/libXp-1.0.0
	 >=x11-libs/libXi-1.1.3
	 >=x11-libs/libXau-1.0.3
	 >=x11-libs/libXdmcp-1.0.2
	 >=x11-libs/libXtst-1.0.3
	 virtual/jpeg
	 >=media-libs/libpng-1.2
	 >=media-libs/giflib-4.1.6
	 >=sys-libs/zlib-1.2.3
	 x11-proto/inputproto
	 x11-proto/xineramaproto
	 pulseaudio?  ( >=media-sound/pulseaudio-0.9.11 )
	 javascript? ( dev-java/rhino:1.6 )
	 zero? ( virtual/libffi )
	 xrender? ( >=x11-libs/libXrender-0.9.4 )
	 systemtap? ( >=dev-util/systemtap-1 )
	 !dev-java/icedtea6
	 nss? ( >=dev-libs/nss-3.12.5-r1 )"

# Additional dependencies for building:
#   zip: extract OpenJDK tarball, and needed by configure
#   xalan/xerces: automatic code generation (also needed for Ant 1.8.0 to work properly)
#   ant, ecj, jdk: required to build Java code
# Only ant-core-1.7.1-r2 and later contain a version of Ant that
# properly respects environment variables, if the build
# sets some environment variables.
#   ca-certificates, perl and openssl are used for the cacerts keystore generation
#   xext headers have two variants depending on version - bug #288855
DEPEND="${RDEPEND}
	|| (
		( >=dev-java/gcj-jdk-4.3 >=app-admin/eselect-ecj-0.5-r1 )
		( >=dev-java/cacao-0.99.2 >=app-admin/eselect-ecj-0.5-r1 )
		dev-java/icedtea6-bin
		dev-java/icedtea:${SLOT}
	)
	app-arch/zip
	>=dev-java/xalan-2.7.0:0
	>=dev-java/xerces-2.9.1:2
	>=dev-java/ant-core-1.7.1-r2
	app-misc/ca-certificates
	dev-lang/perl
	dev-libs/openssl
	|| (
		(
			>=x11-libs/libXext-1.1.1
			>=x11-proto/xextproto-7.1.1
			x11-proto/xproto
		)
		<x11-libs/libXext-1.1.1
	)
	sys-apps/lsb-release"

PDEPEND="webstart? ( dev-java/icedtea-web:6 )
	nsplugin? ( dev-java/icedtea-web:6[nsplugin] )"

# a bit of hack so the VM switching is triggered without causing dependency troubles
JAVA_PKG_NV_DEPEND=">=virtual/jdk-1.5"
JAVA_PKG_WANT_SOURCE="1.5"
JAVA_PKG_WANT_TARGET="1.5"

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

	if use nsplugin && ! use webstart ; then
		elog "Note that the nsplugin flag implies the webstart flag. Enable it to remove this message."
	fi

	# quite a hack since java-config does not provide a way for a package
	# to limit supported VM's for building and their preferred order
	if [[ -n "${JAVA_PKG_FORCE_VM}" ]]; then
		einfo "Honoring user-set JAVA_PKG_FORCE_VM"
	elif has_version "dev-java/icedtea:${SLOT}"; then
		JAVA_PKG_FORCE_VM="icedtea6"
	elif has_version dev-java/icedtea6; then
		JAVA_PKG_FORCE_VM="icedtea6"
	elif has_version dev-java/icedtea6-bin; then
		JAVA_PKG_FORCE_VM="icedtea6-bin"
	elif has_version dev-java/gcj-jdk; then
		JAVA_PKG_FORCE_VM="gcj-jdk"
	elif has_version dev-java/cacao; then
		JAVA_PKG_FORCE_VM="cacao"
	else
		JAVA_PKG_FORCE_VM=""
		# don't die just yet if merging a binpkg - bug #258423
		DIE_IF_NOT_BINPKG=true
	fi

	# if the previous failed, don't even run java eclasses pkg_setup
	# as it might also die when no VM is present
	if [[ -n "${JAVA_PKG_FORCE_VM}" ]]; then
		einfo "Forced vm ${JAVA_PKG_FORCE_VM}"
		java-vm-2_pkg_setup
		java-pkg-2_pkg_setup
	fi

	VMHANDLE="icedtea${SLOT}"
}

src_unpack() {
	if [[ -n ${DIE_IF_NOT_BINPKG} ]]; then
		die "Unable to find a supported VM for building"
	fi
	unpack ${ICEDTEA_PKG}.tar.gz
}

unset_vars() {
	unset JAVA_HOME JDK_HOME CLASSPATH JAVAC JAVACFLAGS
}

src_configure() {
	local config procs rhino_jar
	local vm=$(java-pkg_get-current-vm)
	local vmhome="/usr/$(get_libdir)/jvm/${vm}"

	# IcedTea6 can't be built using IcedTea7; its class files are too new
	if [[ "${vm}" == "icedtea6" ]] || [[ "${vm}" == "icedtea6-bin" ]] ; then
		# If we are upgrading icedtea, then we don't need to bootstrap.
		config="${config} --with-openjdk=$(java-config -O)"
	elif [[ "${vm}" == "gcj-jdk" || "${vm}" == "cacao" ]] ; then
		# For other 1.5 JDKs e.g. GCJ, CACAO.
		config="${config} --with-ecj-jar=/usr/share/eclipse-ecj/ecj.jar" \
		config="${config} --with-gcj-home=${vmhome}"
	else
		eerror "IcedTea${SLOT} must be built with either a JDK based on GNU Classpath or an existing build of IcedTea${SLOT}."
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

	if use javascript ; then
		rhino_jar=$(java-pkg_getjar rhino:1.6 js.jar);
	fi

	if use hs16 ; then
		config="${config} --with-hotspot-build=hs16"
	fi

	unset_vars

	econf ${config} \
		--with-openjdk-src-zip="${DISTDIR}/${OPENJDK_TARBALL}" \
		--with-hotspot-src-zip="${DISTDIR}/${HOTSPOT_TARBALL}" \
		--with-cacao-src-zip="${DISTDIR}/${CACAO_TARBALL}" \
		--with-java="${vmhome}/bin/java" \
		--with-javac="${vmhome}/bin/javac" \
		--with-javah="${vmhome}/bin/javah" \
		--with-abs-install-dir=/usr/$(get_libdir)/icedtea${SLOT} \
		$(use_enable !debug optimizations) \
		$(use_enable doc docs) \
		$(use_with javascript rhino ${rhino_jar}) \
		$(use_enable cacao) \
		$(use_enable pulseaudio pulse-java) \
		$(use_enable xrender) \
		$(use_enable systemtap) \
		$(use_enable nio2) \
		$(use_enable nss) \
		--disable-webstart \
		--disable-plugin \
		|| die "configure failed"
}

src_compile() {
	# Newer versions of Gentoo's ant add
	# an environment variable so it works properly...
	export ANT_RESPECT_JAVA_HOME=TRUE
	# ant -diagnostics in Ant 1.8.0 fails without these
	# otherwise we try to load the least that's needed to avoid possible classpath collisions
	export ANT_TASKS="xerces-2 xalan"

	# Paludis does not respect unset from src_configure
	unset_vars
	emake -j 1  || die "make failed"
}

src_install() {
	local dest="/usr/$(get_libdir)/icedtea${SLOT}"
	local ddest="${D}/${dest}"
	dodir "${dest}" || die

	local arch=${ARCH}
	use x86 && arch=i586

	dodoc README NEWS AUTHORS THANKYOU || die
	dosym "/usr/share/doc/${PF}" "/usr/share/doc/${PN}${SLOT}"

	cd "${S}/openjdk/build/linux-${arch}/j2sdk-image" || die

	if use doc ; then
		# java-pkg_dohtml needed for package-list #302654
		java-pkg_dohtml -r ../docs/* || die "Failed to install documentation"
	fi

	# Collides with icedtea-web, remove files here until upstream bug is solved.
	# http://icedtea.classpath.org/bugzilla/show_bug.cgi?id=633
	rm -fv man/man1/javaws.1 man/ja_JP.eucJP/man1/javaws.1

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

	# We need to generate keystore - bug #273306
	einfo "Generating cacerts file from certificates in /usr/share/ca-certificates/"
	mkdir "${T}/certgen" && cd "${T}/certgen" || die
	cp "${FILESDIR}/generate-cacerts.pl" . && chmod +x generate-cacerts.pl || die
	for c in /usr/share/ca-certificates/*/*.crt; do
		openssl x509 -text -in "${c}" >> all.crt || die
	done
	./generate-cacerts.pl "${ddest}/bin/keytool" all.crt || die
	cp -vRP cacerts "${ddest}/jre/lib/security/" || die
	chmod 644 "${ddest}/jre/lib/security/cacerts" || die

	sed -e "s#@SLOT@#${SLOT}#g" \
		-e "s#@PV@#${ICEDTEA_VER}#g" \
		-e "s#@LIBDIR@#$(get_libdir)#g" \
		< "${FILESDIR}/icedtea.env" > "${T}/icedtea.env"
	set_java_env "${T}/icedtea.env"
}

use_zero() {
	use zero || ( ! use amd64 && ! use x86 && ! use sparc )
}

pkg_postinst() {
	# Set as default VM if none exists
	java-vm-2_pkg_postinst
}
