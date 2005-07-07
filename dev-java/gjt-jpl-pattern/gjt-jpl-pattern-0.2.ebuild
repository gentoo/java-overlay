# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

MY_PN=${PN##*-}
DESCRIPTION="GJT-JPL-Pattern contains interfaces used to recognize well known design patterns in a software system. Most interfaces are only useful for 'tagging' classes as being a part of certain design patterns, and there isn't any implementing code present here."
HOMEPAGE="http://www.gjt.org/pkgdoc/org/gjt/lindfors/pattern/"
# source download doesn't work from homepage
# swipped form source rpm at jpackage: http://jpackage.org/rpm.php?id=987
SRC_URI="mirror://gentoo/${PN}-source.zip"

# license unspecified according to website
LICENSE=""
SLOT="0"
KEYWORDS="~x86"
IUSE="doc jikes"

DEPEND="virtual/jdk
	dev-java/ant
	jikes? (dev-java/jikes)"
RDEPEND="virtual/jre"

S=${WORKDIR}/${MY_PN}

src_unpack() {
	unpack ${A}
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
