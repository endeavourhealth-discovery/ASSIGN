#!/bin/bash

mkdir badges

# Artifact
group_id=$( xmllint --xpath "/*[local-name() = 'project']/*[local-name() = 'groupId']/text()" pom.xml )
artifact=$( xmllint --xpath "/*[local-name() = 'project']/*[local-name() = 'artifactId']/text()" pom.xml )
badgepath=${group_id}.${artifact}

# Version
version=$( xmllint --xpath "/*[local-name() = 'project']/*[local-name() = 'version']/text()" pom.xml )
version=${version/-/--} # Hyphen escaping required by shields.io

# Update badges pre-build
echo "https://img.shields.io/badge/Build-In_progress-orange.svg"
curl -s "https://img.shields.io/badge/Build-In_progress-orange.svg" > badges/build.svg

echo "https://img.shields.io/badge/Version-$version-green.svg"
curl -s "https://img.shields.io/badge/Version-$version-green.svg" > badges/version.svg

echo "https://img.shields.io/badge/Unit_Tests-Pending-orange.svg"
curl -s "https://img.shields.io/badge/Unit_Tests-Pending-orange.svg" > badges/unit-test.svg

# Sync with S3
aws s3 cp badges s3://endeavour-codebuild/badges/${badgepath}/ --recursive --acl public-read

# Build
{ #try
    eval $* &&
    buildresult=0
} || { #catch
    buildresult=1
}

# Build
if [ "$buildresult" -gt "0" ] ; then
        badge_status=failing
        badge_colour=red
else
        badge_status=passing
        badge_colour=green
fi
echo "https://img.shields.io/badge/Build-$badge_status-$badge_colour.svg"
curl -s "https://img.shields.io/badge/Build-$badge_status-$badge_colour.svg" > badges/build.svg

# Unit tests
failures=$( xmllint --xpath 'string(//testsuite/@failures) + string(//testsuite/@errors)' API/target/surefire-reports/TEST-*.xml )

if [ "$failures" -gt "0" ] ; then
        badge_status=failing
        badge_colour=red
else
        badge_status=passing
        badge_colour=green
fi

echo "Generating badge 'https://img.shields.io/badge/Unit_Tests-$badge_status-$badge_colour.svg'"
curl -s "https://img.shields.io/badge/Unit_Tests-$badge_status-$badge_colour.svg" > badges/unit-test.svg

# Sync with S3
aws s3 cp badges s3://endeavour-codebuild/badges/${badgepath}/ --recursive --acl public-read

exit ${buildresult}
