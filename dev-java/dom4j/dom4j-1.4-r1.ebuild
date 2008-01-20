# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Easy to use, open source library for working with XML, XPath and XSLT on the Java platform using the Java Collections Framework and with full support for DOM, SAX and JAXP."
HOMEPAGE="http://dom4j.sourceforge.net/"
SRC_URI="mirror://sourceforge/dom4j/${P}.tar.gz"
LICENSE="dom4j"
SLOT="1.4"
KEYWORDS="~amd64 ~x86"
IUSE=""
COMMON_DEP="=dev-java/jaxen-1.1*
	dev-java/msv
	dev-java/xpp2
	dev-java/saxpath
	dev-java/relaxng-datatype
	dev-java/fop
	dev-java/xsdlib"

DEPEND="=virtual/jdk-1.4*
	${COMMON_DEP}"
RDEPEND="
	>=virtual/jre-1.4
	${COMMON_DEP}"

EANT_GENTOO_CLASSPATH="msv,xpp2,jaxen-1.1,relaxng-datatype,saxpath,xsdlib"
EANT_BUILD_TARGET="clean package"
EANT_ANT_TASKS="fop"

src_unpack() {
	unpack ${A}

	#epatch ${FILESDIR}/fop.patch
	#epatch ${FILESDIR}/DefaultXPath.java.diff
	#epatch ${FILESDIR}/ProxyXmlStartTag.java.diff
	#epatch ${FILESDIR}/DocumentFactory.java.diff
	#epatch ${FILESDIR}/XPathPattern.java.diff
	#epatch ${FILESDIR}/AbstractNode.java.diff
	#epatch ${FILESDIR}/DocumentHelper.java.diff
	#epatch ${FILESDIR}/ProxyDocumentFactory.java.diff
	epatch ${FILESDIR}/makethingscompile.diff
	sed '/<unjar/d' -i "${S}/build.xml" || die

	find "${S}" -name *.jar | xargs rm -rf || die "rm failed"
	cd "${S}/lib" || die "cd failed"
	#java-pkg_jarfrom ${EANT_GENTOO_CLASSPATH}

	for i in $(find ${S} -name build.xml);do
			java-ant_rewrite-classpath "$i"
	done
}

src_install() {
	java-pkg_dojar build/${PN}*.jar
	use doc && java-pkg_dohtml -r "${S}/build/doc/api"
	use source && java-pkg_dosrc src/java/*
}
