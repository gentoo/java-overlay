# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg

DESCRIPTION="NetBeans ${PV} IDE for Java"

IUSE="debug doc"
HOMEPAGE="http://www.netbeans.org"

MAINTARBALL="netbeans-4_0-src-ide_sources.tar.bz2"
JAVADOCTARBALL="netbeans-4_0-docs-javadoc.tar.bz2"
BASELOCATION=" \
http://www.netbeans.org/download/4_0/fcs/200412081800/d5a0f13566068cb86e33a46ea130b207"

SRC_URI="${BASELOCATION}/${MAINTARBALL} \
		 doc? ( ${BASELOCATION}/${JAVADOCTARBALL} )
		 "

SLOT="4.0"

#When we have java-pkg_jar-from to everything only SPL should be needed here. 
LICENSE="SPL"
KEYWORDS="~x86"

#Bad tomcat versions <r2

DEPEND=">=virtual/jdk-1.4.2
		>=dev-java/ant-1.6.1
		=dev-java/xerces-2.6.2*
		=dev-java/commons-logging-1.0*
		dev-java/regexp
		=dev-java/xalan-2*
		=dev-java/junit-3.8*
		dev-java/mdr
		dev-java/sac
		=dev-java/servletapi-2.2*
		=dev-java/servletapi-2.3*
		=dev-java/servletapi-2.4*
		dev-java/commons-el
		dev-java/jtidy
		=dev-java/jaxen-1.1*
		dev-java/saxpath
		~www-servers/tomcat-5.0.28
		dev-java/javamake-bin
		dev-java/mof
		dev-java/jmi
		dev-java/jsr088
		dev-java/xml-commons
		>=dev-java/javahelp-bin-2.0.02-r1"


RDEPEND="
		>=virtual/jre-1.4.2
		 dev-java/commons-el
		 =dev-java/servletapi-2.4*
		 dev-java/sac
		 dev-java/flute
		 dev-java/mdr
		 ~www-servers/tomcat-5.0.28
		"

S=${WORKDIR}/netbeans-src
		
src_unpack () 
{
	unpack $MAINTARBALL

	if use doc; then
		mkdir javadoc
		cd javadoc
		unpack $JAVADOCTARBALL
		rm *.zip
	fi

	cd ${S}
	epatch ${FILESDIR}/nbbuild.patch

	#removing tomcat
	rm -fr tomcatint 

	#we have ant libs here so using the system libs	
	cd ${S}/ant/external/
	epatch ${FILESDIR}/antbuild.xml.patch
	mkdir lib; cd lib
	java-pkg_jar-from ant-tasks
	java-pkg_jar-from ant-core

	cd ${S}/core/external
	java-pkg_jar-from javahelp-bin jh.jar jh-2.0_01.jar
	
	cd ${S}/nbbuild/external
	java-pkg_jar-from javahelp-bin jhall.jar jhall-2.0_01.jar

	cd ${S}/libs/external/
	java-pkg_jar-from xerces-2 xercesImpl.jar xerces-2.6.2.jar	
	java-pkg_jar-from commons-logging commons-logging.jar commons-logging-1.0.4.jar
	java-pkg_jar-from regexp regexp.jar	regexp-1.2.jar
	java-pkg_jar-from xalan xalan-jar xalan-2.5.2.jar
	java-pkg_jar-form xml-commons xml-apis.jar xml-commons-dom-ranges-1.0.b2.jar

	cd ${S}/mdr/external/
	java-pkg_jar-from jmi
	java-pkg_jar-from mof

	cd ${S}/xml/external/
	java-pkg_jar-from sac 
	java-pkg_jar-from xerces-2 xercesImpl.jar xerces2.jar
	java-pkg_jar-from flute

	cd ${S}/httpserver/external/
	java-pkg_jar-from servletapi-2.2 servletapi-2.2.jar servlet-2.2.jar	

	cd ${S}/j2eeserver/external
	java-pkg_jar-from jsr088 jsr088 jsr088.jar jsr88javax.jar
		
	cd ${S}/java/external/
	java-pkg_jar-from javamake-bin javamake.jar javamake-1.2.12.jar
	
	cd ${S}/junit/external/
	java-pkg_jar-from junit junit.jar junit-3.8.1.jar


	cd ${S}/tasklist/external/
	java-pkg_jar-from jtidy Tidy.jar Tidy-r7.jar
	

	cd ${S}/web/external
	java-pkg_jar-from servletapi-2.3 servletapi-2.3.jar servlet-2.3.jar
	java-pkg_jar-from servletapi-2.4 servlet-api.jar servlet-api-2.4.jar	
	java-pkg_jar-from commons-el
	java-pkg_jar-from jaxen-1.1 jaxen-1.1_beta2.jar jaxen-full.jar
	java-pkg_jar-from saxpath
	java-pkg_jar-from tomcat-5	jasper-compiler.jar jasper-compiler-5.0.28.jar
	java-pkg_jar-from tomcat-5	jasper-runtime.jar jasper-runtime-5.0.28.jar

}
src_compile()
{
	local antflags=""
	! use debug && antflags="${antflags} -Dno-deprecation"

	antflags="${antflags} -Dnetbeans.no.pre.unscramble=true"
	antflags="${antflags} -Dmoduleconfig=stable-without-webapps"
	antflags="${antflags} -Dstop.when.broken.modules=true"

	# The build will attempt to display graphical
	# dialogs for the licence agreements if this is set.
	unset DISPLAY
	
	# Move into the folder where the build.xml file lives.
	cd ${S}/nbbuild
	
	# Specify the build-nozip target otherwise it will build
	# a zip file of the netbeans folder, which will copy directly.
	yes yes 2>/dev/null | 	ant $antflags build-nozip || die "Compiling failed!"

	#Remove non-x86 Linux binaries
	find $S -type f -name "*.exe" -o -name "*.cmd" -o \
			        -name "*.bat" -o -name "*.dll"	  \
			| xargs rm -f
}

