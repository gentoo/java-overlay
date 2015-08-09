# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=2
JAVA_PKG_IUSE="source"
CLOJURE_BOOTSTRAP_MODE=1

inherit java-pkg-2 java-ant-2 clojure

DESCRIPTION="Clojure is a dynamic programming language that targets the Java Virtual Machine."
HOMEPAGE="http://clojure.org/"
SRC_URI="http://clojure.googlecode.com/files/clojure_${PV}.zip"

LICENSE="EPL-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

RDEPEND=">=virtual/jre-1.5"
DEPEND=">=virtual/jdk-1.5"

S="${WORKDIR}"

java_prepare() {
	rm -v ${P}.jar || die
}

src_install() {
	java-pkg_newjar ${P}.jar
	java-pkg_dolauncher  ${PN} --main clojure.main
	dodoc readme.txt || die "dodoc failed"
	use source && clojure_dosrc src/jvm src/clj
}
