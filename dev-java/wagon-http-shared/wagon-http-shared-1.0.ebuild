# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="source"
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
DEP="dev-java/jtidy dev-java/wagon-provider-api >=dev-java/plexus-utils-1.4.7"
DEPEND=">=virtual/jdk-1.4 ${DEP}"
RDEPEND=">=virtual/jre-1.4 ${DEP}"
JAVA_MAVEN_CLASSPATH="jtidy wagon-provider-api plexus-utils-1.4.7"

RESTRICT=test
JAVA_PKG_SRC_DIRS="src/main/java/*"
