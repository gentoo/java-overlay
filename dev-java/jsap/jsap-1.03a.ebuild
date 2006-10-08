# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Java Simple Arguments Parser (JSAP)"
HOMEPAGE="http://sourceforge.net/projects/jsap"
SRC_URI="mirror://sourceforge/${PN}/JSAP-1.03a-src.tar.gz"

LICENSE="LGPL"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc test"

DEPEND=">=virtual/jdk-1.4 
	>=dev-java/ant-core-1.5.4
	=dev-java/snip-0.11
	=dev-java/rundoc-0.11
	test? ( dev-java/junit )"

RDEPEND=">=virtual/jre-1.4"
S=${WORKDIR}/JSAP-1.03a

src_unpack()
{
	unpack ${A}

	cd ${S}
	epatch "${FILESDIR}/${P}-build.xml.patch"

	cd ${S}/lib

	rm ant.jar
	rm junit.jar
	java-pkg_jar-from --build-only snip snip.jar snip-0.11.jar
	java-pkg_jar-from --build-only rundoc rundoc.jar rundoc-0.11.jar
	if use test ; then
		java-pkg_jar-from --build-only junit junit.jar 
	fi
	cd ${S}
	eant clean
}

src_compile()
{	
	eant jar $(use_doc javadoc manual)
}

src_install()
{
	java-pkg_newjar dist/JSAP_${PV}.jar ${PN}.jar

	use doc && java-pkg_dohtml -r doc
}

src_test()
{
	eant test
}
