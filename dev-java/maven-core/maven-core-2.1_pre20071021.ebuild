# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_MAVEN_BOOTSTRAP="Y"
inherit java-utils-2 java-maven-2

MY_PN=maven

DESCRIPTION="The core of Maven"
HOMEPAGE="http://maven.apache.org"
SRC_URI="http://dev.gentooexperimental.org/~kiorky/${PF}.tar.bz2"
COMMON_DEPS="
=dev-java/classworlds-1.1*
=dev-java/commons-cli-1*
dev-java/commons-lang
=dev-java/commons-lang-2.3*
dev-java/commons-logging
dev-java/doxia
dev-java/maven-artifact
dev-java/maven-build-context
dev-java/maven-error-diagnostics
dev-java/maven-lifecycle
dev-java/maven-model
dev-java/maven-monitor
dev-java/maven-plugin-api
dev-java/maven-plugin-descriptor
dev-java/maven-plugin-parameter-documenter
dev-java/maven-profile
dev-java/plexus-interactivity-api
dev-java/maven-project
dev-java/maven-reporting
dev-java/maven-settings
dev-java/plexus-classworlds
dev-java/plexus-active-collections
>=dev-java/plexus-container-default-1.0_alpha33_pre20071021
>=dev-java/plexus-component-api-1.0_alpha33_pre20071021
>=dev-java/plexus-utils-1.4.7_pre20071021
dev-java/wagon-http-lightweight
dev-java/wagon-provider-api
dev-java/wagon-ssh
dev-java/wagon-ssh-external
"
DEPEND=">=virtual/jdk-1.4 ${COMMON_DEPS}
source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.4 ${COMMON_DEPS}"
KEYWORDS="~x86"
IUSE="doc source"
SLOT="0"
JAVA_MAVEN_CLASSPATH="
classworlds-1.1
commons-cli-1
commons-lang-2.1
commons-logging
doxia
maven-artifact
maven-build-context
maven-error-diagnostics
maven-lifecycle
maven-model
maven-monitor
maven-plugin-api
maven-plugin-descriptor
maven-plugin-parameter-documenter
maven-profile
maven-project
maven-reporting
maven-settings
plexus-active-collections
plexus-classworlds
plexus-interactivity-api
plexus-container-default-1.0_alpha33
plexus-component-api-1.0_alpha33
plexus-utils-1.4.7
wagon-http-lightweight
wagon-provider-api
wagon-ssh
wagon-ssh-external
"

src_unpack() {
	java-maven-2_src_unpack
	mkdir -p "${S}/src/main/resources" || die
	cp "${FILESDIR}/pom.properties" "${S}/src/main/resources" || die
}

src_install() {
	java-maven-2_src_install

	# default configuration
	dodir "${JAVA_MAVEN_SYSTEM_HOME}"
	insinto "${JAVA_MAVEN_SYSTEM_HOME}"
	doins  "${S}/src/conf/settings.xml"

	# create plugins and systtem repository directories
	keepdir "${JAVA_MAVEN_SYSTEM_PLUGINS}"
	keepdir "${JAVA_MAVEN_SYSTEM_REPOSITORY}"
}

