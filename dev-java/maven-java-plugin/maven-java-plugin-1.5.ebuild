# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit maven-plugin

DESCRIPTION="Java plugin for Maven"
# svn co http://svn.apache.org/repos/asf/maven/maven-1/plugins/tags/MAVEN_JAVA_1_5/ maven-java-plugin-1.5
# tar cjvf maven-java-plugin-1.5-gentoo.tar.bz2 maven-java-plugin-1.5
SLOT="1"
KEYWORDS="~x86"

S="${WORKDIR}/${P}/java"
