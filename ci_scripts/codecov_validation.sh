#
#  codecov_validation.sh
#  SwiftDatastore
#
#  Created by Kukułka Tomasz on 09/11/2022.
#

readonly output=`
curl \
-X POST  \
--data-binary @codecov.yml \
https://codecov.io/validate \
-w %{http_code} \
-s
`

readonly status_code=`echo "$output" | tail -n1`

if [ $status_code -eq 200 ] ; then
    echo "Validation succeeded"
    exit 0
else
    echo "$output" | sed '$ d'
    exit 1
fi