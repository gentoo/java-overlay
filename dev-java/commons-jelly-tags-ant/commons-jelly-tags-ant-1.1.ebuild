# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit commons-jelly-tags java-pkg 

DESCRIPTION=""
# svn co http://svn.apache.org/repos/asf/jakarta/commons/proper/jelly/tags/commons-jelly-tags-ant-1.1/
# tar cjvf commons-jelly-tags-ant-1.1.tar.bz2 commons-jelly-tags-ant-1.1
PATCHES="${FILESDIR}/${P}-gentoo.patch"
SLOT="1"
KEYWORDS="~x86"

RDEPEND="dev-java/commons-grant"

commons-jelly-tags_fix-jars() {
	java-pkg_jar-from commons-grant
}
