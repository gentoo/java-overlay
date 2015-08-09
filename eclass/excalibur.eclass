# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$
#
# Author: Petteri Räty <betelgeuse@gentoo.org>
# Maintained by the java project
#
# The excalibur eclass is a helper for stuff from http://excalibur.apache.org/

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="${PN} from Apache Excalibur"
HOMEPAGE="http://excalibur.apache.org/"

[[ "${EXCALIBUR_MODULES}" ]] || SRC_URI="mirror://apache/excalibur/source/${P}-src.tar.gz"

LICENSE="Apache-2.0"

_excalibur_test() {
	[[ "${EXCALIBUR_TESTS}" ]] || return 1
}

[[ -z "${EXCALIBUR_JDK}" ]] && EXCALIBUR_JDK=1.4
[[ -z "${EXCALIBUR_JRE}" ]] && EXCALIBUR_JRE=1.4

DEPEND=">=virtual/jdk-${EXCALIBUR_JDK}"

RDEPEND=">=virtual/jre-${EXCALIBUR_JRE}"

if _excalibur_test; then
	IUSE="${IUSE} test"
	DEPEND="
		${DEPEND}
		dev-java/ant-junit"
fi

EXPORT_FUNCTIONS src_unpack src_test src_install

excalibur_src_prepare() {
	java-ant_ignore-system-classes
	mkdir -p target/lib
	cd target/lib
	for atom in ${EXCALIBUR_JAR_FROM}; do
		java-pkg_jar-from ${atom}
	done
	if _excalibur_test; then
		java-pkg_jar-from --build-only junit
		for atom in ${EXCALIBUR_TEST_JAR_FROM}; do
			java-pkg_jar-from --build-only --with-dependencies ${atom}
		done
	fi
}

excalibur_src_unpack() {
	unpack ${A}
	cd "${S}"
	excalibur_src_prepare
}

excalibur_src_test() {
	if _excalibur_test; then
		ANT_TASKS="ant-junit" eant -DJunit.present=true
	else
		einfo "This package does not support or have unit tests."
	fi
}

excalibur_src_install() {
	java-pkg_newjar target/${P}.jar
	# There might not be any
	for txt in *.txt; do
		dodoc ${txt} || die "dodoc ${txt} failed"
	done
	use doc && java-pkg_dojavadoc dist/docs/api
	use source && java-pkg_dosrc src/java/*
}
