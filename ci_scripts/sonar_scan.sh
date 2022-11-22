#! /bin/bash

sonar="
sonar-scanner \
-Dsonar.projectKey=tomkuku_SwiftDatastore \
-Dsonar.organization=tomkuku \
-Dsonar.host.url=https://sonarcloud.io \
-Dsonar.login="$SONAR_TOKEN" \
-Dsonar.c.file.suffixes=- \
-Dsonar.cpp.file.suffixes=- \
-Dsonar.objc.file.suffixes=- \
-Dsonar.qualitygate.wait=true \
"

if [[ $GITHUB_REF == refs/pull/* ]] ; then # on pull request
    readonly pr_id=`echo "$GITHUB_REF" | cut -d/ -f3`
    sonar="
    ${sonar}
    -Dsonar.pullrequest.name="$GITHUB_HEAD_REF" \
    -Dsonar.pullrequest.key="$pr_id" \
    -Dsonar.pullrequest.base="$GITHUB_BASE_REF" \
    "
fi

echo $sonar

eval $sonar
