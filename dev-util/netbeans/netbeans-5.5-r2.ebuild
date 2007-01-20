# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/netbeans/netbeans-5.5-r1.ebuild,v 1.8 2007/01/16 12:22:02 caster Exp $

inherit eutils java-pkg-2 java-ant-2 versionator

DESCRIPTION="NetBeans IDE for Java"
HOMEPAGE="http://www.netbeans.org"

MY_PV=$(replace_all_version_separators '_')

SRC_URI="http://us2.mirror.netbeans.org/download/${MY_PV}/fcs/200610171010/${PN}-${MY_PV}-ide_sources.tar.bz2"
LICENSE="CDDL"
SLOT="5.5"
KEYWORDS="~amd64 ~x86 ~x86-fbsd"
IUSE="debug doc"

COMMON_DEPEND="
	>=dev-java/ant-1.6.3
	>=dev-java/commons-logging-1.0.4
	dev-java/flute
	>=dev-java/jakarta-jstl-1.1.2
	>=dev-java/jgoodies-forms-1.0.5
	>=dev-java/jmi-interface-1.0-r3
	>=dev-java/sun-j2ee-deployment-bin-1.1
	>=dev-java/javahelp-bin-2.0.02
	>=dev-java/jsch-0.1.24
	=dev-java/junit-3.8*
	dev-java/sac
	=dev-java/servletapi-2.2*
	=dev-java/swing-layout-1*
	>=dev-java/xerces-2.8.0
	>=dev-java/xml-commons-1.0_beta2"

RDEPEND=">=virtual/jre-1.5
	dev-java/antlr
	=dev-java/commons-beanutils-1.7*
	dev-java/commons-collections
	dev-java/commons-digester
	>=dev-java/commons-fileupload-1.1
	>=dev-java/commons-io-1.2
	dev-java/commons-validator
	dev-java/jakarta-oro
	dev-java/jsr173
	dev-java/jsr181
	dev-java/jsr250
	=dev-java/struts-1.2*
	dev-java/relaxng-datatype
	dev-java/sun-fastinfoset-bin
	dev-java/sun-jaf
	dev-java/sun-javamail
	dev-java/sun-jaxb-bin
	dev-java/sun-jaxp-bin
	dev-java/sun-jaxrpc-bin
	dev-java/sun-jaxws-bin
	dev-java/sun-saaj-bin
	dev-java/sun-sjsxp-bin
	dev-java/xsdlib
	${COMMON_DEPEND}"

DEPEND=">=virtual/jdk-1.5
	dev-java/commons-el
	>=dev-java/commons-jxpath-1.1
	dev-java/glassfish-persistence
	>=dev-java/jcalendar-1.2
	>=dev-java/jdom-1.0
	dev-java/jtidy
	dev-java/prefuse
	>=dev-java/rome-0.6
	=dev-java/servletapi-2.3*
	dev-java/sun-jmx
	>=dev-java/xml-xmlbeans-1.0.4
	>=dev-util/pmd-1.3
	${COMMON_DEPEND}"

S=${WORKDIR}/netbeans-src
BUILDDESTINATION="${S}/nbbuild/netbeans"
ENTERPRISE="3"
IDE_VERSION="7"
PLATFORM="6"
MY_FDIR="${FILESDIR}/${SLOT}-${PR}"
DESTINATION="/usr/share/netbeans-${SLOT}"
JAVA_PKG_BSFIX="off"

src_unpack () {
	unpack ${A}

	# Correct invalid XML
	cd ${S}
	epatch "${MY_FDIR}/jdbcstorage-build.xml-comments.patch"
	epatch "${MY_FDIR}/mdrant-build.xml-comments.patch"

	# Disable the bundled Tomcat in favor of Portage installed version
	cd ${S}/nbbuild
	sed -i -e "s%tomcatint/tomcat5/bundled,%%g" *.properties

	place_unpack_symlinks
}

