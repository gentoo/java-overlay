# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit maven-plugin

DESCRIPTION="Plugin plugin for Maven"
# svn co http://svn.apache.org/repos/asf/maven/maven-1/plugins/tags/MAVEN_PLUGIN_1_7/ maven-plugin-plugin-1.7
# tar cjvf maven-plugin-plugin-1.7-gentoo.tar.bz2 maven-plugin-plugin-1.7/

SLOT="1"
KEYWORDS="~x86"

RDEPEND="
	=dev-java/commons-jelly-tags-xml-1*
	=dev-java/commons-jelly-tags-interaction-1*
"
DEPEND="${RDEPEND}"

maven-plugin_populate-jars() {
	java-pkg_jar-from commons-jelly-tags-xml-1
	java-pkg_jar-from commons-jelly-tags-interaction-1.0
}
