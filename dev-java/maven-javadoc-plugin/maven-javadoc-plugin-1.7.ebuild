# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit maven-plugin

DESCRIPTION="Javadoc plugin for Maven"
#  svn co http://svn.apache.org/repos/asf/maven/maven-1/plugins/tags/MAVEN_JAVADOC_1_7/ maven-javadoc-plugin-1.7
# tar cjvf maven-javadoc-plugin-1.7-gentoo.tar.bz2 maven-javadoc-plugin-1.7/
SLOT="1"
KEYWORDS="~x86"

RDEPEND="dev-java/commons-lang
	dev-java/commons-collections
	=dev-java/maven-xdoc-plugin-1*"
DEPEND="${RDEPEND}"
S="${WORKDIR}/${P}/javadoc"

maven-plugin_populate-jars() {
	java-pkg_jar-from commons-lang
	java-pkg_jar-from commons-collections
}
