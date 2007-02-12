# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg-2 java-utils-2 java-ant-2

MY_P="jboss-${PV}"
MY_P="${MY_P}.GA-src"
MY_EJB3="jboss-EJB-3.0_RC9_Patch_1"
#thirdparty library

MY_WSDL4J_V="1.5.2"
MY_WSDL4J_PN="wsdl4j"
MY_WSDL4J="mirror://sourceforge/wsdl4j/${MY_WSDL4J_PN}-src-${MY_WSDL4J_V}.zip"
MY_COMMONS_LOGGING_V="1.5.2"
MY_COMMONS_LOGGING_PN="commons-logging"
MY_COMMONS_LOGGING="mirror://sourceforge/wsdl4j/${MY_WSDL4J_PN}-src-${MY_WSDL4J_V}.zip"

DESCRIPTION="An open source, standards-compliant, J2EE-based application server implemented in 100% Pure Java."

# for the tests i just take one thing at a time
# ATTENTION: TO REMOVE
#SRC_URI="mirror://sourceforge/jboss/${MY_P}.tar.gz"
#	${MY_WSDL4J}
#	ejb3? ( mirror://sourceforge/jboss/${MY_EJB3}.zip )
#	"

RESTRICT="nomirror"
HOMEPAGE="http://www.jboss.org"
LICENSE="LGPL-2"
IUSE="doc ejb3 srvdir"
SLOT="4"
KEYWORDS="~x86"

# preparing the slotted future
COMMONS_HTTPCLIENT_SLOT="2.0.2"

AVALON_FRAMEWORK_SLOT="4.1"
AVALON_LOGKIT_SLOT="1.2"
COMMONS_BEANUTILS_SLOT="1.7"
MYFACES_SLOT="1"
SERVLETAPI_SLOT="2.4"
ECJ_SLOT="3.1"
BSF_SLOT="2.3"
XERCES_SLOT="2"
XMLSEC_SLOT="1.3"
CGLIB_SLOT="2.1"
BSH_SLOT="1.3.0"
GETOPT_SLOT="1"
HIBERNATE_SLOT="3.2"
HIBERNATE_ANNOTATIONS_SLOT="3.2"
HIBERNATE_ENT_MGR_SLOT="3.2"
# jdk1.7 is not ready to use !
DEPEND="<virtual/jdk-1.7
		app-arch/unzip
		=dev-java/myfaces-${MYFACES_SLOT}*
		dev-java/ant-contrib
		dev-java/ant-tasks
		ejb3?  ( >=virtual/jdk-1.5 )
		!ejb3? ( >=virtual/jdk-1.4 )
		>=dev-java/commons-fileupload-1.1.1
		>=dev-java/commons-discovery-0.2-r2
		>=dev-java/commons-codec-1.3
		=dev-java/bsf-${BSF_SLOT}*
		>=dev-java/commons-lang-2.1
		dev-java/apache-addressing
		dev-java/jaxme
		=dev-java/commons-httpclient-${COMMONS_HTTPCLIENT_SLOT}*
		=dev-java/avalon-framework-${AVALON_FRAMEWORK_SLOT}*
		=dev-java/avalon-logkit-${AVALON_LOGKIT_SLOT}*
		>=dev-java/bcel-5.1-r3
		=dev-java/commons-beanutils-${COMMONS_BEANUTILS_SLOT}*
		>=dev-java/scout-0.7_rc2
		=dev-java/servletapi-${SERVLETAPI_SLOT}*
		>=dev-java/sun-jaf-1.1
		>=dev-java/sun-javamail-1.4
		>=dev-java/trove-1.0.2
		>=dev-java/xdoclet-1.2.3
		>=dev-java/commons-logging-1.0.4
		>=dev-java/commons-collections-3.1
		>=dev-java/commons-digester-1.6
		>=dev-java/snmptrapappender-1.2.8
		>=dev-java/jakarta-slide-webdavclient-2.1
		>=dev-java/jakarta-jstl-1.1.2
		>=dev-java/commons-pool-1.0.1
		=www-servers/tomcat-5.5.20*
		=dev-java/eclipse-ecj-${ECJ_SLOT}*
		>=dev-java/xalan-2.7.0
		=dev-java/xerces-2.7*
		>=dev-java/antlr-2.7.6
		=dev-java/xml-security-${XMLSEC_SLOT}*
		>=dev-java/bsh-1.3.0
		=dev-java/cglib-${CGLIB_SLOT}*
		>=dev-java/commons-el-1.0
		>=dev-java/dom4j-1.6.1
		dev-java/gjt-jpl-util
		dev-java/gjt-jpl-pattern
		dev-java/xml-commons
		=dev-java/java-getopt-${GETOPT_SLOT}*
		=dev-java/hibernate-${HIBERNATE_SLOT}*
		=dev-java/hibernate-annotations-${HIBERNATE_ANNOTATIONS_SLOT}*
		=dev-java/hibernate-entitymanager-${HIBERNATE_ENT_MGR_SLOT}*
		"

