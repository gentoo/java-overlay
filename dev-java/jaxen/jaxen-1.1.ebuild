# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jaxen/jaxen-1.1_beta11.ebuild,v 1.10 2007/01/05 21:43:26 beandog Exp $

inherit java-pkg-2 eutils java-ant-2

MY_P=${P/_beta/-beta-}
DESCRIPTION="A Java XPath Engine"
HOMEPAGE="http://jaxen.org/"
SRC_URI="http://dist.codehaus.org/${PN}/distributions/${MY_P}-src.tar.gz"

LICENSE="jaxen"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86 ~x86-fbsd"
IUSE="doc source test"

RDEPEND=">=virtual/jre-1.4
	~dev-java/jdom-1.0
	=dev-java/dom4j-1*
	dev-java/xom"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	test? ( dev-java/ant-junit )
	source? ( app-arch/zip )
	${RDEPEND}"


S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}

	cd "${S}"
	java-ant_ignore-system-classes

	mkdir -p "${S}/target/lib"
	cd "${S}/target/lib"
	java-pkg_jar-from dom4j-1
	java-pkg_jar-from jdom-1.0
	java-pkg_jar-from xom
}

src_install() {
	java-pkg_newjar target/${MY_P}.jar ${PN}.jar

	use doc && java-pkg_dohtml -r dist/docs/*
	use source && java-pkg_dosrc src/java/main/*
}

src_test() {
	java-pkg_jar-from --into target/lib junit
	ANT_TASKS="ant-junit" eant test -DJunit.present=true
}
