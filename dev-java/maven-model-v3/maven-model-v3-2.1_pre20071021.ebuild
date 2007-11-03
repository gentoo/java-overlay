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

# STEPS TO BUILD:
# - co the src on the tag on the svn
#     * http://svn.apache.org/repos/asf/maven/components/tags/maven-model-3.0.2/
# - patch the pom to include the version for :
#   * jdom : 1.0
#   * plexus-utils : 1.4.6
# - mkdir src/main/java for ant:ant to include the compile step on the build.xml
# - run maven -P all-models compile to generate the stuff (check the pom for
#   adequat profile.)
# - patch:
#     * src/main/java/org/apache/maven/model/v3_0_0/io/jdom/MavenJDOMWriter.java
# - rename the import org.apache.model.Model to org.apache.v3_0_0.model.Model
