#
#  Makefile
#  SwiftDatastore
#
#  Created by Kukułka Tomasz on 02/08/2022.
#

DEVICE = 'iPhone 14'
PLATFORM = 'iOS Simulator'
IOS_VERSION = 16.0

swift_datastore:
	$(call exec-xcodebuild, -project SwiftDatastore/SwiftDatastore.xcodeproj, SwiftDatastore-Debug, YES)

test_app:
	$(call exec-xcodebuild, -project SwiftDatastore/SwiftDatastore.xcodeproj, TestApp-Debug, NO)

cocoa_pods_test_app:
	$(call exec-xcodebuild, -workspace TestApps/CocoaPodsApp/CocoaPodsApp.xcworkspace, Debug, NO)

define exec-xcodebuild
	xcodebuild test \
	$(1) \
	-scheme $(2) \
	-destination platform=$(PLATFORM),name=$(DEVICE),OS=$(IOS_VERSION) \
	-enableCodeCoverage $(3)
endef