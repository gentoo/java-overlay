# We want to get the contents of a variable, with the same name as
# relative_dir, with _ substituted for -, and suffixed with _pkgs
# The contents of said variable should be a comma separated list of
# packages, in the format java-config -p would like
# to rename a jar the separator will be space
# eg : to get
#		* all jars from jarfoo
#		* jarbar.jar from jarbar renamed in jarjar.jar
#		* in thirdparty/foo/lib
#     thirdparty_foo_lib_pkgs="jarfoo,jarbar jarbar.jar jarjar.jar"

tools_lib_pkgs="ant-core,
				ant-pretty ant-pretty.jar pretty.jar,
				ant-tasks,
				bsf-2.3,
				buildmagic-tasks,
				eclipse-ecj-3.1 ecj.jar jdtCompilerAdapter.jar,
				eclipse-ecj-3.1 ecj.jar org.eclipse.jdt.core_3.1.0.jar,
				junit,
				xalan,
				xerces-2.6,
				xml-commons-external-1.3,
				xml-commons-resolver
				"
thirdparty_hsqldb_hsqldb_lib_pkgs="hsqldb"
thirdparty_javagroups_javagroups_lib_pkgs="jgroups"
thirdparty_javassist_lib_pkgs="javassist-3.1"
thirdparty_jboss_aop_lib_pkgs="jboss-aop"
thirdparty_sleepycat_lib_pkgs="db-je"
thirdparty_sun_jaxp_lib_pkgs="crimson-1,gnu-jaxp,xalan"
thirdparty_sun_jaf_lib_pkgs="gnu-jaf-1"
thirdparty_sun_javamail_lib_pkgs="gnu-javamail-1"
thirdparty_sun_jmf_lib_pkgs="jmf-bin"
thirdparty_sun_jmx_lib_pkgs="mx4j-3.0"
thirdparty_xdoclet_xdoclet_lib_pkgs="xdoclet,xjavadoc,commons-logging"
thirdparty_hibernate_lib_pkgs="asm-1.5,hibernate-3"

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
JACORB_SLOT="2.2"
JAVASSIST_SLOT="3.3"
JAXEN_SLOT="1.1"
JOESNMP_SLOT="0.3"
QDOX_SLOT="1.4"
JAVACC_SLOT="3.2"
DTDPARSER_SLOT="1.21"
	# Warning jboss use version="2.7.6.ga"
thirdparty_antlr_lib_depend="dev-java/antlr"
thirdparty_antlr_lib_pkgs="antlr antlr.jar antlr-2.7.6.jar"
	# Warning jboss use version="cvsbuild-7-19"
thirdparty_apache_addressing_lib_depend="dev-java/apache_addressing"
thirdparty_apache_addressing_lib_pkgs="apache_addressing addressing.jar addressing-1.0.jar"
	#
thirdparty_avalon_framework_lib_depend="=dev-java/avalon-framework-${AVALON_FRAMEWORK_SLOT}*"
thirdparty_avalon_framework_pkgs="avalon-framework-${AVALON_FRAMEWORK_SLOT}"
	#
thirdparty_apache_avalon_logkit_lib_depend="=dev-java/avalon-logkit-${AVALON_LOGKIT_SLOT}*"
thirdparty_apache_avalon_logkit_pkgs="avalon-logkit-${AVALON_LOGKIT_SLOT}"
	#
thirdparty_apache_bcel_lib_depend="dev-java/bcel"
thirdparty_apache_bcel_lib_pkgs="bcel"
	#
thirdparty_apache_beanutils_lib_depend="=dev-java/commons-beanutils-${COMMONS_BEANUTILS_SLOT}*"
thirdparty_apache_beanutils_lib_pkgs="commons-beanutils-${COMMONS_BEANUTILS_SLOT}"
	#
thirdparty_apache_bsf_lib_depend="=dev-java/bsf-${BSF_SLOT}*"
thirdparty_apache_bsf_lib_pkgs="bsf-${BSF_SLOT}"
	#
thirdparty_apache_codec_lib_depend="dev-java/commons-codec"
thirdparty_apache_codec_lib_pkgs="commons-codec"
	#
thirdparty_apache_collections_lib_depend="dev-java/commons-collections"
thirdparty_apache_collections_lib_pkgs="commons-collections"
	# Warning they have too identicals jars but named differently see SRCDIR/thirdparty/apache_digester/component-info.xml
thirdparty_apache_digester_lib_depend="dev-java/commons-digester"
thirdparty_apache_digester_lib_pkgs="commons-digester commons-digester.jar commons-digester-1.6.jar,commons-digester"
	#
