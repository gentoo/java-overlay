# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/excalibur-logger/excalibur-logger-2.1.ebuild,v 1.2 2006/12/22 18:12:09 betelgeuse Exp $

EXCALIBUR_TESTS="true"

inherit excalibur

SLOT="0"
KEYWORDS="~x86"

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

EXCALIBUR_JAR_FROM="
	avalon-framework-4.2
	excalibur-pool
	excalibur-instrument"

# Needs jdbc driver from hsqldb
EXCALIBUR_TEST_JAR_FROM="
	excalibur-testcase
	concurrent-util
	hsqldb"
