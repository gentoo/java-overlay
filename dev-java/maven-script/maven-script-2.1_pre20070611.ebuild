# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_MAVEN_BOOTSTRAP="Y"
inherit java-maven-2

DESCRIPTION="Maven is a software project management and comprehension tool."
SRC_URI="http://dev.gentooexperimental.org/~kiorky/${P}.tar.bz2"
HOMEPAGE="http://maven.apache.org/"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86"
IUSE="source doc"
COMMON_DEPS="
dev-java/ant-core
dev-java/bsh
=dev-java/classworlds-1.1*
dev-java/maven-artifact
dev-java/maven-model
dev-java/maven-plugin-api
dev-java/maven-plugin-descriptor
dev-java/maven-project
dev-java/plexus-archiver
dev-java/plexus-classworlds
>=dev-java/plexus-utils-1.4.7_pre20071021
>=dev-java/plexus-container-default-1.0_alpha33_pre20071021
>=dev-java/plexus-component-api-1.0_alpha33_pre20071021
dev-java/plexus-component-factories
"
DEPEND=">=virtual/jdk-1.4 ${COMMON_DEPS}"
RDEPEND=">=virtual/jre-1.4 ${COMMON_DEPS}"
JAVA_MAVEN_CLASSPATH="
ant-core
bsh
classworlds-1.1
maven-artifact
maven-model
maven-plugin-api
maven-plugin-descriptor
maven-project
plexus-archiver
plexus-classworlds
plexus-utils-1.4.7
plexus-container-default-1.0_alpha33
plexus-component-api-1.0_alpha33
plexus-component-factories
"
JAVA_MAVEN_PROJECTS="
maven-script-ant
maven-script-beanshell
"

