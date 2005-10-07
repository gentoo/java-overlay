# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public Licence v2
# $Header: $

inherit java-pkg eutils

MY_P=${P/_beta/-beta-}-src
DESCRIPTION="Project Management and Comprehension Tool for Java"
SRC_URI="http://gentooexperimental.org/distfiles/${MY_P}.tar.bz2
http://gentooexperimental.org/distfiles/maven-plugins-20050905.tar.bz2"
# svn co http://svn.apache.org/repos/asf/maven/maven-1/core/tags/maven-1.1-beta-1/
# on 2005-09-05:
# svn co http://svn.apache.org/repos/asf/maven/maven-1/plugins/trunk/ maven-plugins

HOMEPAGE="http://maven.apache.org"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc jikes"
S=${WORKDIR}/${MY_P}

DEPEND=">=virtual/jdk-1.4
        >=dev-java/ant-core-1.5
		jikes? ( >=dev-java/jikes-1.21 )
		=dev-java/jaxen-1.1*"
RDEPEND=">=virtual/jre-1.4
		 >=dev-java/ant-core-1.6
		 >=dev-java/ant-tasks-1.6
		 =dev-java/commons-beanutils-1.6*
		 =dev-java/commons-cli-1*
		 >=dev-java/commons-collections-3.1
		 =dev-java/commons-httpclient-2.0*
		 =dev-java/commons-io-1*
		 =dev-java/commons-jelly-1*
		 =dev-java/commons-jelly-tags-ant-1*
		 =dev-java/commons-jelly-tags-define-1*
		 =dev-java/commons-jelly-tags-util-1*
		 =dev-java/commons-jelly-tags-xml-1*
		 =dev-java/commons-jelly-tags-interaction-1*
		 =dev-java/commons-jelly-tags-velocity-1*
		 =dev-java/commons-jelly-tags-log-1*
		 =dev-java/commons-jelly-tags-jsl-1*
		 =dev-java/commons-jexl-1.0*
		 >=dev-java/commons-lang-2.0
		 >=dev-java/commons-logging-1.0.3
		 >=dev-java/commons-net-1.2.1
		 =dev-java/dom4j-1.4*
		 =dev-java/xerces-2*
		 >=dev-java/forehead-1.0_beta5
		 >=dev-java/log4j-1.2.8
		 >=dev-java/forehead-1.0_beta5
		 >=dev-java/log4j-1.2.8
		 >=dev-java/plexus-utils-1.0_alpha2
		 >=dev-java/junit-3.8.1
		 ~dev-java/jdom-1.0_beta10
		 =dev-java/mrj-toolkit-stubs-bin-1*
		 =dev-java/abbot-0.13*
		 dev-java/saxpath
		 =dev-java/jaxen-1.0*
		 =dev-java/velocity-1*
		 >=dev-java/antlr-2.7.5
		 =dev-java/wagon-provider-api-1*
		 =dev-java/wagon-file-1*
		 =dev-java/wagon-ssh-1*
		 =dev-java/wagon-ssh-external-1*
		 =dev-java/wagon-http-1*
		 =dev-java/wagon-ftp-1*
		 >=dev-java/jsch-0.1.14
		 >=dev-java/aspectj-1.2
		 =dev-java/castor-0.9*
		 =dev-java/jakarta-regexp-1.3*
		 "
#		 >=dev-java/cvslib-3.6
#		 >=dev-java/xml-commons-1.0

