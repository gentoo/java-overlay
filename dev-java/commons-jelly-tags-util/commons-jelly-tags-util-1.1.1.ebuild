# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

SLOT="1"
JELLY_PATCH_VERSION="1.0"

inherit commons-jelly-tags java-pkg

DESCRIPTION=""
# svn co http://svn.apache.org/repos/asf/jakarta/commons/proper/jelly/tags/COMMONS_JELLY_UTIL-1_1_1/jelly-tags/util/ commons-jelly-tags-util-1.1.1
# tar cjf commons-jelly-tags-util-1.1.1.tar.bz2 commons-jelly-tags-util-1.1.1/

KEYWORDS="~x86"

DEPEND="=dev-java/commons-jelly-tags-junit-1.0*"

commons-jelly-tags_fix-jars() {
	java-pkg_jar-from commons-jelly-tags-junit-1
}
