# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#
# Original Author: fordfrog
# Purpose: Provide unified framework for installing Netbeans 5.5 extra packs
#

ECLASS="netbeans-5.5-pack"
INHERITED="$INHERITED $ECLASS"

IUSE=""
SLOT="5.5"

DEPEND="=dev-util/netbeans-${SLOT}*"
RDEPEND="=dev-util/netbeans-${SLOT}*"

# You can override these variables if needed
MY_PV="$(replace_all_version_separators '_' ${PV})"
MY_P="${PN}-${MY_PV}"
BIN_FILE="${MY_P}-linux.bin"

# Some netbeans packs install all the files into current directory whereas
# some other packs install the files into extra directory (like 'cnd1/<files>').
# If you are creating ebuild for such pack then you must specify the UNPACK_DIR
# so the pack is installed correctly.
UNPACK_DIR="."

NB_DIR="/usr/share/netbeans-${SLOT}"
CLUSTER_FILE="${NB_DIR}/etc/netbeans.clusters"
PRODUCTID_FILE="${NB_DIR}/nb${SLOT}/config/productid"

EXPORT_FUNCTIONS src_unpack src_install pkg_postinst pkg_postrm


# standard src_unpack() for netbeans extra packs
# TODO: it would be better to get rid of addwrite functions (ie move the home to T or
#       something else that would work)
netbeans-5.5-pack_src_unpack() {
	# Walk-around: copy installer to working-directory
	cp ${DISTDIR}/${BIN_FILE} ${WORKDIR}/
	chmod u+x ${WORKDIR}/${BIN_FILE}

	# allow the installer to write stupid files (illusion)
	if [ "${LOGNAME}" = "root" ]; then
		addwrite /root
	else
		addwrite /home/${LOGNAME}
	fi

	# execute installer
	# We must change user HOME dir so the installer does not cause sandbox violation
	${WORKDIR}/${BIN_FILE} -silent

	# Walk-around: remove installer again
	rm ${WORKDIR}/${BIN_FILE}

	# remove unnecessary uninstall informations
	rm -R ${UNPACK_DIR}/_uninst
}


# standard src_install() for netbeans extra packs
netbeans-5.5-pack_src_install() {
	# install everything into netbeans subfolders
	netbeans-5.5-pack_check-cluster
	insinto ${NB_DIR}/${CLUSTER}
	doins -r ${WORKDIR}/${UNPACK_DIR}/*
}


# standard pkg_postinst() for netbeans extra packs
netbeans-5.5-pack_pkg_postinst () {
	einfo "Updating Netbeans ${SLOT} configuration"
	netbeans-5.5-pack_check-cluster
	netbeans-5.5-pack_check-productid

	if [ -z "$(grep ${CLUSTER} ${CLUSTER_FILE})" ]; then
		echo "${CLUSTER}" >> ${CLUSTER_FILE}
	fi

	if [ ! -f ${PRODUCTID_FILE} ]; then
		echo NB_PROF > ${PRODUCTID_FILE}
	elif [ -z "$(grep NB_PROF ${PRODUCTID_FILE})" ]; then
		echo NB_PROF >> ${PRODUCTID_FILE}
	fi
	eend
}


# standard pkg_postrm() for netbeans extra packs
netbeans-5.5-pack_pkg_postrm() {
	einfo "Updating Netbeans ${SLOT} configuration"
	netbeans-5.5-pack_check-cluster
	netbeans-5.5-pack_check-productid
	sed -i -e "s/${CLUSTER}//" ${CLUSTER_FILE}
	sed -i -e "s/${PRODUCTID}//" ${PRODUCTID_FILE}
	eend
}


# check whether CLUSTER variable is set and issues error if it is empty
netbeans-5.5-pack_check-cluster() {
	# CLUSTER must be set
	if [ -z "${CLUSTER}" ]; then
		eerror "CLUSTER variable must be set in the ebuild"
	fi
}


# check whether PRODUCTID variable is set and issues error if it is empty
netbeans-5.5-pack_check-productid() {
	# PRODUCTID must be set
	if [ -z "${PRODUCTID}" ]; then
		eerror "PRODUCTID variable must be set in the ebuild"
	fi
}
