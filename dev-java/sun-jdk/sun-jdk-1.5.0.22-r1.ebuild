# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/sun-jdk/sun-jdk-1.5.0.22-r1.ebuild,v 1.1 2010/03/31 16:11:10 caster Exp $

JAVA_VM_BUILD_ONLY="TRUE"

inherit versionator java-vm-2 eutils pax-utils

UPDATE="$(get_version_component_range 4)"
UPDATE="${UPDATE#0}"
MY_PV="$(get_version_component_range 2-3)u${UPDATE}"

X86_AT="jdk-${MY_PV}-dlj-linux-i586.bin"
AMD64_AT="jdk-${MY_PV}-dlj-linux-amd64.bin"

DESCRIPTION="Sun's Java SE Development Kit"
HOMEPAGE="http://java.sun.com/j2se/1.5.0/"
SRC_URI="x86? ( http://download.java.net/dlj/binaries/${X86_AT} )
		amd64? ( http://download.java.net/dlj/binaries/${AMD64_AT} )"
SLOT="1.5"
LICENSE="dlj-1.1"
KEYWORDS="~amd64 ~x86"
RESTRICT="strip"
IUSE="X alsa doc examples jce nsplugin odbc"

QA_TEXTRELS_x86="opt/${P}/jre/lib/i386/motif21/libmawt.so opt/${P}/jre/lib/i386/libdeploy.so"
QA_DT_HASH="opt/${P}/.*"

DEPEND="jce? ( =dev-java/sun-jce-bin-1.5.0* )"
RDEPEND="sys-libs/glibc
	alsa? ( media-libs/alsa-lib )
	doc? ( =dev-java/java-sdk-docs-1.5.0* )
	X? (
			x11-libs/libXext
			x11-libs/libXi
			x11-libs/libXp
			x11-libs/libXtst
			x11-libs/libXt
			x11-libs/libX11
	)
	odbc? ( dev-db/unixODBC )"

S="${WORKDIR}/jdk$(replace_version_separator 3 _)"

JAVA_PROVIDE="jdbc-stdext jdbc-rowset"

src_unpack() {
	sh "${DISTDIR}/${A}" --accept-license --unpack || die "Failed to unpack"
}

src_compile() {
	# Set PaX markings on all JDK/JRE executables to allow code-generation on
	# the heap by the JIT compiler. This needs to be done before CDS - #215225
	pax-mark m $(list-paxables "${S}"{,/jre}/bin/*)

	# see bug #207282
	if use x86; then
		einfo "Creating the Class Data Sharing archives"
		"${S}"/bin/java -client -Xshare:dump || die
	fi
}

src_install() {
	local dirs="bin include jre lib man"

	dodir /opt/${P}

	cp -pPR ${dirs} "${D}/opt/${P}/" || die "failed to copy"
	dodoc COPYRIGHT README.html || die
	dohtml README.html || die

	cp -pP src.zip "${D}/opt/${P}/" || die

	if use examples; then
		cp -pPR demo "${D}/opt/${P}/" || die
		cp -pPR sample "${D}/opt/${P}/" || die
	fi

	if use jce; then
		cd "${D}"/opt/${P}/jre/lib/security || die
		dodir /opt/${P}/jre/lib/security/strong-jce
		mv "${D}"/opt/${P}/jre/lib/security/US_export_policy.jar \
			"${D}"/opt/${P}/jre/lib/security/strong-jce || die
		mv "${D}"/opt/${P}/jre/lib/security/local_policy.jar \
			"${D}"/opt/${P}/jre/lib/security/strong-jce || die
		local jcedir="/opt/sun-jce-bin-1.5.0/jre/lib/security/unlimited-jce/"
		dosym ${jcedir}/US_export_policy.jar \
			/opt/${P}/jre/lib/security/ || die
		dosym ${jcedir}/local_policy.jar \
			/opt/${P}/jre/lib/security/ || die
	fi

	if use nsplugin; then
		local plugin_dir="ns7-gcc29"
		if has_version '>=sys-devel/gcc-3' ; then
			plugin_dir="ns7"
		fi

		if use x86 ; then
			install_mozilla_plugin /opt/${P}/jre/plugin/i386/$plugin_dir/libjavaplugin_oji.so
		else
			eerror "No plugin available for amd64 arch"
		fi
	fi

	# create dir for system preferences
	dodir /opt/${P}/jre/.systemPrefs
	# Create files used as storage for system preferences.
	touch "${D}"/opt/${P}/jre/.systemPrefs/.system.lock
	chmod 644 "${D}"/opt/${P}/jre/.systemPrefs/.system.lock
	touch "${D}"/opt/${P}/jre/.systemPrefs/.systemRootModFile
	chmod 644 "${D}"/opt/${P}/jre/.systemPrefs/.systemRootModFile

	# install control panel for Gnome/KDE
	if [[ -f ${D}/opt/${P}/jre/plugin/desktop/sun_java.desktop ]]; then
		sed -e "s/INSTALL_DIR\/JRE_NAME_VERSION/\/opt\/${P}\/jre/" \
			-e "s/\(Name=Java\)/\1 Control Panel ${SLOT}/" \
			"${D}"/opt/${P}/jre/plugin/desktop/sun_java.desktop > \
			"${T}"/sun_java-${SLOT}.desktop \
			|| die "Failed to sed .desktop file"

		domenu "${T}"/sun_java-${SLOT}.desktop
	fi

	# bug #56444
	insinto /opt/${P}/jre/lib/
	newins "${FILESDIR}"/fontconfig.Gentoo.properties fontconfig.properties

	set_java_env
	java-vm_revdep-mask
}

pkg_postinst() {
	# Set as default VM if none exists
	java-vm-2_pkg_postinst

	elog "The epoll-based implementation of SelectorProvider is not selected by"
	elog "default."
	elog "Use java -Djava.nio.channels.spi.SelectorProvider=sun.nio.ch.EPollSelectorProvider"
	elog ""
}
