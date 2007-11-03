# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="source" #no javadoc target

JAVA_MAVEN_ADD_GENERATED_STUFF="y"
JAVA_MAVEN_GENERATED_STUFF_UNPACK_DIR="${S}"
JAVA_MAVEN_BOOTSTRAP="Y"
inherit java-maven-2

DESCRIPTION="Maven is a software project management and comprehension tool."
HOMEPAGE="http://maven.apache.org/"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEP="
=dev-java/classworlds-1*
dev-java/plexus-classworlds
dev-java/plexus-active-collections
>=dev-java/plexus-component-api-1.0_alpha33_pre20071021
>=dev-java/plexus-container-default-1.0_alpha33_pre20071021
>=dev-java/plexus-utils-1.4.7_pre20071021
dev-java/wagon-provider-api
dev-java/wagon-file
dev-java/junit
dev-java/easymock
"
DEPEND=">=virtual/jdk-1.4 ${DEP}"
RDEPEND=">=virtual/jre-1.4 ${DEP}"
JAVA_MAVEN_CLASSPATH="
classworlds-1
plexus-classworlds
plexus-active-collections
plexus-component-api-1.0_alpha33
plexus-container-default-1.0_alpha33
plexus-utils-1.4.7
wagon-provider-api
wagon-file
easymock-1
junit
"

RESTRICT=test
JAVA_PKG_SRC_DIRS="src/main/java/*"

# NOTE: the tests are merged with the compiled classes for plexus-compiler to build.
# please adapt future build.xml when bumping

