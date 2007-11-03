# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_MAVEN_BOOTSTRAP="Y"
JAVA_MAVEN_ADD_GENERATED_STUFF="y"
JAVA_MAVEN_GENERATED_STUFF_UNPACK_DIR="${S}"
inherit java-maven-2

DESCRIPTION="Maven is a software project management and comprehension tool."
HOMEPAGE="http://maven.apache.org/"
MY_BASE_URL="http://dev.gentooexperimental.org/~kiorky"
# we need to backport older site-renderer that does not exists in current
# releases of doxia!
SRC_URI="
${SRC_URI}
${MY_BASE_URL}/doxia-sitetools-${PV}.tar.bz2
${MY_BASE_URL}/doxia-sitetools-${PV}-gen-src.tar.bz2
"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86"
IUSE="source doc"
COMMON_DEPS="
dev-java/commons-cli
dev-java/fop
=dev-java/itext-1.4
=dev-java/jakarta-oro-2.0*
dev-java/junit
dev-java/plexus-cli
>=dev-java/plexus-component-api-1.0_alpha33_pre20071021
>=maven-shared-components/maven-shared-components-2.1_pre20071021
>=dev-java/plexus-container-default-1.0_alpha33_pre20071021
dev-java/plexus-i18n
>=dev-java/plexus-utils-1.4.7_pre20071021
dev-java/plexus-velocity
dev-java/maven-plugin-api
dev-java/velocity
dev-java/xalan
dev-java/commons-configuration
>=dev-java/commons-lang-2.1
"
DEPEND=">=virtual/jdk-1.4 ${COMMON_DEPS}"
RDEPEND=">=virtual/jre-1.4 ${COMMON_DEPS}"

JAVA_MAVEN_CLASSPATH="
xalan
commons-configuration
commons-cli-1
commons-lang-2.1
fop
itext-1.4
jakarta-oro-2.0
junit
plexus-cli
plexus-component-api-1.0_alpha33
plexus-container-default-1.0_alpha33
maven-shared-components
maven-plugin-api
plexus-i18n
plexus-utils-1.4.7
plexus-velocity
velocity
"
# PLEASE KEEP  THE ORDER !
JAVA_MAVEN_PROJECTS="
${PF}/doxia-sink-api
${PF}/doxia-core
${PF}/doxia-modules/doxia-module-confluence
${PF}/doxia-modules/doxia-module-docbook-simple
${PF}/doxia-modules/doxia-module-twiki
${PF}/doxia-modules/doxia-module-xdoc
${PF}/doxia-modules/doxia-module-apt
${PF}/doxia-modules/doxia-module-itext
${PF}/doxia-modules/doxia-module-fml
${PF}/doxia-modules/doxia-module-latex
${PF}/doxia-modules/doxia-module-rtf
${PF}/doxia-modules/doxia-module-xhtml
${PF}/doxia-modules
${PF}/doxia-book
${PF}/doxia-maven-plugin
${PF}/
doxia-sitetools-${PV}/
doxia-sitetools-${PV}/doxia-decoration-model
${PF}/doxia-modules/doxia-module-fo
doxia-sitetools-${PV}/doxia-site-renderer
"

S="${WORKDIR}"
JAVA_MAVEN_PATCHES="${FILESDIR}/doxia-sitetools_DefaultSiteRenderer.java.diff"
src_unpack(){
	unpack "doxia-sitetools-${PV}.tar.bz2"
	cd "doxia-sitetools-${PV}" || die
	unpack "doxia-sitetools-${PV}-gen-src.tar.bz2"
	cd .. || die
	java-maven-2_src_unpack
	cp -rf 	\
	"doxia-sitetools-${PV}/doxia-doc-renderer/src/main" \
	"doxia-sitetools-${PV}/doxia-doc-renderer/src/test" \
	"${PF}/doxia-modules/doxia-module-fo/src" || die
}

# NOTE:
# i add doxia-sitetools inside the doxia main ebuild because there is
# interdependance between core doxia and doxia-sitetools
# Please bear in mind to make a bundle of the twices when bumping ;)
# for them to find and rewrite/use it. ;))
# the scheme is :
# TAR/doxia-PV/[[THE CO OF DOXIA]]
# TAR/doxia-sitetools-PV/[[THE CO OF DOXIASITETOOLS]