RDEPEND="
		ejb3?  ( >=virtual/jdk-1.5 )
		!ejb3? ( >=virtual/jdk-1.4 )
		${DEPEND}
		"

S=${WORKDIR}/${MY_P}

INSTALL_DIR="/opt/${PN}-${SLOT}"
CACHE_INSTALL_DIR="/var/cache/${PN}-${SLOT}/localhost"
LOG_INSTALL_DIR="/var/log/${PN}-${SLOT}/localhost"
RUN_INSTALL_DIR="/var/run/${PN}-${SLOT}/localhost"
TMP_INSTALL_DIR="/var/tmp/${PN}-${SLOT}/localhost"
CONF_INSTALL_DIR="/etc/${PN}-${SLOT}/localhost"
FILESDIR_CONF_DIR=""

#switching configuration files directory
if use "srvdir" ; then
	SERVICES_DIR="/srv/localhost/${PN}-${SLOT}"
	FILESDIR_CONF_DIR="${FILESDIR}/${PV}/srvdir"
else
	SERVICES_DIR="/var/lib/${PN}-${SLOT}/localhost"
	FILESDIR_CONF_DIR="${FILESDIR}/${PV}/normal"
fi

# NOTE: When you are updating CONFIG_PROTECT env.d file, you can use this script on your current install
# run from /var/lib/jboss-${SLOT} to get list of files that should be config protected. We protect *.xml,
# *.properties and *.tld files.
# SLOT="4" TEST=`find /var/lib/jboss-${SLOT}/ -type f | grep -E -e "\.(xml|properties|tld)$"`; echo $TEST
# by kiorky better:
# echo "CONFIG_PROTECT=\"$(find /srv/localhost/jboss-4/ -name "*xml" -or -name \
#          "*properties" -or -name "*tld" |xargs echo -n)\"">>env.d/50jboss-4
# NOTE:
# atm: Compiling with jboss compile system
# Will progressivly add gentoo's way to do (eant)
# In the first time, i have the idea to delete partially (see under)
# the /thirdparty directory used by jboss to use jars
# then reconstruct it either from better case to worse:
#    * with ours jars (java-pkg_jarfrom)
#    * with compiled-at-merge-times ones (just cp compiled_jar_path/*.jar destdir/ stuff :p)
#    * with original ones if we cannot have the source (anyway this case is bad !!!)
#
# Indeed, I think this way, the maintenance will be easier as the jars path
# will not change and so we ll not to have to rewrite that much all
# the jboss build.xml.
#
# In the second time, We will have to recontruct the jboss/lib and the
# profiles/deploy and profiles/lib *.jars in the same way:
#	* with ours jars (java-pkg_jarfrom)
#	* with compiled-at-merge-times ones (implies: install the jars(dojar)
# 	* with original ones that we cannot have the source: i don't know, just insinto ?