thirdparty_apache_collections_lib_depend="dev-java/commons-collections"
thirdparty_apache_collections_lib_pkgs="commons-collections"
	#
thirdparty_apache_discovery_lib_depend="dev-java/commons-discovery"
thirdparty_apache_discovery_lib_pkgs="commons-discovery"
	#
thirdparty_apache_fileupload_lib_depend="dev-java/commons-fileupload"
thirdparty_apache_fileupload_lib_pkgs="commons-fileupload"
	# Warning dev-java/commons-httpclient-2.0.2 is in slot 0 atm !
thirdparty_apache_httpclient_lib_depend="commons-httpclient"
thirdparty_apache_httpclient_lib_pkgs="commons-httpclient"
	#
thirdparty_apache_jaxme_lib_depend="dev-java/jaxme"
thirdparty_apache_jaxme_lib_pkgs="jaxme"
	#
thirdparty_apache_lang_depend="dev-java/commons-lang"
thirdparty_apache_lang_pkgs="commons-lang commons-lang.jar commons-lang-2.1.jar"
	#
thirdparty_apache_log4j_lib_depend="dev-java/snmptrapappender dev-java/log4j"
thirdparty_apache_log4j_lib_pkgs="snmptrapappender snmptrapappender.jar snmpTrapAppender.jar,log4j"
	# Waring my faces : jstl-1.1.0.jar from
	# http://www.apache.org/dyn/closer.cgi/myfaces/binaries/myfaces-core-1.1.4-bin.tar.gz
thirdparty_apache_myfaces_lib_depend="=dev-java/myfaces-${MYFACES_SLOT}* dev-java/jakarta-jstl"
thirdparty_apache_myfaces_lib_pkgs="myfaces-${MYFACES_SLOT},jakarta-jstl"
	#
thirdparty_apache_pool_lib_depend="dev-java/commons-pool"
thirdparty_apache_pool_lib_pkgs="commons-pool"
	#
thirdparty_apache_scout_lib_depend="dev-java/scout"
thirdparty_apache_scout_lib_pkgs="scout"
	# Warning  need to be hardly tested as version is 2 in portage but jboss need 1.
thirdparty_apache_slide_lib_depend="dev-java/jakarta-slide-webdavclient"
thirdparty_apache_slide_lib_pkgs="jakarta-slide-webdavclient jakarta-slide-webdavlib.jar webdavlib.jar"
	# warning maybe will it good to test with tomcat6 later
	# use a jasper-compiler-jdt.jar which seems to be ecj, but not identical to
	# the one i use actually, so need to be hardly tested
thirdparty_apache_tomcat_lib_depend="=dev-java/tomcat-5.5* =dev-java/eclipse-ecj-${ECJ_SLOT}*"
thirdparty_apache_tomcat_lib_pkgs="tomcat-5.5,eclipse-ecj-${ECJ_SLOT} ecj.jar jasper-compiler-jdt.jar"
	# Warning maybe will we need to repack the xalan jar
	# http://repository.jboss.com/apache-xalan/j_2.7.0/readme.txt
thirdparty_apache_xalan_lib_depend="dev-java/xalan"
thirdparty_apache_xalan_lib_pkgs="xalan"
	#
thirdparty_apache_xerces_lib_depend="dev-java/xerces-${XERCES_SLOT}*,dev-java/xml-commons"
thirdparty_apache_xerces_lib_pkgs="xerces-${XERCES_SLOT},xml-commons"
	#
thirdparty_apache_xmlsec_lib_depend="=dev-java/xml-security-${XMLSEC_SLOT}*"
thirdparty_apache_xmlsec_lib_pkgs="xml-security-${XMLSEC_SLOT}"
	# Warning Need to test with upper to 1.3.0 versions as it dont install in slot
thirdparty_beanshell_lib_depend="dev-java/bsh"
thirdparty_beanshell_lib_pkgs="bsh bsh.jar bsh-${BSH_SLOT}.jar"
	# Warning specifying nodep in their metadata
thirdparty_cglib_lib_depend="=dev-java/cglib-${CGLIB_SLOT}*"
thirdparty_cglib_lib_pkgs="cglib-${CGLIB_SLOT} cglib-nodep.jar cglib.jar"
	# 
thirdparty_commons_el_lib_depend="dev-java/commons-el"
thirdparty_commons_el_lib_pkgs="commons-el"
	#
thirdparty_dom4j_lib_depend="=dev-java/dom4j-1*"
thirdparty_dom4j_lib_pkgs="dom4j-1"
	# Warning they use a 1.0 version	
