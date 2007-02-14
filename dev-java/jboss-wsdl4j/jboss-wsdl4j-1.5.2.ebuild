# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/wsdl4j/wsdl4j-1.5.1-r1.ebuild,v 1.1 2006/09/17 20:13:13 nichoj Exp $

inherit java-pkg-2 java-ant-2

MY_PV="1.5.2"
MY_PN="wsdl4j"
MY_P="${MY_PN//jboss-}-${MY_PV}"

DESCRIPTION="Web Services Description Language for Java Toolkit (WSDL4J) JBoss patched ersion"
HOMEPAGE="http://wsdl4j.sourceforge.net"
SRC_URI="mirror://sourceforge/wsdl4j/${MY_PN}-src-${MY_PV}.zip"

LICENSE="CPL-1.0"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc source"

DEPEND=">=virtual/jdk-1.4
	>=dev-java/ant-core-1.4
	source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.4"

S=${WORKDIR}/${MY_PN}-${MY_PV//./_}

EANT_DOC_TARGET="javadocs"
EANT_BUILD_TARGET="compile"

src_unpack(){
	unpack ${A}
	cd "${S}" || die "cd failed"
	epatch "${FILESDIR}/${PV}/jboss_wsdl4j.patch"
	cp "${FILESDIR}/${PV}/build.xml" . || die "cp failed"
}

src_install() {
	java-pkg_dojar build/lib/*.jar
	dohtml doc/*.html
	use doc && java-pkg_dohtml -r build/javadocs/
	use source && java-pkg_dosrc src/*
}
