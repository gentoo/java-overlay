# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit maven-plugin

DESCRIPTION="Jar plugin for Maven"
# svn co http://svn.apache.org/repos/asf/maven/maven-1/plugins/tags/MAVEN_JAR_1_7/ maven-jar-plugin-1.7
# tar cjvf maven-jar-plugin-1.7-gentoo.tar.bz2 maven-jar-plugin-1.7/
SLOT="1"
KEYWORDS="~x86"

RDEPEND="dev-java/velocity
	dev-java/commons-jelly-tags-velocity"
DEPEND="${RDEPEND}"
