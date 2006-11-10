# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="NetBeans IDE for Java"
HOMEPAGE="http://www.netbeans.org"

MY_PV=$(get_version_component_range 1-2 ${PV})
MY_PV=$(replace_version_separator 1 '_' ${MY_PV})

RELEASE="200611091900"
DOC_RELEASE="200610231800"
BASELOCATION="http://us1.mirror.netbeans.org/download/${MY_PV/-//}/daily/${RELEASE}"
MAINTARBALL="netbeans-${MY_PV}-daily-src-${RELEASE}-ide_sources-9_Nov_2006_1900.tar.bz2"
JAVADOCTARBALL="http://us1.mirror.netbeans.org/download/${MY_PV/-//}/daily/${DOC_RELEASE}/netbeans-${MY_PV}-daily-docs-${DOC_RELEASE}-javadoc-23_Oct_2006_1800.tar.bz2"

SRC_URI="${BASELOCATION}/${MAINTARBALL}
	 doc? ( ${JAVADOCTARBALL} )"

LICENSE="Apache-1.1 Apache-2.0 SPL W3C sun-bcla-j2eeeditor sun-bcla-javac sun-javac as-is docbook sun-resolver"
SLOT="6.0"
KEYWORDS="~amd64 ~x86"
IUSE="debug doc"

COMMON_DEPEND="
	>=dev-java/antlr-2.7.1
	=dev-java/commons-beanutils-1.7*
	dev-java/commons-collections
	>=dev-java/commons-logging-1.1
	dev-java/flute
	>=dev-java/jakarta-jstl-1.1.2
	>=dev-java/javahelp-bin-2.0.02-r1
	>=dev-java/jmi-interface-1.0-r1
	>=dev-java/jsch-0.1.24
	=dev-java/junit-3.8*
	dev-java/sac
	=dev-java/servletapi-2.2*
	dev-java/sun-j2ee-deployment-bin
	=dev-java/swing-layout-1*
	>=dev-java/xerces-2.8.0
	>=dev-java/xml-commons-1.0_beta2
