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
	$(call exec-xcodebuild, project, SwiftDatastore/SwiftDatastore.xcodeproj, SwiftDatastore-Debug, YES)

test_app:
	$(call exec-xcodebuild, project, SwiftDatastore/SwiftDatastore.xcodeproj, TestApp-Debug, NO)

cocoa_pods_test_app:
	$(call exec-xcodebuild, workspace, TestApps/CocoaPodsApp/CocoaPodsApp.xcworkspace, Debug, NO)

define exec-xcodebuild
	xcodebuild test \
	-$(1) $(2) \
	-scheme $(3) \
	-destination platform=$(PLATFORM),name=$(DEVICE),OS=$(IOS_VERSION) \
	-enableCodeCoverage $(4)
endef