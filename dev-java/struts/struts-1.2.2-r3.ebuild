# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/struts/struts-1.2.2-r2.ebuild,v 1.2 2005/07/09 22:25:44 swegener Exp $

inherit java-pkg

DESCRIPTION="A powerful Model View Controller Framework for JSP/Servlets"
SRC_URI="mirror://apache/struts/source/jakarta-${P}-src.tar.gz"
HOMEPAGE="http://jakarta.apache.org/struts/index.html"
LICENSE="Apache-2.0"
SLOT="1.2"
DEPEND=">=virtual/jdk-1.4
	>=dev-java/ant-1.6.0
	jikes? ( dev-java/jikes )"
RDEPEND=">=virtual/jre-1.4
	=dev-java/commons-beanutils-1.6*
	>=dev-java/commons-collections-2.1
	dev-java/struts-legacy
	>=dev-java/commons-digester-1.5
	>=dev-java/commons-fileupload-1.0
	>=dev-java/commons-lang-2.0
	>=dev-java/commons-logging-1.0.4
	>=dev-java/commons-validator-1.1.3
	=dev-java/jakarta-oro-2.0*
	=dev-java/servletapi-2.3*"
IUSE="doc jikes"
KEYWORDS="~x86 ~ppc ~amd64"

S=${WORKDIR}/jakarta-struts

src_compile() {
	local antflags="compile.library"
	use doc && antflags="${antflags} compile.javadoc"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"

	antflags="${antflags} -Dcommons-beanutils.jar=`java-config -p commons-beanutils-1.6 | sed s/:.*// `"
	antflags="${antflags} -Dcommons-collections.jar=`java-config -p commons-collections`"
	antflags="${antflags} -Dstruts-legacy.jar=`java-config -p struts-legacy`"
	antflags="${antflags} -Dcommons-digester.jar=`java-config -p commons-digester`"
	antflags="${antflags} -Dcommons-fileupload.jar=`java-config -p commons-fileupload`"
	antflags="${antflags} -Djakarta-oro.jar=`java-config -p jakarta-oro-2.0`"
	antflags="${antflags} -Dservlet.jar=`java-config -p servletapi-2.3`"
	antflags="${antflags} -Dcommons-lang.jar=`java-config -p commons-lang`"
	antflags="${antflags} -Dcommons-logging.jar=`java-config -p commons-logging | sed 's/.*://'`"
	antflags="${antflags} -Dcommons-validator.jar=`java-config -p commons-validator`"

	ant ${antflags} || die "compile failed"
}


src_install() {
	java-pkg_dojar target/library/struts.jar

	#install the tld files
	insinto /usr/share/${PN}/lib
	doins target/library/*.tld

	dodoc README STATUS.txt
	use doc && java-pkg_dohtml -r target/documentation/
}
