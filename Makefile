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
	$(call exec-xcodebuild, test, -project SwiftDatastore/SwiftDatastore.xcodeproj, SwiftDatastore-Debug, YES)

test_app:
	$(call exec-xcodebuild, test, -project SwiftDatastore/SwiftDatastore.xcodeproj, TestApp-Debug, NO)

cocoa_pods_test_app:
	$(call exec-xcodebuild, build-for-testing, -workspace TestApps/CocoaPodsApp/CocoaPodsApp.xcworkspace, Debug, NO)

define exec-xcodebuild
	xcodebuild $(1) \
	$(2) \
	-scheme $(3) \
	-destination platform=$(PLATFORM),name=$(DEVICE),OS=$(IOS_VERSION) \
	-enableCodeCoverage $(4)
endef