src_install()
{	
	local DESTINATION="/usr/share/netbeans-${SLOT}"
	insinto $DESTINATION

	local BUILDDESTINATION="${S}/nbbuild/netbeans"
	cd $BUILDDESTINATION

#The program itself
	doins -r * 

	fperms 755 \
		   ${DESTINATION}/bin/netbeans \
		   ${DESTINATION}/platform4/lib/nbexec
	
	#The symlink to the binary
	dodir /usr/bin
	dosym ${DESTINATION}/bin/netbeans /usr/bin/netbeans-${SLOT}

#Ant stuff. We use the system ant.
	local ANTDIR="${DESTINATION}/ide4/ant"
	cd ${D}/${ANTDIR}

	rm -fr ./lib
	dodir /usr/share/ant-core/lib
	dosym /usr/share/ant-core/lib ${ANTDIR}/lib

	rm -fr ./bin
	dodir /usr/share/ant-core/bin
	dosym /usr/share/ant-core/bin  ${ANTDIR}/bin

#NOTICE THIS. We first installed everything here 
#and now we will remove some stuff from here and
#install it somewhere else instead.
 
	cd ${D}/${DESTINATION}
		
#Documentation

	#The next directory seems to be empty	
	if ! rmdir doc 2> /dev/null; then	
		use doc || rm -fr ./doc
	fi

	use doc || rm -fr ./nb4.0/docs
	use doc && java-pkg_dohtml -r ${WORKDIR}/javadoc/*

	dodoc build_info
	dohtml CREDITS.html README.html netbeans.css
	
	rm -f build_info CREDITS.html README.html netbeans.css

#Icons and shortcuts
	echo "Symlinking icons...."

	dodir ${DESTINATION}/icons
	insinto ${DESTINATION}/icons
	doins ${S}/core/ide/release/bin/icons/*png
	
	for res in "16x16" "24x24" "32x32" "48x48" "128x128"
	do
		dodir /usr/share/icons/hicolor/${res}/apps
		dosym ${DESTINATION}/icons/nb${res}.png /usr/share/icons/hicolor/${res}/apps/netbeans.png
	done

	make_desktop_entry netbeans-${SLOT} Netbeans netbeans Development
}

pkg_postinst ()
{
	einfo "Your tomcat directory might not have the right permissions."
	einfo "Please make sure that normal users can read the directory:"
	einfo "/usr/share/tomcat-5"
}
