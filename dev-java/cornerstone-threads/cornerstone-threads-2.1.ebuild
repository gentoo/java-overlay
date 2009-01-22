# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EXCALIBUR_MODULES="
	${PN}-api
	${PN}-impl"

EXCALIBUR_MODULE_USES_PV="false"

EXCALIBUR_TESTS="true"

inherit excalibur-multi

SLOT="0"
KEYWORDS="~x86"

RDEPEND="dev-java/excalibur-thread dev-java/junit dev-java/junitperf"
DEPEND="${RDEPEND}"

S="${WORKDIR}"
IUSE=""

EXCALIBUR_JAR_FROM="excalibur-thread"
EXCALIBUR_TEST_JAR_FROM="excalibur-thread junit junitperf"

src_unpack(){
	excalibur-multi_src_unpack  "${FILESDIR}/build.xml.patch"
}

