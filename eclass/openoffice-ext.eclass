# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

ECLASS="openoffice-ext"
INHERITED="$INHERITED $ECLASS"

inherit eutils multilib

# list of extentions
# OOO_EXTENSIONS="" 

OOO_ROOT_DIR="/usr/$(get_libdir)/openoffice"
OOO_PROGRAM_DIR="${OOO_ROOT_DIR}/program"
UNOPKG="${OOO_PROGRAM_DIR}/unopkg"
OOO_EXT_DIR="${OOO_ROOT_DIR}/share/extension/install"
OPENOFFICE_EXT_OPT_USE=${OPENOFFICE_EXT_OPT_USE:-openoffice}

add_extension() {
	ebegin "Adding extension $1"
	INSTDIR=$(mktemp -d --tmpdir=${T})
	${UNOPKG} add --shared $1 \
	"-env:UserInstallation=file:///${INSTDIR}" \
	"-env:JFW_PLUGIN_DO_NOT_CHECK_ACCESSIBILITY=1"
	if [ -n ${INSTDIR} ]; then rm -rf ${INSTDIR}; fi
	eend
}

flush_unopkg_cache() {
	${UNOPKG} list --shared > /dev/null 2>&1
}

remove_extension() {
	if ${UNOPKG} list --shared $1 >/dev/null; then
		ebegin "Removing extension $1"
		INSTDIR=$(mktemp -d --tmpdir=${T})
		${UNOPKG} remove --shared $1 \
		"-env:UserInstallation=file://${INSTDIR}" \
		"-env:JFW_PLUGIN_DO_NOT_CHECK_ACCESSIBILITY=1"
		if [ -n ${INSTDIR} ]; then rm -rf ${INSTDIR}; fi
    		eend
		flush_unopkg_cache
	fi
}

_openoffice-utils_src_install() {
	cd "${S}" || die
	insinto ${OOO_EXT_DIR}
	for i in ${OOO_EXTENSIONS}
	do
		doins ${i} || die "doins failed."
	done
}

_openoffice-utils_pkg_postinst() {
	for i in ${OOO_EXTENSIONS}
	do
		add_extension ${OOO_EXT_DIR}/${i}
	done

}

_openoffice-utils_pkg_prerm() {
	for i in ${OOO_EXTENSIONS}
	do
		remove_extension ${i}
	done
}

_openoffice-ext_check_use() {
	return $(has ${OPENOFFICE_EXT_OPT_USE} "${IUSE}")
}

if _openoffice-ext_check_use; then
	DEPEND="${OPENOFFICE_EXT_OPT_USE}? ( >=virtual/ooo-3.0 )"
	RDEPEND="${OPENOFFICE_EXT_OPT_USE}? ( >=virtual/ooo-3.0 )"
else
	DEPEND=">=virtual/ooo-3.0"
	RDEPEND=">=virtual/ooo-3.0"
fi

openoffice-ext_src_install() {
	if _openoffice-ext_check_use; then
		use ${OPENOFFICE_EXT_OPT_USE} && _openoffice-utils_src_install
	else
		_openoffice-utils_src_install
	fi
	
}

openoffice-ext_pkg_postinst() {
	if _openoffice-ext_check_use; then
		use ${OPENOFFICE_EXT_OPT_USE} && _openoffice-utils_pkg_postinst
	else
		_openoffice-utils_pkg_postinst
	fi

}

openoffice-ext_pkg_prerm() {
	if _openoffice-ext_check_use; then
		use ${OPENOFFICE_EXT_OPT_USE} && _openoffice-utils_pkg_prerm
	else
		_openoffice-utils_pkg_prerm
	fi
}

EXPORT_FUNCTIONS src_install pkg_postinst pkg_prerm
