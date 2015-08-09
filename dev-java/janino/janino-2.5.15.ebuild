# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="2"

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="An embedded compiler for run-time compilation purposes"
HOMEPAGE="http://www.janino.net/index.html"
SRC_URI="http://dist.codehaus.org/janino/${P}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

RDEPEND=">=virtual/jre-1.4
	dev-java/ant-core"
DEPEND=">=virtual/jdk-1.4
	app-arch/unzip"

java_prepare() {
	find . -iname '*.jar' -delete
	sed -i -e '/executable=\"${/d' build.xml
	java-ant_rewrite-classpath build.xml
}

src_compile() {
	eant -Dgentoo.classpath="$(java-pkg_getjar --build-only ant-core ant.jar)" \
		jar $(use_doc)
}

src_install() {
	java-pkg_dojar "build/lib/${PN}.jar"
	use doc && java-pkg_dojavadoc build/javadoc
	use source && java-pkg_dosrc src/*

	java-pkg_dolauncher "${PN}c" --main org.codehaus.janino.Compiler
}
