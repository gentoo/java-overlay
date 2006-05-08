# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

MY_PN="${PN}-dev"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="An Open Source XMPP (Jabber) client library for instant messaging and presence"
HOMEPAGE="http://www.jivesoftware.org/smack/"
SRC_URI="http://www.jivesoftware.org/builds/${PN}/${MY_P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="2.1"
KEYWORDS="~amd64 ~x86"
IUSE="doc source"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4"

S="${WORKDIR}/${MY_P}"

ant_src_unpack() {
	unpack ${A}

	cd ${S}
	rm *.jar build/lib/*.jar
}

src_compile() {
	eant -f build/build.xml \
		jar $(use_doc javadoc -Djavadoc.dest.dir=api)
}

src_install() {
	java-pkg_dojar *.jar
	dohtml *.html

	use doc && java-pkg_dohtml -r api documentation/*
	use source && java-pkg_dosrc source/*
}
