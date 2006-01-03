# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit maven-plugin

DESCRIPTION="POM plugin for Maven"
# svn co http://svn.apache.org/repos/asf/maven/maven-1/plugins/tags/MAVEN_POM_1_5/ maven-pom-plugin-1.5
# tar cjvf maven-pom-plugin-1.5-gentoo.tar.bz2 maven-pom-plugin-1.5/
SLOT="1"
KEYWORDS="~x86"

maven-plugin_populate-jars() {
	java-pkg_jar-from maven-core-1
	java-pkg_jar-from dom4j-1
	java-pkg_jar-from commons-jelly-tags-log-1
}
