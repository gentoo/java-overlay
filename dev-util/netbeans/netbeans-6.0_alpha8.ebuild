# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/netbeans/netbeans-5.5-r4.ebuild,v 1.1 2007/01/28 19:40:16 fordfrog Exp $

inherit eutils java-pkg-2 java-ant-2 versionator

DESCRIPTION="NetBeans IDE for Java"
HOMEPAGE="http://www.netbeans.org"

SLOT="6.0"
MILESTONE="m8"
MY_PV=$(replace_all_version_separators '_' $(get_version_component_range 1-2))
NB_FILE="${PN}-${MY_PV}-${MILESTONE}-src-200703280911-ide_sources-28_Mar_2007_0911.tar.bz2"
MOBILITY_FILE="${PN}-mobility-${MY_PV}-${MILESTONE}.tar.bz2"
VISUALWEB_FILE="${PN}-visualweb-${MY_PV}-${MILESTONE}.tar.bz2"
SRC_URI="http://us1.mirror.netbeans.org/download/${MY_PV}/${MILESTONE}/200703280911/${NB_FILE}
	mobility? ( http://dev.gentoo.org/~fordfrog/distfiles/${MOBILITY_FILE} )
	visualweb? ( http://dev.gentoo.org/~fordfrog/distfiles/${VISUALWEB_FILE} )"

LICENSE="CDDL"
KEYWORDS="~amd64 ~x86 ~x86-fbsd"
IUSE="debug doc mobility visualweb"

COMMON_DEPEND="
	>=dev-java/ant-1.6.3
	dev-java/antlr
	=dev-java/commons-beanutils-1.7*
	dev-java/commons-collections
	>=dev-java/commons-logging-1.0.4
	dev-java/flute
	>=dev-java/jakarta-jstl-1.1.2
	>=dev-java/sun-j2ee-deployment-bin-1.1
	>=dev-java/javahelp-2.0.02
	>=dev-java/jsch-0.1.24
	=dev-java/junit-3.8*
	>=dev-java/junit-4
	dev-java/sac
	=dev-java/servletapi-2.2*
	=dev-java/swing-layout-1*
	>=dev-java/xerces-2.8.0
	>=dev-java/xml-commons-1.0_beta2
	mobility? (
		dev-java/commons-httpclient
		dev-java/commons-net
		dev-java/proguard
	)
	visualweb? (
		dev-java/commons-digester
		dev-java/commons-fileupload
	)
"

RDEPEND=">=virtual/jre-1.5
	dev-java/commons-digester
	>=dev-java/commons-fileupload-1.1
	>=dev-java/commons-io-1.2
	dev-java/commons-validator
	dev-java/jakarta-oro
	mobility? ( >=dev-java/jdom-1.0 )
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

# NOTE: Currently there is a problem with building netbeans and mobility pack with JDK 1.6
# so we limit it to JDK 1.5 for now.
DEPEND="=virtual/jdk-1.5*
	>=dev-java/commons-cli-1.0
	dev-java/commons-el
	>=dev-java/commons-jxpath-1.1
	>=dev-java/commons-lang-2.1
	dev-java/glassfish-persistence
	mobility? ( dev-java/jakarta-oro )
	>=dev-java/jcalendar-1.2
	>=dev-java/jdom-1.0
	>=dev-java/jmi-interface-1.0-r3
	dev-java/jtidy
	>=dev-java/prefuse-20060715_beta
	>=dev-java/rome-0.6
	=dev-java/servletapi-2.3*
	dev-java/sun-jmx
	>=dev-java/xml-xmlbeans-1.0.4
	dev-util/checkstyle
	>=dev-util/pmd-1.3
	${COMMON_DEPEND}"

S=${WORKDIR}/netbeans-src
BUILDDESTINATION="${S}/nbbuild/netbeans"
ENTERPRISE="4"
IDE_VERSION="8"
PLATFORM="7"
MY_FDIR="${FILESDIR}/${SLOT}"
DESTINATION="/usr/share/netbeans-${SLOT}"
CLUSTER_FILE="/etc/${PN}-${SLOT}/netbeans.clusters"
PRODUCTID_FILE="${DESTINATION}/nb${SLOT}/config/productid"
JAVA_PKG_BSFIX="off"

# NOTE: When compilation is restricted back to >= JDK 1.5 then we should check whether
# rewrite is needed because with Netbeans 5.5 rewrite was needed because of bug #164256.
# Unfortunately the rewrite on Netbeans takes several minutes so turning it off is a big
# time safe.


src_unpack () {
	unpack ${NB_FILE}
	cd ${S}

	if use mobility ; then
		unpack ${MOBILITY_FILE}
	fi

	if use visualweb ; then
		unpack ${VISUALWEB_FILE}
	fi

	# Disable the bundled Tomcat in favor of Portage installed version
	cd ${S}/nbbuild
	sed -i -e "s%tomcatint/tomcat5/bundled,%%g" *.properties

	place_unpack_symlinks
	use mobility && place_unpack_symlinks_mobility
	use visualweb && place_unpack_symlinks_visualweb
}

src_compile() {
	local antflags="-Dstop.when.broken.modules=true"

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
	ANT_OPTS="-Xmx1g -Djava.awt.headless=true" eant ${antflags} build-nozip
	# Running build-javadoc from the same command line as build-nozip doesn't work
	# so we must run it separately
	use doc && ANT_OPTS="-Xmx1g" eant build-javadoc

	if use mobility ; then
		cd ${S}/mobility
		ANT_OPTS="-Xmx1g -Djava.awt.headless=true" eant ${antflags} build
		# no javadoc target for mobility
	fi

	if use visualweb ; then
		cd ${S}/visualweb
		ANT_OPTS="-Xmx1g -Djava.awt.headless=true" eant ${antflags} build
		# no javadoc target for visualweb
	fi

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

	# fix paths per bug# 163483
	sed -i -e 's:"$progdir"/../etc/:/etc/netbeans-6.0/:' ${BUILDDESTINATION}/bin/netbeans
	sed -i -e 's:"${userdir}"/etc/:/etc/netbeans-6.0/:' ${BUILDDESTINATION}/bin/netbeans
}

src_install() {
	insinto ${DESTINATION}

	einfo "Installing the program..."
	cd ${BUILDDESTINATION}
	doins -r *
	use profiler && doins -r ${WORKDIR}/profiler/*

	# Change location of etc files
	insinto /etc/${PN}-${SLOT}
	doins ${BUILDDESTINATION}/etc/*
	rm -fr ${D}/${DESTINATION}/etc
	dosym /etc/${PN}-${SLOT} ${DESTINATION}/etc

	# Replace bundled jars with system jars
	symlink_extjars ${D}/${DESTINATION}
	use mobility && symlink_extjars_mobility ${D}/${DESTINATION}
	use visualweb && symlink_extjars_visualweb ${D}/${DESTINATION}

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

	einfo "Symlinking jars for apisupport"
	cd ${S}/apisupport/external
	java-pkg_jar-from --build-only jdom-1.0
	#java-pkg_jar-from javahelp jsearch.jar jsearch-2.0_04.jar
	java-pkg_jar-from --build-only rome rome.jar rome-fetcher-0.6.jar
	java-pkg_jar-from --build-only rome rome.jar rome-0.6.jar
	#apisupport/project/test/unit/data/example-external-projects/suite3/nbplatform/platform5/core/openide.jar
	#apisupport/project/test/unit/data/example-external-projects/suite3/nbplatform/random/modules/ext/stuff.jar
	#apisupport/project/test/unit/data/example-external-projects/suite3/nbplatform/random/modules/random.jar
	#apisupport/project/test/unit/data/ServiceTest.jar
	#apisupport/samples/feedreader-suite/branding/core/core.jar
	#apisupport/samples/PaintApp-suite/branding/core/core.jar
	#apisupport/samples/PaintApp-suite/ColorChooser/release/modules/ext/ColorChooser.jar
	#apisupport/timers/external/insanelib.jar

	einfo "Symlinking jars for core"
	cd ${S}/core/external
	#java-pkg_jar-from javahelp jh.jar jh-2.0_04.jar
	#core/test/qa-functional/data/SampleProject/data.jar

	# db
	#db/core/test/unit/data/mysql5.0/mysql-connector-java-3.1.12-bin.jar
	#db/visualsqleditor/external/javacc.jar
	#db/visualsqleditor/external/jgraph.jar
	#db/visualsqleditor/release/modules/ext/jgraph.jar

	# extbrowser
	#extbrowser/test/ExtBrowser/qa-functional/testdata/data.jar

	einfo "Symlinking jars for httpserver"
	cd ${S}/httpserver/external
	java-pkg_jar-from servletapi-2.2 servlet.jar servlet-2.2.jar
	# MISSING: webserver.jar (something from tomcat)

	# ide
	#ide/bluej-suite/branding/core/core.jar
	#ide/bluej-suite/branding/modules/org-apache-tools-ant-module.jar

	# java
	#java/external/javac-api.jar
	#java/external/javac-impl.jar
	#java/external/lucene-core-2.1.0.jar
	#java/source/test/unit/data/Annotations.jar

	einfo "Symlinking jars for junit"
	cd ${S}/junit/external
	java-pkg_jar-from junit junit.jar junit-3.8.2.jar
	java-pkg_jar-from junit-4 junit.jar junit-4.1.jar
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
	# MISSING: javaee-api-5.jar
	#j2ee/test/qa-functional/data/freeform_projects/cmp2/lib/junitejb.jar
	#j2ee/test/qa-functional/data/freeform_projects/cmp2/lib/junit.jar
	#j2ee/test/qa-functional/data/libs/MathLib.jar

	einfo "Symlinking jars for j2eeserver"
	cd ${S}/j2eeserver/external
	java-pkg_jar-from sun-j2ee-deployment-bin-1.1 sun-j2ee-deployment-bin.jar jsr88javax.jar

	einfo "Symlinking jars for lexer"
	cd ${S}/lexer/external
	java-pkg_jar-from antlr antlr.jar antlr-2.7.1.jar
	# MISSING: lexer-gen-antlr-2.7.1.jar

	einfo "Symlinking jars for libs"
	cd ${S}/libs/external
	java-pkg_jar-from --build-only commons-lang-2.1 commons-lang.jar commons-lang-2.1.jar
	java-pkg_jar-from commons-logging commons-logging-api.jar commons-logging-api-1.1.jar
	java-pkg_jar-from commons-logging commons-logging.jar commons-logging-1.0.4.jar
	# MISSING: freemarker-2.3.8.jar
	# MISSING: ical4j-1.0-beta1.jar
	java-pkg_jar-from --build-only jcalendar-1.2 jcalendar.jar jcalendar-1.3.2.jar
	java-pkg_jar-from jsch jsch.jar jsch-0.1.24.jar
	# MISSING: jsr223-api.jar
	java-pkg_jar-from --build-only pmd pmd.jar pmd-1.3.jar
	#resolver-1_1_nb.jar (netbeans stuff)
	java-pkg_jar-from swing-layout-1 swing-layout.jar swing-layout-1.0.1.jar
	java-pkg_jar-from --build-only xml-xmlbeans-1 xbean.jar xbean-1.0.4.jar
	java-pkg_jar-from xerces-2 xercesImpl.jar xerces-2.8.0.jar

	einfo "Symlinking jars for mdr"
	cd ${S}/mdr/external
	java-pkg_jar-from --build-only jmi-interface jmi.jar jmi.jar
	java-pkg_jar-from --build-only jmi-interface mof.jar mof.jar
	#mdr/test/perf/src/org/netbeans/mdr/test/data/jmi-java.jar
	#mdr/test/perf/src/org/netbeans/mdr/test/data/mm.mysql-2.0.4-bin-1.jar
	#mdr/test/unit/src/org/netbeans/mdr/test/data/component.jar
	#mdr/test/unit/src/org/netbeans/mdr/test/data/indexedModel.jar
	#mdr/test/unit/src/org/netbeans/mdr/test/data/java-jmi.jar
	#mdr/test/unit/src/org/netbeans/mdr/test/data/pkg_inh-jmi.jar
	#mdr/test/unit/src/org/netbeans/mdr/test/data/staticFeatures.jar
	#mdr/test/unit/src/org/netbeans/mdr/test/data/text-jmi.jar
	#mdr/test/unit/src/org/netbeans/mdr/test/data/uml-14.jar

	# nbbuild
	#nbbuild/external/scrambler.jar

	# openide
	#openide/loaders/test/qa-functional/src/DataLoaderTests/DataObjectTest/data/data.jar

	einfo "Symlinking jars for serverplugins"
	cd ${S}/serverplugins/external
	java-pkg_jar-from --build-only sun-jmx jmxri.jar jmxremote.jar

	einfo "Symlinking jars for subversion"
	cd ${S}/subversion/external
	# MISSING: ini4j.jar
	# MISSING: svnClientAdapter.jar
	#subversion/main/test/qa-functional/data/files/test.jar

	einfo "Symlinking jars for tasklist"
	cd ${S}/tasklist/external
	java-pkg_jar-from antlr antlr.jar
	java-pkg_jar-from commons-beanutils-1.7 commons-beanutils-core.jar
	java-pkg_jar-from --build-only commons-cli-1
	java-pkg_jar-from commons-collections commons-collections.jar
	java-pkg_jar-from --build-only checkstyle
	# MISSING: ical4j-0.9.20.jar
	java-pkg_jar-from --build-only jcalendar-1.2 jcalendar.jar jcalendar-1.3.0.jar
	java-pkg_jar-from --build-only jtidy Tidy.jar Tidy-r7.jar

	# versioncontrol
	#versioncontrol/localhistory/test/lib/tests-qa-functional.jar

	einfo "Symlinking jars for web"
	cd ${S}/web/external
	java-pkg_jar-from --build-only commons-el
	# MISSING: glassfish-jspparser.jar (no ebuild)
	# MISSING: glassfish-logging.jar (no ebuild)
	java-pkg_jar-from jakarta-jstl jstl.jar jstl-1.1.2.jar
	java-pkg_jar-from --build-only servletapi-2.3 servlet.jar servlet-2.3.jar
	# MISSING: servlet2.5-jsp2.1-api.jar (no ebuild)
	java-pkg_jar-from jakarta-jstl standard.jar standard-1.1.2.jar
	#web/external/flyingsaucer/core-renderer.jar
	#web/external/flyingsaucer/cssparser-0-9-4-fs.jar
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

function place_unpack_symlinks_mobility() {
	einfo "Symlinking jars for mobility"
	#mobility/ant-ext/test/unit/data/goldenfiles/org/netbeans/mobility/antext/ExtractTaskTest/test.jar
	#mobility/ant-ext/test/unit/data/goldenfiles/org/netbeans/mobility/antext/JadTaskTest/MobileApplication.jar
	#mobility/ant-ext/test/unit/data/goldenfiles/org/netbeans/mobility/antext/ObfuscateTaskTest/MobileApplication.jar
	#mobility/ant-ext/test/unit/data/goldenfiles/org/netbeans/mobility/antext/RunTaskTest/MobileApplication.jar
	#mobility/cdcplugins/ricoh/release/external/jcifs-1.2.11.jar
	#mobility/cdcplugins/ricoh/release/external/RicohAntTasks.jar
	#mobility/cldcplatform/test/unit/data/goldenfiles/org/netbeans/modules/mobility/cldcplatform/J2MEPlatformTest/MIDletSuite.jar

	cd ${S}/mobility/deployment/ftpscp/external
	java-pkg_jar-from commons-net commons-net.jar commons-net-1.4.1.jar
	java-pkg_jar-from jakarta-oro-2.0 jakarta-oro.jar jakarta-oro-2.0.8.jar

	cd ${S}/mobility/deployment/webdav/external
	java-pkg_jar-from commons-httpclient
	java-pkg_jar-from commons-logging commons-logging.jar
	# MISSING: jakarta-slide-ant-webdav-2.1.jar
	# MISSING: jakarta-slide-webdavlib-2.1.jar
	java-pkg_jar-from --build-only jdom-1.0

	#mobility/designer/nb_midp_components/dist/nb_midp_components.jar
	#mobility/j2meunit/external/jmunit4cldc10-1.0.1.jar
	#mobility/j2meunit/external/jmunit4cldc11-1.0.1.jar

	cd ${S}/mobility/proguard/external
	java-pkg_jar-from proguard proguard.jar proguard3.5.jar

	#mobility/project/test/unit/data/goldenfiles/org/netbeans/modules/mobility/project/classpath/J2MEProjectClassPathExtenderTest/MIDletSuite.jar
	#mobility/project/test/unit/data/goldenfiles/org/netbeans/modules/mobility/project/J2MEProjectGeneratorTest/Studio/MIDletSuite.jar
	#mobility/svg/nb_svg_midp_components/dist/nb_svg_midp_components.jar
	#mobility/svg/perseus_svg_library/release/modules/ext/perseus-nb.jar
}

function place_unpack_symlinks_visualweb() {
	einfo "Symlinking jars for visualweb"
	#visualweb/dataconnectivity/external/derby/jars/derby.jar
	#visualweb/dataconnectivity/external/derby/jars/derbyLocale_de_DE.jar
	#visualweb/dataconnectivity/external/derby/jars/derbyLocale_es.jar
	#visualweb/dataconnectivity/external/derby/jars/derbyLocale_fr.jar
	#visualweb/dataconnectivity/external/derby/jars/derbyLocale_it.jar
	#visualweb/dataconnectivity/external/derby/jars/derbyLocale_ja_JP.jar
	#visualweb/dataconnectivity/external/derby/jars/derbyLocale_ko_KR.jar
	#visualweb/dataconnectivity/external/derby/jars/derbyLocale_pt_BR.jar
	#visualweb/dataconnectivity/external/derby/jars/derbyLocale_zh_CN.jar
	#visualweb/dataconnectivity/external/derby/jars/derbyLocale_zh_TW.jar
	#visualweb/dataconnectivity/external/derby/jars/derbynet.jar
	#visualweb/dataconnectivity/external/derby/jars/derbytools.jar
	#visualweb/ejb/support/release/modules/ext/ejb20.jar

	cd ${S}/visualweb/ravehelp/external
	#java-pkg_jar-from javahelp jhall.jar jhall-2.0_02.jar

	cd ${S}/visualweb/ravelibs/commons-beanutils/release/modules/ext
	#java-pkg_jar-from commons-beanutils-1.7 commons-beanutils.jar

	cd ${S}/visualweb/ravelibs/commons-collections/release/modules/ext
	#java-pkg_jar-from commons-collections

	cd ${S}/visualweb/ravelibs/commons-digester/release/modules/ext
	#java-pkg_jar-from commons-digester

	cd ${S}/visualweb/ravelibs/commons-fileupload/release/modules/ext
	#java-pkg_jar-from commons-fileupload

	cd ${S}/visualweb/ravelibs/commons-logging/release/modules/ext
	#java-pkg_jar-from commons-logging commons-logging.jar

	#visualweb/ravelibs/el-ri-1.2/release/modules/ext/el-impl-1.2.jar
	#visualweb/ravelibs/external/standard.jar
	#visualweb/ravelibs/javaee-5/release/modules/ext/activation.jar
	#visualweb/ravelibs/javaee-5/release/modules/ext/dojo-0.4.1-ajax.jar
	#visualweb/ravelibs/javaee-5/release/modules/ext/javaee.jar
	#visualweb/ravelibs/javaee-5/release/modules/ext/jsf-extensions-common-0.1-SNAPSHOT.jar
	#visualweb/ravelibs/javaee-5/release/modules/ext/jsf-extensions-dynamic-faces-0.1-SNAPSHOT.jar
	#visualweb/ravelibs/javaee-5/release/modules/ext/json2.jar
	#visualweb/ravelibs/javaee-5/release/modules/ext/mail.jar
	#visualweb/ravelibs/javaee-5/release/modules/ext/prototype-1.5.0.jar
	#visualweb/ravelibs/jsf-api/release/modules/ext/jsf-api.jar
	#visualweb/ravelibs/jsf-portlet/external/jsf-portlet.jar
	#visualweb/ravelibs/jsf-ri/release/modules/ext/jsf-impl.jar
	#visualweb/ravelibs/jsf-ri-1.2/release/modules/ext/jsf-ri-1.2.jar
	#visualweb/ravelibs/jsp-api/release/modules/ext/jsp-api.jar
	#visualweb/ravelibs/jstl/release/modules/ext/jstl.jar
	#visualweb/ravelibs/portlet-api/external/portlet.jar
	#visualweb/ravelibs/rowset/release/modules/ext/rowset.jar
	#visualweb/ravelibs/servlet-api/release/modules/ext/servlet-api.jar
	#visualweb/ravelibs/sun-apache-commons/release/modules/ext/com-sun-apache-commons.jar
	#visualweb/sql/release/modules/ext/sqlx.jar
	#visualweb/webui/themes/release/modules/ext/defaulttheme-gray.jar
	#visualweb/webui/themes/release/modules/ext/defaulttheme-green.jar
	#visualweb/webui/themes/release/modules/ext/defaulttheme.jar
	#visualweb/woodstock/components/release/modules/ext/webui-jsf-dt.jar
	#visualweb/woodstock/components/release/modules/ext/webui-jsf.jar
	#visualweb/woodstock/defaulttheme/release/modules/ext/webui-jsf-suntheme.jar
}

function symlink_extjars() {
	# jars named 'org-netbeans-*' are excluded

	einfo "Symlinking enterprise jars"

	#enterprise4/ant/extra/copyfiles.jar (netbeans stuff)

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

	cd ${1}/harness/jnlp
	#jnlp-launcher.jar (netbeans stuff)

	cd ${1}/harness
	java-pkg_jar-from javahelp jsearch.jar jsearch-2.0_04.jar
	#tasks.jar (netbeans stuff)


	einfo "Symlinking ide jars"

	# MISSING: ide8/ant/etc/ant-bootstrap.jar
	# MISSING: ide8/ant/nblib/bridge.jar

	cd ${1}/ide${IDE_VERSION}/modules/ext
	#AbsoluteLayout.jar (netbeans stuff)
	java-pkg_jar-from commons-logging commons-logging.jar commons-logging-1.0.4.jar
	#ddl.jar (netbeans stuff)
	java-pkg_jar-from flute
	# MISSING: freemarker-2.3.8.jar
	# MISSING: ini4j.jar
	#insanelib.jar (netbeans stuff)
	# MISSING: javac-api.jar
	# MISSING: javac-impl.jar
	java-pkg_jar-from jsch jsch.jar jsch-0.1.24.jar
	java-pkg_jar-from junit junit.jar junit-3.8.2.jar
	# MISSING: lucene-core-2.0.0.jar
	#resolver-1_1_nb.jar (netbeans stuff)
	java-pkg_jar-from sac
	java-pkg_jar-from servletapi-2.2 servlet.jar servlet-2.2.jar
	# MISSING: svnClientAdapter.jar
	# MISSING: webserver.jar (something from tomcat)
	java-pkg_jar-from xerces-2 xercesImpl.jar xerces-2.8.0.jar

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

	cd ${1}/ide${IDE_VERSION}/modules/ext/jaxws21
	java-pkg_jar-from sun-jaf
	java-pkg_jar-from sun-fastinfoset-bin
	# MISSING: http.jar (no ebuild)
	java-pkg_jar-from sun-jaxb-bin jaxb-impl.jar
	java-pkg_jar-from sun-jaxb-bin jaxb-xjc.jar
	java-pkg_jar-from sun-jaxws-bin jaxws-rt.jar
	java-pkg_jar-from sun-jaxws-bin jaxws-tools.jar
	java-pkg_jar-from jsr173 jsr173.jar jsr173_api.jar
	java-pkg_jar-from jsr250
	#resolver.jar (netbeans stuff)
	java-pkg_jar-from sun-saaj-bin saaj-impl.jar
	java-pkg_jar-from sun-sjsxp-bin
	# MISSING: stax-ex.jar
	# MISSING: streambuffer.jar

	cd ${1}/ide${IDE_VERSION}/modules/ext/jaxws21/api
	java-pkg_jar-from sun-jaxb-bin jaxb-api.jar
	java-pkg_jar-from sun-jaxws-bin jaxws-api.jar
	java-pkg_jar-from jsr181 jsr181.jar jsr181-api.jar
	java-pkg_jar-from sun-saaj-bin saaj-api.jar

	#ide8/modules/org-apache-tools-ant-module.jar
	#ide8/modules/org-apache-xml-resolver.jar
	#ide8/modules/org-openidex-util.jar


	einfo "Symlinking platform jars"

	#platform7/core/core.jar
	#platform7/core/org-openide-filesystems.jar
	#platform7/lib/boot.jar
	#platform7/lib/org-openide-modules.jar
	#platform7/lib/org-openide-util.jar

	cd ${1}/platform${PLATFORM}/modules/ext
	java-pkg_jar-from javahelp jh.jar jh-2.0_04.jar
	# MISSING: jsr223-api.jar
	java-pkg_jar-from swing-layout-1 swing-layout.jar swing-layout-1.0.1.jar
	#updater.jar (netbeans stuff)

	# MISSING: toplink/toplink-essentials-agent.jar
	# MISSING: toplink/toplink-essentials.jar

	#platform7/modules/org-jdesktop-layout.jar
	#platform7/modules/org-openide-actions.jar
	#platform7/modules/org-openide-awt.jar
	#platform7/modules/org-openide-compat.jar
	#platform7/modules/org-openide-dialogs.jar
	#platform7/modules/org-openide-execution.jar
	#platform7/modules/org-openide-explorer.jar
	#platform7/modules/org-openide-io.jar
	#platform7/modules/org-openide-loaders.jar
	#platform7/modules/org-openide-nodes.jar
	#platform7/modules/org-openide-options.jar
	#platform7/modules/org-openide-text.jar
	#platform7/modules/org-openide-util-enumerations.jar
	#platform7/modules/org-openide-windows.jar


	# nb6.0
	#nb6.0/core/locale/core_nb.jar
	#nb6.0/modules/ext/locale/updater_nb.jar
}

function symlink_extjars_mobility() {
	einfo "Symlinking mobility jars"

	cd ${1}/extra/external
	java-pkg_jar-from commons-httpclient
	java-pkg_jar-from commons-logging commons-logging.jar
	# MISSING: jakarta-slide-ant-webdav-2.1.jar
	# MISSING: jakarta-slide-webdavlib-2.1.jar
	# MISSING: jcifs-1.2.11.jar
	java-pkg_jar-from jdom-1.0
	# MISSING: RicohAntTasks.jar

	cd ${1}/extra/external/proguard
	java-pkg_jar-from proguard proguard.jar proguard3.5.jar

	cd ${1}/extra/modules/ext
	#cdc-agui-swing-layout.jar
	#cdc-pp-awt-layout.jar
	java-pkg_jar-from commons-net commons-net.jar commons-net-1.4.1.jar
	#graphlib.jar
	java-pkg_jar-from jakarta-oro-2.0 jakarta-oro.jar jakarta-oro-2.0.8.jar
	#jmunit4cldc10-1.0.1.jar
	#jmunit4cldc11-1.0.1.jar
	#extra/modules/ext/nb_midp_components.jar
	#extra/modules/ext/nb_svg_midp_components.jar
	#extra/modules/ext/perseus-nb.jar
}

function symlink_extjars_visualweb() {
	# TODO
	echo test
}
