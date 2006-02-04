# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

MY_P="${PN}${PV}"
DESCRIPTION="EasyMock provides Mock Objects for interfaces in JUnit tests by generating them on the fly using Java's proxy mechanism"
HOMEPAGE="http://www.easymock.org/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.zip"

# TODO figure out license
LICENSE=""
SLOT="1"
KEYWORDS="~amd64 ~x86"
IUSE="doc jikes"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	app-arch/zip
	jikes? (dev-java/jikes)"
RDEPEND=">=virtual/jre-1.4"
S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd ${S}
	cp ${FILESDIR}/build-${PVR}.xml build.xml

	# TODO test if this works
	unzip -qq -d src/ src.zip
}

src_compile() {
	local antflags="-Dproject.name=${PN} jar"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"
	use doc && antflags="${antflags} javadoc"

	ant ${antflags} || die "Compilation failed"
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	use doc && java-pkg_dohtml -r dist/doc/api
}
