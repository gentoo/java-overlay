# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EXCALIBUR_MODULES="
${PN}-api
${PN}-impl
${PN}-instrumented"

EXCALIBUR_MODULE_USES_PV="false"

EXCALIBUR_TESTS="true"

inherit excalibur-multi

SLOT="0"
KEYWORDS="~x86"

RDEPEND="
=dev-java/avalon-framework-4.2*
dev-java/junit
dev-java/junitperf
dev-java/commons-collections
dev-java/concurrent-util
dev-java/excalibur-pool
dev-java/excalibur-instrument"
DEPEND="${RDEPEND}"

IUSE=""

S=${WORKDIR}

EXCALIBUR_JAR_FROM="
avalon-framework-4.2
commons-collections
concurrent-util
excalibur-pool
excalibur-instrument"

EXCALIBUR_TEST_JAR_FROM="junit junitperf"

