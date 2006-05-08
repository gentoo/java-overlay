# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="JOTM (Java Open Transaction Manager) is a fully functional open source standalone transaction manager that implements the XA protocol and is compliant with the JTA APIs."
HOMEPAGE="http://jotm.objectweb.org/index.html"
SRC_URI="http://download.fr2.forge.objectweb.org/${PN}/${P}-src.tgz"

LICENSE="BSD"
SLOT="2.0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

DEPEND=">=virtual/jdk-1.3
	dev-java/ant-core"
# TODO: verify that jacorb actually provides JTS classes
# ( org.omg.CosTransactions.PropagationContextHelper )
RDEPEND=">=virtual/jre-1.3
	=dev-java/commons-cli-1*
	dev-java/commons-logging
	=dev-java/howl-logger-0.1*
	=dev-java/jeremie-4*
	=dev-java/jonathan-core-4*
	=dev-java/kilim-1*
	dev-java/log4j
	=dev-java/carol-2.0*
	=dev-java/jboss-module-j2ee-4.0*
	=dev-java/jacorb-2.2*"
#	dev-java/jta
#	dev-java/sun-jts-bin
#	dev-java/sun-j2ee-connector-bin"

ant_src_unpack() {
	unpack ${A}
	cd ${S}

	# for some reason, the author tries to hide some targets by prefixing them
	# with -, so you can't call them from the command line
	epatch ${FILESDIR}/${P}-gentoo.patch

	cd externals
	rm *.jar
	java-pkg_jar-from commons-cli-1
	java-pkg_jar-from commons-logging
	java-pkg_jar-from howl-logger-0.1
	java-pkg_jar-from jeremie-4
	java-pkg_jar-from jonathan-core-4
#	java-pkg_jar-from sun-jts-bin
#	java-pkg_jar-from jta
	java-pkg_jar-from kilim-1 kilim.jar
	java-pkg_jar-from log4j
	java-pkg_jar-from carol-2.0 ow_carol.jar
#	java-pkg_jar-from sun-j2ee-connector-bin
	java-pkg_jar-from jboss-module-j2ee-4
	java-pkg_jar-from jacorb-2.2 omg_services.jar
}

src_compile() {
	eant jar $(use_doc jdoc -Ddist.jdoc=output/dist/api)
}

src_install() {
	java-pkg_dojar output/dist/lib/*.jar
	dodoc README.txt
	use doc && java-pkg_dohtml -r output/dist/api
}
