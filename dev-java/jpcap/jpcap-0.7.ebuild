# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source"
WANT_ANT_TASKS="ant-nodeps"
inherit java-pkg-2 java-ant-2 toolchain-funcs

DESCRIPTION="Java library for capturing and sending network packets"
HOMEPAGE="http://netresearch.ics.uci.edu/kfujii/jpcap/doc/index.html"
SRC_URI="http://netresearch.ics.uci.edu/kfujii/${PN}/${P}.tar.gz"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
DEPEND=">=virtual/jdk-1.5
	net-libs/libpcap"
RDEPEND=">=virtual/jre-1.5
	net-libs/libpcap"

src_unpack() {
	unpack ${A}
	epatch "${FILESDIR}"/make-fixes.patch
	mkdir "${S}"/bin
	rm -rv "${S}"/lib/* || die "rm failed"
}

src_compile() {
	CC=$(tc-getCC) eant jar make $(use_doc)
}

src_install() {
	java-pkg_dojar lib/${PN}.jar
	java-pkg_doso lib/lib${PN}.so
	use doc && java-pkg_dojavadoc doc/javadoc
	use source && java-pkg_dosrc src/java/jpcap
}
