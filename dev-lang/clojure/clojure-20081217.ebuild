# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
JAVA_PKG_IUSE="source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Clojure is a dynamic programming language that targets the Java Virtual Machine."
HOMEPAGE="http://clojure.org/"
SRC_URI="http://clojure.googlecode.com/files/clojure_${PV}.zip"

LICENSE="CPL-1.0 BSD"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""

RDEPEND=">=virtual/jre-1.5"
DEPEND=">=virtual/jdk-1.5"

S="${WORKDIR}/${PN}"

src_prepare() {
	rm -v ${PN}.jar || die
	java-pkg-2_src_prepare
}

src_install() {
	java-pkg_dojar ${PN}.jar
	java-pkg_dolauncher  ${PN} --main clojure.lang.Repl
	dodoc {readme,changes}.txt || die "dodoc failed"
	use source && java-pkg_dosrc src/jvm/closure
}