# ------------------------------------------------------------------------------
# @function do_thirdparty_jar
#
# install jars builded from source in the thirdparty dependancies jboss's
# repository
#
# @param $1 (required) - the path to the jar to write
# @param $2 (required) - the repository subdir to install to
# ------------------------------------------------------------------------------
thirdparty_do_jar() {
	local DEST="${WORKDIR}/${MY_P}/thirdparty/$1/lib/"
	if [[ ! -d ${DEST} ]]; then
		 mkdir -p ${DEST} || die "creation of the subdir $1 failed"
	fi
	einfo "Installing $2 in jboss thirdparty dependency: $1"
	cp -f $2 ${DEST} || die "copy of the jar $2 to the suddir failed"
}

# ------------------------------------------------------------------------------
# @function list_thirdparty_dep_jars
#
# list jars in the thirdparty dependancies jboss's  repository
#
# @param $1 (required) - the path to the jar to write
# ------------------------------------------------------------------------------
thirdparty_list_dep_jars() {
	einfo "thirdparty_list_dep_jars: jars in $1:"
	for i in ${S}/thirdparty/$1/lib/*;do
		einfo "	$(basename $i)"
	done;
}

# ------------------------------------------------------------------------------
# @function thirdparty_build_wsdl4j
#
# build a thirdparty dep
#
# ------------------------------------------------------------------------------
thirdparty_build_commons_logging() {
	einfo "thirdparty_build_commons_logging:"
	cd ${WORKDIR}/${MY_WSDL4J_PN}-${MY_WSDL4J_V//./_}\
		||die "cd failed "
	epatch ${FILESDIR}/${PV}/thirdparties/wsdl4j/jboss_wsdl4j.patch
	cp ${FILESDIR}/${PV}/thirdparties/wsdl4j/build.xml .
	echo $GENTOO_VM
	PORTAGE_QUIET=y eant
	for jar in build/lib/*.jar;do
		thirdparty_do_jar ibm-wsdl4j $jar
	done
#	thirdparty_list_dep_jars ibm-wsdl4j
}

# ------------------------------------------------------------------------------
# @function thirdparty_build_wsdl4j
#
# build a thirdparty dep
#
# ------------------------------------------------------------------------------
thirdparty_build_wsdl4j() {
	einfo	"thirdparty_build_wsdl4j:"
	cd ${WORKDIR}/${MY_WSDL4J_PN}-${MY_WSDL4J_V//./_}\
		||die "thirdparty_build_wsdl4j:	_ cd "
	epatch ${FILESDIR}/${PV}/thirdparties/wsdl4j/jboss_wsdl4j.patch
	cp ${FILESDIR}/${PV}/thirdparties/wsdl4j/build.xml .
	PORTAGE_QUIET=y eant || die "thirdparty_build_wsdl4j: failed"
	for jar in build/lib/*.jar;do
		thirdparty_do_jar ibm-wsdl4j $jar
	done
#	thirdparty_list_dep_jars ibm-wsdl4j
}

# ------------------------------------------------------------------------------
# @function thirdparty_deps_bukild_mergetime_libs
#
# regroup jars to be built at merge time
#
# ------------------------------------------------------------------------------
thirdparty_deps_build_mergetime_libs() {
	einfo "Building thirdparties jboss specific dependencies"
#	thirdparty_build_wsdl4j
}



# ------------------------------------------------------------------------------
# @function thirdparty_dep_get_jars
#
# bring back the  jars from the package given as parameter
#
# @param $1 (required)  - name of the package to use
# @param $2 (required)  - name of the package to get jars from
# @param --jar jar   (optionnal)                 - jar to retrieve
# @param --rename jar-othername.jar (optionnnal) - name of the jar to rename to
# ------------------------------------------------------------------------------
thirdparty_dep_get_jars() {
	local jar="" jarto="" from="" DEST="" slot=""

	while [[ "${1}" == --* ]]; do
		if [[ "${1}" = "--jar" ]]; then
			jar="${2}"
			shift
		elif [[ "${1}" = "--rename" ]]; then
			jarto="${2}"
			shift
		else
				die "thirdparty_dep_get_jars called with unknown parameter:	${1}"
		fi
		shift
	done
	from="$1"
	DEST="${S}/thirdparty/$2/lib"
	mkdir -p ${DEST}||die "thirdparty_dep_get_jars mkdir ${DEST}"
	cd ${DEST}||die "thirdparty_dep_get_jars: failed change cwd"
	java-pkg_jar-from ${from} ${jar}
	if [[ -n ${jarto} ]]; then
		 mv ${jar} ${jarto}
	fi
}

# ------------------------------------------------------------------------------
# @function thirdparty_deps_get_xdoclet
#
# bring back xdoclet jars
#
# ------------------------------------------------------------------------------
thirdparty_deps_get_xdoclet() {
	DEST="${S}/thirdparty/xdoclet/lib"
	mkdir -p ${DEST}||die "mkdir dest failed"
	cd ${DEST}||die "failed change cwd"
	for jar in ${S}/thirdparty.old/xdoclet/lib/*;do
		jar=$(basename $jar)
		jarn="$(basename $jar -jb4.jar).jar"
		if [[ $jar == "xdoclet-xjavadoc-jb4.jar" ]];then
			thirdparty_dep_get_jars --jar xjavadoc.jar --rename $jar xdoclet xjavadoc
		else
			thirdparty_dep_get_jars --jar $jarn --rename $jar xdoclet xdoclet
		fi
	done
}

# ------------------------------------------------------------------------------
# @function thirdparty_use_bundled_jars
#
# bring back jboss thirdparty shipped jars 
# Please only use when there is not any way to get and compile the sources
#
# @param $1 which dependency to get
# ------------------------------------------------------------------------------
thirdparty_use_bundled_jars() {
	ewarn "Bad: using bundled jar for $1"
	cp -rf "${S}/thirdparty.old/$1/" "${S}/thirdparty"\
			|| die "cp $1 failed"
}

# ------------------------------------------------------------------------------
# @function thirdparty_deps_get_jars
#
# regroup jars to be got from the system and put in the repository
#
# ------------------------------------------------------------------------------
thirdparty_deps_get_jars() {
	local DEST="${WORKDIR}/${MY_P}/thirdparty/"
	einfo "Populating jboss repository with our jars"
#	thirdparty_deps_get_xdoclet
	# Warning jboss use version="2.7.6.ga"
#	thirdparty_dep_get_jars --jar antlr.jar --rename antlr-2.7.6.jar antlr antlr
	# Warning jboss use version="cvsbuild-7-19"
#	thirdparty_dep_get_jars	--jar addressing.jar --rename addressing-1.0.jar\
#						 	apache-addressing  apache-addressing
#	thirdparty_dep_get_jars avalon-framework-${AVALON_FRAMEWORK_SLOT} avalon-framework
#	thirdparty_dep_get_jars avalon-logkit-${AVALON_LOGKIT_SLOT}   apache-avalon-logkit
#	thirdparty_dep_get_jars bcel         apache-bcel
#	thirdparty_dep_get_jars commons-beanutils-${COMMONS_BEANUTILS_SLOT}	apache-beanutils
#	thirdparty_dep_get_jars bsf-${BSF_SLOT} apache-bsf
#	thirdparty_dep_get_jars commons-codec apache-codec
#	thirdparty_dep_get_jars commons-collections apache-collections
	# Warning they have too identicals jars but named differently see SRCDIR/thirdparty/apache-digester/component-info.xml
#	thirdparty_dep_get_jars --jar commons-digester.jar \
#		--rename commons-digester-1.6.jar commons-digester apache-digester
#	thirdparty_dep_get_jars commons-digester    apache-digester
#	thirdparty_dep_get_jars commons-discovery   apache-discovery
#	thirdparty_dep_get_jars commons-fileupload  apache-fileupload
	# Warning dev-java/commons-httpclient-2.0.2 is in slot 0 atm !
#	thirdparty_dep_get_jars commons-httpclient  apache-httpclient
#	thirdparty_dep_get_jars jaxme               apache-jaxme
#	thirdparty_dep_get_jars --jar commons-lang.jar --rename commons-lang-2.1.jar commons-lang apache-lang
#	thirdparty_dep_get_jars --jar snmptrapappender.jar --rename snmpTrapAppender.jar  snmptrapappender apache-log4j
#	thirdparty_dep_get_jars log4j apache-log4j
#	# Waring see http://fisheye.jboss.org/browse/JBoss/apache/commons-logging
#	thirdparty_use_bundled_jars apache-logging
	# Warning they use a 1.1patch version, never heard or see anything about it ...
#	thirdparty_use_bundled_jars apache-modeler
	# Waring my faces : jstl-1.1.0.jar from
	# http://www.apache.org/dyn/closer.cgi/myfaces/binaries/myfaces-core-1.1.4-bin.tar.gz
#	thirdparty_dep_get_jars  myfaces-${MYFACES_SLOT} apache-myfaces
#	thirdparty_dep_get_jars  jakarta-jstl            apache-myfaces
#	thirdparty_dep_get_jars  commons-pool            apache-pool
#	thirdparty_dep_get_jars scout        apache-scout
	# Warning  need to be hardly tested as version is 2 in portage but jboss need 1.
#	thirdparty_dep_get_jars --jar jakarta-slide-webdavlib.jar --rename webdavlib.jar \
#			jakarta-slide-webdavclient apache-slide
	# warning maybe will it good to test with tomcat6 later
	# use a jasper-compiler-jdt.jar which seems to be ecj, but not identical to
	# the one i use actually, so need to be hardly tested
#	thirdparty_dep_get_jars tomcat-5.5 apache-tomcat
#	ln -s /usr/share/tomcat-5.5/server/webapps/manager/WEB-INF/lib/catalina-manager.jar \
#		${DEST}/apache-tomcat/lib || die "ln catalina-manager.jar failed"	
#	thirdparty_dep_get_jars --jar ecj.jar --rename jasper-compiler-jdt.jar\
#		eclipse-ecj-${ECJ_SLOT} apache-tomcat
	# Warning see http://repository.jboss.com/apache-velocity/1.4jboss 
	# was getting a 17 MO patch from the original one
	# so i doubt that the good version to patch against ...
#	thirdparty_use_bundled_jars apache-velocity
	# Warning they use a cvs-7-19 version ....
#	thirdparty_use_bundled_jars apache-wss4j
	# Warning maybe will we need to repack the xalan jar
	# http://repository.jboss.com/apache-xalan/j_2.7.0/readme.txt
#	thirdparty_dep_get_jars xalan apache-xalan
#	thirdparty_dep_get_jars xerces-${XERCES_SLOT} apache-xerces
	thirdparty_dep_get_jars xml-commons apache-xerces
#	thirdparty_dep_get_jars xml-security-${XMLSEC_SLOT} apache-xmlsec
	# Warning Need to test with upper to 1.3.0 versions as it dont install in slot
#	thirdparty_dep_get_jars --jar bsh.jar --rename bsh-${BSH_SLOT}.jar bsh beanshell
	# Warning specifying nodep in their metadata
#	thirdparty_dep_get_jars --jar cglib-nodep.jar --rename cglib.jar \
#			cglib-${CGLIB_SLOT} cglib
	thirdparty_dep_get_jars commons-el commons-el
	thirdparty_dep_get_jars dom4j-1 dom4j
	# Warning they use a 1.0 version
	thirdparty_dep_get_jars gjt-jpl-util    gjt-jpl-util
	thirdparty_dep_get_jars gjt-jpl-pattern gjt-jpl-util
	thirdparty_dep_get_jars --jar gnu.getopt.jar --rename getopt.jar \
		java-getopt-${GETOPT_SLOT}  gnu-getopt
	thirdparty_dep_get_jars hibernate-${HIBERNATE_SLOT} hibernate
	thirdparty_dep_get_jars hibernate-annotations-${HIBERNATE_ANNOTATIONS_SLOT}\
		hibernate-annotations
	thirdparty_dep_get_jars hibernate-entitymanager-${HIBERNATE_ENT_MGR_SLOT}\
		hibernate-entitymanager

	#writing entity manager ebuild

#	thirdparty_dep_get_jars trove        trove
#	thirdparty_dep_get_jars servletapi-${SERVLETAPI_SLOT} sun-servlet
#	thirdparty_dep_get_jars sun-javamail sun-javamail
#	thirdparty_dep_get_jars sun-jaf	     sun-jaf
}

src_unpack() {
#	unpack ${A}
	#FOR TEST !!
	mkdir -p "${S}/thirdparty"
	cd ${S} || die "cd failed"
#	mv thirdparty thirdparty.old || die "mv to thirdparty.old failed"
	#	thirdparty_deps_build_mergetime_libs
	thirdparty_deps_get_jars
}

src_compile() {
	cd ${S}
}

src_install() {
	#ensure users dont use it now
	die "Ebuild is not ready even for alpha"

	# jboss core stuff
	# create the directory structure and copy the files
	diropts -m755
	dodir ${INSTALL_DIR}        \
		  ${INSTALL_DIR}/bin    \
		  ${INSTALL_DIR}/client \
	      ${INSTALL_DIR}/lib    \
		  ${SERVICES_DIR} \
		  ${CACHE_INSTALL_DIR}  \
		  ${CONF_INSTALL_DIR}   \
		  ${LOG_INSTALL_DIR}    \
		  ${RUN_INSTALL_DIR} ${TMP_INSTALL_DIR}
	insopts -m645
	diropts -m755
	insinto ${INSTALL_DIR}/bin
	doins -r bin/*.conf bin/*.jar
	exeinto ${INSTALL_DIR}/bin
	doexe bin/*.sh
	insinto ${INSTALL_DIR}
	doins -r client lib

	# copy startup stuff
	doinitd  ${FILESDIR_CONF_DIR}/init.d/${PN}-${SLOT}
	# add multi instances support (here:localhost)
	dosym /etc/init.d/${PN}-${SLOT} /etc/init.d/${PN}-${SLOT}.localhost
	newconfd ${FILESDIR_CONF_DIR}/conf.d/${PN}-${SLOT} ${PN}-${SLOT}
	# add multi instances support (here:localhost)
	newconfd ${FILESDIR_CONF_DIR}/conf.d/${PN}-${SLOT} ${PN}-${SLOT}.localhost
	gunzip  -c ${FILESDIR_CONF_DIR}/env.d/50${PN}-${SLOT}.gz>50${PN}-${SLOT}
	doenvd  50${PN}-${SLOT}
	# jboss profiles creator binary
	exeinto  /usr/bin
	doexe	 ${FILESDIR_CONF_DIR}/bin/jboss-4-profiles-creator.sh
	# implement GLEP20: srvdir
	addpredict ${SERVICES_DIR}
	# make a "gentoo" profile with "default" one as a template
	cp -rf server/default    server/gentoo
	# add optionnal jboss EJB 3.0 implementation
	if use ejb3;then
		einfo "EJB 3.0 support  Activation"
		cd ../$MY_EJB3
		cp -rf ${FILESDIR}/${PV}/ejb3/install.xml .
		JBOSS_HOME="../${MY_P}" ant -f install.xml || die "EJB3 Patch failed"
		einfo "EJB3 installed"
		cd ../${MY_P}
		local backported_jars="jgroups.jar jboss-cache.jar"
		for jar in ${backported_jars};do
			cp -rf server/all/lib/${jar}    server/gentoo/lib
		done
		local backported_apps="jbossws.sar"
		for app in ${backported_apps};do
			cp -rf server/all/deploy/${app}    server/gentoo/deploy
		done
	fi
	# our nice little welcome app
	cp -rf ${FILESDIR}/${PV}//tomcat/webapp/gentoo .
	cd gentoo
	#for /gentoo-doc context
	jar cf ../gentoo.war *
	# for root context
	rm -f WEB-INF/jboss-web.xml
	jar cf ../ROOT.war *
	cd ..
	# installing the tomcat configuration and the webapp
	for PROFILE in all default gentoo ; do
		rm -rf server/${PROFILE}/deploy/jbossweb-tomcat55.sar/ROOT.war
		cp -rf gentoo.war  server/${PROFILE}/deploy/
		cp -rf ROOT.war    server/${PROFILE}/deploy/jbossweb-tomcat55.sar/
		# our tomcat configuration to point to our helper
		cp -rf ${FILESDIR}/${PV}/tomcat/server.xml  server/${PROFILE}/deploy/jbossweb-tomcat55.sar/server.xml
	done
	rm -f gentoo.war ROOT.war
		# installing profiles
	for PROFILE in all default gentoo minimal; do
		# create directory
		diropts -m775
		dodir ${SERVICES_DIR}/${PROFILE}/conf   \
		      ${SERVICES_DIR}/${PROFILE}/deploy ${SERVICES_DIR}/${PROFILE}/lib
		# keep stuff
		keepdir     ${CACHE_INSTALL_DIR}/${PROFILE} \
					${CONF_INSTALL_DIR}/${PROFILE}	\
					${LOG_INSTALL_DIR}/${PROFILE}	\
					${TMP_INSTALL_DIR}/${PROFILE}   \
					${RUN_INSTALL_DIR}/${PROFILE}
		if [[ ${PROFILE} != "minimal" ]]; then
			insopts -m665
			diropts -m775
			insinto  ${SERVICES_DIR}/${PROFILE}/deploy
			doins -r server/${PROFILE}/deploy/*
		else
			dodir  ${SERVICES_DIR}/${PROFILE}/deploy
		fi
		# singleton is just on "all" profile
		local clustering="false"
		[[ ${PROFILE} == "all" ]] && clustering="true"
		# deploy clustering stuff for ejb3
		use "ejb3" && [[ ${PROFILE} == "gentoo" ]] && clustering="true"
		if [[ $clustering == "true" ]];then
			ewarn "Activating clustering support for profile: ${PROFILE}"
			insopts -m665
			diropts -m775
			dodir    ${SERVICES_DIR}/${PROFILE}/deploy-hasingleton
			insinto  ${SERVICES_DIR}/${PROFILE}/deploy-hasingleton
			doins -r server/all/deploy-hasingleton
			dodir    ${SERVICES_DIR}/${PROFILE}/farm
			insinto  ${SERVICES_DIR}/${PROFILE}/farm
			doins -r server/all/farm
		fi
		# copy files
		insopts -m664
		diropts -m772
		insinto  ${SERVICES_DIR}/${PROFILE}/conf
		doins -r server/${PROFILE}/conf/*
		insopts -m644
		diropts -m755
		insinto  ${SERVICES_DIR}/${PROFILE}/lib
		doins -r server/${PROFILE}/lib/*
		# do symlink
		dosym ${CACHE_INSTALL_DIR}/${PROFILE} ${SERVICES_DIR}/${PROFILE}/data
		dosym   ${LOG_INSTALL_DIR}/${PROFILE} ${SERVICES_DIR}/${PROFILE}/log
		dosym   ${TMP_INSTALL_DIR}/${PROFILE} ${SERVICES_DIR}/${PROFILE}/tmp
		dosym   ${RUN_INSTALL_DIR}/${PROFILE} ${SERVICES_DIR}/${PROFILE}/work
		# for conf file, doing the contrary is trickier
		# keeping the conf file with the whole installation but
		# putting a symlink to /etc/ for easy configuration
		dosym ${SERVICES_DIR}/${PROFILE}/conf ${CONF_INSTALL_DIR}/${PROFILE}/conf
		# symlink the tomcat server.xml configuration file
		dosym ${SERVICES_DIR}/${PROFILE}/deploy/jbossweb-tomcat55.sar/server.xml	${CONF_INSTALL_DIR}/${PROFILE}/
	done

	# set some cp
	if use ejb3;then
		java-pkg_regjar ${D}/${INSTALL_DIR}/client/activation.jar
		java-pkg_regjar ${D}/${SERVICES_DIR}/all/lib/jboss-cache.jar
		java-pkg_regjar ${D}/${SERVICES_DIR}/all/lib/jgroups.jar
	fi
	# register runners
	java-pkg_regjar	${D}/${INSTALL_DIR}/bin/*.jar
	#do launch helper scripts which set the good VM to use
	java-pkg_dolauncher jboss-start.sh  --java_args  '${JAVA_OPTIONS}'\
		--main org.jboss.Main      -into ${INSTALL_DIR}
	java-pkg_dolauncher jboss-stop.sh   --java_args  '${JAVA_OPTIONS}'\
		--main org.jboss.Shutdown  -into ${INSTALL_DIR}

	# documentation stuff
	insopts -m645
	diropts -m755
	insinto	"/usr/share/doc/${PF}/${DOCDESTTREE}"
	doins copyright.txt
	doins -r docs/*
	# write access is set for jboss group so user can use netbeans to start jboss
	# fix permissions
	local DIR=""
	DIR="${D}/${INSTALL_DIR} ${D}/${LOG_INSTALL_DIR} ${D}/${TMP_INSTALL_DIR}
	${D}/${CACHE_INSTALL_DIR} ${D}/${RUN_INSTALL_DIR} ${D}/${CONF_INSTALL_DIR}
	${D}/${SERVICES_DIR} "
	chmod -R 765  ${DIR}
	chown -R jboss:jboss ${DIR}
	chmod -R 755 ${D}/usr/share/${PN}-${SLOT}
}

pkg_preinst() {
	# create jboss user
	enewgroup jboss || die "Unable to create jboss group"
	enewuser jboss -1 /bin/sh ${SERVICES_DIR}  jboss || die "Unable to create jboss user"
}

pkg_postinst() {
	elog
	elog "Multi Instance Usage"
	elog " If you want to run multiple instances of JBoss, you can do that this way:"
	elog " 1) sylink init script:"
	elog "    ln -s /etc/init.d/${PN}-${SLOT} /etc/init.d/${PN}-${SLOT}.foo"
	elog " 2) Copy original config file:"
	elog "    cp /etc/conf.d/${PN}-${SLOT} /etc/conf.d/${PN}-${SLOT}.foo"
	elog " 3) Edit the new config file as it will use another JBOSS_SERVER_NAME."
	elog "		Set what do you want to run your new profile/vhost"
	elog "		You have to either:"
	elog "			Bind new JBoss instance to another IP address or change"
	elog "			Change the  used ports in tiomcat configuration so they do not be in conflict)"
	elog " 4) run the new JBoss instance:"
	elog "		/etc/init.d/${PN}-${SLOT}.vhost start (eg vhost=localhost"
	elog "		-> ${PN}-${SLOT}.localhost"
	elog
	elog "Profile manager:"
	elog "We provide now a tool to manage your multiple JBoss profiles"
	elog "	see jboss-profiles-creator.sh --help for usage"
	elog
	elog "Jboss usage:"
	elog "We profile a jboss documentation available for all vhosts"
	elog "	you can access it with"
	elog "	/etc/init.d/${PN}-${SLOT}.localhost start"
	elog "	and now point your browser to http://YOURIP:8080/gentoo-doc"
	elog "	TIPS: "
	elog "		* If you have not redefine the root context, You can even reach it to http://YOURIP:8080/"
	elog
	elog "To redifine the root context: (the thing you reach with http://vhost/)"
	elog "	* Just deploy your one as PROFILE_PATH/deploy/ROOT.war"
	elog "	* To make a war go to the basedir of your application and do "
	elog "			jar cvf ROOT.war *"
	elog "	* Another thing: you can eITher deploy it in a ear or in a war"
}
