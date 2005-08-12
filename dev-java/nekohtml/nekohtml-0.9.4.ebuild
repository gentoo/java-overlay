# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg eutils

DESCRIPTION="NekoHTML is a simple HTML scanner and tag balancer that enables
application programmers to parse HTML documents and access the information using
standard XML interfaces."

HOMEPAGE="http://people.apache.org/~andyc/neko/doc/html/"
SRC_URI="www.apache.org/~andyc/neko/${P}.tar.gz"
DEPEND=">=virtual/jdk-1.3
		dev-java/ant"
RDEPEND=">=virtual/jre-1.3
		=dev-java/xerces-2*
		dev-java/xalan"
LICENSE="CyberNeko Software License-1.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="jikes doc test"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${PF}-build-html.xml.patch
	echo "xerces.jar=$(java-config -p xerces-2)" > build.properties
	echo "xalan.jar=$(java-config -p xalan)" >> build.properties
}

src_compile() {
	local antflags="-buildfile build-html.xml clean jar"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	use doc && antflags="${antflags} doc"
	use test && antflags="${antflags} test"
	ant ${antflags} || die "compile problem"
}

src_install() {
	java-pkg_dojar ${PN}.jar ${PN}Samples.jar ${PN}Xni.jar

	dodoc README_HTML TODO_html
	use doc && java-pkg_dohtml -r doc/html
}
