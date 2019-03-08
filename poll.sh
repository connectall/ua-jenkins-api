#!/bin/bash

. setup.sh

url=http://localhost:8090
key=62dc142c-3f33-4b95-9713-7ad4c7af9107
applink=jenkinsv2

if [ ! -f lasttime ]; then
	touch lasttime
fi

lastRun="`date -r lasttime "+%Y-%m-%d %H:%M:%S"`.001"
echo Last run was $lastRun

json="
{\"appLinkName\":\"jenkinsv2\",
 \"origin\":\"source\",
 \"lastModifiedTime\":\"$lastRun\"
}"

#2017-08-24 14:30:00.000

echo "Send JSON: $json"
echo "via ${ConnectAllUrl}/api/2/postRecord?apikey=$ConnectAllApiKey"

curl \
--header "Content-Type: application/json;charset=UTF-8" -X POST \
-d "$json" \
 ${ConnectAllUrl}/connectall/api/2/search?apikey=$ConnectAllApiKey | tee request.json

touch lasttime
echo

workspace=`cat request.json | sed -e 's/[{}]/''/g' | awk -v RS=',"' -F: '/workspace/ {print $2}' | sed -e 's/\"//g'`
echo
echo Result is $workspace

if [ "$workspace" = "" ]; then
	echo "Nothing to build"
else
	wget --auth-no-challenge --http-user=admin --http-password=welcome --secure-protocol=TLSv1 \
		${JenkinsUrl}/job/${workspace}/build?token=$JenkinsApiKey
fi
