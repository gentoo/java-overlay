# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 eutils

MY_PN=${PN}-framework
MY_P=${MY_PN}-${PV}
DESCRIPTION="Spring is a layered Java/J2EE application framework, based on code published in Expert One-on-One J2EE Design and Development by Rod Johnson (Wrox, 2002)."
HOMEPAGE="http://www.springframework.org/"
SRC_URI="mirror://sourceforge/${MY_PN/-/}/${MY_P}.zip"

LICENSE="Apache-2.0"
SLOT="0"

KEYWORDS="~amd64 ~x86"
# Jikes is broken:
# http://opensource.atlassian.com/projects/spring/browse/SPR-1097
#IUSE="doc jikes"
IUSE="doc source java5"

# TODO fix compilation with Java 1.6 due to JDBC4
DEPEND="
	java5? ( =virtual/jdk-1.5* )
	!java5? ( =virtual/jdk-1.4* )
	dev-java/ant-core
	dev-java/antlr
	app-arch/zip"
#	jikes? ( dev-java/jikes )
# TODO replace sun-jdbc-rowset-bin with free implementation?
RDEPEND="
	java5? (
		>=virtual/jre-1.5
		=dev-java/hibernate-annotations-3.0*
	)
	!java5? ( || ( =virtual/jre-1.4* =virtual/jre-1.5* ) )
	=www-servers/axis-1*
	=dev-java/aopalliance-1*
	dev-java/wsdl4j
	dev-java/c3p0
	=dev-java/burlap-2.1*
	=dev-java/hessian-2.1*
	=dev-java/cglib-2.1*
	dev-java/cos
	=dev-java/dom4j-1*
	=dev-java/easymock-1*
	dev-java/ehcache
	=dev-java/freemarker-2.3*
	=dev-java/hibernate-2*
	=dev-java/hibernate-3.0*
	dev-java/itext
	=dev-java/gnu-jaf-1*
	=dev-java/jboss-module-j2ee-4.0*
	=dev-java/servletapi-2.4*
	dev-java/jakarta-jstl
	dev-java/sun-jdbc-rowset-bin
	>=dev-java/xerces-2.7
	=dev-java/commons-attributes-2*
	=dev-java/commons-beanutils-1.7*
	dev-java/commons-dbcp
	dev-java/commons-digester
	dev-java/commons-fileupload
	=dev-java/commons-httpclient-3*
	dev-java/commons-lang
	dev-java/commons-logging
	dev-java/commons-pool
	=app-text/jasperreports-1.0*
	=dev-java/jamon-1*
	=dev-java/jotm-2.0*
	=dev-java/xapool-1.5*
	dev-java/junit
	dev-java/log4j
	=dev-java/jakarta-oro-2.0*
	dev-java/poi
	=dev-java/quartz-1.5*
	=dev-java/struts-1.2*
	dev-java/velocity
	dev-java/velocity-tools
	dev-java/xjavadoc
	=dev-java/gnu-javamail-1*
	=dev-java/mx4j-core-3.0*
	=dev-java/jboss-module-j2ee-4.0*
	dev-java/wsdl4j
	dev-java/jdbc2-stdext
	=dev-java/jexcelapi-2.5*"
#	dev-java/jmx
#	dev-java/jta
#	dev-java/jms
#	dev-java/sun-qname-bin
S="${WORKDIR}/${MY_P}"

# FIXME build.xml does autodetection of jdk version to figure out if
# annotations should be used. Should control it with a property.

