# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit maven-plugin

DESCRIPTION="Artifact plugin for Maven"
# svn co http://svn.apache.org/repos/asf/maven/maven-1/plugins/tags/MAVEN_ARTIFACT_1_4_1/artifact/ maven-artifact-plugin-1.4.1
# tar cjvf maven-artifact-plugin-1.4.1-gentoo.tar.bz2 maven-artifact-plugin-1.4.1
SLOT="1"
KEYWORDS="~x86"
IUSE=""

RDEPEND="
	=dev-java/maven-core-1*
	=dev-java/commons-io-1*
	dev-java/commons-net
	=dev-java/commons-httpclient-2*
	dev-java/commons-lang
	dev-java/commons-logging
	=dev-java/jsch
	=dev-java/commons-jelly-1*
	=dev-java/commons-jelly-tags-velocity-1*
	dev-java/velocity
"

PATCHES="${FILESDIR}/${P}-fileutils.patch"

maven-plugin_populate-jars() {
	java-pkg_jar-from maven-core-1
	java-pkg_jar-from commons-io-1
	java-pkg_jar-from commons-net
	java-pkg_jar-from commons-httpclient
	java-pkg_jar-from commons-lang
	java-pkg_jar-from commons-logging
	java-pkg_jar-from jsch
	java-pkg_jar-from commons-jelly-1
	java-pkg_jar-from commons-jelly-tags-velocity-1
	java-pkg_jar-from velocity
}
