# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=2
JAVA_PKG_IUSE="source test"
CLOJURE_BOOTSTRAP_MODE=1

inherit java-pkg-2 java-ant-2 clojure

DESCRIPTION="Clojure is a dynamic programming language that targets the Java Virtual Machine."
HOMEPAGE="http://clojure.org/"
SRC_URI="http://clojure.googlecode.com/files/${P}.zip"

LICENSE="EPL-1.0"
SLOT="1.1"
KEYWORDS="~amd64 ~x86"

IUSE=""

RDEPEND=">=virtual/jre-1.5"
DEPEND=">=virtual/jdk-1.5"

java_prepare() {
	rm -v ${PN}.jar || die "Failed to remove compile jar."
}

src_test() {
	java-pkg-2_src_test
}

src_install() {
	java-pkg_newjar ${P/_/-}.jar
	java-pkg_dolauncher  ${PN}-${SLOT} --main clojure.main
	dodoc changes.txt || die "Failed to copy changes.txt"
	dodoc readme.txt  || die "Failed to copy readme.txt"
	use source && clojure_dosrc src/jvm src/clj
}
