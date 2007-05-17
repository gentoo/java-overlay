# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/commons-beanutils/commons-beanutils-1.7.0-r2.ebuild,v 1.10 2007/02/10 19:04:08 nixnut Exp $

JAVA_PKG_IUSE="doc source test"

inherit eutils java-pkg-2 java-ant-2

MY_PN="${PN/-collections}"
MY_P="${MY_PN}-${PV}"
DESCRIPTION="Provides easy-to-use wrappers around Reflection and Introspection APIs"
HOMEPAGE="http://jakarta.apache.org/commons/beanutils/"
SRC_URI="mirror://apache/jakarta/${MY_PN/-//}/source/${MY_P}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc ~ppc64"
IUSE=""

COMMON_DEP="
	>=dev-java/commons-collections-2.1
	>=dev-java/commons-logging-1.0.2
	>=dev-java/commons-beanutils-1.7"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"

# 3.2-r1 added the test-framework support
DEPEND=">=virtual/jdk-1.4
	test? ( dev-java/junit >=dev-java/commons-collections-3.2-r1 )
	${COMMON_DEP}"

S="${WORKDIR}/${MY_P}-src/optional/bean-collections"

pkg_setup() {
	if use test && ! built_with_use dev-java/commons-collections test-framework; then
		eerror "Please re-emerge dev-java/commons-collections with the"
		eerror "test-framework use flag or turn of test support for this package."
		die "USE=\"test\" needs commons-collections with test-framework support"
	fi
	java-pkg-2_pkg_setup
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	echo "commons-collections.jar=$(java-pkg_getjar commons-collections \
		commons-collections.jar)" 	> build.properties

	echo "commons-logging.jar=$(java-pkg_getjar commons-logging commons-logging.jar)" >> build.properties

	local core=commons-beanutils-core.jar
	echo "${core}=$(java-pkg_getjar commons-beanutils-1.7 ${core})" \
		>> build.properties

	touch foo
	# the build.xml tries to update this
	mkdir ../../dist || die
	jar cf ../../dist/commons-beanutils.jar foo || die
}

src_test() {
	eant test -Djunit.jar="$(java-pkg_getjars junit)" \
		-Dcommons-collections-testframework.jar="$(java-pkg_getjar \
			commons-collections commons-collections-testframework.jar)"
}

src_install() {
	java-pkg_dojar dist/*.jar

	use doc && java-pkg_dojavadoc dist/docs/api
	use source && java-pkg_dosrc src/*
}
