# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit maven-plugin

DESCRIPTION="License plugin for Maven"
#  svn co http://svn.apache.org/repos/asf/maven/maven-1/plugins/tags/MAVEN_LICENSE_1_2 maven-license-plugin-1.2
# tar cjvf maven-license-plugin-1.2-gentoo.tar.bz2 maven-license-plugin-1.2
SLOT="1"
KEYWORDS="~x86"

RDEPEND="dev-java/commons-lang
	dev-java/commons-collections"

S="${WORKDIR}/${P}/license"

maven-plugin_populate-jars() {
	java-pkg_jar-from commons-lang
	java-pkg_jar-from commons-collections
}
