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
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	=dev-java/avalon-framework-4.2*
	dev-java/commons-collections
	dev-java/concurrent-util
	dev-java/excalibur-instrument"
DEPEND="${RDEPEND}
	test? ( dev-java/junitperf )"

S="${WORKDIR}"

EXCALIBUR_JAR_FROM="
	avalon-framework-4.2
	commons-collections
	concurrent-util
	excalibur-instrument"

EXCALIBUR_TEST_JAR_FROM="junit junitperf"

src_unpack() {
	excalibur-multi_src_unpack
	cd "${S}"
	sed -i -e 's/org.apache.excalibur/org.apache.avalon.excalibur/' \
		excalibur-pool-api/build.xml excalibur-pool-impl/build.xml \
		excalibur-pool-instrumented/build.xml
}
