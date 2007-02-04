# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-benchmarks/jmeter/jmeter-2.0.1-r1.ebuild,v 1.13 2006/08/05 21:42:43 nichoj Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Load test and measure performance on HTTP/FTP services and databases."
HOMEPAGE="http://jakarta.apache.org/jmeter"
SRC_URI="mirror://apache/jakarta/jmeter/source/jakarta-${P}_src.tgz"

#depends on excalibur-compatibility-1.1
# excalibur-i8ln-1.1
# excalibur-logger-1.1
CDEPEND="=dev-java/rhino-1.5*
		dev-java/commons-collections
		dev-java/commons-httpclient
		dev-java/commons-logging
		=dev-java/avalon-framework-4.2*
		=dev-java/jakarta-oro-2*
		=dev-java/xerces-2*
		=dev-java/jdom-1.0_beta9*
		dev-java/soap
		dev-java/xalan
		>=dev-java/avalon-logkit-1.2
		<dev-java/avalon-logkit-2"


DEPEND=">=virtual/jdk-1.4
		dev-java/ant-core
		doc? ( >=dev-java/velocity-1.4 )
		dev-java/bsh
		${CDEPEND}"
RDEPEND=">=virtual/jre-1.4
		dev-java/junit
		dev-java/bsh
		${CDEPEND}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="doc"

S=${WORKDIR}/jakarta-${P}

src_unpack() {
	unpack ${A}
	cd ${S}/lib
	# FIXME replace all bundled jars bug #63309
	# then rm -f *.jar
	java-pkg_jar-from bsh
	java-pkg_jar-from junit
	java-pkg_jar-from jtidy
	java-pkg_jar-from xerces-2
	java-pkg_jar-from avalon-framework-4.2 \
		avalon-framework.jar avalon-framework-4.1.4.jar
	java-pkg_jar-from commons-collections
	java-pkg_jar-from commons-httpclient \
		commons-httpclient.jar commons-httpclient-2.0.jar
	java-pkg_jar-from commons-logging
	java-pkg_jar-from jakarta-oro-2.0 jakarta-oro.jar jakarta-oro-2.0.8.jar
	java-pkg_jar-from jdom-1.0_beta9 jdom.jar jdom-b9.jar
	java-pkg_jar-from rhino-1.5
	java-pkg_jar-from soap
	java-pkg_jar-from xalan
	java-pkg_jar-from avalon-logkit-1.2 logkit.jar logkit-1.2.jar

	use doc && java-pkg_jarfrom velocity
}

src_compile() {
	local antflags="package"
	use doc && antflags="${antflags} docs-all"
	eant ${antflags} || die "compile problem"
}

src_install() {
	DIROPTIONS="--mode=0775"
	dodir /opt/${PN}
	cp -pPR bin/ lib/ printable_docs/ ${D}/opt/${PN}/
	dodoc README
	use doc && java-pkg_dojavadoc docs/*
}
