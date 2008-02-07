# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=1
JAVA_PKG_IUSE="source"
WANT_ANT_TASKS="ant-nodeps"
inherit java-pkg-2 java-ant-2
DESCRIPTION="Netbeans fork of svnClientAdapter"
HOMEPAGE="http://subversion.netbeans.org/teepee/svnclientadapter.html"
SRC_URI="http://subversion.netbeans.org/files/documents/193/1800/svnClientAdapter-nb6.0.1-src.zip"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND=">=virtual/jdk-1.4"
RDEPEND=">=virtual/jre-1.4"
S="${WORKDIR}/svnClientAdapter-nb${PV}-src"

EANT_BUILD_TARGET="svnClientAdapter.jar"

src_install() {
	java-pkg_dojar build/lib/svnClientAdapter.jar
	use source && java-pkg_dosrc src/main
}
