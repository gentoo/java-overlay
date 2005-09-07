# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg commons-jelly-tags

DESCRIPTION=""
HOMEPAGE=""
#SRC_URI="mirror://gentoo/${P}.tar.bz2"
# svn co http://svn.apache.org/repos/asf/jakarta/commons/proper/jelly/tags/COMMONS-JELLY-ANTLR-1_0/jelly-tags/antlr/ commons-jelly-tags-antlr-1.0
# tar cjvf commons-jelly-tags-antlr-1.0.tar.bz2 commons-jelly-tags-antlr-1.0/
SLOT="1"
KEYWORDS="~x86"

RDEPEND=">=dev-java/antlr-2.7.5"

commons-jelly-tags_fix-jars() {
	java-pkg_jar-from antlr
}
