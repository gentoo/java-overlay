# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/sun-jdk/sun-jdk-1.5.0.09-r1.ebuild,v 1.1 2006/11/22 23:25:15 caster Exp $

inherit java-vm-2 eutils pax-utils

MY_PVL=${PV%.*}_${PV##*.}
MY_PVA=${PV//./_}
S="${WORKDIR}/jdk${MY_PVL}"

X86_AT="jdk-${MY_PVA}-dlj-linux-i586.bin"
AMD64_AT="jdk-${MY_PVA}-dlj-linux-amd64.bin"
if use x86; then
	At=${X86_AT}
elif use amd64; then
	At=${AMD64_AT}
fi
DESCRIPTION="Sun's J2SE Development Kit, version ${PV}"
HOMEPAGE="http://java.sun.com/j2se/1.5.0/"
SRC_URI="x86? ( http://download.java.net/dlj/binaries/${X86_AT} )
		amd64? ( http://download.java.net/dlj/binaries/${AMD64_AT} )"
SLOT="1.5"
LICENSE="dlj-1.1"
KEYWORDS="-* ~amd64 ~x86"
RESTRICT="nostrip"
IUSE="X alsa doc examples jce nsplugin"

QA_TEXTRELS_x86="opt/${P}/jre/lib/i386/motif21/libmawt.so opt/${P}/jre/lib/i386/libdeploy.so"

DEPEND="
	doc? ( =dev-java/java-sdk-docs-1.5.0* )
	jce? ( =dev-java/sun-jce-bin-1.5.0* )"

RDEPEND="
	sys-libs/glibc
	alsa? ( media-libs/alsa-lib )
	doc? ( =dev-java/java-sdk-docs-1.5.0* )
	X? ( || ( ( x11-libs/libX11
				x11-libs/libXext
				x11-libs/libXi
				x11-libs/libXp
				x11-libs/libXt
				x11-libs/libXtst
			  )
				virtual/x11
			)
		)"

JAVA_PROVIDE="jdbc-stdext jdbc-rowset"

PACKED_JARS="lib/tools.jar jre/lib/rt.jar jre/lib/jsse.jar jre/lib/charsets.jar jre/lib/ext/localedata.jar jre/lib/plugin.jar jre/lib/javaws.jar jre/lib/deploy.jar"

src_unpack() {
	if [ ! -r ${DISTDIR}/${At} ]; then
		die "cannot read ${At}. Please check the permission and try again."
	fi

	sh ${DISTDIR}/${At} --accept-license --unpack || die "Failed to unpack"
}

src_install() {
	local dirs="bin include jre lib man" files

	# Set PaX markings on all JDK/JRE executables to allow code-generation on
	# the heap by the JIT compiler.
	files=$(file ${S}/bin/* ${S}/jre/bin/* | grep ELF | sed -e 's/:.*$//')
	pax-mark m ${files}

	dodir /opt/${P}

	for i in $dirs ; do
		cp -pPR $i ${D}/opt/${P}/ || die "failed to copy"
	done
	dodoc COPYRIGHT README.html
	dohtml README.html
	dodir /opt/${P}/share/

	cp -pPR src.zip ${D}/opt/${P}/share/

	if use examples; then
		cp -pPR demo ${D}/opt/${P}/share/
		if ( use x86 || use amd64 ); then
			cp -pPR sample ${D}/opt/${P}/share/
		fi
	fi

	if use jce; then
		cd ${D}/opt/${P}/jre/lib/security
		dodir /opt/${P}/jre/lib/security/strong-jce
		mv ${D}/opt/${P}/jre/lib/security/US_export_policy.jar ${D}/opt/${P}/jre/lib/security/strong-jce
		mv ${D}/opt/${P}/jre/lib/security/local_policy.jar ${D}/opt/${P}/jre/lib/security/strong-jce
		dosym /opt/sun-jce-bin-1.5.0/jre/lib/security/unlimited-jce/US_export_policy.jar /opt/${P}/jre/lib/security/
		dosym /opt/sun-jce-bin-1.5.0/jre/lib/security/unlimited-jce/local_policy.jar /opt/${P}/jre/lib/security/
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
	touch ${D}/opt/${P}/jre/.systemPrefs/.system.lock
	chmod 644 ${D}/opt/${P}/jre/.systemPrefs/.system.lock
	touch ${D}/opt/${P}/jre/.systemPrefs/.systemRootModFile
	chmod 644 ${D}/opt/${P}/jre/.systemPrefs/.systemRootModFile

	# install control panel for Gnome/KDE
	sed -e "s/INSTALL_DIR\/JRE_NAME_VERSION/\/opt\/${P}\/jre/" \
		-e "s/\(Name=Java\)/\1 Control Panel ${SLOT}/" \
		${D}/opt/${P}/jre/plugin/desktop/sun_java.desktop > \
		${T}/sun_java-${SLOT}.desktop

	domenu ${T}/sun_java-${SLOT}.desktop

	# bug #56444
	insinto /opt/${P}/jre/lib/
	newins "${FILESDIR}"/fontconfig.Gentoo.properties fontconfig.properties

	set_java_env
}

pkg_postinst() {
	# Set as default VM if none exists
	java-vm-2_pkg_postinst

	if ! use X; then
		local xwarn="virtual/x11 and/or"
	fi

	echo
	ewarn "Some parts of Sun's JDK require ${xwarn} virtual/lpr to be installed."
	ewarn "Be careful which Java libraries you attempt to use."

	echo
	elog " Be careful: ${P}'s Java compiler uses"
	elog " '-source 1.5' as default. Some keywords such as 'enum'"
	elog " are not valid identifiers any more in that mode,"
	elog " which can cause incompatibility with certain sources."

	echo
	elog "Beginning with 1.5.0.10 the hotspot vm can use epoll"
	elog "The epoll-based implementation of SelectorProvider is not selected by"
	elog "default."
	elog "Use java -Djava.nio.channels.spi.SelectorProvider=sun.nio.ch.EPollSelectorProvider"
}
