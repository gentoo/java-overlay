# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/xmlunit/xmlunit-1.0-r1.ebuild,v 1.2 2005/11/24 18:14:44 compnerd Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="XMLUnit extends JUnit and NUnit to enable unit testing of XML."
SRC_URI="mirror://sourceforge/${PN}/${P/-/}.zip"
HOMEPAGE="http://xmlunit.sourceforge.net/"
LICENSE="BSD"
SLOT="1"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="doc source test"
# We depend on jdk-1.4 as tests fail with jdk > 1.4
# see http://sourceforge.net/tracker/index.php?func=detail&aid=1614984&group_id=23187&atid=377768
# Also docs cannot be built with jdk > 1.5
DEPEND="=virtual/jdk-1.4*
	>=app-arch/unzip-5.50-r1
	test? (
		>=dev-java/ant-1.6
		=dev-java/junit-3.8*
		dev-java/xalan
	)
	!test? ( >=dev-java/ant-core-1.6 )
	source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.4"
EANT_BUILD_TARGET="jar"
EANT_DOC_TARGET="docs"

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${PN}-${PVR}-build.xml.patch
	rm -f ${S}/lib/*.jar
}

src_test() {
	eant test
}

src_install() {
	java-pkg_newjar lib/${PN}${PV}.jar ${PN}.jar

	dodoc README.txt
	use doc && java-pkg_dojavadoc doc
	use source && java-pkg_dosrc src/java/*
}