ANTLR="antlr antlr.jar antlr-2.7.5H3.jar"
AOPALLIANCE="aopalliance-1 aopalliance.jar"
AXIS="axis-1 axis.jar"
SAAJ="axis-1 saaj.jar"
WSDL4J="wsdl4j wsdl4j.jar"
C3P0="c3p0 c3p0.jar c3p0-0.8.5.2.jar"
BURLAP="burlap-2.1 burlap.jar"
HESSIAN="hessian-2.1 hessian.jar"
CGLIB="cglib-2.1 cglib.jar cglib-nodep-2.1.jar"
COS="cos cos.jar"
DOM4J="dom4j-1"
EASYMOCK="easymock-1"
EHCACHE="ehcache ehcache.jar"
FREEMARKER="freemarker-2.3 freemarker.jar"
HIBERNATE2="hibernate-2 hibernate2.jar"
HIBERNATE3="hibernate-3 hibernate3.jar"
HSQLDB="hsqldb hsqldb.jar"
ITEXT="itext iText.jar itext-1.1.4.jar"
ACTIVATION="gnu-jaf-1 activation.jar"
J2EE="jboss-module-j2ee-4 jboss-j2ee.jar"
JAXRPC="jboss-module-j2ee-4 jboss-jaxrpc.jar"
QNAME="wsdl4j qname.jar"
JDBC_STDEXT="jdbc2-stdext jdbc2_0-stdext.jar"
#JMS="jms jms.jar"
JMS="jboss-module-j2ee-4 jboss-j2ee.jar"
JSP_API="servletapi-2.4 jsp-api.jar"
JSTL="jakarta-jstl jstl.jar"
JTA="jta jta.jar"
MAIL="gnu-javamail-1 gnumail.jar mail.jar"
ROWSET="sun-jdbc-rowset-bin rowset.jar"
SERVLET_API="servletapi-2.4 servlet-api.jar"
XML_APIS="xerces-2 xml-apis.jar"
COMMON_COLLECTIONS="commons-collections commons-collections.jar"
COMMONS_ATTRIBUTES_API="commons-attributes-2 commons-attributes-api.jar"
COMMONS_ATTRIBUTES_COMPILER="commons-attributes-2 commons-attributes-compiler.jar"
COMMONS_BEANUTILS="commons-beanutils-1.7"
COMMONS_DBCP="commons-dbcp commons-dbcp.jar"
COMMONS_DIGESTER="commons-digester commons-digester.jar"
COMMONS_FILEUPLOAD="commons-fileupload commons-fileupload.jar"
COMMONS_HTTPCLIENT="commons-httpclient commons-httpclient.jar"
COMMONS_LANG="commons-lang commons-lang.jar"
COMMONS_LOGGING="commons-logging commons-logging.jar"
COMMONS_POOL="commons-pool commons-pool.jar"
STANDARD="jakarta-jstl standard.jar"
JAMON="jamon-1 jamon.jar JAMon.jar"
JASPERREPORTS="jasperreports jasperreports.jar jaspereports-0.6.6.jar"
MX4J="mx4j-core-3.0 mx4j.jar"
MX4J_REMOTE="mx4j-core-3.0 mx4j-remote.jar"
JOTM="jotm-2.0 jotm.jar"
XAPOOL="xapool-1.5 xapool.jar"
JUNIT="junit junit.jar"
LOG4J="log4j log4j.jar log4j-1.2.9.jar"
JAKARTA_ORO="jakarta-oro-2.0 jakarta-oro.jar jakarta-oro-2.0.8.jar"
POI="poi poi.jar poi-2.5.1.jar"
QUARTZ="quartz-1.5 quartz.jar"
STRUTS="struts-1.2 struts.jar"
VELOCITY="velocity velocity.jar velocity-1.4.jar"
VELOCITY_TOOLS_GENERIC="velocity-tools velocity-tools-generic.jar velocity-tools-generic-1.1.jar"
VELOCITY_TOOLS_VIEW="velocity-tools velocity-tools-view.jar velocity-tools-view.1.jar"
JEXCELAPI="jexcelapi-2.5"
XJAVADOC="xjavadoc xjavadoc.jar xjavadoc-1.1.jar"

