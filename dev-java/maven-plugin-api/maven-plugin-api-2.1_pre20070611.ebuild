# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="source"
JAVA_MAVEN_BOOTSTRAP="Y"
inherit java-maven-2

SRC_URI="http://dev.gentooexperimental.org/~kiorky/${P}.tar.bz2"
DESCRIPTION="Maven is a software project management and comprehension tool."
HOMEPAGE="http://maven.apache.org/"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEP="dev-java/junit"
DEPEND=">=virtual/jdk-1.4 ${DEP}"
RDEPEND=">=virtual/jre-1.4 ${DEP}"
JAVA_MAVEN_CLASSPATH="junit"

JAVA_PKG_SRC_DIRS="src/main/java/*"
