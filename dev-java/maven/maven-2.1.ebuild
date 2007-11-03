# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_MAVEN_BOOTSTRAP="Y"
inherit java-maven-2 java-pkg-2 java-utils-2

DESCRIPTION="The core of Maven"
LICENSE="Apache-2.0"
HOMEPAGE="http://maven.apache.org"
COMMON_DEPS="
dev-java/maven-artifact
dev-java/maven-build-context
dev-java/maven-core
dev-java/maven-embedder
dev-java/maven-error-diagnostics
dev-java/maven-lifecycle
dev-java/maven-model
dev-java/maven-monitor
dev-java/maven-plugin-api
dev-java/maven-plugin-descriptor
dev-java/maven-plugin-parameter-documenter
dev-java/maven-plugins
dev-java/maven-profile
dev-java/maven-project
dev-java/maven-reporting
dev-java/maven-script
dev-java/maven-settings
dev-java/maven-shared-components

dev-java/doxia

dev-java/wagon-file
dev-java/wagon-ftp
dev-java/wagon-http-lightweight
dev-java/wagon-http-shared
dev-java/wagon-provider-api
dev-java/wagon-ssh
dev-java/wagon-ssh-common
dev-java/wagon-ssh-common-test
dev-java/wagon-ssh-external

=dev-java/commons-cli-1*
=dev-java/jdom-1.0*
dev-java/jsch
dev-java/jtidy

>=dev-java/plexus-component-api-1.0_alpha33_pre20071021
>=dev-java/plexus-container-default-1.0_alpha33_pre20071021
>=dev-java/plexus-utils-1.4.7_pre20071021
dev-java/plexus-active-collections
dev-java/plexus-classworlds
dev-java/plexus-interactivity-api
"


DEPEND=">=virtual/jdk-1.4 ${COMMON_DEPS} ${MAVEN_PLUGINS_DEPS}
source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.4 ${COMMON_DEPS} ${MAVEN_PLUGINS_DEPS}"
KEYWORDS="~x86"
IUSE="doc source"
SLOT="2"

# maven-repository-metadata
MAVEN_UBERJAR_FAKE="
doxia
maven-artifact
maven-build-context
maven-core
maven-embedder
maven-error-diagnostics
maven-lifecycle
maven-model
maven-monitor
maven-plugin-api
maven-plugin-descriptor
maven-plugin-parameter-documenter
maven-plugins
maven-profile
maven-project
maven-reporting
maven-script
maven-settings
maven-shared-components

wagon-file
wagon-ftp
wagon-http
wagon-http-lightweight
wagon-http-shared
wagon-provider-api
wagon-ssh
wagon-ssh-common
wagon-ssh-common-test
wagon-ssh-external

commons-cli-1
jdom-1.0
jsch
jtidy

plexus-active-collections
plexus-classworlds
plexus-utils-1.4.7
plexus-component-api-1.0_alpha33
plexus-container-default-1.0_alpha33
plexus-interactivity-api
"

src_unpack() {
	mkdir -p "${S}/gentoo_maven_jars" || die

	cd "${S}/gentoo_maven_jars" || die
	for i in ${MAVEN_UBERJAR_FAKE};do
		java-pkg_jar-from ${i}
	done

	# maven settings needs to be first
	inc=0
	for i in $(ls -1 *maven-settings*jar );do
		inc=$((inc+1))
		mv "$i" "0${inc}_${i}"
	done

	# copy our pom
	cp "${FILESDIR}/maven-${PV}.pom" "${S}/pom.xml" || die

	# generate our launch script
	if [[ ! -f "${S}/mvn" ]];then
		cp "${FILESDIR}/mvn" "${S}/mvn" || die
		sed -i "${S}/mvn" -re "s:__MAVENHOME__:${JAVA_MAVEN_SYSTEM_HOME}:g" || die
		sed -i "${S}/mvn" -re "s:__MAVENROOT__:${JAVA_MAVEN_ROOT_HOME}:g" || die
	else
		die "mvn file allready exists"
	fi
}

src_install() {
	# register maven pom
	java-maven-2_install_one

	# replacement for maven uberjar
	cd "${S}/gentoo_maven_jars" || die
	for i in $(ls -1 .); do
		java-pkg_dojar ${i}
	done

	cd "${S}" || die

	# classworlds and basic maven configurations
	keepdir "${JAVA_MAVEN_SYSTEM_HOME}/conf"
	insinto "${JAVA_MAVEN_SYSTEM_HOME}/conf"
	doins "${FILESDIR}/m2_classworlds.conf"
	doins "${FILESDIR}/settings.xml"

	# install our launchers
	# classworlds and basic maven configurations
	keepdir "${JAVA_MAVEN_ROOT_HOME}/conf"
	insinto "${JAVA_MAVEN_ROOT_HOME}/conf"
	doins "${FILESDIR}/m2_classworlds.conf"
	doins "${FILESDIR}/settings.xml"

	chmod 755 "${S}/mvn" || die
	exeinto /usr/bin
	doexe  "${S}/mvn"
}


# NOTES: PLEASE DO NOT ADD WAGON-HTTP. THIS WILL CONFLICT AND PREVENT MAVEN TO
# DOWNLOAD ANYTHING


