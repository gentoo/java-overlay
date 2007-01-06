# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Java 1.6 SwingWorker backport for Java 1.5"
HOMEPAGE="https://swingworker.dev.java.net"
SRC_URI="https://swingworker.dev.java.net/files/documents/2810/41371/${PN}-src.zip"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"

DEPEND=">=virtual/jdk-1.5"
RDEPEND=">=virtual/jre-1.5"

S="${WORKDIR}"

src_compile() {
	eant compile $(use_doc javadoc)
}

src_install() {
	use doc & java-pkg_dojavadoc dist/javadoc
	cd build
	jar cf ../swing-worker.jar *
	cd ..
	java-pkg_dojar swing-worker.jar
}
