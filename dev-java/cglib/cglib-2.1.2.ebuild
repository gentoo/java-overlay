# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg


# TODO I'm sure there's a way to do this from PV
MY_PV="2.1_2"
MY_P="${PN}-${MY_PV}"
DESCRIPTION="cglib is a powerful, high performance and quality Code Generation Library, It is used to extend JAVA classes and implements interfaces at runtime."
SRC_URI="mirror://sourceforge/${PN}/${PN}-src-${MY_PV}.jar"
HOMEPAGE="http://cglib.sourceforge.net"
LICENSE="Apache-1.1"
SLOT="2.1"
KEYWORDS="~x86 ~amd64 ~ppc"
RDEPEND=">=virtual/jre-1.4
	>=dev-java/asm-1.5.2-r1
	=dev-java/asm-1.5*
	=dev-java/aspectwerkz-2*"
DEPEND=">=virtual/jdk-1.4
	jikes? ( >=dev-java/jikes-1.21 )
	source? ( app-arch/zip )
	>=dev-java/ant-core-1.5
	=dev-java/jarjar-0*"
IUSE="doc jikes source"

S=${WORKDIR}

src_unpack() {
	jar xf ${DISTDIR}/${A} || die "failed to unpack"

	cd ${S}/lib
	rm -f *.jar
	java-pkg_jar-from asm-1.5
	java-pkg_jar-from aspectwerkz-2
	java-pkg_jar-from jarjar
}

src_compile() {
	local antflags="jar"
	use doc && antflags="${antflags} javadoc"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	ant ${antflags} || die "builed to build"
}

src_install() {
	java-pkg_newjar dist/${MY_P}.jar ${PN}.jar
	java-pkg_newjar dist/${PN}-nodep-${MY_PV}.jar ${PN}-nodep.jar

	dodoc NOTICE README
	use doc && java-pkg_dohtml -r docs/*
	use source && java-pkg_dosrc src/proxy/net
}
