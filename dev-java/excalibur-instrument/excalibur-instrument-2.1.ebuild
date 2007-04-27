# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/excalibur-logger/excalibur-logger-2.1.ebuild,v 1.2 2006/12/22 18:12:09 betelgeuse Exp $

EXCALIBUR_MODULES="
	${PN}-api-${PV}
	${PN}-client-${PV}
	${PN}-mgr-api-${PV}
	${PN}-mgr-http-${PV}
	${PN}-mgr-impl-${PV}"

EXCALIBUR_TESTS="true"

inherit excalibur-multi

SLOT="0"
KEYWORDS="~x86"

RDEPEND="=dev-java/avalon-framework-4.2*"
DEPEND="${RDEPEND}"

S=${WORKDIR}

EXCALIBUR_JAR_FROM="avalon-framework-4.2"

