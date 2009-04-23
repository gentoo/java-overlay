# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit java-pkg-2

MY_PV="${PV/_/-}"
MY_P="GCalc-${MY_PV}"

DESCRIPTION="Java Mathematical Graphing System"
HOMEPAGE="http://gcalc.net/"
SRC_URI="http://gcalc.net/files/${MY_P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64"
IUSE=""
SLOT="0"

RDEPEND=">=virtual/jre-1.4"

DEPEND=">=virtual/jdk-1.4"

S="${WORKDIR}/${MY_P}"

java_prepare() {
	rm -rv *.jar src/*.jar || die "failed to remove bundled jars"
}

src_compile() {
	cd "${S}/src"
	ejavac $(find . -name '*.java')

	touch myManifest
	jar cmf myManifest ${PN}.jar resources pluginlist.xml $(find . -name '*.class') || die "jar failed"
}

src_install() {
	java-pkg_dojar src/${PN}.jar
	java-pkg_dolauncher gcalc --main net.gcalc.calc.GCalc

	newicon src/resources/gicon.png ${PN}.png || die "newicon failed"
	make_desktop_entry ${PN} "GCalc Java Mathematical Graphing System"
}
