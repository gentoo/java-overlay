# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/sun-jdk/sun-jdk-1.5.0.05.ebuild,v 1.2 2005/10/10 16:23:12 betelgeuse Exp $

inherit java-vm-2 eutils

MY_PV=${PV/_beta*/}
MY_PVL=${MY_PV%.*}_${MY_PV##*.}
MY_PVA=${MY_PV//./_}
ALPHA=${PV#*_alpha}
DATE="20_mar_2007"
MY_RPV=${MY_PV%.*}


BASE_URL="http://download.java.net/jdk7/binaries/"
x86file="jdk-7-ea-bin-b${ALPHA}-linux-i586-${DATE}.bin"
amd64file="jdk-7-ea-bin-b${ALPHA}-linux-amd64-${DATE}.bin"

if use x86; then
	At=${x86file}
elif use amd64; then
	At=${amd64file}
fi

S="${WORKDIR}/jdk${MY_RPV}"
DESCRIPTION="Sun's Java Development Kit"
HOMEPAGE="https://jdk7.dev.java.net/"
SRC_URI="x86? ( ${BASE_URL}/$x86file ) amd64? ( ${BASE_URL}/$amd64file )"
SLOT="1.7"
LICENSE="sun-prerelease-jdk7"
KEYWORDS="~amd64 ~x86"
RESTRICT="nostrip fetch"
IUSE="doc nsplugin examples"

DEPEND="sys-apps/sed"

RDEPEND="x86? ( sys-libs/lib-compat )
	doc? ( =dev-java/java-sdk-docs-1.6.0* )"

JAVA_PROVIDE="jdbc-stdext jdbc-rowset"

PACKED_JARS="lib/tools.jar jre/lib/rt.jar jre/lib/jsse.jar jre/lib/charsets.jar jre/lib/ext/localedata.jar jre/lib/plugin.jar jre/lib/javaws.jar jre/lib/deploy.jar"

# this is needed for proper operating under a PaX kernel without activated grsecurity acl
CHPAX_CONSERVATIVE_FLAGS="pemsv"

QA_TEXTRELS_x86="opt/${P}/jre/lib/i386/server/libjvm.so
	opt/${P}/jre/lib/i386/client/libjvm.so
	opt/${P}/jre/lib/i386/motif21/libmawt.so
	opt/${P}/jre/lib/i386/libdeploy.so"

pkg_nofetch() {
	local myfile
	#initialisation
	myfile=${x86file}
	if use x86; then
		myfile=${x86file} 
	elif use amd64; then
		myfile=${amd64file} 
	fi

	einfo "Please download:"
	einfo "${myfile} from ${BASE_URL}${myfile}"
	einfo "Then place it in ${DISTDIR}"
	einfo "tip: wget ${BASE_URL}${myfile} -O ${DISTDIR}/${myfile}"

	ewarn "By downloading and installing, you are agreeing to the terms"
	ewarn "of Sun's prerelease license."
}

src_unpack() {
	# Do a little voodoo to extract the distfile
	# Find the ELF in the script
	testExp=$'\105\114\106'
	startAt=$(grep -aonm 1 ${testExp}  ${DISTDIR}/${At} | cut -d: -f1)
	# Extract and run it
	tail -n +${startAt} ${DISTDIR}/${At} > install.sfx
	chmod +x install.sfx
	./install.sfx >/dev/null || die
	rm install.sfx

	if [ -f ${S}/bin/unpack200 ]; then
		UNPACK_CMD=${S}/bin/unpack200
		chmod +x $UNPACK_CMD
		sed -i 's#/tmp/unpack.log#/dev/null\x00\x00\x00\x00\x00\x00#g' $UNPACK_CMD
		for i in $PACKED_JARS; do
			PACK_FILE=${S}/$(dirname $i)/$(basename $i .jar).pack
			if [ -f ${PACK_FILE} ]; then
				echo "	unpacking: $i"
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
	local dirs="bin include jre lib man"
	dodir /opt/${P}

	for i in $dirs ; do
		cp -pPR $i ${D}/opt/${P}/ || die "failed to copy"
	done
	dodoc COPYRIGHT LICENSE README.html
	dohtml README.html
	dodir /opt/${P}/share/

	if use examples; then
		cp -pPR demo sample ${D}/opt/${P}/share/
	fi
	cp -pPR src.zip ${D}/opt/${P}/share/


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
		-e "s/\(Name=Java\)/\1 Control Panel/" \
		${D}/opt/${P}/jre/plugin/desktop/sun_java.desktop > \
		${T}/sun_java-${SLOT}.desktop

	domenu ${T}/sun_java-${SLOT}.desktop

	set_java_env
}

pkg_postinst() {
	# Set as default VM if none exists
	java-vm-2_pkg_postinst

	# if chpax is on the target system, set the appropriate PaX flags
	# this will not hurt the binary, it modifies only unused ELF bits
	# but may confuse things like AV scanners and automatic tripwire
	if has_version sys-apps/chpax; then
		echo
		einfo "setting up conservative PaX flags for jar, javac and java"

		for paxkills in "jar" "javac" "java" "javah" "javadoc"; do
			chpax -${CHPAX_CONSERVATIVE_FLAGS} /opt/${P}/bin/$paxkills
		done

		chpax -${CHPAX_CONSERVATIVE_FLAGS} /opt/${P}/jre/bin/java_vm

		einfo "you should have seen lots of chpax output above now"
		ewarn "make sure the grsec ACL contains those entries also"
		ewarn "because enabling it will override the chpax setting"
		ewarn "on the physical files - help for PaX and grsecurity"
		ewarn "can be given by #gentoo-hardened + hardened@gentoo.org"
	fi

	echo
	ewarn "Some parts of Sun's JDK require virtual/x11 and/or virtual/lpr to be installed."
	ewarn "Be careful which Java libraries you attempt to use."

	echo
	einfo " Be careful: ${P}'s Java compiler uses"
	einfo " '-source 1.7' as default. This means that some keywords "
	einfo " such as 'enum' are not valid identifiers any more in that mode,"
	einfo " which can cause incompatibility with certain sources."
	einfo " Additionally, some API changes may cause some breakages."
}
