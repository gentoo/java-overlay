# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/hibernate/hibernate-2.1.6.ebuild,v 1.1 2004/08/11 14:47:35 voxus Exp $

inherit java-pkg

DESCRIPTION="cglib is a powerful, high performance and quality Code Generation Library, It is used to extend JAVA classes and implements interfaces at runtime."
SRC_URI="mirror://sourceforge/${PN}/${PN}-src-${PV}.jar"
HOMEPAGE="http://cglib.sourceforge.net"
LICENSE="APACHE-1.1"
SLOT="2"
KEYWORDS="~x86 ~amd64"
RDEPEND="
		>=virtual/jre-1.4
		=dev-java/asm-1*
		dev-java/aspectwerkz
		"
DEPEND=">=virtual/jdk-1.4
		>=dev-java/ant-core-1.5
		"
IUSE="doc jikes"

S=${WORKDIR}

src_unpack() {
	jar xf ${DISTDIR}/${A} || die "failed to unpack"
	cd lib
		rm *.jar
		java-pkg_jar-from asm-1
		java-pkg_jar-from aspectwerkz
	cd ..
	sed -i -r \
		-e 's/destdir="docs"/destdir="docs\/api"/g' \
			build.xml
}

src_compile() {
	local antflags="jar"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	use doc && antflags="${antflags} javadoc"
	ant ${antflags} || die "builed to build"
}

src_install() {
	mv dist/${PN}-${PV}.jar dist/${PN}.jar
	mv dist/${PN}-full-${PV}.jar dist/${PN}-full.jar
	java-pkg_dojar dist/${PN}.jar dist/${PN}-full.jar
	dodoc LICENSE NOTICE README
	use doc && java-pkg_dohtml -r docs/*
}