thirdparty_gjt_jpl_util_lib_depend="dev-java/gjt-jpl-util,dev-java/gjt-jpl-pattern"
thirdparty_gjt_jpl_util_lib_pkgs="gjt-jpl-util,gjt-jpl-pattern"
	#
thirdparty_ibm_wsdl4j_lib_depend="dev-java/jboss-wsdl4j"
thirdparty_ibm_wsdl4j_lib_pkgs="jboss-wsdl4j"
	#
thirdparty_jgroups_lib_depend="dev-java/jgroups"
thirdparty_jgroups_lib_pkgs="jgroups"
	#
thirdparty_juddi_lib_depend="dev-java/juddi"
thirdparty_juddi_lib_pkgs="juddi"
	#
thirdparty_junit_lib_depend="dev-java/junit"
thirdparty_junit_lib_pkgs="junit"
	#
thirdparty_jfreechart_lib_depend="dev-java/jfreechart,dev-java/jcommon"
thirdparty_jfreechart_lib_pkgs="jfreechart,jcommon"
	#
thirdparty_oswego_concurrent_lib_depend="dev-jaca/concurrent-util"
thirdparty_oswego_concurrent_lib_pkgs="concurrent-util"
	#
thirdparty_trove_lib_depend="dev-java/trove"
thirdparty_trove_lib_pkgs="trove"
	#
thirdparty_sun_jaf_lib_depend="dev-java/sun-jaf"
thirdparty_sun_jaf_lib_pkgs="sun-jaf"
	#
thirdparty_sun_javamail_lib_depend="dev-java/sun-javamail"
thirdparty_sun_javamail_lib_pkgs="sun-javamail"
	#
thirdparty_sun_javacc_lib_depend="dev-java/javacc"
thirdparty_sun_javacc_lib_pkgs="javacc"
	#
thirdparty_sun_servlet_lib_depend="=dev-java/servletapi-${SERVLETAPI_SLOT}*"
thirdparty_sun_servlet_lib_pkgs="servletapi-${SERVLETAPI_SLOT}"
	# Warning take the bin ones while we re not modularized (circular dependencies )	
thirdparty_hibernate_lib_depend="=dev-java/hibernate-${HIBERNATE_SLOT}*"
thirdparty_hibernate_lib_pkgs="hibernate-${HIBERNATE_SLOT}"
	#
thirdparty_hibernate_annotations_lib_depend="=dev-java/hibernate-annotations-bin-${HIBERNATE_ANNOTATIONS_SLOT}*"
thirdparty_hibernate_annotations_lib_pkgs="hibernate-annotations-bin-${HIBERNATE_ANNOTATIONS_SLOT}"
	#
thirdparty_hibernate_entitymanager_lib_depend="=dev-java/hibernate-entitymanager-bin-${HIBERNATE_ENT_MGR_SLOT}*"
thirdparty_hibernate_entitymanager_lib_pkgs="hibernate-entitymanager-bin-${HIBERNATE_ENT_MGR_SLOT}"
	#
thirdparty_jaxen_lib_depend="=dev-java/jaxen-${JAXEN_SLOT}*"
thirdparty_jaxen_lib_pkgs="jaxen-${JAXEN_SLOT}"
	#
thirdparty_javassist_lib_depend="=dev-java/javassist-${JAVASSIST_SLOT}*"
thirdparty_javassist_lib_pkgs="javassist-${JAVASSIST_SLOT}"
	# Warning they use SP1 !!!
thirdparty_joesnmp_lib_depend="=dev-java/joesnmp-${JOESNMP_SLOT}*"
thirdparty_joesnmp_lib_pkgs="joesnmp-${JOESNMP_SLOT}"
	#
thirdparty_qdox_lib_depend="=dev-java/qdox-${QDOX_SLOT}*"
thirdparty_qdox_lib_pkgs="qdox-${QDOX_SLOT}"
	#
thirdparty_wutka_dtdparser_lib_depend="=dev-java/dtdparser-${DTDPARSER_SLOT}*"
thirdparty_wutka_dtdparser_lib_pkgs="dtdparser-${DTDPARSER_SLOT}"
	#
thirdparty_quartz_lib_depend="=dev-java/quartz-1.5*"
thirdparty_quartz_lib_pkgs="quartz-1.5"
	# they have a -ext jar with just two classes in ext/
thirdparty_xml_sax_lib_depend="dev-java/sax"
thirdparty_xml_sax_lib_pkgs="sax sax.jar sax2.jar,sax sax.jar sax2-ext.jar"
	#
thirdparty_gnu_getopt_lib_depend="=dev-java/java-getopt-${GETOPT_SLOT}*"
thirdparty_gnu_getopt_lib_pkgs="java-getopt-${GETOPT_SLOT} gnu.getopt.jar getopt.jar"
	#
