# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg

DESCRIPTION="Commons Attributes enables Java programmers to use C#/.Net-style attributes in their code."
HOMEPAGE="http://jakarta.apache.org/commons/attributes/"
SRC_URI="http://www.wmwweb.com/apache/jakarta/commons/attributes/source/${P}-src.tgz"

LICENSE="Apache-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc jikes"

DEPEND="virtual/jdk
	dev-java/ant
	jikes? (dev-java/jikes)
	dev-java/xjavadoc"
RDEPEND="virtual/jre
	dev-java/commons-collections
	dev-java/junit"

ANT="ant-core ant.jar"
XJAVADOC="xjavadoc xjavadoc.jar"
COMMONS_COLLECTIONS="commons-collections commons-collections.jar"
JUNIT="junit junit.jar"

src_unpack() {
	mkdir ${S}
	cd ${S}
	unpack ${A}

	epatch ${FILESDIR}/${P}-build_xml.patch

	mkdir -p target/classes/org/apache/commons/attributes
	cp ${FILESDIR}/anttasks.properties target/classes/org/apache/commons/attributes/

	mkdir -p target/lib
	cd target/lib
	java-pkg_jar-from ${ANT}
	java-pkg_jar-from ${XJAVADOC}
	java-pkg_jar-from ${COMMONS_COLLECTIONS}
	
}

src_compile() {
	local antflags="-Dproject.name=${PN} jar"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"
	use doc && antflags="${antflags} javadoc"

	ant ${antflags} || die "Compilation failed"
}

src_install() {
	java-pkg_newjar target/${PN}-api-${PV}.jar ${PN}-api.jar
	java-pkg_newjar target/${PN}-compiler-${PV}.jar ${PN}-compiler.jar

	dodoc NOTICE.txt RELEASE.txt
	dohtml README.html

	use doc && java-pkg_dohtml -r api
}
