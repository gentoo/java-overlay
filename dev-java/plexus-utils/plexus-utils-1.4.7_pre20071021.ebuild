# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="source" #no javadoc target

JAVA_MAVEN_BOOTSTRAP="Y"
inherit java-maven-2

DESCRIPTION="The Plexus project provides a full software stack for creating and executing software projects."
HOMEPAGE="http://plexus.codehaus.org/"
SRC_URI="http://dev.gentooexperimental.org/~kiorky/${P}.tar.bz2"
LICENSE="as-is" # http://plexus.codehaus.org/plexus-utils/license.html
SLOT="1.4.7"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEP="=dev-java/classworlds-1.1*"
DEPEND=">=virtual/jdk-1.4 ${DEP}"
RDEPEND=">=virtual/jre-1.4 ${DEP}"
EANT_EXTRA_FLAGS="-Dproject.name=${PN}"
JAVA_MAVEN_CLASSPATH="classworlds-1.1"

JAVA_PKG_SRC_DIRS="src/main/java/*"
RESTRICT="test" #until at least it works
