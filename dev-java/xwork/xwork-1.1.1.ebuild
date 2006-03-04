# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2

DESCRIPTION="A command-pattern framework that is used to power WebWork as well as other applications"
HOMEPAGE="http://opensymphony.com/xwork/"
SRC_URI="https://${PN}.dev.java.net/files/documents/709/28621/${P}.zip"

LICENSE=""
SLOT="1.1"
KEYWORDS="~x86"
IUSE="doc java5 source"

DEPEND="java5? ( >=virtual/jdk-1.5 )
	!java5? ( >=virtual/jdk-1.4 )
	app-arch/unzip"
RDEPEND="java5? ( >=virtual/jre-1.5 )
	!java5? ( >=virtual/jre-1.4 )"

S="${WORKDIR}"


ant_src_unpack() {
	unpack ${A}
	cd ${S}

	rm *.jar
	cd lib
	einfo "QA Notice: Using bundled jars!"
}

src_compile() {
	local antflags="-Dskip.ivy=false jar"
	use java5 && antflags="${antflags} tiger"
	eant ${antflags} $(use_doc javadocs)
}

src_install() {
	java-pkg_newjar build/${P}.jar ${PN}.jar
	use java5 && java-pkg_newjar build/${PN}-tiger-${PV}.jar ${PN}-tiger.jar
	use doc && java-pkg_dohtml -r dist/docs/api
	use source && java-pkg_dosrc src/java/*
}
