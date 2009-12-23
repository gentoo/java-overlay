# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/emul-linux-x86-java/emul-linux-x86-java-1.4.2.19.ebuild,v 1.4 2009/05/29 20:34:25 caster Exp $

JAVA_VM_BUILD_ONLY="TRUE"

inherit multilib eutils pax-utils java-vm-2

MY_PV=${PV%.*}_${PV##*.}
MY_PV2=${PV//./_}
MY_PN=j2re
At="${MY_PN}-${MY_PV2}-linux-i586.bin"
S="${WORKDIR}/j2re${MY_PV}"
DESCRIPTION="Sun's Java SE Runtime Environment (32bit)"
HOMEPAGE="http://java.sun.com/j2se/1.4.2/"
SRC_URI=${At}
SLOT="1.4"
LICENSE="sun-bcla-java-vm-1.4.2"
KEYWORDS="-* ~amd64"
# pre stripped
RESTRICT="fetch strip"
IUSE="X alsa nsplugin"

DEPEND=""

RDEPEND="alsa? ( app-emulation/emul-linux-x86-soundlibs )
	X? ( app-emulation/emul-linux-x86-xlibs )"

DL_PREFIX="https://cds.sun.com/is-bin/INTERSHOP.enfinity/WFS/CDS-CDS_Developer-Site/en_US/-/USD/ViewProductDetail-Start?ProductRef="
DOWNLOAD_URL="${DL_PREFIX}${MY_PN}-${MY_PV}-oth-JPR@CDS-CDS_Developer"

QA_TEXTRELS_amd64="opt/${P}/lib/i386/libawt.so
	opt/${P}/plugin/i386/ns4/libjavaplugin.so
	opt/${P}/plugin/i386/ns610/libjavaplugin_oji.so
	opt/${P}/plugin/i386/ns610-gcc32/libjavaplugin_oji.so"
QA_DT_HASH="opt/${P}/.*"

pkg_nofetch() {
	einfo "Please download ${At} from:"
	einfo ${DOWNLOAD_URL}
	einfo "and move it to ${DISTDIR}"
}

src_unpack() {
	if [ ! -r "${DISTDIR}"/${At} ]; then
		eerror "cannot read ${At}. Please check the permission and try again."
		die
	fi
	#Search for the ELF Header
	testExp=$(echo -e '\0177\0105\0114\0106\0001\0001\0001')
	startAt=`grep -aonm 1 ${testExp}  ${DISTDIR}/${At} | cut -d: -f1`
	tail -n +${startAt} "${DISTDIR}"/${At} > install.sfx
	chmod +x install.sfx
	./install.sfx || die
	rm install.sfx

	if [ -f "${S}"/lib/unpack ]; then
		UNPACK_CMD="${S}"/lib/unpack
		chmod +x $UNPACK_CMD
		sed -i 's#/tmp/unpack.log#/dev/null\x00\x00\x00\x00\x00\x00#g' $UNPACK_CMD
		local PACKED_JARS="lib/rt.jar lib/jsse.jar lib/charsets.jar \
			lib/ext/localedata.jar lib/plugin.jar javaws/javaws.jar"
		for i in $PACKED_JARS; do
			PACK_FILE=${S}/`dirname $i`/`basename $i .jar`.pack
			if [ -f ${PACK_FILE} ]; then
				echo "	unpacking: $i"
				$UNPACK_CMD ${PACK_FILE} "${S}"/$i
				rm -f ${PACK_FILE}
			fi
		done
	fi
}

src_install() {
	local dirs="bin lib man javaws plugin"
	dodir /opt/${P}

	cp -pPR ${dirs} "${D}/opt/${P}/"

	pax-mark srpm $(list-paxables "${D}"/opt/${P}/bin/*)

	dodoc CHANGES COPYRIGHT README THIRDPARTYLICENSEREADME.txt || die
	dohtml Welcome.html ControlPanel.html || die

	if use nsplugin; then
		local plugin_dir="ns610"
		if has_version '>=sys-devel/gcc-3.2' ; then
			plugin_dir="ns610-gcc32"
		fi
		install_mozilla_plugin /opt/${P}/plugin/i386/$plugin_dir/libjavaplugin_oji.so
	fi

	# bug #147259
	dosym ../javaws/javaws /opt/${P}/bin/javaws

	# create dir for system preferences
	dodir /opt/${P}/.systemPrefs

	# create dir for system preferences
	dodir /opt/${P}/.systemPrefs
	# Create files used as storage for system preferences.
	touch "${D}/opt/${P}/.systemPrefs/.system.lock"
	chmod 644 "${D}/opt/${P}/.systemPrefs/.system.lock"
	touch "${D}/opt/${P}/.systemPrefs/.systemRootModFile"
	chmod 644 "${D}/opt/${P}/.systemPrefs/.systemRootModFile"

	# FIXME figure out how to handle the control pannel conflict with
	# sun-jdk-bin

	# install control panel for Gnome/KDE
#	sed -e "s/INSTALL_DIR\/JRE_NAME_VERSION/\/opt\/${P}/" \
#		-e "s/\(Name=Java\)/\1 Control Panel/" \
#		"${D}/opt/${P}/plugin/desktop/sun_java.desktop" > \
#		"${T}/sun_java-jre.desktop"
#	domenu "${T}/sun_java-jre.desktop"

	set_java_env
	java-vm_revdep-mask
}
