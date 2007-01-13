# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/excalibur-logger/excalibur-logger-2.1.ebuild,v 1.2 2006/12/22 18:12:09 betelgeuse Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Instrumentation from the Excalibur containerkit"
HOMEPAGE="http://excalibur.apache.org/component-list.html"

# Having these in one ebuild makes updating easier
# excalibur-pool is implemented the same way

SUB="api client mgr-api mgr-http mgr-impl"

for sub in $SUB; do
	SRC_URI="${SRC_URI}
	mirror://apache/excalibur/${PN}/source/${PN}-${sub}-${PV}-src.tar.gz"
done

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86"

IUSE="doc source"

COMMON_DEP="=dev-java/avalon-framework-4.2*"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"

DEPEND=">=virtual/jdk-1.4
		dev-java/ant-core
		${COMMON_DEP}
		source? ( app-arch/zip )
		test? ( 
			dev-java/junit 
			dev-java/ant-tasks 
		)"

S=${WORKDIR}


src_unpack() {
	unpack ${A}
	for sub in ${SUB}; do
		cd ${PN}-${sub}-${PV} || die
		java-ant_ignore-system-classes
		mkdir -p target/lib
		cd target/lib || die
		java-pkg_jar-from avalon-framework-4.2
		cd "${WORKDIR}"
	done
}

src_compile() {
	for sub in ${SUB}; do
		cd ${PN}-${sub}-${PV}
		local api="${S}/${PN}-api-${PV}/target/${PN}-api-${PV}.jar"
		[[ -e "${api}" ]] && ln -s ${api} target/lib
		local mgrapi="${S}/${PN}-mgr-api-${PV}/target/${PN}-mgr-api-${PV}.jar"
		[[ -e "${mgrapi}" ]] && ln -s ${mgrapi} target/lib
		java-pkg-2_src_compile
		cd "${S}"
	done
}

src_test() {
	for sub in ${SUB}; do
		cd ${PN}-${sub}-${PV}
		cd target/lib
		java-pkg_jar-from --build-only junit
		cd ../..
		eant test -DJunit.present=true
		cd "${S}"
	done
}

src_install() {
	for sub in ${SUB}; do
		cd ${PN}-${sub}-${PV}
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
