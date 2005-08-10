# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg eutils

DESCRIPTION="A Java toolkit to use images in the Scalable Vector Graphics (SVG) format for various purposes, such as viewing, generation or manipulation."
HOMEPAGE="http://xml.apache.org/batik/"
SRC_URI="mirror://apache/xml/batik/${PN}-src-${PV}.zip"

LICENSE="Apache-2"
SLOT="1.6"
KEYWORDS="~x86"
IUSE="doc jikes"

RDEPEND=">=virtual/jre-1.3
	=dev-java/rhino-1.5*
	=dev-java/xerces-2.6*"
DEPEND=">=virtual/jdk-1.3
	${RDEPEND}
	app-arch/unzip
	dev-java/ant-core"

S=${WORKDIR}/xml-batik

src_unpack() {
	unpack ${A}

	use jikes && epatch ${FILESDIR}/${P}-jikes.patch

	cd ${S}/lib && rm -f *.jar
	java-pkg_jar-from rhino-1.5
	java-pkg_jar-from xerces-2
}

src_compile() {
	local antflags="jars all-jar"
	use doc && antflags="${antflags} javadoc"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	
	ant ${antflags} || die "compile problem"
}

src_install() {
	java-pkg_dojar ${P}/batik*.jar

	cd ${P}/lib
	rm {js,x*}.jar

	# needed because batik expects this layout:
	# batik.jar lib/*.jar
	# there are hardcoded classpathes in the manifest :(
	for jar in *.jar
	do
		java-pkg_dojar ${jar}
		rm -f ${jar}
		ln -s ${DESTTREE}/share/${PN}-${SLOT}/lib/${jar} ${jar}
	done

	cd ${S}
	cp -ra ${P}/lib ${D}${DESTTREE}/share/${PN}-${SLOT}/lib/

	dodoc README
	use doc && java-pkg_dohtml -r ${P}/docs/api xdocs/*

	echo "#!/bin/sh" > ${PN}${SLOT}
	echo '${JAVA_HOME}/bin/java -classpath $(java-config -p batik-1.5.1,xerces-2,rhino-1.5) org.apache.batik.apps.svgbrowser.Main $*' >> ${PN}${SLOT}
	dobin ${PN}${SLOT}

}
