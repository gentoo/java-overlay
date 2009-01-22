# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EXCALIBUR_TESTS="true"

inherit excalibur

SLOT="0"
KEYWORDS="~x86"
IUSE=""

RDEPEND="
	=dev-java/avalon-framework-4.2*
	dev-java/excalibur-pool
	dev-java/excalibur-instrument
	"

DEPEND="${RDEPEND}
	test? (
		dev-java/excalibur-testcase
		dev-java/concurrent-util
	)"

IUSE=""

EXCALIBUR_JAR_FROM="
	avalon-framework-4.2
	excalibur-pool
	excalibur-instrument"

# Needs jdbc driver from hsqldb
EXCALIBUR_TEST_JAR_FROM="
	excalibur-testcase
	concurrent-util
	hsqldb"
