# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=2
CLOJURE_VERSION="1.1"
JAVA_PKG_IUSE="source test"

inherit clojure java-ant-2

DESCRIPTION="User contributed packages for Clojure."
HOMEPAGE="http://code.google.com/p/clojure-contrib/"
SRC_URI="http://clojure-contrib.googlecode.com/files/${P}.zip"

LICENSE="EPL-1.0"
SLOT="1.1"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_test() {
	java-pkg-2_src_test
}

src_install() {
	java-pkg_dojar ${PN}.jar
	use source && clojure_dosrc src
}
