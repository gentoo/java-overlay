# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="source" #No javadoc target
JAVA_MAVEN_ADD_GENERATED_STUFF="y"
JAVA_MAVEN_BOOTSTRAP="Y"
JAVA_MAVEN_GENERATED_STUFF_UNPACK_DIR="${S}"
inherit java-maven-2

DESCRIPTION="Maven is a software project management and comprehension tool."
HOMEPAGE="http://maven.apache.org/"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
COMMON_DEPS="
=dev-java/jdom-1.0*
>=dev-java/plexus-utils-1.4.7_pre20071021
"
DEPEND=">=virtual/jdk-1.4 ${COMMON_DEPS}"
RDEPEND=">=virtual/jre-1.4 ${COMMON_DEPS}"
JAVA_MAVEN_CLASSPATH="
plexus-utils-1.4.7
jdom-1.0
"

RESTRICT=test
