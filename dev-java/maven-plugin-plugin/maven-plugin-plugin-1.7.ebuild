# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# This version is meant for maven-1.1 apparently.
inherit maven-plugin

DESCRIPTION="Plugin plugin for Maven"
# svn co http://svn.apache.org/repos/asf/maven/maven-1/plugins/tags/MAVEN_PLUGIN_1_7/ maven-plugin-plugin-1.7
# tar cjvf maven-plugin-plugin-1.7-gentoo.tar.bz2 maven-plugin-plugin-1.7/

SLOT="1"
KEYWORDS="-*"

RDEPEND="
	=dev-java/commons-lang-2.0*
	=dev-java/commons-jelly-tags-xml-1*
	dev-java/commons-logging
	~dev-java/jdom-1.0
	dev-java/saxpath
	=dev-java/jaxen-1.0*
	>=dev-java/xerces-2.7
	dev-java/msv
	dev-java/iso-relax
	dev-java/relaxng-datatype
	dev-java/xsdlib
"
DEPEND="${RDEPEND}"

maven-plugin_populate-jars() {
	java-pkg_jar-from commons-lang
	java-pkg_jar-from commons-jelly-tags-xml-1
	java-pkg_jar-from commons-logging
	java-pkg_jar-from jdom-1.0
	java-pkg_jar-from saxpath
	java-pkg_jar-from jaxen
	java-pkg_jar-from xerces-2
	java-pkg_jar-from msv
	java-pkg_jar-from iso-relax
	java-pkg_jar-from relaxng-datatype
	java-pkg_jar-from xsdlib
}
