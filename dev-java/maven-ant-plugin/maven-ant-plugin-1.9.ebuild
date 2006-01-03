# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit maven-plugin

DESCRIPTION="Ant plugin for Maven"
# svn co http://svn.apache.org/repos/asf/maven/maven-1/plugins/tags/MAVEN_POM_1_5/ maven-pom-plugin-1.5
# tar cjvf maven-pom-plugin-1.5-gentoo.tar.bz2 maven-pom-plugin-1.5/
SLOT="1"
KEYWORDS="~x86"
IUSE=""

RDEPEND="dev-java/commons-jelly-tags-xml"
DEPEND="${RDEPEND}"

maven-plugin_populate-jars() {
	java-pkg_jar-from commons-jelly-tags-xml-1 \
			commons-jelly-tags-xml.jar \
			commons-jelly-tags-xml-20040613.030723.jar
}
