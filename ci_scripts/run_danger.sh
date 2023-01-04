#!/bin/bash

#
#  run_danger.sh
#  SwiftDatastore
#
#  Created by Kukułka Tomasz on 09/11/2022.
#

set -ex

cp -r ~/Library/Developer/Xcode/DerivedData/SwiftDatastore*/Logs/Test/*.xcresult SwiftDatastore.xcresult

bundle install
bundle exec danger