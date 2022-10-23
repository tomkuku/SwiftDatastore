#
#  EntityPropertyTests.swift
#  SwiftDatastoreTests
#
#  Created by Kukułka Tomasz on 15/09/2022.
#

Pod::Spec.new do |spec|

  spec.name           = "SwiftDatastore"
  spec.version        = "2.0"
  spec.summary        = "Elegeant and easy way to store data in Swift."
  spec.description    = "SwiftDatastore is a wrapper to CoreData. It has been created to add opportunity to use CoreData methods and objects in easy way."
  spec.homepage       = "https://github.com/tomkuku/SwiftDatastore"
  spec.license        = "MIT"
  spec.author         = "Tomasz Kukułka"

  spec.swift_version  = "5.5"
  spec.platform       = :ios, "13.0"

  spec.source         = { :git => 'https://github.com/tomkuku/SwiftDatastore.git', :tag => "2.0" }

  spec.source_files   = "SwiftDatastore/SwiftDatastore/**/*.swift"
  spec.exclude_files  = [ 'SwiftDatastore/SwiftDatastore/SwiftDatastoreTests/**/*' ]
  spec.weak_framework = 'XCTest'
end
