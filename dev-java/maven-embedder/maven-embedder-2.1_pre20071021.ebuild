# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $


JAVA_MAVEN_BOOTSTRAP="y"
JAVA_PKG_IUSE="source doc"
inherit java-maven-2

SRC_URI="http://dev.gentooexperimental.org/~kiorky/${P}.tar.bz2"
DESCRIPTION="Maven is a software project management and comprehension tool."
HOMEPAGE="http://maven.apache.org/"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
COMMON_DEPS="
=dev-java/commons-cli-1*
=dev-java/jdom-1.0*
dev-java/maven-artifact
dev-java/maven-build-context
dev-java/maven-core
dev-java/maven-lifecycle
dev-java/maven-model
dev-java/maven-monitor
>=dev-java/plexus-utils-1.4.7_pre20071021
dev-java/maven-plugin-api
dev-java/maven-plugin-descriptor
dev-java/maven-profile
dev-java/maven-project
dev-java/maven-settings
dev-java/plexus-classworlds
>=dev-java/plexus-component-api-1.0_alpha33_pre20071021
>=dev-java/plexus-container-default-1.0_alpha33_pre20071021
dev-java/wagon-file
dev-java/wagon-http-lightweight
dev-java/wagon-provider-api
dev-java/wagon-ssh
dev-java/wagon-ssh-external
"
DEPEND=">=virtual/jdk-1.4 ${COMMON_DEPS}"
RDEPEND=">=virtual/jre-1.4 ${COMMON_DEPS}"
JAVA_PKG_SRC_DIRS="src/main/java/*"
JAVA_MAVEN_CLASSPATH="
commons-cli-1
jdom-1.0
maven-artifact
maven-build-context
maven-core
maven-lifecycle
maven-model
maven-monitor
maven-plugin-api
maven-plugin-descriptor
maven-profile
maven-project
maven-settings
plexus-classworlds
plexus-component-api-1.0_alpha33
plexus-container-default-1.0_alpha33
plexus-utils-1.4.7
wagon-file
wagon-http-lightweight
wagon-provider-api
wagon-ssh
wagon-ssh-external
"