REPOSITORY="${WORKDIR}/.maven/repository"
src_unpack() {
	unpack ${A} || die "Unpack Failed!"

	cd ${WORKDIR}/maven-plugins
#	epatch ${FILESDIR}/maven-plugins-20050905-gentoo.patch
	cd ${S}
	epatch ${FILESDIR}/${P}-gentoo.patch

	# The particular file names expected will probably change between releases
	mkdir -p ${REPOSITORY}/ant/jars
	cd ${REPOSITORY}/ant/jars
	java-pkg_jar-from ant-core ant.jar ant-1.6.5.jar
	java-pkg_jar-from ant-core ant.jar ant-1.5.3-1.jar
	java-pkg_jar-from ant-core ant-launcher.jar ant-launcher-1.6.5.jar
	# this probably isn't reliable...
	java-pkg_jar-from ant-tasks ant-junit.jar ant-optional-1.5.3-1.jar
	
	java-pkg_jar-from ant-tasks ant-trax.jar ant-trax-1.6.5.jar
	java-pkg_jar-from ant-tasks ant-junit.jar ant-junit-1.6.5.jar

	mkdir -p ${REPOSITORY}/commons-beanutils/jars
	cd ${REPOSITORY}/commons-beanutils/jars
	java-pkg_jar-from commons-beanutils-1.6 commons-beanutils.jar commons-beanutils-1.6.1.jar

	mkdir -p ${REPOSITORY}/commons-cli/jars
	cd ${REPOSITORY}/commons-cli/jars
	java-pkg_jar-from commons-cli-1 commons-cli.jar commons-cli-1.0-beta-2.jar

	mkdir -p ${REPOSITORY}/commons-collections/jars
	cd ${REPOSITORY}/commons-collections/jars
	java-pkg_jar-from commons-collections commons-collections.jar commons-collections-3.0.jar
	java-pkg_jar-from commons-collections commons-collections.jar commons-collections-3.1.jar

	mkdir -p ${REPOSITORY}/commons-httpclient/jars
	cd ${REPOSITORY}/commons-httpclient/jars
	java-pkg_jar-from commons-httpclient commons-httpclient.jar commons-httpclient-2.0.2.jar
	java-pkg_jar-from commons-httpclient commons-httpclient.jar commons-httpclient-2.0.jar

	mkdir -p ${REPOSITORY}/commons-io/jars
	cd ${REPOSITORY}/commons-io/jars
	java-pkg_jar-from commons-io-1 commons-io.jar commons-io-1.0.jar

	mkdir -p ${REPOSITORY}/commons-jelly/jars
	cd ${REPOSITORY}/commons-jelly/jars
	java-pkg_jar-from commons-jelly-1 commons-jelly.jar commons-jelly-1.0.jar
	java-pkg_jar-from commons-jelly-1 commons-jelly.jar commons-jelly-1.0-beta-4.jar
	java-pkg_jar-from commons-jelly-tags-ant-1 \
		commons-jelly-tags-ant.jar commons-jelly-tags-ant-1.1.jar
	java-pkg_jar-from commons-jelly-tags-define-1 \
		commons-jelly-tags-define.jar commons-jelly-tags-define-1.0.jar
	java-pkg_jar-from commons-jelly-tags-util-1 \
		commons-jelly-tags-util.jar commons-jelly-tags-util-1.1.1.jar
	java-pkg_jar-from commons-jelly-tags-xml-1 \
		commons-jelly-tags-xml.jar commons-jelly-tags-xml-1.0.jar
	java-pkg_jar-from commons-jelly-tags-xml-1 \
		commons-jelly-tags-xml.jar commons-jelly-tags-xml-1.1.jar
	java-pkg_jar-from commons-jelly-tags-interaction-1 \
		commons-jelly-tags-interaction.jar commons-jelly-tags-interaction-1.0.jar
	java-pkg_jar-from commons-jelly-tags-velocity-1 \
		commons-jelly-tags-velocity.jar commons-jelly-tags-velocity-1.0.jar
	java-pkg_jar-from commons-jelly-tags-antlr-1 \
		commons-jelly-tags-antlr.jar commons-jelly-tags-antlr-1.0.jar
	java-pkg_jar-from commons-jelly-tags-log-1 \
		commons-jelly-tags-log.jar commons-jelly-tags-log-1.0.jar
	java-pkg_jar-from commons-jelly-tags-jsl-1 \
		commons-jelly-tags-jsl.jar commons-jelly-tags-jsl-1.0.jar

	mkdir -p ${REPOSITORY}/commons-jexl/jars
	cd ${REPOSITORY}/commons-jexl/jars
	java-pkg_jar-from commons-jexl-1.0 commons-jexl.jar commons-jexl-1.0.jar
	java-pkg_jar-from commons-jexl-1.0 commons-jexl.jar commons-jexl-1.0-beta-1.jar

	mkdir -p ${REPOSITORY}/commons-lang/jars
	cd ${REPOSITORY}/commons-lang/jars
	java-pkg_jar-from commons-lang commons-lang.jar commons-lang-2.0.jar

	mkdir -p ${REPOSITORY}/commons-logging/jars
	cd ${REPOSITORY}/commons-logging/jars
	java-pkg_jar-from commons-logging commons-logging.jar commons-logging-1.0.3.jar

	mkdir -p ${REPOSITORY}/commons-net/jars
	cd ${REPOSITORY}/commons-net/jars
	java-pkg_jar-from commons-net commons-net.jar commons-net-1.2.1.jar
	java-pkg_jar-from commons-net commons-net.jar commons-net-1.1.0.jar

	mkdir -p ${REPOSITORY}/dom4j/jars
	cd ${REPOSITORY}/dom4j/jars
	java-pkg_jar-from dom4j-1 dom4j.jar dom4j-1.4.jar
	java-pkg_jar-from dom4j-1 dom4j.jar dom4j-1.4-dev-8.jar

	mkdir -p ${REPOSITORY}/forehead/jars
	cd ${REPOSITORY}/forehead/jars
	java-pkg_jar-from forehead forehead.jar forehead-1.0-beta-5.jar

	mkdir -p ${REPOSITORY}/log4j/jars
	cd ${REPOSITORY}/log4j/jars
	java-pkg_jar-from log4j log4j.jar log4j-1.2.8.jar
	# maven-model-3.0.0 ?
	# maven ?

	mkdir -p ${REPOSITORY}/plexus/jars
	cd ${REPOSITORY}/plexus/jars
	java-pkg_jar-from plexus-utils plexus-utils.jar plexus-utils-1.0-alpha-2.jar
	java-pkg_jar-from plexus-utils plexus-utils.jar plexus-utils-1.0-alpha-3.jar

	mkdir -p ${REPOSITORY}/gnu-regexp/jars
	cd ${REPOSITORY}/gnu-regexp/jars
	java-pkg_jar-from gnu-regexp-1 gnu-regexp.jar gnu-regexp-1.1.4.jar

	mkdir -p ${REPOSITORY}/xerces/jars
	cd ${REPOSITORY}/xerces/jars
	java-pkg_jar-from xerces-2 xercesImpl.jar xerces-2.4.0.jar
	java-pkg_jar-from xerces-2 xmlParserAPIs.jar xmlParserAPIs-2.2.1.jar

	mkdir -p ${REPOSITORY}/xml-apis/jars
	cd ${REPOSITORY}/xml-apis/jars
	java-pkg_jar-from xerces-2 xml-apis.jar xml-apis-1.0.b2.jar

	mkdir -p ${REPOSITORY}/junit/jars
	cd ${REPOSITORY}/junit/jars
	java-pkg_jar-from junit junit.jar junit-3.8.1.jar

	mkdir -p ${REPOSITORY}/jdom/jars
	cd ${REPOSITORY}/jdom/jars
	java-pkg_jar-from jdom-1.0_beta10 jdom.jar jdom-b10.jar

	mkdir -p ${REPOSITORY}/abbot/jars
	cd ${REPOSITORY}/abbot/jars
	java-pkg_jar-from abbot-0.13 abbot.jar abbot-0.13.0.jar

	mkdir -p ${REPOSITORY}/mrj/jars
	cd ${REPOSITORY}/mrj/jars
	java-pkg_jar-from mrj-toolkit-stubs-bin-1 MRJToolkitStubs.jar MRJToolkitStubs-1.0.jar

	mkdir -p ${REPOSITORY}/saxpath/jars
	cd ${REPOSITORY}/saxpath/jars
	java-pkg_jar-from saxpath saxpath.jar saxpath-1.0-FCS.jar

	mkdir -p ${REPOSITORY}/jaxen/jars
	cd ${REPOSITORY}/jaxen/jars
	java-pkg_jar-from jaxen jaxen-full.jar jaxen-1.0-FCS-full.jar

	mkdir -p ${REPOSITORY}/velocity/jars
	cd ${REPOSITORY}/velocity/jars
	java-pkg_jar-from velocity-1 velocity.jar velocity-1.4-dev.jar
	java-pkg_jar-from velocity-1 velocity.jar velocity-1.4.jar

	mkdir -p ${REPOSITORY}/antlr/jars
	cd ${REPOSITORY}/antlr/jars
	java-pkg_jar-from antlr antlr.jar antlr-2.7.5.jar

	mkdir -p ${REPOSITORY}/org.apache.maven.wagon/jars
	cd ${REPOSITORY}/org.apache.maven.wagon/jars
	java-pkg_jar-from wagon-provider-api-1 wagon-provider-api.jar \
		wagon-provider-api-1.0-alpha-3.jar
	java-pkg_jar-from wagon-file-1 wagon-file.jar wagon-file-1.0-alpha-3.jar
	java-pkg_jar-from wagon-file-1 wagon-file.jar wagon-file-1.0-alpha-4.jar
	java-pkg_jar-from wagon-ftp-1 wagon-ftp.jar wagon-ftp-1.0-alpha-3.jar
	java-pkg_jar-from wagon-ssh-1 wagon-ssh.jar wagon-ssh-1.0-alpha-3.jar
	java-pkg_jar-from wagon-ssh-1 wagon-ssh.jar wagon-ssh-1.0-alpha-4.jar
	java-pkg_jar-from wagon-ssh-external-1 wagon-ssh-external.jar \
		wagon-ssh-external-1.0-alpha-3.jar
	java-pkg_jar-from wagon-ssh-external-1 wagon-ssh-external.jar \
		wagon-ssh-external-1.0-alpha-4.jar
	java-pkg_jar-from wagon-http-1 wagon-http.jar wagon-http-1.0-alpha-4.jar
	java-pkg_jar-from wagon-http-1 wagon-http.jar wagon-http-1.0-alpha-3.jar

	mkdir -p ${REPOSITORY}/jsch/jars
	cd ${REPOSITORY}/jsch/jars
	java-pkg_jar-from jsch jsch.jar jsch-0.1.14.jar

	mkdir -p ${REPOSITORY}/aspectj/jars
	cd ${REPOSITORY}/aspectj/jars
	java-pkg_jar-from aspectj aspectjrt.jar aspectjrt-1.2.1.jar
	java-pkg_jar-from aspectj aspectjtools.jar aspectjtools-1.2.1.jar

	mkdir -p ${REPOSITORY}/castor/jars
	cd ${REPOSITORY}/castor/jars
	java-pkg_jar-from castor-0.9 castor.jar castor-0.9.5.jar

	mkdir -p ${REPOSITORY}/regexp/jars
	cd ${REPOSITORY}/regexp/jars
	java-pkg_jar-from jakarta-regexp-1.3 jakarta-regexp.jar regexp-1.3.jar

	mkdir -p ${REPOSITORY}/netbeans/jars
	cd ${REPOSITORY}/netbeans/jars
	java-pkg_jar-from javacvs cvslib.jar cvslib-3.6.jar

	# checkstyle-4.0-beta5
	# checkstyle-optional-4.0-beta5
	# commons-beanutils-core-1.7.0
}

