# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/icedtea/icedtea-7.2.0-r1.ebuild,v 1.5 2011/11/06 23:22:43 caster Exp $
# Build written by Andrew John Hughes (gnu_andrew@member.fsf.org)

# *********************************************************
# * IF YOU CHANGE THIS EBUILD, CHANGE ICEDTEA-6.* AS WELL *
# *********************************************************

EAPI="4"

inherit flag-o-matic java-pkg-2 java-vm-2 pax-utils versionator

LICENSE="Apache-1.1 Apache-2.0 GPL-1 GPL-2 GPL-2-with-linking-exception LGPL-2 MPL-1.0 MPL-1.1 public-domain W3C"
SLOT="7"
KEYWORDS="~amd64 ~x86"

DESCRIPTION="A harness to build OpenJDK using Free Software build tools and dependencies"
ICEDTEA_VER="$(get_version_component_range 2-3)"
ICEDTEA_PKG=icedtea-${ICEDTEA_VER}
OPENJDK_TARBALL="0a76e5390e68.tar.gz"
CORBA_TARBALL="4d9e4fb8af09.tar.gz"
HOTSPOT_TARBALL="b28ae681bae0.tar.gz"
JAXP_TARBALL="948e734135ea.tar.gz"
JAXWS_TARBALL="a2ebfdc9db7e.tar.gz"
JDK_TARBALL="2054526dd141.tar.gz"
LANGTOOLS_TARBALL="9b85f1265346.tar.gz"
CACAO_TARBALL="4549072ab2de.tar.gz"
JAMVM_TARBALL="310c491ddc14e92a6ffff27030a1a1821e6395a8.tar.gz"
SRC_URI="http://icedtea.classpath.org/download/source/${ICEDTEA_PKG}.tar.gz
		 http://icedtea.classpath.org/hg/release/icedtea7-forest-2.0/archive/${OPENJDK_TARBALL}
		 http://icedtea.classpath.org/hg/release/icedtea7-forest-2.0/corba/archive/${CORBA_TARBALL}
		 http://icedtea.classpath.org/hg/release/icedtea7-forest-2.0/jaxp/archive/${JAXP_TARBALL}
		 http://icedtea.classpath.org/hg/release/icedtea7-forest-2.0/jaxws/archive/${JAXWS_TARBALL}
		 http://icedtea.classpath.org/hg/release/icedtea7-forest-2.0/jdk/archive/${JDK_TARBALL}
		 http://icedtea.classpath.org/hg/release/icedtea7-forest-2.0/hotspot/archive/${HOTSPOT_TARBALL}
		 http://icedtea.classpath.org/hg/release/icedtea7-forest-2.0/langtools/archive/${LANGTOOLS_TARBALL}
		 jamvm? ( http://icedtea.classpath.org/download/drops/jamvm/jamvm-${JAMVM_TARBALL} )"
HOMEPAGE="http://icedtea.classpath.org"
S=${WORKDIR}/${ICEDTEA_PKG}

# Missing options:
# shark - needs adding
IUSE="debug doc examples jamvm javascript +nsplugin pulseaudio systemtap +webstart zero"

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
	 media-libs/lcms:2
	 >=sys-libs/zlib-1.2.3
	 x11-proto/inputproto
	 x11-proto/xineramaproto
	 pulseaudio?  ( >=media-sound/pulseaudio-0.9.11 )
	 javascript? ( dev-java/rhino:1.6 )
	 zero? ( virtual/libffi )
	 >=x11-libs/libXrender-0.9.4
	 systemtap? ( >=dev-util/systemtap-1 )
	 !dev-java/icedtea:0
	 sys-apps/attr
	 >=dev-libs/glib-2.26
	 media-libs/fontconfig"

# Additional dependencies for building:
#   zip: extract OpenJDK tarball, and needed by configure
#   ant, ecj, jdk: required to build Java code
# Only ant-core-1.8.1 has fixed ant -diagnostics when xerces+xalan are not present.
# ca-certificates, perl and openssl are used for the cacerts keystore generation
# xext headers have two variants depending on version - bug #288855
# autoconf - as long as we use eautoreconf, version restrictions for bug #294918
DEPEND="${RDEPEND}
	|| (
		>=dev-java/gcj-jdk-4.3
		>=dev-java/cacao-0.99.2
		dev-java/icedtea:7
		dev-java/icedtea-bin:6
		dev-java/icedtea:6
	)
	app-arch/zip
	>=dev-libs/libxslt-1.1.26
	>=dev-java/ant-core-1.8.1
	dev-java/ant-nodeps
	app-misc/ca-certificates
	dev-lang/perl
	dev-libs/openssl
	sys-apps/lsb-release
	app-arch/cpio"
#	 || ( >=sys-devel/autoconf-2.65:2.5 <sys-devel/autoconf-2.64:2.5 )"

PDEPEND="webstart? ( dev-java/icedtea-web:7 )
	nsplugin? ( dev-java/icedtea-web:7[nsplugin] )"

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

	# quite a hack since java-config does not provide a way for a package
	# to limit supported VM's for building and their preferred order
	if [[ -n "${JAVA_PKG_FORCE_VM}" ]]; then
		einfo "Honoring user-set JAVA_PKG_FORCE_VM"
	elif has_version "<=dev-java/icedtea-7.2.0:7"; then
		JAVA_PKG_FORCE_VM="icedtea7"
	elif has_version ">dev-java/icedtea-7.2.0:7"; then
		JAVA_PKG_FORCE_VM="icedtea-7"
	elif has_version "<=dev-java/icedtea-6.1.10.4:6"; then
		JAVA_PKG_FORCE_VM="icedtea6"
	elif has_version ">dev-java/icedtea-6.1.10.4:6"; then
		JAVA_PKG_FORCE_VM="icedtea-6"
	elif has_version dev-java/icedtea-bin:6; then
		JAVA_PKG_FORCE_VM="icedtea6-bin"
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

	# without this, access violation is thrown
	addpredict "/proc/self/coredump_filter"
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

	if [[ "${vm}" == "icedtea6" || "${vm}" == "icedtea-6" || "${vm}" == "icedtea6-bin" ]] ; then
		# We can't currently bootstrap with a IcedTea6 JVM :(
		config="${config} --disable-bootstrap"
	elif [[ "${vm}" != "gcj-jdk" && "${vm}" != "cacao" && "${vm}" != "icedtea7" && "${vm}" != "icedtea-7" ]] ; then
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

	if use javascript ; then
		rhino_jar=$(java-pkg_getjar rhino:1.6 js.jar);
	fi

# CACAO disabled until it has OpenJDK7 support
#	if use cacao ; then
#		config="${config} --with-cacao-src-zip=${DISTDIR}/${CACAO_TARBALL}";
#	fi

	if use jamvm ; then
		config="${config} --with-jamvm-src-zip=${DISTDIR}/${JAMVM_TARBALL}";
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
		--with-jdk-home="$(java-config -O)" \
		--with-abs-install-dir=/usr/$(get_libdir)/icedtea${SLOT} \
		--disable-jdk-tests \
		$(use_enable !debug optimizations) \
		$(use_enable doc docs) \
		$(use_with javascript rhino ${rhino_jar}) \
		$(use_enable zero) \
		$(use_enable pulseaudio pulse-java) \
		$(use_enable systemtap)
}