"
DEPEND=">=virtual/jdk-1.5
	dev-java/ant-core
	dev-java/ant-tasks
	dev-util/checkstyle
	=dev-java/commons-cli-1*
	dev-java/commons-el
	dev-java/commons-jxpath
	dev-java/glassfish-persistence
	>=dev-java/jcalendar-1.3.0
	>=dev-java/jdom-1.0
	dev-java/jtidy
	>=dev-util/pmd-1.3
	dev-java/prefuse
	>=dev-java/rome-0.6
	=dev-java/servletapi-2.3*
	dev-java/xml-xmlbeans
	${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.5
	>=dev-java/commons-fileupload-1.1.1
	>=dev-java/commons-io-1.2
	dev-java/commons-digester
	dev-java/commons-validator
	=dev-java/jakarta-oro-2.0*
	dev-java/jsfapi
	dev-java/jsr173
	dev-java/jsr181
	dev-java/jsr250
	dev-java/relaxng-datatype
	=dev-java/struts-1.3*
	dev-java/sun-fastinfoset-bin
	dev-java/sun-jaf
	dev-java/sun-jaxp-bin
	dev-java/sun-javamail
	dev-java/sun-jaxb-bin
	dev-java/sun-jaxrpc-bin
	dev-java/sun-jaxws-bin
	dev-java/sun-saaj-bin
	dev-java/sun-sjsxp-bin
	dev-java/xsdlib
	${COMMON_DEPEND}"

TOMCATSLOT="5.5"
S=${WORKDIR}/netbeans-src
BUILDDESTINATION="${S}/nbbuild/netbeans"
ENTERPRISE="4"
IDE_VERSION="8"
PLATFORM="7"
MY_FDIR="${FILESDIR}/${SLOT}"
DESTINATION="${ROOT}usr/share/netbeans-${SLOT}"
JAVA_PKG_BSFIX="off"

antflags=""

set_env() {

	antflags=""

	if use debug; then
		antflags="${antflags} -Dbuild.compiler.debug=true"
		antflags="${antflags} -Dbuild.compiler.deprecation=true"
	else
		antflags="${antflags} -Dbuild.compiler.deprecation=false"
	fi

	antflags="${antflags} -Dstop.when.broken.modules=true"

	# -Xmx1g: Increase Java maximum heap size, otherwise ant will die with
	#         an OutOfMemoryError while building.
	# -Djava.awt.headless=true: Sun JDK doesnt like that very much, so
	#                           lets pleasure them too ;-)
	#
	# We use the ANT_OPTS environment variable because other ways seem to
	# fail.
	#
	export ANT_OPTS="${ANT_OPTS} -Xmx1g -Djava.awt.headless=true"

}

src_unpack () {
	ewarn "This version comes from process of major rewrite of the code"
	ewarn "so a lot of features and modules do not work at the moment. "
	ewarn "If you want a more stable release of Netbeans 6.0, use      "
	ewarn "netbeans-6.0_alpha20061023 which is pretty usable. But if   "
	ewarn "you want to see the great new features that will come in new"
	ewarn "Netbeans release then this is the right version :-)         "
	ebeep
	epause 20

	unpack ${MAINTARBALL}

	if use doc; then
		mkdir javadoc && cd javadoc
		unpack ${JAVADOCTARBALL} || die "Unable to extract javadoc"
		rm -f *.zip
	fi

	cd ${S}/nbbuild
	# Disable the bundled Tomcat in favor of Portage installed version
	sed -i -e "s%tomcatint/tomcat5/bundled,%%g" *.properties

	set_env
	place_symlinks
}

src_compile() {

	set_env

	# The location of the main build.xml file
	cd ${S}/nbbuild

	# Specify the build-nozip target otherwise it will build
	# a zip file of the netbeans folder, which will copy directly.
	eant ${antflags} build-nozip

	# Remove non-x86 Linux binaries
	find ${BUILDDESTINATION} -type f \
		-name "*.exe" -o \
		-name "*.cmd" -o \
		-name "*.bat" -o \
		-name "*.dll"	  \
		| xargs rm -f

	# Removing external stuff. They are api docs from external libs.
	cd ${BUILDDESTINATION}/ide${IDE_VERSION}/docs
	rm -f *.zip

	# The next directory seems to be empty
	if ! rmdir doc 2> /dev/null; then
		use doc || rm -fr ./doc
	fi

	# Use the system ant
	cd ${BUILDDESTINATION}/ide${IDE_VERSION}/ant

	rm -fr ./lib
	rm -fr ./bin

	# Set a initial default jdk
	echo "netbeans_jdkhome=\"\$(java-config -O)\"" >> ${BUILDDESTINATION}/etc/netbeans.conf
}

src_install() {
	insinto $DESTINATION

	einfo "Installing the program..."
	cd ${BUILDDESTINATION}
	doins -r *

	symlink_extjars ${D}/${DESTINATION}

	fperms 755 \
		   ${DESTINATION}/bin/netbeans \
		   ${DESTINATION}/platform${PLATFORM}/lib/nbexec

	# The wrapper wrapper :)
	newbin ${MY_FDIR}/startscript.sh ${PN}-${SLOT}

	# Netbeans config utility
	newbin ${MY_FDIR}/config.sh ${PN}-${SLOT}-config

	# Ant installation
	local ANTDIR="${DESTINATION}/ide${IDE_VERSION}/ant"
	cd ${D}/${ANTDIR}

	dodir /usr/share/ant-core/lib
	dosym /usr/share/ant-core/lib ${ANTDIR}/lib

	dodir /usr/share/ant-core/bin
	dosym /usr/share/ant-core/bin  ${ANTDIR}/bin

	# Documentation
	einfo "Installing Documentation..."

	cd ${D}/${DESTINATION}

	use doc && java-pkg_dohtml -r ${WORKDIR}/javadoc/*

	dodoc build_info
	dohtml CREDITS.html README.html netbeans.css

	rm -f build_info CREDITS.html README.html netbeans.css

	# Icons and shortcuts
	einfo "Installing icons..."

	dodir ${DESTINATION}/icons
	insinto ${DESTINATION}/icons
	doins ${S}/ide/branding/release/*png

	for res in "16x16" "24x24" "32x32" "48x48" "128x128" ; do
		dodir /usr/share/icons/hicolor/${res}/apps
		dosym ${DESTINATION}/icons/netbeans.png /usr/share/icons/hicolor/${res}/apps/netbeans.png
	done

	make_desktop_entry netbeans-${SLOT} "Netbeans ${SLOT}" netbeans Development
}

pkg_postinst () {
	elog "The integrated Tomcat is not installed, but you can easily  "
	elog "use the system Tomcat. See Netbeans documentation if you    "
	elog "don't know how to do that. The relevant settings are in the "
	elog "runtime window.                                             "
	elog
	elog "If you are upgrading from Netbeans 5.5 or you use both 5.5  "
	elog "and 6.0 then you might find useful our configuration        "
	elog "utility '${PN}-${SLOT}-config'. Run it without parameters   "
	elog "to see what it can do for you. You might also need it if you"
	elog "want to use ant-1.7 with Netbeans because default Netbeans  "
	elog "configuration doesn't work with Gentoo ant-1.7.             "
	elog
        elog "If you are using some packages on top of Netbeans, you have"
        elog "to re-emerge them now.                                     "
}

pkg_postrm() {
#	einfo "Removing symlinks to jars from"
#	einfo "${DESTINATION}"
#	find ${DESTINATION} -type l | xargs rm -fr

	if ! test -e /usr/bin/netbeans-${SLOT}; then
		einfo "Because of the way Portage works at the moment"
		einfo "symlinks to the system jars are left to:"
		einfo "${DESTINATION}"
		einfo "If you are uninstalling Netbeans you can safely"
		einfo "remove everything in this directory"
	fi
}

# Supporting functions for this ebuild

function fix_manifest() {
	sed -i "s%ext/${1}%$(java-pkg_getjar ${2} ${3})%" ${4}
}

# This function is used before src_compile to replace the bundled
# stuff used during compile. Stuff in here should be in $DEPEND
function place_symlinks() {
	einfo "Symlinking apisupport/external"
	cd ${S}/apisupport/external
	java-pkg_jar-from --build-only jdom-1.0
	java-pkg_jar-from --build-only javahelp-bin jsearch.jar jsearch-2.0_04.jar
	java-pkg_jar-from --build-only rome rome.jar rome-fetcher-0.6.jar
	java-pkg_jar-from --build-only rome rome.jar rome-0.6.jar

	einfo "Symlinking core/external"
	cd ${S}/core/external
	java-pkg_jar-from javahelp-bin jh.jar jh-2.0_04.jar

	einfo "Symlinking db/external"
	cd ${S}/db/external
	# MISSING: fake-jdbc40.jar (not found)

	einfo "Symlinking httpserver/external"
	cd ${S}/httpserver/external
	java-pkg_jar-from servletapi-2.2 servlet.jar servlet-2.2.jar
	# MISSING: webserver.jar (something from tomcat)

	einfo "Symlinking java/external"
	cd ${S}/java/external
	# javac-api.jar
	# javac-impl.jar
	# MISSING: lucene-core-2.0.0.jar (only old ebuild)

	einfo "Symlinking junit/external"
	cd ${S}/junit/external
	java-pkg_jar-from junit junit.jar junit-3.8.2.jar

	einfo "Symlinking j2ee/external"
	cd ${S}/j2ee/external
	java-pkg_jar-from --build-only glassfish-persistence

	einfo "Symlinking j2eeserver/external"
	cd ${S}/j2eeserver/external
	java-pkg_jar-from sun-j2ee-deployment-bin-1.1 sun-j2ee-deployment-bin.jar jsr88javax.jar

	einfo "Symlinking lexer/external"
	cd ${S}/lexer/external
	java-pkg_jar-from antlr antlr.jar antlr-2.7.1.jar
	java-pkg_jar-from antlr antlr.jar lexer-gen-antlr-2.7.1.jar

	einfo "Symlinking libs/external"
	cd ${S}/libs/external
	java-pkg_jar-from commons-logging commons-logging.jar commons-logging-1.0.4.jar
	java-pkg_jar-from jsch jsch.jar jsch-0.1.24.jar
	java-pkg_jar-from --build-only pmd pmd.jar pmd-1.3.jar
	# MISSING: resolver-1_1_nb.jar (patched xml-commons-resolver)
	java-pkg_jar-from swing-layout-1 swing-layout.jar swing-layout-1.0.1.jar
	java-pkg_jar-from --build-only xml-xmlbeans-1 xbean.jar xbean.jar
	java-pkg_jar-from xerces-2 xercesImpl.jar xerces-2.8.0.jar
	java-pkg_jar-from xml-commons xml-apis.jar xml-commons-dom-ranges-1.0.b2.jar

	einfo "Symlinking mdr/external"
	cd ${S}/mdr/external
	java-pkg_jar-from jmi-interface jmi.jar jmi.jar
	java-pkg_jar-from jmi-interface mof.jar mof.jar

	einfo "Symlinking nbbuild/external"
	cd ${S}/nbbuild/external
	# MISSING: scrambler.jar (no ebuild)

	einfo "Symlinking serverplugins/external"
	cd ${S}/serverplugins/external
	# MISSING: jmxremote.jar (no ebuild)

	einfo "Symlinking subversion/external"
	cd ${S}/subversion/external
	# MISSING: ini4j.jar (no ebuild)
	# MISSING: svnClientAdapter.jar (no ebuild)

	einfo "Symlinking tasklist/external"
	cd ${S}/tasklist/external
	java-pkg_jar-from antlr
	java-pkg_jar-from commons-beanutils-1.7 commons-beanutils-core.jar
	java-pkg_jar-from --build-only commons-cli-1
	java-pkg_jar-from commons-collections
	java-pkg_jar-from --build-only checkstyle
	# MISSING: ical4j.jar (no ebuild)
	java-pkg_jar-from --build-only jcalendar-1.2 jcalendar.jar jcalendar-1.3.0.jar
	java-pkg_jar-from --build-only jtidy Tidy.jar Tidy-r7.jar

	einfo "Symlinking web/external"
	cd ${S}/web/external
	java-pkg_jar-from --build-only commons-el
	# MISSING: glassfish-jspparser.jar (no ebuild)
	# MISSING: glassfish-logging.jar (no ebuild)
	java-pkg_jar-from jakarta-jstl jstl.jar jstl-1.1.2.jar
	java-pkg_jar-from --build-only servletapi-2.3 servlet.jar servlet-2.3.jar
	# MISSING: servlet2.5-jsp2.1-api.jar (no ebuild)
	java-pkg_jar-from jakarta-jstl standard.jar standard-1.1.2.jar

	einfo "Symlinking xml/external"
	cd ${S}/xml/external
	java-pkg_jar-from flute
	java-pkg_jar-from --build-only commons-jxpath commons-jxpath.jar jxpath.jar
	java-pkg_jar-from --build-only prefuse-2006
	# MISSING: resolver-1_1_nb.jar (patched xml-commons-resolver)
	java-pkg_jar-from sac
}

# Because Netbeans uses copy to the jars to the destination directory, we need
# to overwrite the jars in src_install with symlinks once again
# --> stuff in here should be in $RDEPEND
function symlink_extjars() {
	einfo "Symlinking enterprise${ENTERPRISE}/modules/ext"
	cd ${1}/enterprise${ENTERPRISE}/modules/ext
	#appsrvbridge.jar (nb)
	# MISSING: glassfish-jspparser.jar (no ebuild)
	# MISSING: glassfish-logging.jar (no ebuild)
	#jsp-parser-ext.jar (nb)
	java-pkg_jar-from sun-j2ee-deployment-bin-1.1 sun-j2ee-deployment-bin.jar jsr88javax.jar
	java-pkg_jar-from jakarta-jstl jstl.jar
	#org-netbeans-modules-web-httpmonitor.jar (nb)
	# MISSING: persistence-tool-support.jar (no ebuild)
	# MISSING: servlet2.5-jsp2.1-api.jar (no ebuild)
	java-pkg_jar-from jakarta-jstl standard.jar
	#websvcregistry.jar (nb)

	einfo "Symlinking ide${IDE_VERSION}/modules/ext"
	cd ${1}/ide${IDE_VERSION}/modules/ext
	#AbsoluteLayout.jar (nb)
	java-pkg_jar-from commons-logging commons-logging.jar commons-logging-1.0.4.jar
	#ddl.jar (nb)
	java-pkg_jar-from flute
	# MISSING: gjast.jar (no ebuild)
	# MISSING: ini4j.jar (no ebuild)
	#javac-api.jar
	#javac-impl.jar
	java-pkg_jar-from jmi-interface jmi.jar jmi.jar
	#jmiutils.jar (nb)
	java-pkg_jar-from jsch jsch.jar jsch-0.1.24.jar
	java-pkg_jar-from junit junit.jar junit-3.8.2.jar
	#lucene-core-2.0.0.jar
	#org-netbeans-modules-java-j2seplatform-probe.jar (nb)
	#org-netbeans-tax.jar (nb)
	# MISSING: resolver-1_1_nb.jar (patched xml-commons-resolver)
	java-pkg_jar-from sac
	java-pkg_jar-from servletapi-2.2 servlet.jar servlet-2.2.jar
	# MISSING: svnClientAdapter.jar (no ebuild)
	# MISSING: webserver.jar (something from tomcat)
	java-pkg_jar-from xerces-2 xercesImpl.jar xerces-2.8.0.jar
	java-pkg_jar-from xml-commons xml-apis.jar xml-commons-dom-ranges-1.0.b2.jar

	einfo "Symlinking ide${IDE_VERSION}/modules/ext/jaxrpc16"
	cd ${1}/ide${IDE_VERSION}/modules/ext/jaxrpc16
	java-pkg_jar-from sun-jaf
	java-pkg_jar-from sun-fastinfoset-bin
	java-pkg_jar-from sun-jaxp-bin
	# MISSING: jax-qname.jar (not found)
	java-pkg_jar-from sun-jaxrpc-bin jaxrpc-api.jar
	java-pkg_jar-from sun-jaxrpc-bin jaxrpc-impl.jar
	java-pkg_jar-from sun-jaxrpc-bin jaxrpc-spi.jar
	java-pkg_jar-from jsr173 jsr173.jar jsr173_api.jar
	java-pkg_jar-from sun-javamail
	java-pkg_jar-from relaxng-datatype
	java-pkg_jar-from sun-saaj-bin saaj-api.jar
	java-pkg_jar-from sun-saaj-bin saaj-impl.jar
	java-pkg_jar-from xsdlib

	einfo "Symlinking ide${IDE_VERSION}/modules/ext/jaxws20"
	cd ${1}/ide${IDE_VERSION}/modules/ext/jaxws20
	java-pkg_jar-from sun-jaf
	java-pkg_jar-from sun-fastinfoset-bin
	# MISSING: http.jar (no ebuild)
	java-pkg_jar-from sun-jaxb-bin jaxb-api.jar
	java-pkg_jar-from sun-jaxb-bin jaxb-impl.jar
	java-pkg_jar-from sun-jaxb-bin jaxb-xjc.jar
	java-pkg_jar-from sun-jaxws-bin jaxws-api.jar
	java-pkg_jar-from sun-jaxws-bin jaxws-rt.jar
	java-pkg_jar-from sun-jaxws-bin jaxws-tools.jar
	java-pkg_jar-from jsr173 jsr173.jar jsr173_api.jar
	java-pkg_jar-from jsr181 jsr181.jar jsr181-api.jar
	java-pkg_jar-from jsr250
	#resolver.jar (nb)
	java-pkg_jar-from sun-saaj-bin saaj-api.jar
	java-pkg_jar-from sun-saaj-bin saaj-impl.jar
	java-pkg_jar-from sun-sjsxp-bin

	einfo "Symlinking platform${PLATFORM}/modules/ext"
	cd ${1}/platform${PLATFORM}/modules/ext
	java-pkg_jar-from javahelp-bin jh.jar jh-2.0_04.jar
	java-pkg_jar-from swing-layout-1 swing-layout.jar swing-layout-1.0.1.jar
	#updater.jar (nb)
	#org-openide-text.jar (nb)
}
