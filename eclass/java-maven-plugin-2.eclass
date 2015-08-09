# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit java-maven-2

HOMEPAGE="http://maven.apache.org"
LICENSE="Apache-2.0"

JAVA_MAVEN_PLUGIN_COMMON_DEPS="
>dev-java/doxia-1.0_alpha9
dev-java/junit
dev-java/maven-artifact
dev-java/maven-base-poms
dev-java/maven-core
dev-java/maven-model
dev-java/maven-plugin-api
dev-java/maven-plugin-descriptor
dev-java/maven-project
dev-java/maven-reporting
dev-java/maven-settings
dev-java/maven-shared-components
dev-java/plexus-classworlds
>=dev-java/plexus-component-api-1.0_alpha33_pre20071021
>=dev-java/plexus-container-default-1.0_alpha33_pre20071021
>=dev-java/plexus-utils-1.4.7_pre20071021 
dev-java/wagon-provider-api
"
JAVA_MAVEN_PLUGIN_CLASSPATH="
doxia 
junit
maven-artifact
maven-core
maven-model
maven-plugin-api
maven-plugin-descriptor
maven-project
maven-reporting
maven-settings
maven-shared-components
plexus-classworlds
plexus-utils-1.4.7
plexus-component-api-1.0_alpha33
plexus-container-default-1.0_alpha33 
wagon-provider-api
"

RDEPEND=">=virtual/jre-1.4 ${JAVA_MAVEN_PLUGIN_COMMON_DEPS}"
DEPEND=">=virtual/jdk-1.4  ${JAVA_MAVEN_PLUGIN_COMMON_DEPS}"

java-maven-plugin-2_src_unpack() {
	java-maven-2_src_unpack
}

# if you override, think to append the eclass classpath.
java-maven-plugin-2_src_compile() {
	JAVA_MAVEN_CLASSPATH="${JAVA_MAVEN_CLASSPATH} ${JAVA_MAVEN_PLUGIN_CLASSPATH}"
	java-maven-2_src_compile
}

java-maven-plugin-2_src_install() {
	java-maven-2_src_install
}

EXPORT_FUNCTIONS src_unpack src_compile src_install

