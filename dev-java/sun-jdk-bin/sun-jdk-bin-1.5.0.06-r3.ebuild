# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/sun-jdk/sun-jdk-1.5.0.06-r2.ebuild,v 1.2 2006/03/12 13:31:29 betelgeuse Exp $

inherit java eutils

MY_PVL=${PV%.*}_${PV##*.}
MY_PVA=${PV//./_}
S="${WORKDIR}/jdk${MY_PVL}"
DESCRIPTION="Sun's J2SE Development Kit, version ${PV}"
HOMEPAGE="http://java.sun.com/j2se/1.5.0/"
SLOT="1.5"
LICENSE="dlj-1.1"
KEYWORDS="~x86 ~amd64 -*"
RESTRICT="nostrip stricter"
IUSE="X alsa doc browserplugin nsplugin jce mozilla examples"


DEPEND="sys-apps/sed
	jce? ( dev-java/sun-jce-bin )
	doc? ( =dev-java/java-sdk-docs-1.5.0* )"

RDEPEND="
	alsa? ( media-libs/alsa-lib )
	doc? ( =dev-java/java-sdk-docs-1.5.0* )
	X? ( || ( ( x11-libs/libICE
				x11-libs/libSM
		 		x11-libs/libX11
				x11-libs/libXau
				x11-libs/libXdmcp
				x11-libs/libXext
				x11-libs/libXi
				x11-libs/libXp
				x11-libs/libXt
				x11-libs/libXtst
			  )
				virtual/x11
			)
		)"

PROVIDE="virtual/jre
	virtual/jdk"

PACKED_JARS="lib/tools.jar jre/lib/rt.jar jre/lib/jsse.jar jre/lib/charsets.jar jre/lib/ext/localedata.jar jre/lib/plugin.jar jre/lib/javaws.jar jre/lib/deploy.jar"

# this is needed for proper operating under a PaX kernel without activated grsecurity acl
CHPAX_CONSERVATIVE_FLAGS="pemsv"

src_unpack() {

#        #Search for the ELF Header
        testExp=`echo -e "\105\114\106"`
        startAt=`grep -aonm 1 ${testExp}  ${DISTDIR}/${A} | cut -d: -f1`
        tail -n +${startAt} ${DISTDIR}/${A} > install.sfx
        chmod +x install.sfx
        ./install.sfx || die
        rm install.sfx

        if [ -f ${S}/bin/unpack200 ]; then
                UNPACK_CMD=${S}/bin/unpack200
                chmod +x $UNPACK_CMD
                sed -i 's#/tmp/unpack.log#/dev/null\x00\x00\x00\x00\x00\x00#g' $UNPACK_CMD
                for i in $PACKED_JARS; do
                        PACK_FILE=${S}/`dirname $i`/`basename $i .jar`.pack
                        if [ -f ${PACK_FILE} ]; then
                                echo "  unpacking: $i"
                                $UNPACK_CMD ${PACK_FILE} ${S}/$i
                                rm -f ${PACK_FILE}
                        fi
                done
                rm -f ${UNPACK_CMD}
        else
                die "unpack not found"
        fi

	${S}/bin/java -client -Xshare:dump
}

src_install() {
	dodir /opt/${P}

	for i in bin include jre lib man; do
		cp -pPR $i ${D}/opt/${P}/ || die "failed to copy ${i}"
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
	
	if use nsplugin ||       # global useflag for netscape-compat plugins
	   use browserplugin ||  # deprecated but honor for now
	   use mozilla; then     # wrong but used to honor it
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
	dodir /opt/${P}/.systemPrefs

	# install control panel for Gnome/KDE
	sed -e "s/INSTALL_DIR\/JRE_NAME_VERSION/\/opt\/${P}\/jre/" \
		-e "s/\(Name=Java\)/\1 Control Panel/" \
		${D}/opt/${P}/jre/plugin/desktop/sun_java.desktop > \
		${T}/sun_java.desktop

	domenu ${T}/sun_java.desktop

	use !alsa && java_remove-libjsoundalsa /opt/${P}/jre/

	set_java_env ${FILESDIR}/${VMHANDLE}

	fix-i386-dir /opt/${P}/jre/lib/
}

pkg_postinst() {
	# Create files used as storage for system preferences.
	PREFS_LOCATION=/opt/${P}/jre
	mkdir -p ${PREFS_LOCATION}/.systemPrefs
	if [ ! -f ${PREFS_LOCATION}/.systemPrefs/.system.lock ] ; then
		touch $PREFS_LOCATION/.systemPrefs/.system.lock
		chmod 644 $PREFS_LOCATION/.systemPrefs/.system.lock
	fi
	if [ ! -f $PREFS_LOCATION/.systemPrefs/.systemRootModFile ] ; then
		touch $PREFS_LOCATION/.systemPrefs/.systemRootModFile
		chmod 644 $PREFS_LOCATION/.systemPrefs/.systemRootModFile
	fi

	# Set as default VM if none exists
	java_pkg_postinst

	#Show info about netscape
	if has_version '>=www-client/netscape-navigator-4.79-r1' || has_version '>=www-client/netscape-communicator-4.79-r1' ; then
		echo
		einfo "If you want to install the plugin for Netscape 4.x, type"
		einfo
		einfo "   cd /usr/lib/nsbrowser/plugins/"
		einfo "   ln -sf /opt/${P}/jre/plugin/i386/ns4/libjavaplugin.so"
	fi

	# if chpax is on the target system, set the appropriate PaX flags
	# this will not hurt the binary, it modifies only unused ELF bits
	# but may confuse things like AV scanners and automatic tripwire
	if has_version sys-apps/chpax
	then
		echo
		einfo "setting up conservative PaX flags for jar, javac and java"

		for paxkills in "jar" "javac" "java" "javah" "javadoc"
		do
			chpax -${CHPAX_CONSERVATIVE_FLAGS} /opt/${P}/bin/$paxkills
		done

		# /opt/$VM/jre/bin/java_vm
		chpax -${CHPAX_CONSERVATIVE_FLAGS} /opt/${P}/jre/bin/java_vm

		einfo "you should have seen lots of chpax output above now"
		ewarn "make sure the grsec ACL contains those entries also"
		ewarn "because enabling it will override the chpax setting"
		ewarn "on the physical files - help for PaX and grsecurity"
		ewarn "can be given by #gentoo-hardened + hardened@gentoo.org"
	fi

	if ! use X; then
		local xwarn="virtual/x11 and/or"
	fi

	echo
	ewarn "Some parts of Sun's JDK require ${xwarn} virtual/lpr to be installed."
	ewarn "Be careful which Java libraries you attempt to use."

	echo
	einfo " Be careful: ${P}'s Java compiler uses"
	einfo " '-source 1.5' as default. Some keywords such as 'enum'"
	einfo " are not valid identifiers any more in that mode,"
	einfo " which can cause incompatibility with certain sources."

	if ! use nsplugin && ( use browserplugin || use mozilla ); then
		echo
		ewarn "The 'browserplugin' and 'mozilla' useflags will not be honored in"
		ewarn "future jdk/jre ebuilds for plugin installation.  Please"
		ewarn "update your USE to include 'nsplugin'."
	fi
}
