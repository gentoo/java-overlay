# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="source doc"

JAVA_MAVEN_BOOTSTRAP="Y"
inherit java-maven-2

DESCRIPTION="The Wagon API project defines a simple API for transfering resources (artifacts) to and from repositories"
# svn co http://svn.apache.org/repos/asf/maven/wagon/tags/*/wagon-provider-api/ wagon-provider-api
SRC_URI="http://dev.gentooexperimental.org/~kiorky/${P}.tar.bz2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
LICENSE="Apache-2.0"
HOMEPAGE="http://maven.apache.org"
DEP="
=dev-java/commons-httpclient-2*
dev-java/commons-lang
dev-java/commons-logging
dev-java/jtidy
>=dev-java/plexus-component-api-1.0_alpha33_pre20071021
>=dev-java/plexus-container-default-1.0_alpha33_pre20071021
>=dev-java/plexus-utils-1.4.7_pre20071021
dev-java/wagon-http-shared
dev-java/wagon-provider-api
"
DEPEND=">=virtual/jdk-1.4 ${DEP}"
RDEPEND=">=virtual/jre-1.4 ${DEP}"
JAVA_MAVEN_CLASSPATH="
commons-httpclient
commons-lang
commons-logging
jtidy
plexus-component-api-1.0_alpha33
plexus-container-default-1.0_alpha33
plexus-utils-1.4.7
wagon-http-shared
wagon-provider-api
"

