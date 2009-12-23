# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/blackdown-jdk/blackdown-jdk-1.4.2.03-r16.ebuild,v 1.3 2008/12/21 16:12:48 serkan Exp $

JAVA_SUPPORTS_GENERATION_1="true"
JAVA_VM_BUILD_ONLY="TRUE"
inherit java-vm-2 versionator pax-utils

JREV=$(get_version_component_range 4- )
JV=$(get_version_component_range 1-3 )
J_URI="mirror://blackdown.org/JDK-${JV}"

DESCRIPTION="Blackdown Java Development Kit"
SRC_URI="amd64? ( ${J_URI}/amd64/${JREV}/j2sdk-${JV}-${JREV}-linux-amd64.bin )
	x86? ( ${J_URI}/i386/${JREV}/j2sdk-${JV}-${JREV}-linux-i586.bin )"

HOMEPAGE="http://www.blackdown.org"

SLOT="1.4.2"
LICENSE="sun-bcla-java-vm"
KEYWORDS="-* ~amd64 ~x86"
IUSE="X alsa doc examples nsplugin odbc"

DEPEND=""
RDEPEND="odbc? ( dev-db/unixODBC )
	alsa? ( media-libs/alsa-lib )
	x86? ( net-libs/libnet )
	sys-libs/glibc
	X? (
		x11-libs/libICE
		x11-libs/libSM
		x11-libs/libXext
		x11-libs/libXi
		x11-libs/libXp
		x11-libs/libXtst
		x11-libs/libXt
		x11-libs/libX11
	)
	doc? ( =dev-java/java-sdk-docs-1.4.2* )"

JAVA_PROVIDE="jdbc-stdext"

S="${WORKDIR}/j2sdk${JV}"

RESTRICT="strip"

# Extract the 'skip' value (offset of tarball) we should pass to tail
get_offset() {
	[ ! -f "$1" ] && return

	local offset=$(gawk '
		/^[[:space:]]*skip[[:space:]]*=/ {
			sub(/^[[:space:]]*skip[[:space:]]*=/, "")
			SKIP = $0
		}
		END { print SKIP }' $1)

	echo $offset
}

src_unpack() {
	local offset=$(get_offset ${DISTDIR}/${A})

	if [ -z "${offset}" ] ; then
		die "Failed to get offset of tarball!"
	fi

	echo ">>> Unpacking ${A}..."
	tail -n +${offset} "${DISTDIR}"/${A} | tar --no-same-owner -jxpf - || die
}

unpack_jars() {
	# New to 1.4.2
	local PACKED_JARS="lib/tools.jar jre/lib/rt.jar jre/lib/jsse.jar jre/lib/charsets.jar jre/lib/ext/localedata.jar jre/lib/plugin.jar jre/javaws/javaws.jar"
	local JAVAHOME="${D}/opt/${P}"
	local UNPACK_CMD=""
	if [ -f "$JAVAHOME/lib/unpack" ]; then
		UNPACK_CMD="$JAVAHOME/lib/unpack"
		chmod +x "$UNPACK_CMD"
		packerror=""
		sed -i 's#/tmp/unpack.log#/dev/null\x00\x00\x00\x00\x00\x00#g' $UNPACK_CMD
		for i in $PACKED_JARS; do
			if [ -f "$JAVAHOME/`dirname $i`/`basename $i .jar`.pack" ]; then
				einfo "Creating ${JAVAHOME}/${i}\n"
				"$UNPACK_CMD" "$JAVAHOME/`dirname $i`/`basename $i .jar`.pack" "$JAVAHOME/$i"
				if [ ! -f "$JAVAHOME/$i" ]; then
					ewarn "Failed to unpack jar files ${i}. Please refer\n"
					ewarn "to the Troubleshooting section of the Installation\n"
					ewarn "Instructions on the download page for more information.n"
					packerror="1"
				fi
				rm -f "$JAVAHOME/`dirname $i`/`basename $i .jar`.pack"
			fi
		done
	fi
	rm -f "$UNPACK_CMD"
}

src_install() {
	typeset platform

	# Set PaX markings on all JDK/JRE executables to allow code-generation on
	# the heap by the JIT compiler.
	pax-mark m $(list-paxables "${S}"{,/jre}/bin/*)

	dodir /opt/${P}

	cp -pPR "${S}"/{bin,jre,lib,man,include} "${D}"/opt/${P} || die "failed to copy"

	dodir /opt/${P}/share/
	if use examples; then
		cp -pPR "${S}"/demo "${D}"/opt/${P}/share/ || die "failed to copy"
	fi

	cp -pPR "${S}"/src.zip "${D}/opt/${P}/" || die "failed to copy"
	dosym "../src.zip" /opt/${P}/share || die "failed dosym"

	dodoc README
	dohtml README.html

	if use nsplugin; then
		case ${ARCH} in
			amd64) platform="amd64" ;;
			x86) platform="i386" ;;
			ppc) platform="ppc" ;;
			sparc*) platform="sparc" ;;
		esac

		install_mozilla_plugin /opt/${P}/jre/plugin/${platform}/mozilla/libjavaplugin_oji.so
	else
		rm -f "${D}"/opt/${P}/jre/plugin/${platform}/mozilla/libjavaplugin_oji.so
	fi

	find "${D}"/opt/${P} -type f -name "*.so" -exec chmod +x \{\} \;

	sed -i "s/standard symbols l/symbol/g" "${D}"/opt/${P}/jre/lib/font.properties

	# install env into /etc/env.d
	set_java_env
	java-vm_revdep-mask

	# Fix for bug 26629
	if [[ "${PROFILE_ARCH}" == "sparc64" ]]; then
		dosym /opt/${P}/jre/lib/sparc /opt/${P}/jre/lib/sparc64
	fi

	unpack_jars
}

pkg_postinst() {
	# Set as default system VM if none exists
	java-vm-2_pkg_postinst

	elog ""
	elog "Starting with 1.4.0.03-r16 demos are installed only with USE=examples"
	elog ""
	elog "Starting with 1.4.0.03-r16 the src.jar is installed to the standard"
	elog "location. It is still symlinked to the old location (/opt/${P}/share)"
	elog "but it will be removed if there will ever be a version bump."
	elog "See https://bugs.gentoo.org/show_bug.cgi?id=2241"
	elog "for more details."
}
