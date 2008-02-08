# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/struts/struts-1.1-r5.ebuild,v 1.2 2007/05/17 20:38:39 betelgeuse Exp $

WANT_ANT_TASKS="ant-trax"
JAVA_PKG_IUSE="doc source"
inherit java-pkg-2 java-ant-2

DESCRIPTION="A powerful Model View Controller Framework for JSP/Servlets"
SRC_URI="mirror://apache/jakarta/struts/source/jakarta-${P}-src.tar.gz"
HOMEPAGE="http://jakarta.apache.org/struts/index.html"
LICENSE="Apache-1.1"
SLOT="1.1"
COMMON_DEP="=dev-java/commons-beanutils-1.6*
	>=dev-java/commons-collections-2.1
	dev-java/struts-legacy
	>=dev-java/commons-digester-1.5
	>=dev-java/commons-fileupload-1.0
	=dev-java/commons-lang-2.0*
	>=dev-java/commons-logging-1.0
	=dev-java/commons-validator-1.1*
	=dev-java/jakarta-oro-2.0*
	=dev-java/servletapi-2.3*"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.4
	${COMMON_DEP}"
IUSE=""
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"

S=${WORKDIR}/jakarta-${P}-src

src_compile() {
	local antflags="compile.library"
	antflags="${antflags} -Dcommons-beanutils.jar=$(java-pkg_getjar commons-beanutils-1.6 commons-beanutils.jar)"
	antflags="${antflags} -Dcommons-collections.jar=$(java-pkg_getjar \
		commons-collections commons-collections.jar)"
	antflags="${antflags} -Dstruts-legacy.jar=$(java-pkg_getjars struts-legacy)"
	antflags="${antflags} -Dcommons-digester.jar=$(java-pkg_getjars commons-digester)"
	antflags="${antflags} -Dcommons-fileupload.jar=$(java-pkg_getjars commons-fileupload)"
	antflags="${antflags} -Djakarta-oro.jar=$(java-pkg_getjars jakarta-oro-2.0)"
	antflags="${antflags} -Dservlet.jar=$(java-pkg_getjars servletapi-2.3)"
	antflags="${antflags} -Dcommons-lang.jar=$(java-pkg_getjars commons-lang)"
	antflags="${antflags} -Dcommons-logging.jar=$(java-pkg_getjar commons-logging commons-logging.jar)"
	antflags="${antflags} -Dcommons-validator.jar=$(java-pkg_getjars commons-validator)"

	eant ${antflags} $(use_doc compile.javadoc)
}

src_install() {
	java-pkg_dojar target/library/${PN}.jar

	# install the tld files
	insinto /usr/share/${PN}-${SLOT}/lib
	doins target/library/*.tld

	dodoc README STATUS || die
	use doc && java-pkg_dojavadoc target/documentation/api
	use source && java-pkg_dosrc src/*/*
}
