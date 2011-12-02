# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/icedtea/icedtea-7.2.0-r3.ebuild,v 1.1 2011/12/02 12:27:17 sera Exp $
# Build written by Andrew John Hughes (gnu_andrew@member.fsf.org)

# *********************************************************
# * IF YOU CHANGE THIS EBUILD, CHANGE ICEDTEA-6.* AS WELL *
# *********************************************************

EAPI="4"

inherit java-pkg-2 java-vm-2 pax-utils prefix versionator

ICEDTEA_PKG=icedtea-$(get_version_component_range 2-3)
OPENJDK_TARBALL="0a76e5390e68.tar.gz"
CORBA_TARBALL="4d9e4fb8af09.tar.gz"
HOTSPOT_TARBALL="b28ae681bae0.tar.gz"
JAXP_TARBALL="948e734135ea.tar.gz"
JAXWS_TARBALL="a2ebfdc9db7e.tar.gz"
JDK_TARBALL="2054526dd141.tar.gz"
LANGTOOLS_TARBALL="9b85f1265346.tar.gz"
CACAO_TARBALL="4549072ab2de.tar.gz" # 30 Aug 2011
JAMVM_TARBALL="jamvm-310c491ddc14e92a6ffff27030a1a1821e6395a8.tar.gz" # 26 Sep 2011
#CACAO_TARBALL="cacao-2204b08fcae9.tar.gz" # 03 Nov 2011
#JAMVM_TARBALL="jamvm-4617da717ecb05654ea5bb9572338061106a414d.tar.gz" # 10 Oct 2011
S=${WORKDIR}/${ICEDTEA_PKG}

