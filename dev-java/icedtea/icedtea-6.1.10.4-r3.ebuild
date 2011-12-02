# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/icedtea/icedtea-6.1.10.4-r3.ebuild,v 1.1 2011/12/02 12:27:17 sera Exp $
# Build written by Andrew John Hughes (gnu_andrew@member.fsf.org)

# *********************************************************
# * IF YOU CHANGE THIS EBUILD, CHANGE ICEDTEA-7.* AS WELL *
# *********************************************************

EAPI="4"

inherit java-pkg-2 java-vm-2 pax-utils prefix versionator

ICEDTEA_PKG=${PN}$(replace_version_separator 1 -)
OPENJDK_BUILD="22"
OPENJDK_DATE="28_feb_2011"
OPENJDK_TARBALL="openjdk-6-src-b${OPENJDK_BUILD}-${OPENJDK_DATE}.tar.gz"
JAXP_TARBALL="jaxp144_01.zip"
JAXWS_TARBALL="jdk6-jaxws-b20.zip"
JAF_TARBALL="jdk6-jaf-b20.zip"
HOTSPOT_TARBALL="f0f676c5a2c6.tar.gz"
CACAO_TARBALL="c7bf150bfa46.tar.gz" # 17 Mar 2011
JAMVM_TARBALL="jamvm-a95ca049d3bb257d730535a5d5ec3f73a943d0aa.tar.gz" # 25 Mar 2011
#CACAO_TARBALL="cacao-2204b08fcae9.tar.gz" # 03 Nov 2011
#JAMVM_TARBALL="jamvm-4617da717ecb05654ea5bb9572338061106a414d.tar.gz" # 10 Oct 2011
S=${WORKDIR}/${ICEDTEA_PKG}

