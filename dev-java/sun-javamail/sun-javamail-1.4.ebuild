# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2

DESCRIPTION="A Java-based framework to build multiplatform mail and messaging applications."
HOMEPAGE="http://java.sun.com/products/javamail/index.html"
SRC_URI="http://dev.gentoo.org/~nichoj/distfiles/${P}.tar.bz2"

LICENSE="CDDL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc source"

DEPEND=">=virtual/jdk-1.5
	dev-java/ant-core
	dev-java/sun-jaf
	source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.4"
S="${WORKDIR}/mail"

JAVA_PKG_WANT_SOURCE="1.4"
JAVA_PKG_WANT_TARGET="1.4"

src_unpack() {
	unpack ${A}
	cd ${S}
	java-pkg_jar-from sun-jaf activation.jar activation-real.jar
	cp -L activation-real.jar activation.jar
}

src_compile() {
	eant jar $(use_doc docs) -Djavaee.jar=activation.jar
}

src_install() {
	java-pkg_dojar build/release/mail.jar
	use doc && java-pkg_dojavadoc build/release/docs/javadocs
	use source && java-pkg_dosrc src/java
}