src_compile() {
	# Newer versions of Gentoo's ant add
	# an environment variable so it works properly...
	export ANT_RESPECT_JAVA_HOME=TRUE

	# We try to load the least that's needed to avoid possible classpath collisions
	export ANT_TASKS="ant-nodeps"

	emake -j 1
}

src_install() {
	local dest="/usr/$(get_libdir)/icedtea${SLOT}"
	local ddest="${D}/${dest}"
	dodir "${dest}"

	local arch=${ARCH}

	dodoc README NEWS AUTHORS
	dosym "/usr/share/doc/${PF}" "/usr/share/doc/${PN}${SLOT}"

	cd "${S}/openjdk.build/j2sdk-image" || die

	# Don't hide classes
	rm -f lib/ct.sym

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

	# bug #388127
	dodir /etc/sandbox.d
	echo 'SANDBOX_PREDICT="/dev/random:/proc/self/coredump_filter"' > "${D}/etc/sandbox.d/20${VMHANDLE}"
}

use_zero() {
	use zero || ( ! use amd64 && ! use x86 && ! use sparc )
}

pkg_preinst() {
	if has_version "<=dev-java/icedtea-7.2.0:7"; then
		# portage would preserve the symlink otherwise, related to bug #384397
		rm -f "${ROOT}/usr/lib/jvm/icedtea7"
		elog "To unify the layout and simplify scripts, the identifier of Icedtea-7*"
		elog "has changed from 'icedtea7' to 'icedtea-7' starting from version 7.2.0-r1"
		elog "If you had icedtea7 as system VM, the change should be automatic, however"
		elog "build VM settings in /etc/java-config-2/build/jdk.conf are not changed"
		elog "and the same holds for any user VM settings. Sorry for the inconvenience."
	fi
}

pkg_postinst() {
	# Set as default VM if none exists
	java-vm-2_pkg_postinst
}
