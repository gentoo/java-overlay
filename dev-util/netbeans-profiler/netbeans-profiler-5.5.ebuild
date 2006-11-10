# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

inherit versionator

MY_PV="$(replace_all_version_separators '_' ${PV})"

DESCRIPTION="NetBeans Profiler"
HOMEPAGE="http://profiler.netbeans.org/"
SRC_URI="http://us1.mirror.netbeans.org/download/${MY_PV}/fcs/200610171010/${PN}-${MY_PV}-linux.bin"

LICENSE="SPL"
SLOT="5.5"
KEYWORDS="~x86"
IUSE=""

RDEPEND=""
DEPEND="=dev-util/netbeans-${SLOT}*"

src_unpack() {
	# Walk-around: copy installer to working-directory
	cp ${DISTDIR}/${PN}-${MY_PV}-linux.bin ${WORKDIR}/
	chmod u+x ${WORKDIR}/${PN}-${MY_PV}-linux.bin

	#if [[ -e /root/vpd.properties ]]; then
	#	einfo "The /root/vpd.properties file exists, this can"
	#	einfo "cause big problems."
	#	einfo "If so, please move this for the time of installation!"
	#fi

	# allow the installer to write stupid files (illusion)
	if [ "${LOGNAME}" = "root" ]; then
		addwrite /root
	else
		addwrite /home/${LOGNAME}
	fi

	# execute installer
	# We must change user HOME dir so the installer does not cause sandbox violation
	${WORKDIR}/${PN}-${MY_PV}-linux.bin -silent

	# Walk-around: remove installer again
	rm ${WORKDIR}/${PN}-${MY_PV}-linux.bin

	# remove unnecessary uninstall informations
	rm -R _uninst
}


src_install() {
	# install everything into netbeans subfolders
	insinto /usr/share/netbeans-${SLOT}/profiler1
	doins -r ${WORKDIR}/*
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
