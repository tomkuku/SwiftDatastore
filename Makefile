#
#  Makefile
#  SwiftDatastore
#
#  Created by Kukułka Tomasz on 02/08/2022.
#

DEVICE = 'iPhone 14'
PLATFORM = 'iOS Simulator'
IOS_VERSION = 16.1
ENABLE_CODE_COVERGAE = -enableCodeCoverage YES
PROJECT = -project
WORKSPACE = -workspace

all: swift_datastore test_app cocoa_pods_test_app spm_test_app
	

swift_datastore:
	$(call exec-xcodebuild, test, $(PROJECT) SwiftDatastore/SwiftDatastore.xcodeproj, SwiftDatastore-Debug, $(ENABLE_CODE_COVERGAE))

test_app:
	$(call exec-xcodebuild, test, $(PROJECT) SwiftDatastore/SwiftDatastore.xcodeproj, TestApp-Debug)

cocoa_pods_test_app:
	$(call exec-xcodebuild,  , $(WORKSPACE) TestApps/CocoaPodsApp/CocoaPodsApp.xcworkspace, Debug)

spm_test_app:
	$(call exec-xcodebuild,  , $(PROJECT) TestApps/SPMApp/SPMApp.xcodeproj, Debug)

define exec-xcodebuild
	xcodebuild $(1) \
	$(2) \
	-scheme $(3) \
	-destination platform=$(PLATFORM),name=$(DEVICE),OS=$(IOS_VERSION) \
	$(4)
endef
