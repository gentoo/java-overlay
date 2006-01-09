# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit maven-plugin

DESCRIPTION="Site generation plugin for Maven"
# svn co http://svn.apache.org/repos/asf/maven/maven-1/plugins/tags/MAVEN_CHANGES_1_6/ maven-changes-plugins-1.6
# tar cjvf maven-changes-plugins-1.6-gentoo.tar.bz2 maven-changes-plugins-1.6/

SLOT="1"
KEYWORDS="~x86"

RDEPEND="
	=dev-java/dom4j-1*
	=dev-java/jaxen-1.1*
	=dev-java/commons-io-1*
"
DEPEND="${RDEPEND}"

maven-plugin_populate-jars() {
	java-pkg_jar-from dom4j-1
	java-pkg_jar-from jaxen-1.1
	java-pkg_jar-from commons-io-1
}
