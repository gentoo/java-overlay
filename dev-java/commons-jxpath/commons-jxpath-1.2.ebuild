# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-jxpath/commons-jxpath-1.1-r2.ebuild,v 1.1 2006/07/22 22:58:20 nelchael Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Applies XPath expressions to graphs of objects of all kinds."
HOMEPAGE="http://jakarta.apache.org/commons/jxpath/"
SRC_URI="mirror://apache/jakarta/commons/jxpath/source/${P}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc source"

COMMON_DEPEND="=dev-java/commons-beanutils-1.6*
	=dev-java/servletapi-2.3*
	~dev-java/jdom-1.0_beta9"
RDEPEND=">=virtual/jre-1.3
	${COMMON_DEPEND}"
DEPEND="|| ( =virtual/jdk-1.3* =virtual/jdk-1.4* )
	${COMMON_DEPEND}
	dev-java/ant-core"

src_unpack() {
	unpack ${A}
	cd ${S}

	# Don't automatically run tests
	epatch "${FILESDIR}/${P}-gentoo.patch"

	mkdir -p ${S}/target/lib
	cd ${S}/target/lib
	java-pkg_jar-from commons-beanutils-1.6
	java-pkg_jar-from servletapi-2.3
	java-pkg_jar-from jdom-1.0_beta9
}

src_compile() {
	eant -Dnoget=true jar $(use_doc javadoc)
}

src_install() {
	java-pkg_dojar target/${PN}.jar
	use doc && java-pkg_dohtml -r dist/docs/
	use source && java-pkg_dosrc src/java/*
}
