# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Easy to use, open source library for working with XML, XPath and XSLT on the Java platform using the Java Collections Framework and with full support for DOM, SAX and JAXP."
HOMEPAGE="http://dom4j.sourceforge.net/"
SRC_URI="mirror://sourceforge/dom4j/${P}.tar.gz"
LICENSE="dom4j"
SLOT="1.4"
KEYWORDS="~x86"
IUSE="doc source"
RDEPEND="=virtual/jdk-1.4*
	dev-java/jaxme
	=dev-java/jaxen-1.1*
	dev-java/jsr173
	dev-java/msv
	dev-java/xpp2
	dev-java/xalan
	dev-java/xpp3
	=dev-java/avalon-logkit-1.2*
	=dev-java/avalon-framework-4.1*
	=dev-java/junit-3*
	dev-java/saxpath
	dev-java/relaxng-datatype
	dev-java/fop
	=dev-java/batik-1.5*
	=dev-java/xml-commons-external-1.3*
	source? ( app-arch/zip )
	dev-java/ant-core
	>=dev-java/xerces-2.7
	dev-java/xsdlib"

DEPEND="${RDEPEND}"

EANT_GENTOO_CLASSPATH="batik-1.5,fop,jaxen-1.1,xml-commons-external-1.3,saxpath,junit,jaxme,jsr173,msv,xpp3,xpp2,relaxng-datatype,xsdlib,xalan,xerces-2.6,avalon-logkit-1.2,avalon-framework-4.1"
EANT_DOC_TARGET="javadoc"
EANT_BUILD_TARGET="clean package"

src_unpack() {
	unpack ${A}

	epatch ${FILESDIR}/fop.patch
	epatch ${FILESDIR}/DefaultXPath.java.diff
	epatch ${FILESDIR}/ProxyXmlStartTag.java.diff
	epatch ${FILESDIR}/DocumentFactory.java.diff
	epatch ${FILESDIR}/XPathPattern.java.diff
	epatch ${FILESDIR}/AbstractNode.java.diff
	epatch ${FILESDIR}/DocumentHelper.java.diff
	epatch ${FILESDIR}/ProxyDocumentFactory.java.diff

	find "${S}" -name *.jar | xargs rm -rf || die "rm failed"
	cd "${S}/lib" || die "cd failed"
	java-pkg_jarfrom ${EANT_GENTOO_CLASSPATH}

	for i in $(find ${S} -name build.xml);do
			java-ant_rewrite-classpath "$i"
	done
}

src_install() {
	java-pkg_dojar build/${PN}*.jar
	use doc && java-pkg_dohtml -r "${S}/build/doc/api"
	use source && java-pkg_dosrc src/java/*
}
