# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/icedtea/icedtea-6.1.10.4-r1.ebuild,v 1.5 2011/11/18 11:01:47 sera Exp $
# Build written by Andrew John Hughes (gnu_andrew@member.fsf.org)

# *********************************************************
# * IF YOU CHANGE THIS EBUILD, CHANGE ICEDTEA-7.* AS WELL *
# *********************************************************

EAPI="4"

inherit pax-utils java-pkg-2 java-vm-2 versionator

LICENSE="Apache-1.1 Apache-2.0 GPL-1 GPL-2 GPL-2-with-linking-exception LGPL-2 MPL-1.0 MPL-1.1 public-domain W3C"
SLOT="6"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"

DESCRIPTION="A harness to build the OpenJDK using Free Software build tools and dependencies"
ICEDTEA_VER="$(get_version_component_range 2-4)"
ICEDTEA_PKG=icedtea${SLOT}-${ICEDTEA_VER}
OPENJDK_BUILD="22"
OPENJDK_DATE="28_feb_2011"
OPENJDK_TARBALL="openjdk-6-src-b${OPENJDK_BUILD}-${OPENJDK_DATE}.tar.gz"
JAXP_TARBALL="jaxp144_01.zip"
JAXWS_TARBALL="jdk6-jaxws-b20.zip"
JAF_TARBALL="jdk6-jaf-b20.zip"
HOTSPOT_TARBALL="f0f676c5a2c6.tar.gz"
CACAO_TARBALL="c7bf150bfa46.tar.gz"
JAMVM_TARBALL="jamvm-a95ca049d3bb257d730535a5d5ec3f73a943d0aa.tar.gz"
SRC_URI="http://icedtea.classpath.org/download/source/${ICEDTEA_PKG}.tar.gz
		 http://download.java.net/openjdk/jdk6/promoted/b${OPENJDK_BUILD}/${OPENJDK_TARBALL}
		 http://icedtea.classpath.org/download/drops/${JAXWS_TARBALL}
		 http://icedtea.classpath.org/download/drops/${JAF_TARBALL}
		 http://icedtea.classpath.org/download/drops/${JAXP_TARBALL}
		 hs20? ( http://hg.openjdk.java.net/hsx/hsx20/master/archive/${HOTSPOT_TARBALL} )
		 cacao? ( http://icedtea.classpath.org/download/drops/cacao/${CACAO_TARBALL} )
		 jamvm? ( http://icedtea.classpath.org/download/drops/jamvm/${JAMVM_TARBALL} )"
HOMEPAGE="http://icedtea.classpath.org"
S=${WORKDIR}/${ICEDTEA_PKG}

# Missing options:
# shark - needs adding
IUSE="cacao debug doc examples +hs20 jamvm javascript nio2 +nsplugin +nss pulseaudio systemtap +webstart +xrender zero"

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
		dev-java/icedtea-bin:6
		dev-java/icedtea:${SLOT}
	)
	app-arch/zip
	>=dev-java/xalan-2.7.0:0
	>=dev-java/xerces-2.9.1:2
	>=dev-java/ant-core-1.7.1-r2
	dev-java/ant-nodeps
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

	if [[ "${MERGE_TYPE}" == "binary" ]]; then
		return
	fi

	# icedtea doesn't like some locales. #330433 #389717
	export LANG="C" LC_ALL="C"

	# quite a hack since java-config does not provide a way for a package
	# to limit supported VM's for building and their preferred order
	if [[ -n "${JAVA_PKG_FORCE_VM}" ]]; then
		einfo "Honoring user-set JAVA_PKG_FORCE_VM"
	elif has_version "<=dev-java/icedtea-6.1.10.4:${SLOT}"; then
		JAVA_PKG_FORCE_VM="icedtea6"
	elif has_version ">dev-java/icedtea-6.1.10.4:${SLOT}"; then
		JAVA_PKG_FORCE_VM="icedtea-6"
	elif has_version "<dev-java/icedtea-bin-6.1.10.4:6"; then
		JAVA_PKG_FORCE_VM="icedtea6-bin"
	elif has_version ">=dev-java/icedtea-bin-6.1.10.4:6"; then
		JAVA_PKG_FORCE_VM="icedtea-bin-6"
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
	unpack ${ICEDTEA_PKG}.tar.gz
}

unset_vars() {
	unset JAVA_HOME JDK_HOME CLASSPATH JAVAC JAVACFLAGS
}

src_configure() {
	local config procs rhino_jar
	local vm=$(java-pkg_get-current-vm)
	# the VM symlinks are installed specifically to /usr/lib (not get_libdir), bug 380853
	local vmhome="/usr/lib/jvm/${vm}"

	# IcedTea6 can't be built using IcedTea7; its class files are too new
	if has "${vm}" icedtea6 icedtea-6 icedtea6-bin icedtea-bin-6; then
		# If we are upgrading icedtea, then we don't need to bootstrap.
		config="${config} --with-jdk-home=$(java-config -O) --disable-bootstrap"
	elif has "${vm}" gcj-jdk cacao; then
		# For other 1.5 JDKs e.g. GCJ, CACAO.
		config="${config} --with-ecj-jar=/usr/share/eclipse-ecj/ecj.jar" \
		config="${config} --with-jdk-home=${vmhome}"
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

	if use hs20 ; then
		config="${config} --with-hotspot-build=hs20 --with-hotspot-src-zip=${DISTDIR}/${HOTSPOT_TARBALL}"
	fi

	if use cacao ; then
		config="${config} --with-cacao-src-zip=${DISTDIR}/${CACAO_TARBALL}"
	fi

	if use jamvm ; then
		config="${config} --with-jamvm-src-zip=${DISTDIR}/${JAMVM_TARBALL}"
	fi

	unset_vars

	econf ${config} \
		--with-openjdk-src-zip="${DISTDIR}/${OPENJDK_TARBALL}" \
		--with-jaxp-drop-zip="${DISTDIR}/${JAXP_TARBALL}" \
		--with-jaxws-drop-zip="${DISTDIR}/${JAXWS_TARBALL}" \
		--with-jaf-drop-zip="${DISTDIR}/${JAF_TARBALL}" \
		--with-abs-install-dir=/usr/$(get_libdir)/icedtea${SLOT} \
		$(use_enable !debug optimizations) \
		$(use_enable doc docs) \
		$(use_with javascript rhino ${rhino_jar}) \
		$(use_enable cacao) \
		$(use_enable jamvm) \
		$(use_enable pulseaudio pulse-java) \
		$(use_enable xrender) \
		$(use_enable systemtap) \
		$(use_enable nio2) \
		$(use_enable nss)
}

src_compile() {
	# Newer versions of Gentoo's ant add
	# an environment variable so it works properly...
	export ANT_RESPECT_JAVA_HOME=TRUE
	# ant -diagnostics in Ant 1.8.0 fails without these
	# otherwise we try to load the least that's needed to avoid possible classpath collisions
	export ANT_TASKS="xerces-2 xalan ant-nodeps"

	emake
}

src_install() {
	local dest="/usr/$(get_libdir)/icedtea${SLOT}"
	local ddest="${D}/${dest}"
	dodir "${dest}"

	dodoc README NEWS AUTHORS THANKYOU
	dosym "/usr/share/doc/${PF}" "/usr/share/doc/${PN}${SLOT}"

	cd "${S}/openjdk.build/j2sdk-image" || die

	if use doc ; then
		# java-pkg_dohtml needed for package-list #302654
		java-pkg_dohtml -r ../docs/* || die "Failed to install documentation"
	fi

	# doins can't handle symlinks.
	cp -vRP bin include jre lib man "${ddest}" || die "failed to copy"

	# Set PaX markings on all JDK/JRE executables to allow code-generation on
	# the heap by the JIT compiler.
	pax-mark m $(list-paxables "${ddest}"{,/jre}/bin/*)

	dodoc ASSEMBLY_EXCEPTION THIRD_PARTY_README

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

pkg_preinst() {
	if has_version "<=dev-java/icedtea-6.1.10.4:${SLOT}"; then
		# portage would preserve the symlink otherwise, related to bug #384397
		rm -f "${ROOT}/usr/lib/jvm/icedtea6"
		elog "To unify the layout and simplify scripts, the identifier of Icedtea-6*"
		elog "has changed from 'icedtea6' to 'icedtea-6' starting from version 6.1.10.4-r1"
		elog "If you had icedtea6 as system VM, the change should be automatic, however"
		elog "build VM settings in /etc/java-config-2/build/jdk.conf are not changed"
		elog "and the same holds for any user VM settings. Sorry for the inconvenience."
	fi
}

pkg_postinst() {
	# Set as default VM if none exists
	java-vm-2_pkg_postinst
}
