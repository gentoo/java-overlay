# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg commons-jelly-tags

DESCRIPTION=""
HOMEPAGE=""
# svn co http://svn.apache.org/repos/asf/jakarta/commons/proper/jelly/tags/COMMONS_JELLY_UTIL-1_1_1/jelly-tags/util/ commons-jelly-tags-util-1.1.1
# tar cjf commons-jelly-tags-util-1.1.1.tar.bz2 commons-jelly-tags-util-1.1.1/
#SRC_URI="mirror://gentoo/${P}.tar.bz2"
SLOT="1"
KEYWORDS="~x86"

DEPEND="=dev-java/commons-jelly-tags-junit-1.0*"

commons-jelly-tags_fix-jars() {
	java-pkg_jar-from commons-jelly-tags-junit-1
}
