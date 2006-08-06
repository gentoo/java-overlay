# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 test-harness

DESCRIPTION=""
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="2"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=virtual/jdk-1.4
	dev-java/jikes
	dev-java/eclipse-ecj
	dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4"

WORKDIR="${S}"

TEST_SRC_INSTALL_FUNCTIONS="java-pkg_dojar java-pkg_regjar \
	java-pkg_newjar java-pkg_doso java-pkg_regso java-pkg_dosrc \
	java-pkg_dowar java-pkg_dohtml"
TEST_SRC_UNPACK_FUNCTIONS="java-pkg_jarfrom java-pkg_getjar"

# Backup package.env file before testing death
pre_test_death() {
	[[ -f ${JAVA_PKG_ENV} ]] && cp ${JAVA_PKG_ENV} ${T}
}

# restore package.env file after death
post_fail_test_death() {
	[[ -f ${T}/package.env ]] && cp ${T}/package.env ${JAVA_PKG_ENV}
}

test_java-pkg_dojar() {
	local failed_checks=0
	local jar1=${JAVA_PKG_JARDEST}/dojar1.jar
	local jar2=${JAVA_PKG_JARDEST}/dojar2.jar
	local jar3=${JAVA_PKG_JARDEST}/dojar3.jar
	local jar4=${JAVA_PKG_JARDEST}/dojar4.jar
	local jar5=${JAVA_PKG_JARDEST}/fantasy-land

	# test normal file
	touch $(basename ${jar1})
	expect_no_death java-pkg_dojar $(basename ${jar1})
	expect_exists ${D}/${jar1}

	# test normal file 2
	touch $(basename ${jar2})
	expect_no_death java-pkg_dojar $(basename ${jar2})
	expect_exists ${D}/${jar2}

	# test a symlink
	touch $(basename ${jar3})
	ln -sf $(basename ${jar3}) $(basename ${jar4})
	expect_no_death java-pkg_dojar $(basename ${jar4})

	# test nonexistant file
	expect_death java-pkg_dojar fantasy-land.jar
	expect_not_exists ${D}/${jar5}

	# test no args
	expect_death java-pkg_dojar

	# TODO test package.env

	return ${failed_checks}
}

test_java-pkg_regjar() {
	local jar1=${JAVA_PKG_JARDEST}/regjar1.jar
	local jar2=${JAVA_PKG_JARDEST}/regjar2.jar
	local jar3=${JAVA_PKG_JARDEST}/regjar3.jar

	# test normal file with ${D} path
	touch ${D}/${jar1}
	expect_no_death java-pkg_regjar ${D}/${jar1}
	# test with real path
	expect_no_death java-pkg_regjar ${jar1}

	# test non-existant file with ${D} path
	expect_death java-pkg_regjar ${D}/${jar2}

	# test non-existant file with real path
	expect_death java-pkg_regjar ${jar2}

	# TODO test package.env

	return ${failed_checks}
}

test_java-pkg_newjar() {
	local orig1=origjar1.jar
	local orig2=origjar2.jar
	local orig3=origjar3.jar
	local jar1=newjar1.jar
	local jar2=newjar2.jar
	local jar3=newjar3.jar

	# test no args
	expect_death java-pkg_newjar 

	# test non-existant orig
	expect_death java-pkg_newjar foooooo.jar baaaaaar.jar
	expect_not_exists ${D}/${JAVA_PKG_JARDEST}/baaaaaar.jar

	# test existing jar with target name
	touch ${orig1}
	expect_no_death java-pkg_newjar ${orig1} ${jar1}

	# test existing jar with default name
	touch ${orig2}
	expect_no_death java-pkg_newjar ${orig2}

	# TODO test package.env

	return ${failed_checks}
}

test_java-pkg_doso() {
	local so1=doso1.so
	local so2=doso2.so

	touch ${so1} ${so2}
	expect_no_death java-pkg_doso *.so
	expect_exists ${D}/${JAVA_PKG_LIBDEST}/${so1}
	expect_exists ${D}/${JAVA_PKG_LIBDEST}/${so2}

	expect_death java-pkg_doso fake.so
	expect_not_exists ${D}/${JAVA_PKG_LIBDEST}/fake.so

	# TODO test package.env

	return ${failed_checks}
}

test_java-pkg_regso() {
	local failed_checks=0

	local so1=${JAVA_PKG_LIBDEST}/regso1.so
	local so2=${JAVA_PKG_LIBDEST}/regso2.so

	dodir ${JAVA_PKG_LIBDEST}
	touch ${D}/${so1}
	expect_no_death java-pkg_regso  ${so1}

	touch ${D}/${so2}
	expect_no_death java-pkg_regso ${D}/${so2}

	expect_death java-pkg_regso aieeeeeeeeeeee

	# TODO test package.env

	return ${failed_checks}
}

# TODO implement
test_java-pkg_dohtml() {
	expect_death java-pkg_dohtml

	touch test.html
	expect_no_death java-pkg_dohtml test.html
	expect_exists ${D}/usr/share/${PF}/html/test.html

	# TODO install some javadoc-like structures, and make sure it gets recorded
}

# TODO test_dojavadoc

test_java-pkg_dosrc() {
	local failed_checks=0
	mkdir -p com
	touch com/Test.java

	expect_death java-pkg_dosrc
	expect_not_exists ${JAVA_PKG_SOURCESPATH}/${PN}-src.zip

	expect_death java-pkg_dosrc asdfasfdas
	expect_not_exists ${JAVA_PKG_SOURCESPATH}/${PN}-src.zip

	expect_no_death java-pkg_dosrc com
	expect_exists ${JAVA_PKG_SOURCESPATH}/${PN}-src.zip

	# TODO test package.env

	return ${failed_checks}
}

# TODO test_dolauncher

test_java-pkg_dowar() {
	local failed_checks=0
	local war1=${JAVA_PKG_WARDEST}/war1.war
	expect_death java-pkg_dowar
	expect_death java-pkg_dowar nonexistant.war

	touch $(basename ${war1})
	expect_no_death java-pkg_dowar $(basename ${war1})
	expect_exists ${D}/${war1}

	# TODO test package.env
}

# TODO test_recordjavadoc


# TODO test_jarfrom
test_java-pkg_jarfrom() {
	# no args should die
	expect_death java-pkg_jarfrom

	# getting stuff from a package that doesn't exist should die
	# FIXME!
#	expect_death java-pkg_jarfrom ant-fake
	
	# getting all jars shouldn't die
	expect_no_death java-pkg_jarfrom ant-core

	# getting a jar that doesn't exist should die
	expect_exists ant.jar ant-launcher.jar
}

# TODO test_getjars

test_java-pkg_getjar() {
	# no args
	expect_death java-pkg_getjar

	# only the first arg
	expect_death java-pkg_getjar ant-core

	# make sure doesn't die with valid args
	expect_no_death java-pkg_getjar ant-core ant.jar

	expect_string /usr/share/ant-core/lib/ant.jar \
		java-pkg_getjar ant-core ant.jar

	# invalid package name
	expect_death java-pkg_getjar ant-fake ant.jar

	# invalid jar
	expect_death java-pkg_getjar ant-core fake.jar
}

# TODO test query/support functions, like verify vm version, checking
# target/source
