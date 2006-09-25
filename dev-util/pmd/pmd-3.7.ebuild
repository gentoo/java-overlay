# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/pmd/pmd-3.4.ebuild,v 1.1 2006/01/08 03:21:52 nichoj Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="A Java source code analyzer. It finds unused variables, empty catch blocks, unnecessary object creation and so forth."
HOMEPAGE="http://pmd.sourceforge.net"
SRC_URI="mirror://sourceforge/pmd/${PN}-src-${PV}.zip"

LICENSE="pmd"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE="doc source"

RDEPEND=">=virtual/jre-1.3
	=dev-java/jaxen-1.0*
	dev-java/saxpath
	dev-java/xml-commons
	>=dev-java/xerces-2.6"
DEPEND=">=virtual/jdk-1.3
	${RDEPEND}
	app-arch/unzip
	dev-java/ant-core
	source? ( app-arch/zip )"

src_unpack() {
	unpack ${A}

	cd ${S}
	epatch ${FILESDIR}/${P}-gentoo.patch

	cd ${S}/lib/
	rm -f *.jar
	java-pkg_jar-from saxpath
	java-pkg_jar-from jaxen
	java-pkg_jar-from xerces-2 xercesImpl.jar
	java-pkg_jar-from xml-commons
}

src_compile() {
	cd ${S}/bin
	eant jar $(use_doc javadoc)
}

src_install() {
	java-pkg_newjar lib/${P}.jar ${PN}.jar
	dodir /usr/share/ant-core/lib/
	dosym /usr/share/${PN}/lib/${PN}.jar /usr/share/ant-core/lib/ant-${PN}.jar

	newbin bin/${PN}.sh ${PN}
	newbin bin/designer.sh ${PN}-designer
	cp -r rulesets ${D}/usr/share/${PN}

	use doc && java-pkg_dohtml -r docs/api
	use source && java-pkg_dosrc src/*
}

pkg_postinst() {
	einfo ""
	einfo "Example rulesets can be found under"
	einfo "/usr/share/pmd/rulesets/"
	einfo ""
}
