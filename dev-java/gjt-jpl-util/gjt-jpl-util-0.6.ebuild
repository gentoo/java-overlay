# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg eutils

MY_PN=${PN##*-}
DESCRIPTION=" A collection of miscellaneous classes and methods that generally come in handy in all sorts of situations."
HOMEPAGE="http://www.gjt.org/pkgdoc/org/gjt/lindfors/util/"
# source download doesn't work from homepage
# swipped form source rpm at jpackage: http://jpackage.org/rpm.php?id=988
SRC_URI="mirror://gentoo/${PN}-source.zip"

# unspecified according to website
LICENSE=""
SLOT="0"
KEYWORDS="~x86"
IUSE="doc jikes"

DEPEND="virtual/jdk
	dev-java/ant
	jikes? (dev-java/jikes)"
RDEPEND="virtual/jre
	dev-java/gjt-jpl-pattern"

S=${WORKDIR}/${MY_PN}

src_unpack() {
	unpack ${A}
	cd ${S}

	# from jpackages
	epatch ${FILESDIR}/${PN}-build_xml-jpp.patch
	mkdir classes
}

src_compile() {
	cd ${S}/build
	local antflags="-Dclasspath=$(java-pkg_getjars gjt-jpl-pattern) lib"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"
	use doc && antflags="${antflags} javadoc"

	ant ${antflags} || die "Compilation failed"
}

src_install() {
	cd ${S}
	java-pkg_newjar build/jpl-util-0_6.jar ${PN}.jar
	dodoc doc/Readme.txt

	use doc && java-pkg_dohtml -r build/api doc/guide
}
