#!/bin/bash
PKGS="flute,commons-logging,junit,sac,xerces-2,tomcat-5,jmi,mof,"
PKGS="${PKGS}commons-el,xml-commons,javahelp-bin,"
PKGS="${PKGS}servletapi-2.2,servletapi-2.3,servletapi-2.4"
CLASSPATH=${CLASSPATH}:$(java-config --classpath=${PKGS}) /usr/share/netbeans-4.0/bin/netbeans
