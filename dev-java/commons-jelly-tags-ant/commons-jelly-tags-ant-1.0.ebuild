# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg commons-jelly-tags

DESCRIPTION=""
HOMEPAGE=""
# svn co http://svn.apache.org/repos/asf/jakarta/commons/proper/jelly/tags/COMMONS_JELLY_ANT-1_0/jelly-tags/ant/ commons-jelly-tags-ant-1.0
# tar cjvf commons-jelly-tags-ant-1.0.tar.bz2 commons-jelly-tags-ant-1.0
#SRC_URI="mirror://gentoo/${P}.tar.bz2"

KEYWORDS="~x86"

RDEPEND="dev-java/commons-grant"

commons-jelly-tags_fix-jars() {
	java-pkg_jar-from commons-grant
}