src_compile() {
	local antflags=""

	if use debug; then
		antflags="${antflags} -Dbuild.compiler.debug=true"
		antflags="${antflags} -Dbuild.compiler.deprecation=true"
	else
		antflags="${antflags} -Dbuild.compiler.deprecation=false"
	fi

	# The build will attempt to display graphical
	# dialogs for the licence agreements if this is set.
	unset DISPLAY

	# Fails to compile
	java-pkg_filter-compiler ecj-3.1 ecj-3.2

	# Specify the build-nozip target otherwise it will build
	# a zip file of the netbeans folder, which will copy directly.
	cd ${S}/nbbuild
	ANT_OPTS="-Xmx1g -Djava.awt.headless=true" eant ${antflags} -Dstop.when.broken.modules=true \
		build-nozip
	# Running build-javadoc from the same command line as build-nozip doesn't work
	# so we must run it separately
	use doc && ANT_OPTS="-Xmx1g" eant build-javadoc

	# Remove non-x86 Linux binaries
	find ${BUILDDESTINATION} -type f \
		-name "*.exe" -o \
		-name "*.cmd" -o \
		-name "*.bat" -o \
		-name "*.dll"	  \
		| xargs rm -f

	# Removing external stuff. They are api docs from external libs.
	rm -f ${BUILDDESTINATION}/ide${IDE_VERSION}/docs/*.zip

	# Remove zip files from generated javadocs.
	rm -f ${BUILDDESTINATION}/javadoc/*.zip

	# Use the system ant
	cd ${BUILDDESTINATION}/ide${IDE_VERSION}/ant
	rm -fr lib
	rm -fr bin

	# Set a initial default jdk
	echo "netbeans_jdkhome=\"\$(java-config -O)\"" >> ${BUILDDESTINATION}/etc/netbeans.conf
}

src_install() {
	insinto ${DESTINATION}

	einfo "Installing the program..."
	cd ${BUILDDESTINATION}
	doins -r *

	# Change location of etc files
	insinto /etc/${PN}-${SLOT}
	doins ${BUILDDESTINATION}/etc/*
	rm -fr ${D}/${DESTINATION}/etc
	dosym /etc/${PN}-${SLOT} ${DESTINATION}/etc

	# Replace bundled jars with system jars
	symlink_extjars ${D}/${DESTINATION}

	# Correct permissions on executables
	fperms 755 \
		   ${DESTINATION}/bin/netbeans \
		   ${DESTINATION}/platform${PLATFORM}/lib/nbexec

	# The wrapper wrapper :)
	newbin ${MY_FDIR}/startscript.sh netbeans-${SLOT}

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
	dodoc build_info
	dohtml CREDITS.html README.html netbeans.css
	rm -f build_info CREDITS.html README.html netbeans.css

	use doc && java-pkg_dojavadoc ${S}/nbbuild/build/javadoc

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
	elog "The integrated Tomcat is not installed, but you can easily "
	elog "use the system Tomcat. See Netbeans documentation if you   "
	elog "don't know how to do that. The relevant settings are in the"
	elog "runtime window.                                            "
	elog
	elog "If you are using some packages on top of Netbeans, you have"
	elog "to re-emerge them now.                                     "
}

pkg_postrm() {
	if ! test -e /usr/bin/netbeans-${SLOT}; then
		elog "Because of the way Portage works at the moment"
		elog "symlinks to the system jars are left to:"
		elog "${DESTINATION}"
		elog "If you are uninstalling Netbeans you can safely"
		elog "remove everything in this directory"
	fi
}

# Supporting functions for this ebuild

function place_unpack_symlinks() {
	# Here are listed all bundled jars, some of them cannot be replaced.

	# ant
	#ant/freeform/test/unit/data/example-projects/simple/lib/lib1.jar
	#ant/freeform/test/unit/data/example-projects/simple/lib/lib2.jar
	#ant/test/qa-functional/src/org/netbeans/test/gui/ant/data/antscripts.jar

	einfo "Symlinking jars for apisupport"
	cd ${S}/apisupport/external
	java-pkg_jar-from --build-only jdom-1.0
	java-pkg_jar-from javahelp-bin jsearch.jar jsearch-2.0_03.jar
	java-pkg_jar-from --build-only rome rome.jar rome-fetcher-0.6.jar
	java-pkg_jar-from --build-only rome rome.jar rome-0.6.jar
	#apisupport/project/test/unit/data/example-external-projects/suite3/nbplatform/platform5/core/openide.jar
	#apisupport/project/test/unit/data/example-external-projects/suite3/nbplatform/random/modules/ext/stuff.jar
	#apisupport/project/test/unit/data/example-external-projects/suite3/nbplatform/random/modules/random.jar
	#apisupport/samples/feedreader-suite/branding/core/core.jar
	#apisupport/samples/feedreader-suite/branding/modules/org-netbeans-core.jar
	#apisupport/samples/feedreader-suite/branding/modules/org-netbeans-core-windows.jar
	#apisupport/samples/PaintApp-suite/branding/core/core.jar
	#apisupport/samples/PaintApp-suite/branding/modules/org-netbeans-core.jar
	#apisupport/samples/PaintApp-suite/branding/modules/org-netbeans-core-windows.jar
	#apisupport/samples/PaintApp-suite/ColorChooser/release/modules/ext/ColorChooser.jar

	einfo "Symlinking jars for core"
	cd ${S}/core/external
	java-pkg_jar-from javahelp-bin jh.jar jh-2.0_03.jar
	#core/test/qa-functional/data/SampleProject/data.jar

	# db
	#db/core/test/unit/data/mysql5.0/mysql-connector-java-3.1.12-bin.jar
	# MISSING: db/external/fake-jdbc40.jar (no ebuild)

	# extbrowser
	#extbrowser/test/ExtBrowser/qa-functional/testdata/data.jar

	einfo "Symlinking jars for httpserver"
	cd ${S}/httpserver/external
	java-pkg_jar-from servletapi-2.2 servlet.jar servlet-2.2.jar
	# MISSING: webserver.jar (something from tomcat)

	# java
	# MISSING: java/external/gjast.jar (no ebuild)

	einfo "Symlinking jars for junit"
	cd ${S}/junit/external
	java-pkg_jar-from junit junit.jar junit-3.8.1.jar
	#junit/test/function/lib/test.jar

	einfo "Symlinking jars for j2ee"
	#j2ee/archiveproject/test/qa-functional/data/jbrejb14.jar
	#j2ee/clientproject/test/unit/data/projects/ApplicationClient1/libs/jar0.jar
	#j2ee/clientproject/test/unit/data/projects/ApplicationClient1/libs/jar1.jar
	#j2ee/clientproject/test/unit/data/projects/ApplicationClient1/libs/jar2.jar
	#j2ee/ejbfreeform/test/unit/data/test-app/lib/test-lib1.jar
	#j2ee/ejbjarproject/test/unit/data/projects/EJBModule1/libs/jar0.jar
	#j2ee/ejbjarproject/test/unit/data/projects/EJBModule1/libs/jar1.jar
	#j2ee/ejbjarproject/test/unit/data/projects/EJBModule1/libs/jar2.jar
	cd ${S}/j2ee/external
	java-pkg_jar-from --build-only glassfish-persistence
	#j2ee/test/qa-functional/data/freeform_projects/cmp2/lib/junitejb.jar
	#j2ee/test/qa-functional/data/freeform_projects/cmp2/lib/junit.jar
	#j2ee/test/qa-functional/data/libs/MathLib.jar

	einfo "Symlinking jars for j2eeserver"
	cd ${S}/j2eeserver/external
	java-pkg_jar-from sun-j2ee-deployment-bin-1.1 sun-j2ee-deployment-bin.jar jsr88javax.jar

	einfo "Symlinking jars for libs"
	cd ${S}/libs/external
	java-pkg_jar-from commons-logging commons-logging.jar commons-logging-1.0.4.jar
	java-pkg_jar-from jgoodies-forms forms.jar forms-1.0.5.jar
	java-pkg_jar-from jsch jsch.jar jsch-0.1.24.jar
	java-pkg_jar-from --build-only pmd pmd.jar pmd-1.3.jar
	#resolver-1_1_nb.jar (netbeans stuff)
	java-pkg_jar-from swing-layout-1 swing-layout.jar swing-layout-1.0.jar
	java-pkg_jar-from --build-only xml-xmlbeans-1 xbean.jar xbean-1.0.4.jar
	java-pkg_jar-from xerces-2 xercesImpl.jar xerces-2.8.0.jar
	java-pkg_jar-from xml-commons xml-apis.jar xml-commons-dom-ranges-1.0.b2.jar

	einfo "Symlinking jars for mdr"
	cd ${S}/mdr/external
	java-pkg_jar-from jmi-interface jmi.jar jmi.jar
	java-pkg_jar-from jmi-interface mof.jar mof.jar
	#mdr/test/perf/src/org/netbeans/mdr/test/data/jmi-java.jar
	#mdr/test/perf/src/org/netbeans/mdr/test/data/mm.mysql-2.0.4-bin-1.jar
	#mdr/test/unit/src/org/netbeans/mdr/test/data/component.jar
	#mdr/test/unit/src/org/netbeans/mdr/test/data/indexedModel.jar
	#mdr/test/unit/src/org/netbeans/mdr/test/data/java-jmi.jar
	#mdr/test/unit/src/org/netbeans/mdr/test/data/pkg_inh-jmi.jar
	#mdr/test/unit/src/org/netbeans/mdr/test/data/staticFeatures.jar
	#mdr/test/unit/src/org/netbeans/mdr/test/data/text-jmi.jar
	#mdr/test/unit/src/org/netbeans/mdr/test/data/uml-14.jar

	einfo "Symlinking jars for nbbuild"
	cd ${S}/nbbuild/external
	java-pkg_jar-from javahelp-bin jhall.jar jhall-2.0_03.jar
	#scrambler.jar (netbeans stuff)

	# openide
	#openide/test/qa-functional/src/DataLoaderTests/DataObjectTest/data/data.jar
	#openide/test/qa-functional/src/gui/explorer/data/testfiles/CopyCutPasteRenameTest/test.jar

	einfo "Symlinking jars for serverplugins"
	cd ${S}/serverplugins/external
	java-pkg_jar-from --build-only sun-jmx jmxri.jar jmxremote.jar

	einfo "Symlinking jars for tasklist"
	cd ${S}/tasklist/external
	# MISSING: ical4j.jar (no ebuild)
	java-pkg_jar-from --build-only jcalendar-1.2
	java-pkg_jar-from --build-only jtidy Tidy.jar Tidy-r7.jar

	einfo "Symlinking jars for web"
	cd ${S}/web/external
	java-pkg_jar-from --build-only commons-el
	# MISSING: glassfish-jspparser.jar (no ebuild)
	# MISSING: glassfish-logging.jar (no ebuild)
	java-pkg_jar-from jakarta-jstl jstl.jar jstl-1.1.2.jar
	java-pkg_jar-from --build-only servletapi-2.3 servlet.jar servlet-2.3.jar
	# MISSING: servlet2.5-jsp2.1-api.jar (no ebuild)
	java-pkg_jar-from jakarta-jstl standard.jar standard-1.1.2.jar
	#web/jspdebug/test/qa-functional/data/TestTagLibrary/jsp-api-2.0.jar
	#web/jspdebug/test/qa-functional/data/TestTagLibrary/servlet-api-2.4.jar
	#web/project/test/unit/data/projects/WebApplication1/libs/jar0.jar
	#web/project/test/unit/data/projects/WebApplication1/libs/jar1.jar
	#web/project/test/unit/data/projects/WebApplication1/libs/jar2.jar
	#web/test/qa-functional/data/PerformanceTestData/src/org/netbeans/test/performance/test.jar

	einfo "Symlinking jars for xml"
	cd ${S}/xml/external
	java-pkg_jar-from flute
	java-pkg_jar-from --build-only commons-jxpath commons-jxpath.jar jxpath1.1.jar
	java-pkg_jar-from --build-only prefuse-2006 prefuse.jar prefuse.jar
	#resolver-1_1_nb.jar (netbeans stuff)
	java-pkg_jar-from sac
}

function symlink_extjars() {
	einfo "Symlinking enterprise jars"

	cd ${1}/enterprise${ENTERPRISE}/modules/ext
	#appsrvbridge.jar (netbeans stuff)
	# MISSING: glassfish-jspparser.jar (no ebuild)
	# MISSING: glassfish-logging.jar (no ebuild)
	#jsp-parser-ext.jar (netbeans stuff)
	java-pkg_jar-from sun-j2ee-deployment-bin-1.1 sun-j2ee-deployment-bin.jar jsr88javax.jar
	java-pkg_jar-from jakarta-jstl jstl.jar
	# MISSING: persistence-tool-support.jar (no ebuild)
	# MISSING: servlet2.5-jsp2.1-api.jar (no ebuild)
	java-pkg_jar-from jakarta-jstl standard.jar
	#websvcregistry.jar (netbeans stuff)

	cd ${1}/enterprise${ENTERPRISE}/modules/ext/blueprints
	# MISSING: bp-ui-14.jar (no ebuild)
	# MISSING: bp-ui-5.jar (no ebuild)
	java-pkg_jar-from commons-fileupload commons-fileupload.jar commons-fileupload-1.1.1.jar
	java-pkg_jar-from commons-io-1 commons-io.jar commons-io-1.2.jar
	java-pkg_jar-from commons-logging commons-logging.jar commons-logging-1.1.jar
	# MISSING: shale-remoting.jar (no ebuild)

	cd ${1}/enterprise${ENTERPRISE}/modules/ext/jsf
	java-pkg_jar-from commons-beanutils-1.7 commons-beanutils.jar
	java-pkg_jar-from commons-collections commons-collections.jar
	java-pkg_jar-from commons-digester commons-digester.jar
	java-pkg_jar-from commons-logging commons-logging.jar
	# MISSING: jsf-api.jar (no ebuild)
	# MISSING: jsf-impl.jar (no ebuild)

	cd ${1}/enterprise${ENTERPRISE}/modules/ext/struts
	java-pkg_jar-from antlr antlr.jar
	java-pkg_jar-from commons-beanutils-1.7 commons-beanutils.jar
	java-pkg_jar-from commons-digester commons-digester.jar
	java-pkg_jar-from commons-fileupload commons-fileupload.jar
	java-pkg_jar-from commons-logging commons-logging.jar
	java-pkg_jar-from commons-validator commons-validator.jar
	java-pkg_jar-from jakarta-oro-2.0 jakarta-oro.jar
	java-pkg_jar-from struts-1.2 struts.jar


	einfo "Symlinking harness jars"

	cd ${1}/harness
	java-pkg_jar-from javahelp-bin jsearch.jar jsearch-2.0_03.jar


	einfo "Symlinking ide jars"

	cd ${1}/ide${IDE_VERSION}/modules/ext
	#AbsoluteLayout.jar (netbeans stuff)
	java-pkg_jar-from commons-logging commons-logging.jar commons-logging-1.0.4.jar
	#ddl.jar (netbeans stuff)
	java-pkg_jar-from flute
	java-pkg_jar-from jgoodies-forms forms.jar forms-1.0.5.jar
	# MISSING: gjast.jar (no ebuild)
	#java-parser.jar (netbeans stuff)
	java-pkg_jar-from jmi-interface jmi.jar jmi.jar
	#jmiutils.jar (netbeans stuff)
	java-pkg_jar-from jsch jsch.jar jsch-0.1.24.jar
	java-pkg_jar-from junit junit.jar junit-3.8.1.jar
	#mdr.jar (netbeans stuff)
	java-pkg_jar-from jmi-interface mof.jar mof.jar
	#resolver-1_1_nb.jar (netbeans stuff)
	java-pkg_jar-from sac
	java-pkg_jar-from servletapi-2.2 servlet.jar servlet-2.2.jar
	# MISSING: webserver.jar (something from tomcat)
	java-pkg_jar-from xerces-2 xercesImpl.jar xerces-2.8.0.jar
	java-pkg_jar-from xml-commons xml-apis.jar xml-commons-dom-ranges-1.0.b2.jar

	cd ${1}/ide${IDE_VERSION}/modules/ext/jaxrpc16
	java-pkg_jar-from sun-jaf
	java-pkg_jar-from sun-fastinfoset-bin
	java-pkg_jar-from sun-jaxp-bin
	# MISSING: jax-qname.jar (no ebuild)
	java-pkg_jar-from sun-jaxrpc-bin jaxrpc-api.jar
	java-pkg_jar-from sun-jaxrpc-bin jaxrpc-impl.jar
	java-pkg_jar-from sun-jaxrpc-bin jaxrpc-spi.jar
	java-pkg_jar-from jsr173 jsr173.jar jsr173_api.jar
	java-pkg_jar-from sun-javamail
	java-pkg_jar-from relaxng-datatype
	java-pkg_jar-from sun-saaj-bin saaj-api.jar
	java-pkg_jar-from sun-saaj-bin saaj-impl.jar
	java-pkg_jar-from xsdlib

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
	#resolver.jar (netbeans stuff)
	java-pkg_jar-from sun-saaj-bin saaj-api.jar
	java-pkg_jar-from sun-saaj-bin saaj-impl.jar
	java-pkg_jar-from sun-sjsxp-bin


	einfo "Symlinking platform jars"
	cd ${1}/platform${PLATFORM}/modules/ext
	java-pkg_jar-from javahelp-bin jh.jar jh-2.0_03.jar
	java-pkg_jar-from swing-layout-1 swing-layout.jar swing-layout-1.0.jar
	#updater.jar (netbeans stuff)
}
