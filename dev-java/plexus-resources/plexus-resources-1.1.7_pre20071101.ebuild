# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="source"
JAVA_MAVEN_ADD_GENERATED_STUFF="y"
JAVA_MAVEN_GENERATED_STUFF_UNPACK_DIR="${S}"
JAVA_MAVEN_BOOTSTRAP="Y"
inherit java-maven-2

DESCRIPTION="The Plexus project provides a full software stack for creating and executing software projects."
HOMEPAGE="http://plexus.codehaus.org/"
LICENSE="as-is" # http://plexus.codehaus.org/plexus-utils/license.html
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
JAVA_PKG_SRC_DIRS="src/main/java/org"
DEP="
>=dev-java/plexus-utils-1.4.7_pre20071021
>=dev-java/plexus-container-default-1.0_alpha33_pre20071021
>=dev-java/plexus-component-api-1.0_alpha33_pre20071021
"
DEPEND=">=virtual/jdk-1.4 ${DEP}"
RDEPEND=">=virtual/jre-1.4 ${DEP}"
JAVA_MAVEN_CLASSPATH="
plexus-utils-1.4.7
plexus-container-default-1.0_alpha33
plexus-component-api-1.0_alpha33
"
