# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit java-pkg-2 java-ant-2 rpm

MY_PN=${PN##*-}
DESCRIPTION="A set of interfaces used to recognize well known design patterns in a software system."
HOMEPAGE="http://www.gjt.org/pkgdoc/org/gjt/lindfors/pattern/"
SRC_URI="http://mirrors.dotsrc.org/jpackage/1.6/generic/free/SRPMS/${P}-2jpp.src.rpm"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4"

S=${WORKDIR}/${MY_PN}

src_unpack() {
	rpm_src_unpack
	cd "${S}"
	cp "${FILESDIR}/build-${PV}.xml" build.xml
	mkdir -p src/org/gjt/lindfors/${MY_PN}
	mv *.java src/org/gjt/lindfors/${MY_PN}
}

src_compile() {
	eant -Dproject.name=${PN} jar $(use_doc)
}

src_install() {
	java-pkg_dojar dist/${PN}.jar
	dodoc doc/README.TXT

	use doc && java-pkg_dojavadoc dist/doc/api
}