thirdparty_odmg_lib_depend="dev-java/odmg"
thirdparty_odmg_lib_pkgs="odmg odmg.jar odmg-3.0.jar"
	# jboss use the modified and non patched jacorb !
thirdparty_jacorb_lib_depend="=dev-java/jacorb-${JACORB_SLOT}* =dev-java/jboss-jacorb-${JACORB_SLOT}*"
thirdparty_jacorb_lib_pkgs="jacorb-${JACORB_SLOT},jboss-jacorb-${JACORB_SLOT} core_jacorb.jar core_jacorb_g.jar,jboss-jacorb-${JACORB_SLOT} idl.jar idl_g.jar,jboss-jacorb-${JACORB_SLOT} jacorb.jar jacorb_g.jar,jboss-jacorb-${JACORB_SLOT} jacorb_services.jar jacorb_services_g.jar,jboss-jacorb-${JACORB_SLOT} omg_services.jar omg_services_g.jar,jboss-jacorb-${JACORB_SLOT} security.jar security_g.jar"

	# Warning see http://fisheye.jboss.org/browse/JBoss/apache/commons-logging
	thirdparty_use_bundled_jars apache-logging
	# Warning they use a 1.1patch version, never heard or see anything about it ...
	thirdparty_use_bundled_jars apache-modeler
		# Warning see http://repository.jboss.com/apache-velocity/1.4jboss
	# was getting a 17 MO patch from the original one
	# so i doubt that the good version to patch against ...
	thirdparty_use_bundled_jars apache-velocity
	# Warning they use a cvs-7-19 version ....
	thirdparty_use_bundled_jars apache-wss4j
	# Warning I dont find the source for 1.4
	thirdparty_use_bundled_jars junitejb
	for i in ${DEST}/jacorb/lib/*;do
		mv $i $(basename $i .jar)_g.jar;
	done

common_library_dirs="apache-httpclient/lib
				 apache-jaxme/lib
				 apache-log4j/lib
				 apache-slide/lib
				 apache-xerces/lib
				 jboss/jbossxb
				 oswego-concurrent/lib
				 sun-jaf/lib
				 wutka-dtdparser/lib"
vjmx_library_dirs="apache-bcel/lib
				 apache-commons/lib
				 apache-log4j/lib
				 apache-xalan/lib
				 dom4j-dom4j/lib
				 gnu-regexp/lib
				 junit-junit/lib
				 oswego-concurrent/lib
				 sun-jaxp/lib
				 xml-sax/lib"
system_library_dirs="apache-commons/lib
				 apache-log4j/lib
				 dom4j-dom4j/lib
				 gnu-getopt/lib
				 junit-junit/lib
				 oswego-concurrent/lib"
j2ee_library_dirs="sun-jaf/lib
				 sun-servlet/lib"
deployment_library_dirs="dom4j-dom4j/lib"
jaxrpc_library_dirs="apache-commons/lib
				 apache-log4j/lib
				 apache-xerces/lib
				 ibm-wsdl4j/lib
				 sun-jaf/lib
				 sun-javamail/lib
				 sun-servlet/lib"
naming_library_dirs="apache-log4j/lib
				 junit-junit/lib"
transaction_library_dirs="apache-commons/lib
				 apache-log4j/lib
				 oswego-concurrent/lib"
server_library_dirs="apache-log4j/lib
				 apache-bcel/lib
				 apache-commons/lib
				 gjt-jpl-util/lib
				 ibm-wsdl4j/lib
				 oswego-concurrent/lib
				 junit-junit/lib
				 sun-javacc/lib
				 sun-servlet/lib
				 gnu-getopt/lib"
security_library_dirs="apache-log4j/lib
				 dom4j-dom4j/lib
				 junit-junit/lib
				 hsqldb-hsqldb/lib
				 sun-javacc/lib
				 oswego-concurrent/lib"
connector_library_dirs="apache-log4j/lib
				 apache-commons/lib
				 oswego-concurrent/lib
				 sun-javamail/lib"
#  iiop  needs  jacorb-jacorb/lib  too
iiop_library_dirs="apache-avalon/lib
				 apache-log4j/lib
				 junit-junit/lib
				 oswego-concurrent/lib"
#  jboss.ne  needs  apache-addressing/lib  and  apache-wss4j/lib  too
net_library_dirs="apache-commons/lib
				 apache-log4j/lib
				 dom4j-dom4j/lib
				 ibm-wsdl4j/lib
				 junit-junit/lib
				 sun-jaf/lib
				 sun-javamail/lib
				 sun-servlet/lib"
media_library_dirs="apache-xalan/lib
				 dom4j-dom4j/lib
				 junit-junit/lib
				 sun-jmf/lib"
messaging_library_dirs="apache-commons/lib
				 apache-log4j/lib
				 apache-xalan/lib
				 junit-junit/lib
				 u-regexp/lib
				 oswego-concurrent/lib"
cluster_library_dirs="apache-commons/lib
				 apache-log4j/lib
				 javagroups-javagroups/lib
				 oswego-concurrent/lib"
management_library_dirs="apache-commons/lib
				 apache-log4j/lib"
remoting_library_dirs="apache-commons/lib
				 apache-log4j/lib
				 javagroups-javagroups/lib
				 jboss-aop/lib
				 junit-junit/lib
				 oswego-concurrent/lib
				 sun-jaxp/lib
				 sun-jmx/lib"
# varia	  needs	  apache-scout/lib
varia_library_dirs="apache-commons/lib
				 apache-log4j/lib
				 apache-velocity/lib
				 apache-xalan/lib
				 beanshell-beanshell/lib
				 gnu-regexp/lib
				 hsqldb-hsqldb/lib
				 javagroups-javagroups/lib
				 opennms/joesnmp/lib
				 sun-jaf/lib
				 sun-javamail/lib
				 sun-servlet/lib
				 juddi-juddi/lib"
cache_library_dirs="apache-xalan/lib
				 apache-log4j/lib
				 gnu-regexp/lib
				 junit-junit/lib
				 javagroups-javagroups/lib
				 oswego-concurrent/lib
				 sleepycat/lib
				 sun-jaxp/lib
				 sun-jmx/lib
				 xdoclet-xdoclet/lib"
jms_library_dirs="javassist/lib
				 javagroups-javagroups/lib
				 junit-junit/lib
				 oswego-concurrent/lib"
jmx_remoting_library_dirs="apache-log4j/lib
				 oswego-concurrent/lib"
tomcat_library_dirs="apache-commons/lib
				 apache-tomcat55
				 dom4j-dom4j/lib
				 javagroups-javagroups/lib
				 junit-junit/lib
				 oswego-concurrent/lib
				 sun-servlet/lib"
console_library_dirs="gnu-getopt/lib
				 apache-log4j/lib
				 apache-commons/lib
				 dom4j-dom4j/lib
				 beanshell-beanshell/lib
				 sun-servlet/lib
				 jfreechart/lib
				 trove/lib"
hibernate_library_dirs="apache-commons/lib
				 apache-xalan/lib
				 dom4j-dom4j/lib
				 hibernate/lib
				 odmg/lib
				 cglib/lib"
webservice_library_dirs="apache-commons/lib
				 apache-xerces/lib
				 dom4j-dom4j/lib
				 ibm-wsdl4j/lib
				 sun-jaf/lib
				 sun-javamail/lib
				 sun-servlet/lib"

# modules interdependencies
# indentation is not funzy, just sync to the right ;)
common_module_depends=""
jmx_module_depends="         common"
j2ee_module_depends="        common"
naming_module_depends="      common"
system_module_depends="      common jmx"
jaxrpc_module_depends="      common     j2ee"
deployment_module_depends="  common jmx j2ee system"
transaction_module_depends=" common jmx j2ee system"
server_module_depends="      common jmx j2ee system naming        transaction"
media_module_depends="       common jmx j2ee system        server "
security_module_depends="    common jmx j2ee system naming server "
net_module_depends="         common jmx j2ee system        server             security jaxrpc "
connector_module_depends="   common jmx j2ee system        server transaction security"
iiop_module_depends="        common jmx j2ee system naming server transaction security"
messaging_module_depends="   common jmx j2ee system naming server transaction security"
cluster_module_depends="     common jmx j2ee system naming server transaction security        messaging"
management_module_depends="  common jmx j2ee system        server                                       cluster    connector"
remoting_module_depends="    common jmx j2ee system naming        transaction          jaxrpc "
jmx_remoting_module_depends="common jmx                                                                            remoting"
varia_module_depends="       common jmx j2ee system naming server transaction security jaxrpc messaging cluster  "
cache_module_depends="       common jmx j2ee system naming server transaction security        messaging management remoting"
jms_module_depends="         common jmx j2ee system                                                                remoting"
tomcat_module_depends="      common jmx j2ee system        server             security                  cluster    connector cache"
console_module_depends="     common jmx      system server                    security        messaging management varia     aop"
hibernate_module_depends="   common jmx j2ee system server        transaction                                                cache "
webservice_module_depends="  common jmx j2ee system server                             jaxrpc                      remoting "
