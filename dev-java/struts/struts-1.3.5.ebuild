# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/struts/struts-1.2.9.ebuild,v 1.1 2006/03/31 15:49:34 karltk Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="A powerful Model View Controller Framework for JSP/Servlets"
SRC_URI="mirror://apache/struts/source/${P}-src.zip"
HOMEPAGE="http://struts.apache.org/"
LICENSE="Apache-2.0"
SLOT="1.3"
IUSE="doc source"
KEYWORDS="~amd64 ~ppc ~x86"

COMMON_DEP="
	>=dev-java/antlr-2.7.2
	=dev-java/commons-beanutils-1.7*
	=dev-java/commons-chain-1.1*
	>=dev-java/jakarta-jstl-1
	>=dev-java/commons-logging-1
	>=dev-java/commons-digester-1.6
	=dev-java/commons-validator-1.3*
	=dev-java/jakarta-oro-2.0*
	>=dev-java/commons-fileupload-1.1.1
	=dev-java/servletapi-2.3*
	=dev-java/bsf-2.3*
	=dev-java/jsfapi-1*
	>=dev-java/junit-3.8"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"

DEPEND=">=virtual/jdk-1.4
	${RDEPEND}
	>=dev-java/ant-1.6.0
	app-arch/zip"

S=${WORKDIR}/${P}/src

src_unpack() {
	unpack ${A}

	cd ${S}

	mkdir lib

	cd lib
	java-pkg_jarfrom antlr
	java-pkg_jarfrom commons-beanutils-1.7
	java-pkg_jarfrom commons-chain-1.1
	java-pkg_jarfrom jakarta-jstl
	java-pkg_jarfrom commons-logging
	java-pkg_jarfrom commons-digester
	java-pkg_jarfrom commons-validator-1.3
	java-pkg_jarfrom jakarta-oro-2.0
	java-pkg_jarfrom commons-fileupload
	java-pkg_jarfrom servletapi-2.3
	java-pkg_jarfrom bsf-2.3
	java-pkg_jarfrom jsfapi-1
	java-pkg_jarfrom junit
	cd ..

	epatch ${FILESDIR}/struts-1.3.build.xml.patch
}

src_compile() {
	eant all-modules $(use_doc)
}

src_install() {
	for module_name in "core" "taglib" "extras" "tiles" "scripting" "el" "faces"
	do
		java-pkg_dojar lib/struts-${module_name}.jar

		use source && java-pkg_dosrc ${module_name}/src/main/java/*
	done

	dodoc ../NOTICE.txt ../LICENSE.txt

	use doc && java-pkg_dohtml -r target/docs/
}
