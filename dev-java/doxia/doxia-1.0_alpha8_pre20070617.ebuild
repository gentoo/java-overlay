# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_MAVEN_BOOTSTRAP="Y"
JAVA_MAVEN_ADD_GENERATED_STUFF="y"
JAVA_MAVEN_GENERATED_STUFF_UNPACK_DIR="${S}"
inherit java-maven-2

DESCRIPTION="Maven is a software project management and comprehension tool."
HOMEPAGE="http://maven.apache.org/"
LICENSE="Apache-2.0"
SLOT="1.0_alpha8"
KEYWORDS="~x86"
IUSE="source doc"
COMMON_DEPS="
=dev-java/jakarta-oro-2.0*
dev-java/junit
>=dev-java/plexus-component-api-1.0_alpha33_pre20071021
>=dev-java/plexus-container-default-1.0_alpha33_pre20071021
dev-java/plexus-i18n
>=dev-java/plexus-utils-1.4.7_pre20071021
dev-java/plexus-velocity
dev-java/velocity
"
DEPEND=">=virtual/jdk-1.4 ${COMMON_DEPS}"
RDEPEND=">=virtual/jre-1.4 ${COMMON_DEPS}"

JAVA_MAVEN_CLASSPATH="
jakarta-oro-2.0
junit
plexus-component-api-1.0_alpha33
plexus-container-default-1.0_alpha33
plexus-i18n
plexus-utils-1.4.7
plexus-velocity
velocity
"
# add  a patch to add interdeps while compiling:
#  doxia-sink-api for core
#  doxia-core     for tkwiki
#  doxia-decoration-model for siterdr
#  doxia-core for siterdr
JAVA_MAVEN_PROJECTS="
doxia-sink-api doxia-core
doxia-decoration-model
doxia-site-renderer
doxia-modules/doxia-module-confluence
doxia-modules/doxia-module-docbook-simple
doxia-modules/doxia-module-twiki
"

