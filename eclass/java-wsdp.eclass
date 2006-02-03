# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#
# Original Author: Krzysiek Pawlik <nelchael@gentoo.org>
# Purpose: Automate installation of Sun's JWSDP components
#

inherit java-pkg

ECLASS="java-wsdp"
INHERITED="$INHERITED $ECLASS"

EXPORT_FUNCTIONS src_unpack src_install pkg_nofetch

[[ -z "${JWSDP_VERSION}" ]] && die "No JWSDP version given."
JWSDP_VERSION="${JWSDP_VERSION/./_}"
JWSDP_PKG="${PN/sun-/}"
JWSDP_PKG="${JWSDP_PKG/-bin/}"

DESCRIPTION="Sun's Java Web Services Developer Pack - ${JWSDP_DESC} (${JWSDP_PKG})"
HOMEPAGE="http://java.sun.com/webservices/jwsdp/"
SRC_URI="jwsdp-${JWSDP_VERSION}-unix.sh"
LICENSE="sun-jwsdp"
SLOT="0"
RESTRICT="fetch nostrip"

IUSE="doc"

DEPEND=">=virtual/jdk-1.5
	app-arch/unzip
	dev-java/sax
	dev-java/xalan
	dev-java/xerces"

pkg_nofetch() {

	einfo "Please go to following URL:"
	einfo " ${HOMEPAGE}"
	einfo "download file named jwsdp-${JWSDP_VERSION}-unix.sh and place it in:"
	einfo " ${DISTDIR}"

}

java-wsdp_src_unpack() {

	einfo "Extracting zip file..."
	mkdir "${T}/unpacked" || die "mkdir failed"

	# This tries to figure out right offset:
	offset="`grep -a '^tail +' ${DISTDIR}/${A} | sed -e 's/.*+\([0-9]\+\).*/\1/'`"

	tail -n +${offset} "${DISTDIR}/${A}" > "${T}/unpacked/packed.zip" || \
		die	"tail failed"

	cd "${T}/unpacked/"
	unzip "packed.zip" &> /dev/null || die "unzip failed"

	einfo "Installing using Sun's installer, please wait..."
	cd "${T}/unpacked/"
	java JWSDP -silent -P installLocation="${WORKDIR}/base" || die "java failed"

	einfo "Removing useless files..."
	cd "${WORKDIR}/base"
	rm -fr _uninst uninstall.sh images
	# Bundled ant? Why?
	rm -fr apache-ant

}

java-wsdp_src_install() {

	einfo "Installing ${JWSDP_PKG}..."
	cd "${WORKDIR}/base/${JWSDP_PKG}"

	# Remove existing compiled jars:
	for i in ${REMOVE_JARS}; do
		rm -f lib/${i}.jar
	done

	java-pkg_dojar lib/*.jar

	if use doc; then
		if [[ -d docs ]]; then
			einfo "Installing documentation..."
			java-pkg_dohtml -r docs/*
		else
			einfo "No docs directory"
		fi
	fi

}
