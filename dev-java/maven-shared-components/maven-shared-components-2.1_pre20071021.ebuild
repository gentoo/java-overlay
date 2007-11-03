# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_MAVEN_BOOTSTRAP="Y"
JAVA_MAVEN_ADD_GENERATED_STUFF="Y"

inherit java-maven-2

DESCRIPTION="Maven is a software project management and comprehension tool."
HOMEPAGE="http://maven.apache.org/"
MY_BASE_URL="http://dev.gentooexperimental.org/~kiorky"
SRC_URI="${MY_BASE_URL}/${P}.tar.bz2
${MY_BASE_URL}/${P}-gen-src.tar.bz2"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86"
IUSE="source doc"
COMMON_DEPS="
dev-java/maven-base-poms
dev-java/ant-core
dev-java/ant-junit
dev-java/bsh
=dev-java/doxia-1.0_alpha8*
>dev-java/doxia-1.0_alpha8
=dev-java/easymock-1*
dev-java/junit
>dev-java/maven-artifact-2.1_pre20070614
dev-java/maven-core
dev-java/maven-model
dev-java/maven-plugin-api
dev-java/maven-plugin-descriptor
dev-java/maven-project
dev-java/maven-settings
dev-java/plexus-archiver
dev-java/plexus-classworlds
dev-java/plexus-compiler
dev-java/maven-model-v3
=dev-java/dom4j-1.4*
>=dev-java/plexus-utils-1.4.7_pre20071021
>=dev-java/plexus-container-default-1.0_alpha33_pre20071021
>=dev-java/plexus-component-api-1.0_alpha33_pre20071021
dev-java/qdox
dev-java/bcel
dev-java/wagon-provider-api
dev-java/plexus-digest
dev-java/commons-collections
dev-java/xalan
dev-java/xml-commons
dev-java/maven-reporting
dev-java/commons-validator
=dev-java/asm-3*
dev-java/maven-build-context
"
DEPEND=">=virtual/jdk-1.4 ${COMMON_DEPS}"
RDEPEND=">=virtual/jre-1.4 ${COMMON_DEPS}"

JAVA_MAVEN_CLASSPATH="
commons-validator
commons-collections
ant-core
ant-junit
bsh
doxia-1.0_alpha8
doxia
plexus-digest
easymock-1
junit
dom4j-1.4
bcel
maven-build-context
maven-core
maven-model
maven-plugin-api
maven-plugin-descriptor
maven-project
maven-settings
plexus-archiver
plexus-classworlds
maven-model-v3
plexus-compiler
plexus-utils-1.4.7
plexus-container-default-1.0_alpha33
plexus-component-api-1.0_alpha33
qdox-1.6
wagon-provider-api
xalan
xml-commons
maven-reporting
asm-3
maven-artifact
"
# PLEASE KEEP  THE ORDER !
JAVA_MAVEN_PROJECTS="
maven-reporting-impl
maven-shared-io
maven-plugin-tools
file-management
maven-ant
maven-common-artifact-filters
maven-app-configuration
maven-repository-builder
maven-plugin-tools/maven-plugin-tools-model
maven-plugin-tools/maven-plugin-tools-api
maven-plugin-tools/maven-plugin-tools-java
maven-plugin-tools/maven-plugin-tools-ant
maven-plugin-tools/maven-plugin-tools-beanshell
maven-plugin-testing-harness
maven-invoker
maven-shared-monitor
maven-verifier
maven-archiver
maven-dependency-analyzer
maven-dependency-tree
maven-downloader
maven-model-converter
maven-osgi
maven-script
maven-shared-jar
maven-test-tools
maven-toolchain
"

# maven-web-ui-tests

JAVA_MAVEN_GENERATED_STUFF_UNPACK_DIR="${S}"
JAVA_MAVEN_PATCHES="${FILESDIR}/maven-artifact.patch"
# NOTE:
# * Be carefull, top pom.xml modules  were broken, i updated it by  hand before tarballing it ...
# for maven parent pom, just kick off the parent node from the pom.xml file!
# Maybe following modules are not neccessary so i dont include them:
# * maven-web-ui-tests #needing selenium / not used so not packaged atm
