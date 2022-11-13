#
#  find_destination.sh
#  SwiftDatastore
#
#  Created by Kukułka Tomasz on 13/11/2022.
#

#!/bin/bash

# Parametres:
#  $1 - project/wrokspace
#  $2 - scheme
#  $3 - sdk 

set -e

xcodebuild \
-showdestinations \
$1 \
-scheme $2 \
-sdk $3 \
> xcodebuild_output \
2>/dev/null

readonly destinations=`cat xcodebuild_output | grep 'platform:iOS Simulator.*OS:'`
readonly simulator_id=`echo "$destinations" | tail -n 1 | awk -F'id:' '{ print $2 }' | cut -d, -f1`

# echo "$simulator_id"

prepared_destination="platform=iOS Simulator,id=$simulator_id"

echo "$prepared_destination"

rm xcodebuild_output

set +e