DESCRIPTION="A harness to build OpenJDK using Free Software build tools and dependencies"
HOMEPAGE="http://icedtea.classpath.org"
SRC_URI="
	http://icedtea.classpath.org/download/source/${ICEDTEA_PKG}.tar.gz
	http://download.java.net/openjdk/jdk6/promoted/b${OPENJDK_BUILD}/${OPENJDK_TARBALL}
	http://icedtea.classpath.org/download/drops/${JAXWS_TARBALL}
	http://icedtea.classpath.org/download/drops/${JAF_TARBALL}
	http://icedtea.classpath.org/download/drops/${JAXP_TARBALL}
	hs20? ( http://hg.openjdk.java.net/hsx/hsx20/master/archive/${HOTSPOT_TARBALL} )
	cacao? ( http://icedtea.classpath.org/download/drops/cacao/${CACAO_TARBALL} )
	jamvm? ( http://icedtea.classpath.org/download/drops/jamvm/${JAMVM_TARBALL} )"

LICENSE="Apache-1.1 Apache-2.0 GPL-1 GPL-2 GPL-2-with-linking-exception LGPL-2 MPL-1.0 MPL-1.1 public-domain W3C"
SLOT="6"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"

# Missing options: zero shark - for building additional vms
IUSE="+X +alsa -cacao cjk +cups debug doc examples +hs20 -jamvm javascript
	+jbootstrap nio2 +nsplugin +nss pulseaudio +source systemtap +webstart"
REQUIRED_USE="
	cacao? ( jbootstrap )
	jamvm? ( jbootstrap )"

# JTReg doesn't pass at present
RESTRICT="test"

# Ideally the following were optional at build time.
ALSA_COMMON_DEP="
	>=media-libs/alsa-lib-1.0"
CUPS_COMMON_DEP="
	>=net-print/cups-1.2.12"
X_COMMON_DEP="
	dev-libs/glib
	>=media-libs/freetype-2.3.5
	>=x11-libs/gtk+-2.8:2
	>=x11-libs/libX11-1.1.3
	>=x11-libs/libXext-1.1.1
	>=x11-libs/libXi-1.1.3
	>=x11-libs/libXrender-0.9.4
	>=x11-libs/libXtst-1.0.3"
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

# media-fonts/lklug needs ppc ppc64 keywords
RDEPEND="${COMMON_DEP}
	!dev-java/icedtea6
	X? (
		${X_COMMON_DEP}
		media-fonts/dejavu
		cjk? (
			media-fonts/arphicfonts
			media-fonts/baekmuk-fonts
			!ppc? ( !ppc64? ( media-fonts/lklug ) )
			media-fonts/lohit-fonts
			media-fonts/sazanami
		)
	)
	alsa? ( ${ALSA_COMMON_DEP} )
	cups? ( ${CUPS_COMMON_DEP} )"

# Additional dependencies for building:
#   zip: extract OpenJDK tarball, and needed by configure
#   xalan/xerces: automatic code generation (also needed for Ant 1.8.0 to work properly)
#   ant, jdk: required to build Java code
#   ecj: required for bootstrap builds
# Only ant-core-1.7.1-r2 and later contain a version of Ant that
# properly respects environment variables, if the build
# sets some environment variables.
# ca-certificates, perl and openssl are used for the cacerts keystore generation
# xext headers have two variants depending on version - bug #288855
# !eclipse-ecj-3.7 - bug #392587
DEPEND="${COMMON_DEP} ${ALSA_COMMON_DEP} ${CUPS_COMMON_DEP} ${X_COMMON_DEP}
	|| (
		>=dev-java/gcj-jdk-4.3
		dev-java/icedtea-bin:6
		dev-java/icedtea:6
	)
	app-arch/cpio
	app-arch/zip
	app-misc/ca-certificates
	>=dev-java/ant-core-1.7.1-r2
	dev-java/ant-nodeps
	>=dev-java/xalan-2.7.0:0
	>=dev-java/xerces-2.9.1:2
	dev-lang/perl
	dev-libs/openssl
	dev-util/pkgconfig
	sys-apps/lsb-release
	${X_DEPEND}
	jbootstrap? (
		|| ( <dev-java/eclipse-ecj-3.7 dev-java/ecj-gcj )
	)"

PDEPEND="webstart? ( dev-java/icedtea-web:6 )
	nsplugin? ( dev-java/icedtea-web:6[nsplugin] )"

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
}

src_unpack() {
	unpack ${ICEDTEA_PKG}.tar.gz
}

src_configure() {
	local config bootstrap
	local vm=$(java-pkg_get-current-vm)

	# IcedTea6 can't be built using IcedTea7; its class files are too new
	if has "${vm}" icedtea6 icedtea-6 icedtea6-bin icedtea-bin-6; then
		use jbootstrap && bootstrap=yes
	elif has "${vm}" gcj-jdk; then
		# gcj-jdk ensures ecj is present.
		use jbootstrap || einfo "bootstrap forced on for ${vm}, ignoring use jbootstrap"
		bootstrap=yes
	else
		eerror "IcedTea${SLOT} must be built with either a JDK based on GNU Classpath or an existing build of IcedTea${SLOT}."
		die "Install a GNU Classpath JDK (gcj-jdk)"
	fi

	if [[ ${bootstrap} ]] ; then
		local ecj_jar="$(readlink "${EPREFIX}"/usr/share/eclipse-ecj/ecj.jar)"

		# Don't use eclipse-ecj-3.7 #392587
		local ecj_all=( "${EPREFIX}"/usr/share/{eclipse-ecj,ecj-gcj}-* )
		ecj_all=( "${ecj_all[@]/*eclipse-ecj-3.7*/}" )
		if ! has "${ecj_jar%/lib/ecj.jar}" "${ecj_all[@]}"; then
			ecj_jar="${ecj_jar%/lib/ecj.jar}"
			ewarn "${ecj_jar##*/} set as system ecj, can't use for bootstrap"
			ewarn "Found usable: ${ecj_all[@]##*/}"
			ewarn "using ${ecj_all##*/} instead"
			ecj_jar="${ecj_all}"/lib/ecj.jar
		fi

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
			if use cacao; then
				extra_vms="${extra_vms},cacao"
				config="${config} --with-cacao-src-zip=${DISTDIR}/${CACAO_TARBALL}"
			fi
			if use jamvm; then
				extra_vms="${extra_vms},jamvm"
				config="${config} --with-jamvm-src-zip=${DISTDIR}/${JAMVM_TARBALL}"
			fi
			if [[ ${extra_vms} ]]; then
				config="${config} --with-additional-vms=${extra_vms#,}"
			fi
		elif use cacao || use jamvm; then
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

	if use hs20 ; then
		config="${config} --with-hotspot-build=hs20 --with-hotspot-src-zip=${DISTDIR}/${HOTSPOT_TARBALL}"
	fi

	unset JAVA_HOME JDK_HOME CLASSPATH JAVAC JAVACFLAGS

	econf ${config} \
		--with-openjdk-src-zip="${DISTDIR}/${OPENJDK_TARBALL}" \
		--with-jaxp-drop-zip="${DISTDIR}/${JAXP_TARBALL}" \
		--with-jaxws-drop-zip="${DISTDIR}/${JAXWS_TARBALL}" \
		--with-jaf-drop-zip="${DISTDIR}/${JAF_TARBALL}" \
		--with-jdk-home="$(java-config -O)" \
		--with-abs-install-dir=/usr/$(get_libdir)/icedtea${SLOT} \
		$(use_enable !debug optimizations) \
		$(use_enable doc docs) \
		$(use_enable nio2) \
		$(use_enable nss) \
		$(use_enable pulseaudio pulse-java) \
		$(use_enable systemtap)
}

src_compile() {
	# Newer versions of Gentoo's ant add
	# an environment variable so it works properly...
	export ANT_RESPECT_JAVA_HOME=TRUE

	# ant -diagnostics in Ant 1.8.0 fails without xerces-2 and xalan
	# We try to load the least that's needed to avoid possible classpath collisions
	export ANT_TASKS="xerces-2 xalan ant-nodeps"

	# Build and pax mark the intermidiate jdk. #389751
	if host-is-pax; then
		emake icedtea-ecj
		java-vm_set-pax-markings openjdk.build-ecj/j2sdk-image
	fi

	emake
}

src_install() {
	local dest="/usr/$(get_libdir)/icedtea${SLOT}"
	local ddest="${ED}/${dest}"
	dodir "${dest}"

	dodoc README NEWS AUTHORS THANKYOU
	dosym /usr/share/doc/${PF} /usr/share/doc/${PN}${SLOT}

	cd openjdk.build/j2sdk-image || die

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

	# Bug 390663
	cp "${FILESDIR}"/fontconfig.Gentoo.properties.src "${T}"/fontconfig.Gentoo.properties || die
	eprefixify "${T}"/fontconfig.Gentoo.properties
	insinto "${dest}"/jre/lib
	doins "${T}"/fontconfig.Gentoo.properties

	set_java_env "${FILESDIR}/icedtea.env"
}

pkg_preinst() {
	if has_version "<=dev-java/icedtea-6.1.10.4:${SLOT}"; then
		# portage would preserve the symlink otherwise, related to bug #384397
		rm -f "${EROOT}/usr/lib/jvm/icedtea6"
		elog "To unify the layout and simplify scripts, the identifier of Icedtea-6*"
		elog "has changed from 'icedtea6' to 'icedtea-6' starting from version 6.1.10.4-r1"
		elog "If you had icedtea6 as system VM, the change should be automatic, however"
		elog "build VM settings in /etc/java-config-2/build/jdk.conf are not changed"
		elog "and the same holds for any user VM settings. Sorry for the inconvenience."
	fi
}
