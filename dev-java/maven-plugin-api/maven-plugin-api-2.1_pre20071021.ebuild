# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="source"
JAVA_MAVEN_GENERATED_STUFF_UNPACK_DIR="${S}"
JAVA_MAVEN_ADD_GENERATED_STUFF="Y"
JAVA_MAVEN_BOOTSTRAP="Y"
inherit java-maven-2

DESCRIPTION="Maven is a software project management and comprehension tool."
HOMEPAGE="http://maven.apache.org/"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
COMMON_DEPS="
dev-java/plexus-classworlds
>=dev-java/plexus-utils-1.4.7_pre20071021
dev-java/maven-artifact
>=dev-java/plexus-container-default-1.0_alpha33_pre20071021
>=dev-java/plexus-component-api-1.0_alpha33_pre20071021
dev-java/junit
dev-java/maven-lifecycle
"
DEPEND=">=virtual/jdk-1.4 ${COMMON_DEPS}"
RDEPEND=">=virtual/jre-1.4 ${COMMON_DEPS}"
JAVA_MAVEN_CLASSPATH="
junit
plexus-classworlds
maven-artifact
maven-lifecycle
plexus-utils-1.4.7
plexus-container-default-1.0_alpha33
plexus-component-api-1.0_alpha33
"

JAVA_PKG_SRC_DIRS="src/main/java/*"
