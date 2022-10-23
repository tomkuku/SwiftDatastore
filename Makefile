#
#  Makefile
#  Datastore
#
#  Created by Kukułka Tomasz on 02/08/2022.
#

DEVICE = 'iPhone 12'
PLATFORM = 'iOS Simulator'
IOS_VERSION = 15.2

framework:
	$(call exec-xcodebuild, SwiftDatastore/SwiftDatastore, Debug, YES)

demo_app_cocoa_pods:
	$(call exec-xcodebuild, DemoAppCocoaPods/DemoAppCocoaPods, Debug, NO)

define exec-xcodebuild
	xcodebuild test \
	-project $(1).xcodedproj \
	-scheme $(2) \
	-destination platform=$(PLATFORM),name=$(DEVICE),OS=$(IOS_VERSION) \
	-enableCodeCoverage $(3)
endef