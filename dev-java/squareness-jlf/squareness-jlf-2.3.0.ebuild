# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Squareness Java Look and Feel"
HOMEPAGE="http://squareness.beeger.net/"
SRC_URI="mirror://sourceforge/squareness/${PN/-/_}_src-${PV}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

S="${WORKDIR}"

RDEPEND=">=virtual/jre-1.4
	dev-java/laf-plugin"

DEPEND=">=virtual/jdk-1.4
	dev-java/laf-plugin"

src_compile() {
	find . -name '*.java' -print > sources.list
	ejavac -cp .:$(java-pkg_getjars laf-plugin) @sources.list
	rm -rf sources.list 
  	find . -name '*' -not -name '*.java' -type f -not -name 'classes.list' -not -name '*.txt' -print > classes.list
  	touch myManifest
  	jar cmf myManifest ${PN}.jar @classes.list
}

src_install() {
	java-pkg_dojar ${PN}.jar
	dodoc license/squareness_license.txt
}
