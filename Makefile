#
#  Makefile
#  Datastore
#
#  Created by Kukułka Tomasz on 02/08/2022.
#

DEVICE = 'iPhone 12'
PLATFORM = 'iOS Simulator'
IOS_VERSION = 15.2

swift_datastore:
	$(call exec-xcodebuild, SwiftDatastore/SwiftDatastore, SwiftDatastore-Debug, YES)

test_app:
	$(call exec-xcodebuild, SwiftDatastore/SwiftDatastore, TestApp-Debug, NO)

define exec-xcodebuild
	xcodebuild test \
	-project $(1).xcodeproj \
	-scheme $(2) \
	-destination platform=$(PLATFORM),name=$(DEVICE),OS=$(IOS_VERSION) \
	-enableCodeCoverage $(3)
endef