# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg commons-jelly-tags

DESCRIPTION=""
HOMEPAGE=""
# I don't think this is really 1.1, because it makes a jar with 1.0 in it... so
# I'm going to assume it's actually 1.0, since the other 1.0 tag doesn't work...
# svn co
# http://svn.apache.org/repos/asf/jakarta/commons/proper/jelly/tags/commons-jelly-tags-xml-1.1/ commons-jelly-tags-xml-1.0
#SRC_URI="mirror://gentoo/${P}.tar.bz2"

KEYWORDS="~x86"

DEPEND="=dev-java/commons-jelly-tags-junit-1.0*"

commons-jelly-tags_fix-jars() {
	java-pkg_jar-from commons-jelly-tags-junit-1.0
}
