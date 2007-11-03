# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_MAVEN_BOOTSTRAP="Y"
JAVA_MAVEN_ADD_GENERATED_STUFF="y"
inherit java-maven-2

DESCRIPTION="The Plexus project provides a full software stack for creating and executing software projects."
HOMEPAGE="http://plexus.codehaus.org/"

LICENSE="as-is" # http://plexus.codehaus.org/plexus-utils/license.html
SLOT="0"
KEYWORDS="~x86"
IUSE="source doc"
COMMON_DEPS="
>=dev-java/plexus-utils-1.4.7_pre20071021
>=dev-java/plexus-container-default-1.0_alpha33_pre20071021
>=dev-java/plexus-component-api-1.0_alpha33_pre20071021
"
DEPEND=">=virtual/jdk-1.4 	${COMMON_DEPS}"
RDEPEND=">=virtual/jre-1.4	${COMMON_DEPS}"

EANT_EXTRA_FLAGS="-Dproject.name=${PN}"
JAVA_MAVEN_CLASSPATH="
plexus-utils-1.4.7
plexus-container-default-1.0_alpha33
plexus-component-api-1.0_alpha33
"

