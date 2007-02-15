# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

MY_PN="db-derby"
MY_P="${MY_PN}-${PV}"
DESCRIPTION="Relational database implemented entirely in Java"
HOMEPAGE="http://db.apache.org/derby/index.html"
SRC_URI="http://apache.cict.fr/db/derby/${MY_PN}-${PV}/${MY_PN}-${PV}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 "
IUSE="doc source examples"

DEPEND=">=virtual/jdk-1.4
		>=dev-java/geronimo-specs-1.1
		>=dev-java/jakarta-oro-2.0.8
		>=dev-java/xml-commons-1.0_beta2
		>=dev-java/javacc-3.2
		>=dev-java/xalan-2.7.0-r2
		dev-java/sun-jce-bin
"
RDEPEND="${DEPEND} >=virtual/jre-1.4"

S="${WORKDIR}/${MY_P}-src"

#EANT_BUILD_TARGET="all"
EANT_GENTOO_CLASSPATH="xalan"

pkg_setup() {
	die "Wants me; Finnish me !!!"
	for i in jta servlet;do
		if ! built_with_use dev-java/geronimo-specs $i;then
			eerror "Please enable $i USE for dev-java/geronimo-specs and rebuild it"
			die "missing USE for dev-java/geronimo-specs"
		fi
	done
}

src_unpack(){
	unpack ${A}
	cd "${S}/tools/java" || die "cd failed"
	mv empty.jar empty.jar.old || die "mv failed"
	rm -f *jar || die "rm failed"
	# getting Dependencies
	java-pkg_jar-from jakarta-oro-2.0 jakarta-oro.jar jakarta-oro-2.0.8.jar
	java-pkg_jar-from xml-commons
	java-pkg_jar-from javacc
	java-pkg_jar-from geronimo-specs geronimo-spec-jta.jar geronimo-spec-jta-1.0.1B-rc4.jar
	java-pkg_jar-from geronimo-specs geronimo-spec-servlet.jar geronimo-spec-servlet-2.4-rc4.jar
	mkdir "xslt4j-2_5_0" || die "mkdir failed"
	cd    "xslt4j-2_5_0" || die "cd xalan failed"
	java-pkg_jar-from xalan
	cd .. || die "cd return failed"
	mv empty.jar.old empty.jar || die "re-mv failed"
	cd "${S}" || die "cd failed"
	for i in $(find ${S} -name build.xml);do
		java-ant_rewrite-classpath "$i"
	done
	die "end"
}

src_compile() {
	eant buildsource -Dj14lib=/opt/sun-jdk-1.4.2.13/jre/lib
}

src_install() {
	java-pkg_newjar dist/lib/${PN}.jar
	use doc && java-pkg_dojavadoc dist/docs
	use source && java-pkg_dosrc modules/jaxr-api/src/java/
	use source && java-pkg_dosrc    modules/scout/src/java/
	if use examples; then
			dodir /usr/share/doc/${PF}/examples
			cp -r src/samples/* ${D}/usr/share/doc/${PF}/examples
	fi
}


