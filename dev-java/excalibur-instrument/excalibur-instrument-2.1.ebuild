# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EXCALIBUR_MODULES="
	${PN}-api-${PV}
	${PN}-client-${PV}
	${PN}-mgr-api-${PV}
	${PN}-mgr-http-${PV}
	${PN}-mgr-impl-${PV}"

EXCALIBUR_TESTS="true"

inherit excalibur-multi

SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="=dev-java/avalon-framework-4.2*"
DEPEND="${RDEPEND}"

S="${WORKDIR}"

EXCALIBUR_JAR_FROM="avalon-framework-4.2"

