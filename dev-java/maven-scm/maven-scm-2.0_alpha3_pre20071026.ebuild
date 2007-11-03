# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_MAVEN_BOOTSTRAP="y"
JAVA_MAVEN_ADD_GENERATED_STUFF="y"
JAVA_MAVEN_GENERATED_STUFF_UNPACK_DIR="${S}"
inherit java-maven-2

DESCRIPTION="Maven is a software project management and comprehension tool."
HOMEPAGE="http://maven.apache.org/"
#MY_BASE_URL="http://dev.gentooexperimental.org/~kiorky"
#MY_BASE_URL="http://localhost"
#SRC_URI="${MY_BASE_URL}/${P}.tar.bz2 ${MY_BASE_URL}/${P}-gen-src.tar.bz2"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="source doc"
COMMON_DEPS="
>=dev-java/plexus-container-default-1.0_alpha33_pre20071021
>=dev-java/plexus-component-api-1.0_alpha33_pre20071021
>=dev-java/plexus-utils-1.4.7_pre20071021
dev-java/junit
=dev-java/jakarta-regexp-1.4
dev-java/ganymed-ssh2
dev-java/maven-project
dev-java/maven-settings
dev-java/maven-plugin-api
"
## TEST ant-apache-regexp is usefull ?
## ADD cvsclient from org.netbeans.lib
## ADD maven-plugin-testing-harness from org.apache.maven.shared

DEPEND=">=virtual/jdk-1.4 ${COMMON_DEPS}"
RDEPEND=">=virtual/jre-1.4 ${COMMON_DEPS}"

JAVA_MAVEN_CLASSPATH="
plexus-container-default-1.0_alpha33
plexus-component-api-1.0_alpha33
plexus-utils-1.4.7
jakarta-regexp-1.4
ganymed-ssh2
maven-project
maven-settings
maven-plugin-api
junit
"

## TEST ant-apache-regexp is usefull ?

# PLEASE KEEP  THE ORDER !
JAVA_MAVEN_PROJECTS="
maven-scm-api
maven-scm-managers/maven-scm-manager-plexus
maven-scm-test
maven-scm-providers/maven-scm-provider-local
maven-scm-providers/maven-scm-providers-svn/maven-scm-provider-svn-commons
maven-scm-providers/maven-scm-providers-cvs/maven-scm-provider-cvs-commons
maven-scm-providers/maven-scm-providers-cvs/maven-scm-provider-cvstest
maven-scm-providers/maven-scm-providers-cvs/maven-scm-provider-cvsexe
maven-scm-providers/maven-scm-providers-cvs/maven-scm-provider-cvsjava
maven-scm-providers/maven-scm-providers-svn/maven-scm-provider-svntest
maven-scm-providers/maven-scm-providers-svn/maven-scm-provider-svnexe
maven-scm-providers/maven-scm-provider-vss
maven-scm-providers/maven-scm-provider-perforce
maven-scm-providers/maven-scm-provider-hg
maven-scm-providers/maven-scm-provider-bazaar
maven-scm-providers/maven-scm-provider-starteam
maven-scm-providers/maven-scm-provider-synergy
maven-scm-providers/maven-scm-provider-clearcase
maven-scm-plugin
maven-scm-client
maven-scm-site
"
