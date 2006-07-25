# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils rpm java-pkg-2 java-ant-2

MY_PN=${PN##*-}
DESCRIPTION=" A collection of miscellaneous classes and methods that generally come in handy in all sorts of situations."
HOMEPAGE="http://www.gjt.org/pkgdoc/org/gjt/lindfors/util/"
# source download doesn't work from homepage
# swipped form source rpm at jpackage: http://jpackage.org/rpm.php?id=988
SRC_URI="http://mirrors.dotsrc.org/jpackage/1.6/generic/free/SRPMS/${P}-2jpp.src.rpm"

# unspecified according to website
LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4
	dev-java/gjt-jpl-pattern"

S=${WORKDIR}/${MY_PN}

src_unpack() {
	rpm_src_unpack
	cd ${S}

	# from jpackages
	epatch ${FILESDIR}/${PN}-build_xml-jpp.patch
	mkdir classes
}

src_compile() {
	cd ${S}/build
	local antflags="-Dclasspath=$(java-pkg_getjars gjt-jpl-pattern) lib"
	use doc && antflags="${antflags} javadoc"

	eant ${antflags}
}

src_install() {
	java-pkg_newjar build/jpl-util-0_6.jar ${PN}.jar
	dodoc doc/Readme.txt

	use doc && java-pkg_dohtml -r build/api doc/guide
}
