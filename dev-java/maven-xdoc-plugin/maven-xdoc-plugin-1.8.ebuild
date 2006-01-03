# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit maven-plugin

DESCRIPTION="Xdoc plugin for Maven"
# svn co http://svn.apache.org/repos/asf/maven/maven-1/plugins/tags/MAVEN_XDOC_1_8/xdoc/ maven-xdoc-plugin-1.8
# tar cjvf maven-xdoc-plugin-1.8-gentoo.tar.bz2 maven-xdoc-plugin-1.8/
SLOT="1"
KEYWORDS="~x86"

RDEPEND="
	=dev-java/dom4j-1*
	=dev-java/commons-jelly-1*
	=dev-java/commons-jelly-tags-jsl-1*
	=dev-java/commons-jelly-tags-log-1*
	=dev-java/commons-jelly-tags-velocity-1*
	=dev-java/commons-jelly-tags-xml-1*
	dev-java/commons-logging
	=dev-java/maven-core-1*
	dev-java/velocity
	dev-java/dvsl
	dev-java/xml-commons"
DEPEND="${RDEPEND}"

maven-plugin_populate-jars() {
	java-pkg_jar-from dom4j-1
	java-pkg_jar-from commons-jelly-1
	java-pkg_jar-from commons-jelly-tags-jsl-1
	java-pkg_jar-from commons-jelly-tags-log-1
	java-pkg_jar-from commons-jelly-tags-velocity-1
	java-pkg_jar-from commons-jelly-tags-xml-1
	java-pkg_jar-from commons-logging
	java-pkg_jar-from maven-core-1
	java-pkg_jar-from velocity
	java-pkg_jar-from dvsl
	java-pkg_jar-from xml-commons xml-apis.jar
}
