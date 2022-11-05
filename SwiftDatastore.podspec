#
#  SwiftDatastore.podspec
#
#  Created by Kukułka Tomasz on 24/10/2022.
#

Pod::Spec.new do |spec|

  spec.name           = "SwiftDatastore"
  spec.version        = "0.3.0"
  spec.summary        = "Elegeant and easy way to store data in Swift."
  spec.description    = "SwiftDatastore is a wrapper to CoreData. It has been created to add opportunity to use CoreData methods and objects in easy way."
  spec.homepage       = "https://github.com/tomkuku/SwiftDatastore"
  spec.license        = "MIT"
  spec.author         = "Tomasz Kukułka"

  spec.swift_version  = "5.5"
  spec.platform       = :ios, "13.0"

  spec.source         = { :git => 'https://github.com/tomkuku/SwiftDatastore.git', :tag => spec.version.to_s }

  spec.source_files   = "SwiftDatastore/SwiftDatastore/**/*.swift"
end