DESCRIPTION="A harness to build OpenJDK using Free Software build tools and dependencies"
HOMEPAGE="http://icedtea.classpath.org"
SRC_URI="
	http://icedtea.classpath.org/download/source/${ICEDTEA_PKG}.tar.gz
	http://icedtea.classpath.org/hg/release/icedtea7-forest-2.0/archive/${OPENJDK_TARBALL}
	http://icedtea.classpath.org/hg/release/icedtea7-forest-2.0/corba/archive/${CORBA_TARBALL}
	http://icedtea.classpath.org/hg/release/icedtea7-forest-2.0/jaxp/archive/${JAXP_TARBALL}
	http://icedtea.classpath.org/hg/release/icedtea7-forest-2.0/jaxws/archive/${JAXWS_TARBALL}
	http://icedtea.classpath.org/hg/release/icedtea7-forest-2.0/jdk/archive/${JDK_TARBALL}
	http://icedtea.classpath.org/hg/release/icedtea7-forest-2.0/hotspot/archive/${HOTSPOT_TARBALL}
	http://icedtea.classpath.org/hg/release/icedtea7-forest-2.0/langtools/archive/${LANGTOOLS_TARBALL}
	jamvm? ( http://icedtea.classpath.org/download/drops/jamvm/${JAMVM_TARBALL} )"
	#cacao? ( http://icedtea.classpath.org/download/drops/cacao/${CACAO_TARBALL} )

LICENSE="Apache-1.1 Apache-2.0 GPL-1 GPL-2 GPL-2-with-linking-exception LGPL-2 MPL-1.0 MPL-1.1 public-domain W3C"
SLOT="7"
KEYWORDS="~amd64 ~x86"

# Missing options: cacao zero shark - for building additional vms
IUSE="+X +alsa cjk +cups debug doc examples -jamvm javascript +jbootstrap
	+nsplugin +nss pulseaudio +source systemtap +webstart"
REQUIRED_USE="
	jamvm? ( jbootstrap )"
	#cacao? ( jbootstrap )

# Ideally the following were optional at build time.
ALSA_COMMON_DEP="
	>=media-libs/alsa-lib-1.0"
CUPS_COMMON_DEP="
	>=net-print/cups-1.2.12"
X_COMMON_DEP="
	>=dev-libs/atk-1.30.0
	>=dev-libs/glib-2.26
	media-libs/fontconfig
	>=media-libs/freetype-2.3.5
	>=x11-libs/cairo-1.8.8
	x11-libs/gdk-pixbuf:2
	>=x11-libs/gtk+-2.8:2
	>=x11-libs/libX11-1.1.3
	>=x11-libs/libXext-1.1.1
	>=x11-libs/libXi-1.1.3
	>=x11-libs/libXrender-0.9.4
	>=x11-libs/libXtst-1.0.3
	>=x11-libs/pango-1.24.5"
X_DEPEND="
	>=x11-libs/libXau-1.0.3
	>=x11-libs/libXdmcp-1.0.2
	>=x11-libs/libXinerama-1.0.2
	>=x11-libs/libXp-1.0.0
	x11-proto/inputproto
	>=x11-proto/xextproto-7.1.1
	x11-proto/xineramaproto
	x11-proto/xproto"

# virtual/libffi is needed for Zero
COMMON_DEP="
	>=media-libs/giflib-4.1.6
	media-libs/lcms:2
	>=media-libs/libpng-1.2
	>=sys-devel/gcc-4.3
	>=sys-libs/glibc-2.11.2
	>=sys-libs/zlib-1.2.3
	virtual/jpeg
	javascript? ( dev-java/rhino:1.6 )
	nss? ( >=dev-libs/nss-3.12.5-r1 )
	pulseaudio?  ( >=media-sound/pulseaudio-0.9.11 )
	systemtap? ( >=dev-util/systemtap-1 )
	!amd64? ( !sparc? ( !x86? ( virtual/libffi ) ) )"

# cups is needed for X. #390945 #390975
RDEPEND="${COMMON_DEP}
	!dev-java/icedtea:0
	X? (
		${CUPS_COMMON_DEP}
		${X_COMMON_DEP}
		media-fonts/dejavu
		cjk? (
			media-fonts/arphicfonts
			media-fonts/baekmuk-fonts
			media-fonts/lklug
			media-fonts/lohit-fonts
			media-fonts/sazanami
		)
	)
	alsa? ( ${ALSA_COMMON_DEP} )
	cups? ( ${CUPS_COMMON_DEP} )"

# Additional dependencies for building:
#   zip: extract OpenJDK tarball, and needed by configure
#   ant, jdk: required to build Java code
#   ecj: required for bootstrap builds
# Only ant-core-1.8.1 has fixed ant -diagnostics when xerces+xalan are not present.
# ca-certificates, perl and openssl are used for the cacerts keystore generation
# xext headers have two variants depending on version - bug #288855
# autoconf - as long as we use eautoreconf, version restrictions for bug #294918
DEPEND="${COMMON_DEP} ${ALSA_COMMON_DEP} ${CUPS_COMMON_DEP} ${X_COMMON_DEP}
	|| (
		>=dev-java/gcj-jdk-4.3
		dev-java/icedtea-bin:7
		dev-java/icedtea-bin:6
		dev-java/icedtea:7
		dev-java/icedtea:6
	)
	app-arch/cpio
	app-arch/zip
	app-misc/ca-certificates
	>=dev-java/ant-core-1.8.1
	dev-java/ant-nodeps
	dev-lang/perl
	>=dev-libs/libxslt-1.1.26
	dev-libs/openssl
	dev-util/pkgconfig
	sys-apps/attr
	sys-apps/lsb-release
	${X_DEPEND}
	jbootstrap? (
		|| ( dev-java/eclipse-ecj dev-java/ecj-gcj )
	)"
#	 || ( >=sys-devel/autoconf-2.65:2.5 <sys-devel/autoconf-2.64:2.5 )"

PDEPEND="webstart? ( dev-java/icedtea-web:7 )
	nsplugin? ( dev-java/icedtea-web:7[nsplugin] )"

# a bit of hack so the VM switching is triggered without causing dependency troubles
JAVA_PKG_NV_DEPEND=">=virtual/jdk-1.5"
JAVA_PKG_WANT_SOURCE="1.5"
JAVA_PKG_WANT_TARGET="1.5"

pkg_setup() {
	if use nsplugin && ! use webstart ; then
		elog "Note that the nsplugin flag implies the webstart flag. Enable it to remove this message."
	fi

	[[ "${MERGE_TYPE}" == "binary" ]] && return #258423

	# icedtea doesn't like some locales. #330433 #389717
	export LANG="C" LC_ALL="C"

	# quite a hack since java-config does not provide a way for a package
	# to limit supported VM's for building and their preferred order
	if [[ -n "${JAVA_PKG_FORCE_VM}" ]]; then
		einfo "Honoring user-set JAVA_PKG_FORCE_VM"
	elif has_version "<=dev-java/icedtea-7.2.0:7"; then
		JAVA_PKG_FORCE_VM="icedtea7"
	elif has_version ">dev-java/icedtea-7.2.0:7"; then
		JAVA_PKG_FORCE_VM="icedtea-7"
	elif has_version "dev-java/icedtea-bin:7"; then
		JAVA_PKG_FORCE_VM="icedtea-bin-7"
	elif has_version "<=dev-java/icedtea-6.1.10.4:6"; then
		JAVA_PKG_FORCE_VM="icedtea6"
	elif has_version ">dev-java/icedtea-6.1.10.4:6"; then
		JAVA_PKG_FORCE_VM="icedtea-6"
	elif has_version "<dev-java/icedtea-bin-6.1.10.4:6"; then
		JAVA_PKG_FORCE_VM="icedtea6-bin"
	elif has_version ">=dev-java/icedtea-bin-6.1.10.4:6"; then
		JAVA_PKG_FORCE_VM="icedtea-bin-6"
	elif has_version dev-java/gcj-jdk; then
		JAVA_PKG_FORCE_VM="gcj-jdk"
	else
		die "Unable to find a supported VM for building"
	fi

	einfo "Forced vm ${JAVA_PKG_FORCE_VM}"
	java-vm-2_pkg_setup
	java-pkg-2_pkg_setup

	# For bootstrap builds as the sandbox control file might not yet exist.
	addpredict /proc/self/coredump_filter
}

src_unpack() {
	unpack ${ICEDTEA_PKG}.tar.gz
}

java_prepare() {
	# Fix non bootstrap builds with PaX enabled kernels. Bug #389751
	# Move applying test_gamma.patch to before creating boot copy.
	if host-is-pax; then
		sed -i -e 's|patches/boot/test_gamma.patch||' Makefile.in || die
		sed -i -e 's|openjdk-boot|openjdk|g' patches/boot/test_gamma.patch || die
		export DISTRIBUTION_PATCHES=patches/boot/test_gamma.patch
	fi
}

src_configure() {
	local config bootstrap
	local vm=$(java-pkg_get-current-vm)

	if has "${vm}" icedtea7 icedtea-7 icedtea-bin-7; then
		use jbootstrap && bootstrap=yes
	elif has "${vm}" icedtea6 icedtea-6 icedtea6-bin icedtea-bin-6; then
		if use jbootstrap; then
			einfo "We can't currently bootstrap with a IcedTea6 JVM :("
			einfo "bootstrap forced off, ignoring use jbootstrap"
		fi
	elif has "${vm}" gcj-jdk; then
		# gcj-jdk ensures ecj is present.
		use jbootstrap || einfo "bootstrap forced on for ${vm}, ignoring use jbootstrap"
		bootstrap=yes
	else
		eerror "IcedTea must be built with either a JDK based on GNU Classpath or an existing build of IcedTea."
		die "Install a GNU Classpath JDK (gcj-jdk)"
	fi

	if [[ ${bootstrap} ]]; then
		local ecj_jar="$(readlink "${EPREFIX}"/usr/share/eclipse-ecj/ecj.jar)"

		config="${config} --enable-bootstrap"
		config="${config} --with-ecj-jar=${ecj_jar}"
	else
		config="${config} --disable-bootstrap"
	fi

	# Always use HotSpot as the primary VM if available. #389521 #368669 #357633 ...
	if has "${ARCH}" amd64 sparc x86; then
		config="${config} --disable-zero --disable-cacao --disable-jamvm --disable-shark"

		if [[ ${bootstrap} ]]; then
			local extra_vms
			#if use shark; then
			#	extra_vms="${extra_vms},shark"
			#elif use zero; then
			#	extra_vms="${extra_vms},zero"
			#fi
			# CACAO disabled until it has OpenJDK7 support
			#if use cacao; then
			#	extra_vms="${extra_vms},cacao"
			#	config="${config} --with-cacao-src-zip=${DISTDIR}/${CACAO_TARBALL}"
			#fi
			if use jamvm; then
				extra_vms="${extra_vms},jamvm"
				config="${config} --with-jamvm-src-zip=${DISTDIR}/${JAMVM_TARBALL}"
			fi
			if [[ ${extra_vms} ]]; then
				config="${config} --with-additional-vms=${extra_vms#,}"
			fi
		elif use jamvm; then
			ewarn "Can't build additional VMs without bootstrap."
			ewarn "Rebuild IcedTea with a JDK that allows bootstrapping."
		fi
	else
		config="${config} --enable-zero --disable-cacao --disable-jamvm --disable-shark"
		# local extra_vms
	fi

	# OpenJDK-specific parallelism support. Bug #389791, #337827
	# Implementation modified from waf-utils.eclass
	# Note that "-j" is converted to "-j1" as the system doesn't support --load-average
	local procs=$(echo -j1 ${MAKEOPTS} | sed -r "s/.*(-j\s*|--jobs=)([0-9]+).*/\2/" )
	config="${config} --with-parallel-jobs=${procs}";
	einfo "Configuring using --with-parallel-jobs=${procs}"

	if use javascript ; then
		config="${config} --with-rhino=$(java-pkg_getjar rhino:1.6 js.jar)"
	else
		config="${config} --without-rhino"
	fi

	unset JAVA_HOME JDK_HOME CLASSPATH JAVAC JAVACFLAGS

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
		$(use_enable nss) \
		$(use_enable pulseaudio pulse-java) \
		$(use_enable systemtap)
}

src_compile() {
	# Newer versions of Gentoo's ant add
	# an environment variable so it works properly...
	export ANT_RESPECT_JAVA_HOME=TRUE

	# We try to load the least that's needed to avoid possible classpath collisions
	export ANT_TASKS="ant-nodeps"

	# Build and pax mark the intermidiate jdk. #389751
	if host-is-pax; then
		emake -j1 icedtea-boot
		java-vm_set-pax-markings openjdk.build-boot
	fi

	emake -j 1
}

src_install() {
	local dest="/usr/$(get_libdir)/icedtea${SLOT}"
	local ddest="${ED}/${dest}"
	dodir "${dest}"

	dodoc README NEWS AUTHORS
	dosym /usr/share/doc/${PF} /usr/share/doc/${PN}${SLOT}

	# http://www.mail-archive.com/openjdk@lists.launchpad.net/msg06599.html
	if use jamvm; then
		dosym ${dest}/jre/lib/$(get_system_arch)/jamvm/libjvm.so \
			${dest}/jre/lib/$(get_system_arch)
	fi

	cd openjdk.build/j2sdk-image || die

	# Don't hide classes
	rm lib/ct.sym || die

	# doins can't handle symlinks.
	cp -vRP bin include jre lib man "${ddest}" || die

	dodoc ASSEMBLY_EXCEPTION THIRD_PARTY_README

	if use doc; then
		# java-pkg_dohtml needed for package-list #302654
		java-pkg_dohtml -r ../docs/* || die
	fi

	if use examples; then
		dodir "${dest}/share";
		cp -vRP demo sample "${ddest}/share/" || die
	fi

	if use source; then
		cp src.zip "${ddest}" || die
	fi

	# Fix the permissions.
	find "${ddest}" \! -type l \( -perm /111 -exec chmod 755 {} \; -o -exec chmod 644 {} \; \) || die

	# Needs to be done before generating cacerts
	java-vm_set-pax-markings "${ddest}"

	# We need to generate keystore - bug #273306
	einfo "Generating cacerts file from certificates in ${EPREFIX}/usr/share/ca-certificates/"
	mkdir "${T}/certgen" && cd "${T}/certgen" || die
	cp "${FILESDIR}/generate-cacerts.pl" . && chmod +x generate-cacerts.pl || die
	for c in "${EPREFIX}"/usr/share/ca-certificates/*/*.crt; do
		openssl x509 -text -in "${c}" >> all.crt || die
	done
	./generate-cacerts.pl "${ddest}/bin/keytool" all.crt || die
	cp -vRP cacerts "${ddest}/jre/lib/security/" || die
	chmod 644 "${ddest}/jre/lib/security/cacerts" || die

	# OpenJDK7 should be able to use fontconfig instead, but wont hurt to
	# install it anyway. Bug 390663
	cp "${FILESDIR}"/fontconfig.Gentoo.properties.src "${T}"/fontconfig.Gentoo.properties || die
	eprefixify "${T}"/fontconfig.Gentoo.properties
	insinto "${dest}"/jre/lib
	doins "${T}"/fontconfig.Gentoo.properties

	set_java_env "${FILESDIR}/icedtea.env"
	java-vm_sandbox-predict /proc/self/coredump_filter
}

pkg_preinst() {
	if has_version "<=dev-java/icedtea-7.2.0:7"; then
		# portage would preserve the symlink otherwise, related to bug #384397
		rm -f "${EROOT}/usr/lib/jvm/icedtea7"
		elog "To unify the layout and simplify scripts, the identifier of Icedtea-7*"
		elog "has changed from 'icedtea7' to 'icedtea-7' starting from version 7.2.0-r1"
		elog "If you had icedtea7 as system VM, the change should be automatic, however"
		elog "build VM settings in /etc/java-config-2/build/jdk.conf are not changed"
		elog "and the same holds for any user VM settings. Sorry for the inconvenience."
	fi
}
