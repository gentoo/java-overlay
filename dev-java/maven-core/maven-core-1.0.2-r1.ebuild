# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-maven-2

MAVEN_JT_PV="1.0.1"
MY_PN=maven

DESCRIPTION="The core of Maven"
HOMEPAGE="http://maven.apache.org"
SRC_URI="http://dev.gentooexperimental.org/~kiorky/${PF}.tar.bz2
		http://gentooexperimental.org/distfiles/maven-jelly-tags-${MAVEN_JT_PV}-gentoo.tar.bz2"
LICENSE="Apache-2.0"
SLOT="1"
KEYWORDS=""
IUSE="doc source"
DEPS="dev-java/ant-core
	=dev-java/commons-beanutils-1.7*
	=dev-java/commons-betwixt-0.6*
	=dev-java/commons-cli-1*
	dev-java/commons-collections
	dev-java/commons-digester
	dev-java/commons-grant
	>=dev-java/commons-graph-0.8.2
	=dev-java/commons-httpclient-2*
	=dev-java/commons-io-1*
	=dev-java/commons-jelly-1*
	=dev-java/commons-jelly-tags-ant-1*
	=dev-java/commons-jelly-tags-define-1*
	=dev-java/commons-jelly-tags-util-1*
	=dev-java/commons-jelly-tags-xml-1*
	=dev-java/commons-jexl-1.0*
	dev-java/commons-lang
	dev-java/junit
	dev-java/commons-logging
	=dev-java/dom4j-1.6*
	dev-java/forehead
	=dev-java/jaxen-1.1*
	dev-java/log4j
	dev-java/plexus-utils
	>=dev-java/xerces-2.7
	dev-java/xml-commons
	dev-java/werkz
	dev-java/ant-nodeps
	dev-java/ant-jsch
	=virtual/jdk-1.4*
	"
DEPEND="${DEPS}
		source? ( app-arch/zip )"
RDEPEND="${DEPS}"

EANT_DOC_TARGET="javadoc"
EANT_BUILD_TARGET="jar"
#We will need to check wich opt ant task is used !
EANT_GENTOO_CLASSPATH="ant-core
				commons-beanutils-1.7
				commons-cli-1
				commons-collections
				commons-digester
				commons-grant
				commons-httpclient
				commons-io-1
				commons-jelly-1
				commons-jelly-tags-ant-1
				commons-jelly-tags-define-1
				commons-jelly-tags-util-1
				commons-jelly-tags-xml-1
				commons-jexl-1.0
				commons-lang
				commons-logging
				commons-betwixt-0.7
				dom4j-1
				forehead
				jaxen-1.1
				log4j
				plexus-utils
				xerces-2
				xml-commons
				junit
				werkz
				commons-graph"

S="${WORKDIR}/${PF}"

# build process:
# 1. build maven-core + jellytags as there will no circular dependencies
# 2. build maven-core with classes reference
# 3. build jellytags  with classes reference

src_unpack() {
	unpack ${A}
	# change org.apache.plexus to org.codehaus.plexus
	sed -i -e 's/org\.apache\.plexus/org\.codehaus\.plexus/g' \
		"${S}"/src/java/org/apache/maven/plugin/GoalToJellyScriptHousingMapper.java \
		"${S}"/src/java/org/apache/maven/util/DVSLPathTool.java \
		"${S}"/src/java/org/apache/maven/repository/AbstractArtifact.java\
		|| die
	# maven and jelly orginals
	cp -rf "${S}" "${S}-dist"
	cp -rf "${WORKDIR}/maven-jelly-tags-${MAVEN_JT_PV}/src" "${S}" || die
	#copy ant files
	cp -f "${FILESDIR}/build.xml-${PVR}" \
		"${S}/build.xml" || die
	cp -f "${FILESDIR}/build.xml-core-${PVR}" \
		"${S}-dist/build.xml" || die
	cp -f "${FILESDIR}/build.xml-jelly-${PVR}"\
		"maven-jelly-tags-${MAVEN_JT_PV}/build.xml" || die
	# remove bundled jars
	find . -name *.jar -type f -exec rm -rf '{}' \;
	# rewrite some stuff
	java-maven-2-rewrite_build_xml
	# add maven.jar big jar to the classpath of #2 and #3
	for i in\
		"${S}-dist/build.xml"\
		"maven-jelly-tags-${MAVEN_JT_PV}/build.xml";
	do
		sed -i $i -re\
		 's/path=\"\$\{gentoo.classpath\}\"/path=\"\.\.\/\$\{pf\}\/target\/maven.jar:\$\{gentoo.classpath\}\"/'\
		 || die
	done
	# fix version
	sed -i ${S}-dist/src/conf/driver.properties -re\
		"s/@pom.currentVersion@/${PV}-gentoo/g"\
		|| die
}

