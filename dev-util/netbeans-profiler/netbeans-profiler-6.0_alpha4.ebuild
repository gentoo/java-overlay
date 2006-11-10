# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

inherit versionator

SLOT="6.0"

MY_PV="$(replace_all_version_separators '_' ${SLOT})"
MY_PVDEV="$(replace_all_version_separators '' ${SLOT})dev"

DESCRIPTION="NetBeans Profiler"
HOMEPAGE="http://profiler.netbeans.org/"
SRC_URI="http://netbeans.org/download/${MY_PV}/m4/200610231500/profiler-${MY_PVDEV}-linux.bin"

LICENSE="SPL"
KEYWORDS="~x86"
IUSE=""

RDEPEND=""
DEPEND="=dev-util/netbeans-${SLOT}*"

src_unpack() {
	# Walk-around: copy installer to working-directory
	cp ${DISTDIR}/profiler-${MY_PVDEV}-linux.bin ${WORKDIR}/
	chmod u+x ${WORKDIR}/profiler-${MY_PVDEV}-linux.bin

	# allow the installer to write stupid files (illusion)
	if [ "${LOGNAME}" = "root" ]; then
		addwrite /root
	else
		addwrite /home/${LOGNAME}
	fi

	# execute installer
	# We must change user HOME dir so the installer does not cause sandbox violation
	${WORKDIR}/profiler-${MY_PVDEV}-linux.bin -silent

	# Walk-around: remove installer again
	rm ${WORKDIR}/profiler-${MY_PVDEV}-linux.bin

	# remove unnecessary uninstall informations
	rm -R ${WORKDIR}/profiler1/_uninst
}


src_install() {
	# install everything into netbeans subfolders
	insinto /usr/share/netbeans-${SLOT}/profiler1
	doins -r ${WORKDIR}/profiler1/*
}

pkg_postinst () {
	einfo "Updating Netbeans ${SLOT} configuration"
	FILE="/usr/share/netbeans-${SLOT}/etc/netbeans.clusters"
	if [ -z "$(grep profiler1 ${FILE})" ]; then
		echo "profiler1" >> ${FILE}
	fi
	FILE="/usr/share/netbeans-${SLOT}/nb${SLOT}/config/productid"
	if [ ! -f ${FILE} ]; then
		echo NB_PROF > ${FILE}
	elif [ -z "$(grep NB_PROF ${FILE})" ]; then
		echo NB_PROF >> ${FILE}
	fi
	eend
}

pkg_postrm() {
	einfo "Updating Netbeans ${SLOT} configuration"
	sed -i -e "s/profiler1//" /usr/share/netbeans-${SLOT}/etc/netbeans.clusters
	sed -i -e "s/NB_PROF//" /usr/share/netbeans-${SLOT}/nb${SLOT}/config/productid
	eend
}