src_compile() {
	local antflags="-Dmaven.plugins.directory=${WORKDIR}/maven-plugins" 
	antflags="${antflags} -Dmaven.test.skip=true"
	antflags="${antflags} -Dmaven.home.local=${WORKDIR}/.maven"
	antflags="${antflags} -Dmaven.repo.local=${WORKDIR}/.maven/repository"

	local mavenflags="-Dmaven.plugins.directory=${WORKDIR}/maven-plugins"
	if [ $(memory) -lt 524228 ] ; then
		echo
		ewarn "To build maven, atleast 512MB of RAM is recommended."
		ewarn "Your system has less than 512MB of RAM, continuing anyways."
		echo

		antflags="${antflags} -Xmx512m -Dmaven.test.skip=true"
		mavenflags="${mavenflags} -Xmx512m -Dmaven.test.skip=true"
	fi

	
	local MAVEN_HOME=${WORKDIR}/build
#	local MAVEN_HOME_LOCAL=${WORKDIR}/.maven/
#	local MAVEN_REPO_LOCAL=${WORKDIR}/.maven/

	
#	touch ${S}/build.properties
#	echo "maven.home.local=${WORKDIR}/.maven" >> ${S}/build.properties
#	echo "maven.dist.tar.executable=tar" >> ${S}/build.properties

	if use jikes ; then
		antflags="${antflags} -Dbuild.compiler=jikes"
	fi

	mkdir -p ${WORKDIR}/build
	cd ${WORKDIR}/build
#	MAVEN_HOME=${MAVEN_HOME} \
#		MAVEN_HOME_LOCAL=${MAVEN_HOME_LOCAL} \
#		MAVEN_REPO_LOCAL=${MAVEN_REPO_LOCAL} \
		MAVEN_HOME="${WORKDIR}/build" ant ${antflags} -f ${S}/build-bootstrap.xml || die "Compile Failed!"
}

src_install() {
	die "Not ready to install yet"
	dodir /usr/share/maven
	dodir /usr/lib/java

	exeinto /usr/bin
	doexe ${WORKDIR}/build/bin/maven

	insinto /etc/env.d
	doins ${FILESDIR}/25maven

	rm -rf ${WORKDIR}/build/repository
	cp -Rdp ${WORKDIR}/build/* ${D}/usr/share/maven 
}

function memory() {
	cat /proc/meminfo | grep MemTotal | sed -r "s/[^0-9]*([0-9]+).*/\1/"
}
