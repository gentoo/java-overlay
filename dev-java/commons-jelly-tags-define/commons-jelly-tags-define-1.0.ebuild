# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

SLOT="1"

inherit commons-jelly-tags-2

KEYWORDS=""
DEPEND="=dev-java/commons-jelly-tags-junit-1*
		=dev-java/commons-jelly-tags-log-1*
		=dev-java/commons-jelly-tags-xml-1*
		=dev-java/commons-jelly-tags-dynabean-1*"
EANT_GENTOO_CLASSPATH="commons-jelly-tags-junit-1,commons-jelly-tags-log-1,commons-jelly-tags-xml-1,commons-jelly-tags-dynabean-1"

