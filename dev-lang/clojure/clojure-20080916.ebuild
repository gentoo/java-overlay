# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=1
JAVA_PKG_IUSE="source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Clojure is a dynamic programming language that targets the Java Virtual Machine."
HOMEPAGE="http://clojure.org/"
MY_P=${PN}_${PV}
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.zip"

LICENSE="CPL-1.0 BSD"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""

RDEPEND=">=virtual/jre-1.5"
DEPEND=">=virtual/jdk-1.5"

S="${WORKDIR}"

src_unpack() {
	unpack ${A}
	rm "${S}"/${PN}.jar || die
}

src_install() {
	java-pkg_dojar ${PN}.jar
	java-pkg_dolauncher  ${PN} --main clojure.lang.Repl
	dodoc {readme,changes}.txt
	use source && java-pkg_dosrc src/jvm/closure
}
