# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/excalibur-logger/excalibur-logger-2.1.ebuild,v 1.2 2006/12/22 18:12:09 betelgeuse Exp $

inherit excalibur

SRC_URI="mirror://apache/excalibur/${PN}/source/${P}-src.tar.gz"

SLOT="0"
KEYWORDS="~x86"

DEPEND="
	=dev-java/avalon-framework-4.2*
	=dev-java/avalon-logkit-2*
	dev-java/excalibur-component
	dev-java/excalibur-logger
	dev-java/junit"
RDEPEND="${DEPEND}"

EXCALIBUR_JAR_FROM="
	avalon-framework-4.2
	avalon-logkit-2.0
	excalibur-component
	excalibur-logger
	junit"