src_compile(){
	local antflags="-Dpf=${PN}-${PVR}"
	#1
	eant ${EANT_BUILD_TARGET} ${antflags}
	eant $(use_doc ${EANT_DOC_TARGET})
	#i2
	cd "${S}-dist" || die
	eant ${EANT_BUILD_TARGET} ${antflags}
	eant $(use_doc ${EANT_DOC_TARGET})
	#3
	cd "${WORKDIR}/maven-jelly-tags-${MAVEN_JT_PV}" || die
	eant ${EANT_BUILD_TARGET} ${antflags}
	eant $(use_doc ${EANT_DOC_TARGET})
}

src_install() {
	cd "${WORKDIR}/maven-jelly-tags-${MAVEN_JT_PV}" || die
	java-pkg_newjar target/*.jar /maven-jelly-tags.jar

	cd "${S}-dist" || die
	java-pkg_dojar target/${MY_PN}.jar

	dodir "${JAVA_MAVEN_SYSTEM_HOME}"
	insinto "${JAVA_MAVEN_SYSTEM_HOME}"
	doins src/xsd/*
	doins src/conf/driver.properties

	keepdir "${JAVA_MAVEN_SYSTEM_PLUGINS}"
	keepdir "${JAVA_MAVEN_SYSTEM_REPOSITORY}"

	# Doing an equivalent launcher to:
	# "JAVA_HOME/bin/java" \
	# 	MAVEN_OPTS="-Xmx256m" \
	# 	-Djavax.xml.parsers.SAXParserFactory=org.apache.xerces.jaxp.SAXParserFactoryImpl \
	# 	-Djavax.xml.parsers.DocumentBuilderFactory=org.apache.xerces.jaxp.DocumentBuilderFactoryImpl \
	# 	"-Djava.endorsed.dirs=${MAVEN_ENDORSED}" \
	#  	-classpath "${MAVEN_HOME}/lib/forehead-${FOREHEAD_VERSION}.jar" \
	#  	"-Dforehead.conf.file=${MAVEN_HOME}/bin/forehead.conf"  \
	#  	"-Dtools.jar=$TOOLS_JAR" \
	#  	"-Dmaven.home=${MAVEN_HOME}" \
	#  	com.werken.forehead.Forehead  "$@"
	local JAVAOPT="-Djavax.xml.parsers.SAXParserFactory=org.apache.xerces.jaxp.SAXParserFactoryImpl
			-Djavax.xml.parsers.DocumentBuilderFactory=org.apache.xerces.jaxp.DocumentBuilderFactoryImpl
			-Dmaven.plugin.dir=${JAVA_MAVEN_SYSTEM_PLUGINS}
			-Dmaven.repo.remote=file:/${JAVA_MAVEN_SYSTEM_REPOSITORY}
			-Dtools.jar=\$(java-config-2 -t) -Dmaven.home=${JAVA_MAVEN_SYSTEM_HOME}	"
	for i in $(java-config -p ant-jsch,ant-nodeps) "${D}usr/share/${PN}-${SLOT}"/lib/*.jar;do
		java-pkg_regjar $i
	done
	java-pkg_dolauncher maven-${SLOT}  --java_args "${JAVAOPT}" \
		--main org.apache.maven.cli.App
}
