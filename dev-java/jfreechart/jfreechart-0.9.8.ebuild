# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jfreechart/jfreechart-0.9.21.ebuild,v 1.6 2005/09/03 22:46:02 betelgeuse Exp $

inherit java-pkg

DESCRIPTION="JFreeChart is a free Java class library for generating charts"
HOMEPAGE="http://www.jfree.org"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
LICENSE="LGPL-2"
# TODO complain to upstream about instable api
SLOT="0.9.8"
KEYWORDS="x86 ppc amd64"
IUSE="doc jikes"
RDEPEND=">=virtual/jdk-1.3
	=dev-java/jcommon-0.8*
	=dev-java/servletapi-2.3*
	dev-java/gnu-jaxp"
DEPEND=">=virtual/jdk-1.3
	${RDEPEND}
	dev-java/ant-core
	jikes? ( dev-java/jikes )"

src_unpack() {
	unpack ${A}
	cd ${S}
	rm -f lib/* *.jar
}

src_compile() {
	local antflags="compile compile-demo -Djcommon.jar=$(java-pkg_getjars jcommon-0.8) \
		-Dservlet.jar=$(java-pkg_getjar servletapi-2.3 servlet.jar) \
		-Dgnujaxp.jar=$(java-pkg_getjars gnu-jaxp)"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	use doc && antflags="${antflags} javadoc"
	ant -f ant/build.xml ${antflags} || die "compile failed"
}

src_install() {
	java-pkg_newjar ${P}.jar ${PN}.jar
	java-pkg_newjar ${P}-demo.jar ${PN}-demo.jar
	dodoc README
	use doc && java-pkg_dohtml -r javadoc/
}

