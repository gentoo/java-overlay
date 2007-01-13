# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/excalibur-logger/excalibur-logger-2.1.ebuild,v 1.2 2006/12/22 18:12:09 betelgeuse Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Pool from the Excalibur containerkit"
HOMEPAGE="http://excalibur.apache.org/component-list.html"

# These are separated to -api -impl and -instrumented
# excalibur-datasource needs all three so we use one ebuild
# to keep version bumping simpler

SUB="api impl instrumented"

for sub in $SUB; do
	SRC_URI="${SRC_URI}
	mirror://apache/excalibur/${PN}/source/${PN}-${sub}-${PV}-src.tar.gz"
done

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86"

IUSE="doc source test"

RDEPEND=">=virtual/jre-1.4"

DEPEND=">=virtual/jdk-1.4
		dev-java/ant-core
		source? ( app-arch/zip )
		test? ( 
			dev-java/junit 
			dev-java/junitperf
			dev-java/ant-tasks 
		)"

S=${WORKDIR}


src_unpack() {
	unpack ${A}
	for sub in ${SUB}; do
		cd ${PN}-${sub}
		epatch "${FILESDIR}/2.1-build.xml-javadoc.patch"

		java-ant_ignore-system-classes
		mkdir -p target/lib
		cd target/lib || die
		# Needed for impl
		java-pkg_jar-from avalon-framework-4.2
		java-pkg_jar-from commons-collections
		java-pkg_jar-from concurrent-util
		# Needed for instrumented
		java-pkg_jar-from excalibur-instrument excalibur-instrument-api.jar
		cd "${WORKDIR}"
	done
}

src_compile() {
	for sub in ${SUB}; do
		cd ${PN}-${sub}
		local api="${S}/${PN}-api/target/${PN}-api-${PV}.jar"
		[[ -e "${api}" ]] && ln -s ${api} target/lib
		java-pkg-2_src_compile
		cd "${S}"
	done
}

src_test() {
	for sub in ${SUB}; do
		cd ${PN}-${sub}
		cd target/lib
		java-pkg_jar-from --build-only junit
		java-pkg_jar-from --build-only junitperf
		cd ../..
		eant test -DJunit.present=true
		cd "${S}"
	done
}

src_install() {
	for sub in ${SUB}; do
		cd ${PN}-${sub}
		java-pkg_newjar target/${PN}-${sub}-${PV}.jar ${PN}-${sub}.jar
		if use doc; then
			# Doing this manually or we would have api/x/api/
			docinto html/api/${PN}-${sub}
			dohtml -r dist/docs/api/* || die
		fi
		use source && java-pkg_dosrc src/java/*
		cd "${S}"
	done
	use doc && java-pkg_recordjavadoc
}
