# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils rpm java-pkg-2 java-ant-2

MY_PN=${PN##*-}
DESCRIPTION="Collection of miscellaneous classes and methods that come in handy in all sorts of situations"
HOMEPAGE="http://www.gjt.org/pkgdoc/org/gjt/lindfors/util/"
# source download doesn't work from homepage
# swipped form source rpm at jpackage: http://jpackage.org/rpm.php?id=988
SRC_URI="http://mirrors.dotsrc.org/jpackage/1.6/generic/free/SRPMS/${P}-2jpp.src.rpm"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

COMMON_DEPEND="dev-java/gjt-jpl-pattern:0"
DEPEND="${COMMON_DEPEND}
	>=virtual/jdk-1.4
	dev-java/ant-core
"
RDEPEND="${COMMON_DEPEND}
	>=virtual/jre-1.4
"

DOCS=( doc/Readme.txt )

S=${WORKDIR}/${MY_PN}

src_prepare() {
	# from jpackages
	epatch "${FILESDIR}/${PN}-build_xml-jpp.patch"
	mkdir classes || die
}

src_compile() {
	cd "${S}"/build
	local antflags="-Dclasspath=$(java-pkg_getjars gjt-jpl-pattern) lib"
	use doc && antflags="${antflags} javadoc"

	eant ${antflags}
}

src_install() {
	default

	java-pkg_newjar build/jpl-util-0_6.jar ${PN}.jar
	use doc && java-pkg_dohtml -r build/api doc/guide
}
