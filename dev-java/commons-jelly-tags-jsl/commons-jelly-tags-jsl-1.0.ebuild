# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg commons-jelly-tags

DESCRIPTION=""
HOMEPAGE=""
# svn co http://svn.apache.org/repos/asf/jakarta/commons/proper/jelly/tags/COMMONS_JELLY_JSL-1_0/jelly-tags/jsl/ commons-jelly-tags-jsl-1.0
# tar cjf commons-jelly-tags-jsl-1.0.tar.bz2 commons-jelly-tags-jsl-1.0
#SRC_URI="mirror://gentoo/${P}.tar.bz2"

SLOT="1"
KEYWORDS="~x86"
RDEPEND="dev-java/commons-grant
	=dev-java/commons-cli-1*
	=dev-java/commons-jelly-tags-xml-1*"

commons-jelly-tags_fix-jars() {
	java-pkg_jar-from commons-grant
	java-pkg_jar-from commons-cli-1
	java-pkg_jar-from commons-jelly-tags-xml-1
}
