# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit maven-plugin

DESCRIPTION="Site generation plugin for Maven"
# svn co http://svn.apache.org/repos/asf/maven/maven-1/plugins/tags/maven-site-plugin-1.6.1/
# tar cjvf maven-site-plugin-1.6.1-gentoo.tar.bz2 maven-site-plugin-1.6.1/

SLOT="1"
KEYWORDS="~x86"

RDEPEND="
	=dev-java/commons-lang-2.0*
	>=dev-java/ant-tasks-1.6.5
	=dev-java/commons-net-1*
	=dev-java/jakarta-oro-2.0*
	=dev-java/maven-changes-plugin-1*
"
DEPEND="${RDEPEND}"
