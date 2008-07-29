# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="source test"
inherit java-pkg-2 java-ant-2

DESCRIPTION="JvYAMLb, YAML processor extracted from JRuby"
HOMEPAGE="http://code.google.com/p/jvyamlb/"
SRC_URI="http://jvyamlb.googlecode.com/files/jvyamlb-src-${PV}.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=virtual/jre-1.4"

DEPEND=">=virtual/jdk-1.4
	test? ( dev-java/ant-junit )"

JAVA_ANT_REWRITE_CLASSPATH="true"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Don't do tests unnecessarily.
	sed -i 's:depends="test":depends="compile":' build.xml
}

src_install() {
	java-pkg_newjar lib/${P}.jar
	use source && java-pkg_dosrc src/*
}

src_test() {
	ANT_TASKS="ant-junit" eant test
}
