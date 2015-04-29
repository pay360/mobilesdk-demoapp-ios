#!/bin/bash -x 

NEXUS_ROOT=http://192.168.6.244/nexus 

if [ -z "$FRAMEWORK_VERSION" ] ; then
   echo no framework version specified using default 
   FRAMEWORK_VERSION=1.0.0-SNAPSHOT 
fi 

rm -rf Paypoint.framework Paypoint.framework.zip

echo Downloading PayPoint framework version $FRAMERWORK_VERSION from Nexus 

ARTIFACT_URL="${NEXUS_ROOT}/service/local/artifact/maven/redirect?r=blue-snapshots&g=net.paypoint&a=mobilesdk-ios&v=${FRAMEWORK_VERSION}&e=zip"

curl  -Lf ${ARTIFACT_URL} -o  Paypoint.framework.zip
ditto -xz Paypoint.framework.zip Paypoint.framework  
