# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg rpm

MY_PN=${PN##*-}
DESCRIPTION="A set of interfaces used to recognize well known design patterns in a software system."
HOMEPAGE="http://www.gjt.org/pkgdoc/org/gjt/lindfors/pattern/"
SRC_URI="http://mirrors.dotsrc.org/jpackage/1.6/generic/free/SRPMS/${P}-2jpp.src.rpm"

# license 'unspecified' according to website
LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc jikes"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	jikes? ( dev-java/jikes )"
RDEPEND=">=virtual/jre-1.4"

S=${WORKDIR}/${MY_PN}

src_unpack() {
	rpm_src_unpack
	cd ${S}
	cp ${FILESDIR}/build-${PVR}.xml build.xml
	mkdir -p src/org/gjt/lindfors/${MY_PN}
	mv *.java src/org/gjt/lindfors/${MY_PN}
}

src_compile() {
	local antflags="-Dproject.name=${PN} jar"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"
	use doc && antflags="${antflags} javadoc"

	ant ${antflags} || die "Compilation failed"
}

src_install() {
	java-pkg_dojar dist/${PN}.jar
	dodoc doc/README.TXT

	use doc && java-pkg_dohtml -r dist/doc/api
}
