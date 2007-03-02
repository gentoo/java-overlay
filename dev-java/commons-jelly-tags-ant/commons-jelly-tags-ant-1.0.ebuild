# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit commons-jelly-tags-2

SLOT="1"
KEYWORDS=""
DEPEND="=dev-java/commons-jelly-tags-junit-1.0*
		dev-java/ant-core
		dev-java/commons-grant
		dev-java/ant-junit
		=dev-java/commons-jelly-tags-util-1.0*"
EANT_GENTOO_CLASSPATH="commons-jelly-tags-junit-1,ant-core,commons-grant,ant-junit,commons-jelly-tags-util-1"
