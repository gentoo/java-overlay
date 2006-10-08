# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="an Apache ANT optional task that extracts snippets of code from text files"
HOMEPAGE="http://www.martiansoftware.com/lab/index.html"
SRC_URI="http://www.martiansoftware.com/lab/${PN}/${P}-src.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc"

# FIXME: get minimal version possible
RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.4 
        >=dev-java/ant-core-1.5.4" # FIXME ant-core version

src_unpack() {
	unpack ${A}

	cd "${S}"
	epatch "${FILESDIR}/${P}-build.xml.patch"

}

src_compile()
{	
	eant clean jar $(use_doc)
}

src_install()
{
	java-pkg_newjar dist/${P}.jar ${PN}.jar

	use doc && java-pkg_dohtml -r javadoc
}

