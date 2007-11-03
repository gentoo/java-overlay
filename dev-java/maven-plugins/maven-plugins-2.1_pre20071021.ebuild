# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="source" #no javadoc target
JAVA_MAVEN_BOOTSTRAP="Y"
JAVA_MAVEN_ADD_GENERATED_STUFF="y"
JAVA_MAVEN_GENERATED_STUFF_UNPACK_DIR="${S}"
inherit java-maven-plugin-2

DESCRIPTION="Maven is a software project management and comprehension tool."
HOMEPAGE="http://maven.apache.org/"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
COMMON_DEPS="
dev-java/ant-core
dev-java/ant-junit
dev-java/antlr
>=dev-java/bsh-2.0_beta4-r2
dev-java/checkstyle
dev-java/commons-collections
>=dev-java/commons-httpclient-3
=dev-java/commons-lang-2.1*
>dev-java/dom4j-1.4
dev-java/easymock
dev-java/gnu-javamail
=dev-java/jaxen-1.1*
>=dev-java/jdom-1.0_beta10-r4
dev-java/maven-plugin-registry
dev-java/plexus-active-collections
dev-java/plexus-archiver
dev-java/plexus-cli
dev-java/plexus-compiler
dev-java/plexus-digest
dev-java/plexus-i18n
dev-java/plexus-interactivity-api
dev-java/plexus-io
dev-java/plexus-mail-sender
dev-java/plexus-resources
dev-java/plexus-velocity
dev-java/saxpath
dev-java/velocity
dev-java/wagon
dev-java/wagon-file
dev-java/wagon-ftp
dev-java/wagon-http
dev-java/wagon-http-lightweight
dev-java/wagon-http-shared
dev-java/wagon-ssh
dev-java/wagon-ssh-common
dev-java/wagon-ssh-common-test
dev-java/wagon-ssh-external
dev-java/xalan
dev-java/xml-commons
dev-java/xstream
"
DEPEND=">=virtual/jdk-1.4 ${COMMON_DEPS}"
RDEPEND=">=virtual/jre-1.4 ${COMMON_DEPS}"
JAVA_MAVEN_CLASSPATH="
ant-core
ant-junit
antlr
bsh
checkstyle
commons-collections
commons-httpclient-3
commons-httpclient-3
commons-lang-2.1
dom4j-1
easymock-1
gnu-javamail-1
jaxen-1.1
jdom-1.0
maven-plugin-registry
plexus-active-collections
plexus-archiver
plexus-cli
plexus-compiler
plexus-digest
plexus-i18n
plexus-interactivity-api
plexus-io
plexus-mail-sender
plexus-resources
plexus-velocity
saxpath
velocity
wagon-file
wagon-ftp
wagon-http
wagon-http-lightweight
xstream
wagon-http-shared
wagon-ssh
wagon-ssh-common
wagon-ssh-common-test
wagon-ssh-external
xalan
xml-commons
"
RESTRICT=test
JAVA_PKG_SRC_DIRS="src/main/java/*"
JAVA_MAVEN_PROJECTS="
maven-ant-plugin
maven-antrun-plugin
maven-assembly-plugin
maven-changes-plugin
maven-clean-plugin
maven-compiler-plugin
maven-dependency-plugin
maven-deploy-plugin
maven-doap-plugin
maven-docck-plugin
maven-ear-plugin
maven-ejb-plugin
maven-gpg-plugin
maven-install-plugin
maven-invoker-plugin
maven-jar-plugin
maven-javadoc-plugin
maven-one-plugin
maven-patch-plugin
maven-plugin-plugin
maven-remote-resources-plugin
maven-repository-plugin
maven-resources-plugin
maven-source-plugin
maven-stage-plugin
maven-toolchains-plugin
maven-verifier-plugin
maven-war-plugin
"

# NOTES:
# those plugins are not packaged because i dont see them very used !
# And they used not packaged deps/crappy one
# So package them if only it is really neccesary
# * maven-plugin-plugin  dont compile! strange errors
# * maven-changelog-plugin  need maven-scm -> huge, can be done later
# * maven-checkstyle-plugin  : depends on a very old doxia, we will certainly
# not need it into our build system anyway as it is something to do reports
# against code written...
# * maven-eclipse-plugin  relying on bndlib, i suppose we ll not generated
#  eclipse projects files when emerging ;)
# * maven-help-plugin: not essential. do not build (api problems)
# * maven-idea-plugin : api problems, same as eclipse plugin
# maven-pmd-plugin  : api problem + lot of deps. This is for reporting, no need
# to have it for systems compiles.
# * maven-rar-plugin  needs MAVEN-SCM TODO: IMPORTANT TO PACKAGE THIS ONE
# QUICKLY
# * maven-site-plugin : we dont need reports and site plugins needs jetty stuff
# ...
# * maven-project-info-reports-plugin : no need  needs MAVEN-SCM


JAVA_MAVEN_PATCHES="${FILESDIR}/maven-javadoc-plugin.diff ${FILESDIR}/maven-war-plugin.diff"
#JAVA_MAVEN_PATCHES="${FILESDIR}/maven-assembly-plugin.patch"