src_unpack() {
	unpack ${A}
	# disable support for toplink, ojb, jsf, jdo, and ibatis until they can be
	# propertly packaged
	# tweak build.xml, so it doesn't try to use specific jars in its classpaths
	epatch ${FILESDIR}/${P}-excludes.patch


	cd ${S}
	mkdir -p lib
	cd lib

	if use java5; then
		java-pkg_jar-from hibernate-annotations-3.0
	fi
	java-pkg_jar-from ${ANTLR}

	mkdir aopalliance
	cd aopalliance
	java-pkg_jar-from ${AOPALLIANCE}
	cd ..

	java-pkg_jar-from ${AXIS}
	java-pkg_jar-from ${SAAJ}
	java-pkg_jar-from ${WSDL4J}

	#96751
	java-pkg_jar-from ${C3P0}

	java-pkg_jar-from ${BURLAP} #97005
	java-pkg_jar-from ${HESSIAN} #97007

	java-pkg_jar-from ${CGLIB}

	#97011
	java-pkg_jar-from ${COS}

	java-pkg_jar-from ${DOM4J}

	java-pkg_jar-from ${EASYMOCK}

	java-pkg_jar-from ${EHCACHE}

	java-pkg_jar-from ${FREEMARKER}

	java-pkg_jar-from ${HIBERNATE2}
	java-pkg_jar-from ${HIBERNATE3}

	# ${S}/lib/hsqldb needed for example only
	# TODO: ${S}/lib/ibatis

	java-pkg_jar-from ${ITEXT}

	java-pkg_jar-from ${ACTIVATION}
	java-pkg_jar-from ${J2EE}
	java-pkg_jar-from ${JAXRPC}
	java-pkg_jar-from ${QNAME}
	java-pkg_jar-from ${JDBC_STDEXT}
	java-pkg_jar-from ${JMS}
	java-pkg_jar-from ${JSP_API}
	java-pkg_jar-from ${JSTL}
	java-pkg_jar-from ${MAIL}
	java-pkg_jar-from ${ROWSET} #97012
	java-pkg_jar-from ${SERVLET_API}
	java-pkg_jar-from ${XML_APIS}
	# don't need for compiling
#	java-pkg_jar-from ${JTA}

	mkdir ${S}/lib/jakarta-commons
	cd ${S}/lib/jakarta-commons
	# the following are only used for the example
	#rm commons-{beanutils,discovery,validator}.jar
	java-pkg_jar-from ${COMMONS_ATTRIBUTES_API} #97008
	java-pkg_jar-from ${COMMONS_ATTRIBUTES_COMPILER} #97008

	cd ..
	java-pkg_jar-from ${COMMONS_BEANUTILS}
	java-pkg_jar-from ${COMMONS_DBCP}
	java-pkg_jar-from ${COMMONS_DIGESTER}
	java-pkg_jar-from ${COMMONS_FILEUPLOAD}
	java-pkg_jar-from ${COMMONS_HTTPCLIENT}
	java-pkg_jar-from ${COMMONS_LANG}
	java-pkg_jar-from ${COMMONS_LOGGING}
	java-pkg_jar-from ${COMMONS_POOL}

	java-pkg_jar-from ${STANDARD}

	#97009
	java-pkg_jar-from ${JAMON}

	#96906
	java-pkg_jar-from ${JASPERREPORTS}

	# TODO ${S}/lib/jdo

	java-pkg_jar-from ${MX4J}
	java-pkg_jar-from ${MX4J_REMOTE}
#	rm jmxremote_optional.jar # only needed for testing

	java-pkg_jar-from ${JOTM}
	java-pkg_jar-from ${XAPOOL}

	# TODO ${S}/lib/jsf

	java-pkg_jar-from ${JUNIT}

	java-pkg_jar-from ${LOG4J}

	# TODO ${S}/lib/ojb

	java-pkg_jar-from ${JAKARTA_ORO}

	java-pkg_jar-from ${POI}

	java-pkg_jar-from ${QUARTZ}

	java-pkg_jar-from ${STRUTS}

	# TODO toplink

	java-pkg_jar-from ${VELOCITY}
	java-pkg_jar-from ${VELOCITY_TOOLS_GENERIC}
	java-pkg_jar-from ${VELOCITY_TOOLS_VIEW}

	java-pkg_jar-from ${JEXCELAPI}

	mkdir xdoclet
	cd xdoclet
	java-pkg_jar-from ${XJAVADOC}
}

src_compile() {
	local antflags="alljars"
#	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	use doc && antflags="${antflags} javadoc14"

	ant ${antflags} || die "Compilation failed"

	cp -r docs/reference/html_single reference
}

src_install() {
	java-pkg_dojar dist/*.jar

	dodoc changelog.txt notice.txt readme.txt

	use doc && java-pkg_dohtml -r docs/{MVC-step-by-step,api,taglib} reference
	use source && java-pkg_dosrc ${S}/src
}

# TODO figure out what the heck we should say here
#pkg_postinst() {
#	einfo "Notice:"
#	einfo "A number of Spring's features require packages which have"
#	einfo "not made their way into portage."
#	einfo "These features have been built using 3rd party JAR files,"
#	einfo ""
#}
