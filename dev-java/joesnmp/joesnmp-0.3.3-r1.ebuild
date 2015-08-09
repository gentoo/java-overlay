# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="joeSNMP is an open-source Java SNMP class library published under the LGPL."
HOMEPAGE="http://sourceforge.net/projects/joesnmp/"
SRC_URI="mirror://sourceforge/${PN}/${P}.zip"

LICENSE="LGPL-2.1"
SLOT="0.3"
KEYWORDS="~x86"
IUSE="doc"

# TODO determine java veresions
DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4"

src_unpack() {
	unpack ${A}
	cd ${S}

	# patch for javadocs
	epatch ${FILESDIR}/${P}-gentoo.patch

	# remove packed jars, which aren't used
	rm tools/ant/lib/*.jar
}

src_compile() {
	eant build $(use_doc)
}

src_install() {
	java-pkg_dojar output/lib/*.jar

	dodoc README.txt CHANGELOG.txt TODO.txt docs/FAQ.txt
	use doc && java-pkg_dohtml -r docs/api
}
