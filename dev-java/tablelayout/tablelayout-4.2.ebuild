# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source"
inherit java-pkg-2 java-pkg-simple

DESCRIPTION="Layout manager that makes creating user interfaces fast and easy"
HOMEPAGE="https://tablelayout.dev.java.net/"
SRC_URI="https://tablelayout.dev.java.net/files/documents/3495/15739/TableLayout-src-2009-08-26.jar"
LICENSE="tablelayout"
KEYWORDS="~amd64"
SLOT="0"
IUSE=""

DEPEND=">=virtual/jdk-1.4"
RDEPEND=">=virtual/jre-1.4"
