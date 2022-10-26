<h1 align="center">SwiftDatastore</h1>
<h3 align="center">Elegeant and easy way to store data in Swift</h3>

<p align="center">
<a href="https://github.com/tomkuku/SwiftDatastore/actions">
<img alt="Build Status" src="https://img.shields.io/github/workflow/status/tomkuku/SwiftDatastore/Build%20and%20Test/main?logo=github" /></a>
<a href="https://github.com/tomkuku/SwiftDatastore/commits">
<img alt="Last Commit" src="https://img.shields.io/github/last-commit/tomkuku/SwiftDatastore?logo=git" /></a>
<a href="https://app.codecov.io/gh/tomkuku/SwiftDatastore">
<img alt="Code coverage" src="https://codecov.io/github/tomkuku/SwiftDatastore/coverage.svg?branch=main" /></a>
<a href="https://github.com/tomkuku/SwiftDatastore/blob/main/LICENSE.md">
<img alt="License" src="https://img.shields.io/github/license/tomkuku/SwiftDatastore?color=blue" /></a>
</p>
</br>
<p align="center">
<a herf="https://github.com/tomkuku/SwiftDatastore/blob/main/LICENSE.md">
<img alt="Swift" src="https://img.shields.io/badge/Swift->=_5.5-orange?logo=swift&style=flat" /></a>
<img alt="Platforms" src="https://img.shields.io/badge/platforms-iOS_+13.0-yellowgreen?style=flat&logo=apple&name=platforms&color=lightgrey" />
</p>
</br>
<p align="center">
<img alt="CocoaPods" src="https://img.shields.io/badge/CocoaPods-compatible-informational?logo=cocoapods&style=flat" />
</p>

</br>

### What is SwiftDatastore and why should I use it?
`SwiftDatastore` is a wrapper to CoreData. It has been created to add opportunity to use `CoreData` methods and objects in easy way. For example to store value of person's age in CoreData's datamodel we need to choose Int16-64 but then in code we want use this property in easy way - as Int so every time we need to convert it to Int what is uncomfortable.

`SwiftDatastore` has set of `PropertyWrappers` which allow you for getting and setting value without converting types manually every time. You decide what type you want, `SwiftDatastore` does the rest for you.

`SwiftDatastore` also has wide set of prepared generic methods so you don't need to make any own implementations. What is import each method is tested ✅. Full list of methods is below.

Just try it 😊!

</br>

### **Table of Content**:
- [Installation](#installation)
- [Overview](#overview)
- [Create DatastoreObject](#create-datastoreobject)
    - [Attributes](#attributes)
        - [`NotOptional`](#notoptional)
        - [`Optional`](#optional)
        - [`Enum`](#enum)
    - [Relationship](#relationship)
        - [`ToOne`](#toone)
        - [`ToMany`](#tomany)
- [Using SwiftDatastore's](#using-swiftdatastores)
- [SwiftDatastore’s operations](#swiftdatastores-operations)
    - [`perform`](#perform)
    - [`createObject`](#createobject)
    - [`deleteObject`](#deleteobject)
    - [`saveChanges`](#savechanges)
    - [`reverChanges`](#revertchanges)
    - [`fetch`](#fetch)
    - [`fetchFirst`](#fetchfirst)
    - [`fetchProperties`](#fetchproperties)
    - [`count`](#count)
    - [`convert existing object`](#convert-existing-object)
    - [`deleteMany`](#deletemany)
    - [`updateMany`](#updatemany)
    - [`refresh`](#refresh)
- [Using ViewContext](#using-viewcontext)
- [Using FetchedObjectsController](#using-fetchedobjectscontroller)
    - [`numberOfSections`](#numberofsections)
    - [`numberOfObjects`](#numberofobjects)
    - [`getObject`](#getobject)
    - [`sectionName`](#sectionname)
    - [`observeChanges`](#observechanges)
- [`OrderBy`](#orderby)
- [`Where`](#where)
- [Observe](#observe)

</br>
</br>

## Installation
### **[CocoaPods](http://cocoapods.org)**
In your `Podfile` in the target in which you want to use SwiftDatastore add:
``` ruby
pod 'SwiftDatastore'
```

and then run:
``` ruby
pod install
```

## Overview
In the `CoreData` you create `NSManagedObject` on specific `NSManagedObjectContext`. And then you can use these objects on theirs contexts.
In the `SwiftDatastore` you create `DatastoreObject` (counterpart of `NSManagedObject`) on specific `Datastore's Context` (counterpart of `NSManagedObjectContext`).

### Context
- It allows you to perform operations on datastore.
You should create new, spearate Context for each operation like: upload data, download data etc. Such action increase performance.

### ViewContext
- It's single instance, created to cowork with UI components. This `Context` is read only so you don't able to create, save or delete object on this context.

### FetchedObjectsController
- It is counterpart of `NSFetchedResultsController` and is used for fetching objects in grouped, ordered way on UI componenets.

***

## Create DatastoreObject
To create class which represents an entity this class must inherite after `DatastoreObject` class.

Your class should have the same name as `Entity` in `datamodel`.
``` Swift
class Employee: DatastoreObject {
}
```

If you need to perform some operations after init use `required init(managedObject: ManagedObjectLogic)` but you need insert `super.init(managedObject: managedObject)` into it's body like on example below:
``` Swift
class Employee: DatastoreObject {
    // Properties

    required init(managedObject: ManagedObjectLogic) {
        super.init(managedObject: managedObject)

        // do something here ...
    }
}
```

⚠️ If for some reason your class has a name other than the `Entity` that this class represents, you must override `entityName` the class  property.

``` Swift
class Employee: DatastoreObject {
    override class var entityName: String {
        "EntityName"
    }
}
```

If you need to do something after the object is created, you can override the `objectDidCreate` method, which is only called after the object is created.



This method does nothing by default.
``` Swift
class Employee: DatastoreObject {
    @Attribute.NotOptional var id: UUID

    override func objectDidCreate() {
        id = UUID()
    }
}
```

***

## Attributes
Each attribute is `property wrapper`.

⚠️ Name of variable must be the same as name of this attribute in `datamodel`.

### `NotOptional`
It represents single attribute of entity which mustn't return nil value.
Use this Attribute when you are sure that stored value is never nil.

⛔️ If this attribute returns nil value it will crash your app.

You can use it with all attribute types e.g: Int16, Int, Double, String, UUID, URL, Date etc.

``` Swift
class Employee: DatastoreObject {
    @Attribute.NotOptional var id: UUID! // The exclamation mark at the end is not required.
    @Attribute.NotOptional var name: String
    @Attribute.NotOptional var dateOfBirth: Date
    @Attribute.NotOptional var age: Int // In data model this attribute may be: Integer 16, Integer 32, Integer 64.
}
```

👌 You can use `objectDidCreate()` method to set default value.
``` Swift
class Employee: DatastoreObject {
    @Attribute.NotOptional var id: UUID

    override func objectDidCreate() {
        id = UUID()
    }
}
```

👌 If you need to have **constant (`let`)** property of `Attribute` you can set it as `private(set)`.
``` Swift
class Employee: DatastoreObject {
    @Attribute.NotOptional private(set) var id: UUID
}
```

⛔️ Be careful when setting the type of an attribute in the DatastoreObject. For example: in a datamodel you set the name width attribute to the type Double, in the DatastoreObject class you set the same name attribute with the type Float. It will crash your application!

### `Optional`
It represents single attribute of entity which can return or store nil value.
Use this Attribute when you aren't sure that stored value is never nil.

You can use it with all attribute types e.g: Int16, Int, Double, String, UUID, URL, Date etc.
``` Swift
class Employee: DatastoreObject {
    @Attribute.Optional var secondName: String? // The question mark at the end is required.
    @Attribute.Optional var profileImageData: Data?
}
```

### `Enum`
It represents an `enum` value.
This `enum` must meet the `RawRepresentable` protocol because it's `rawValue` is saved in `SQLite dtatbase`.

⚠️ You must use the same `RawValue` type (e.g: Int16) as attribute's type set in `datamodel`.

This type of Attribute always returns an optional values.
``` Swift
enum Position: Int16 {
    case developer
    case uiDesigner
    case productOwner
}

class Employee: DatastoreObject {
    @Attribute.Enum var position: Position?
}

// ...

employee.position = .developer
```

***

## Relationship
Each attribute is `property wrapper`.

⚠️ Name of variable must be the same as name of this attribute in `datamodel`.

### `ToOne`
It represents `one-to-one` relationship beetwen SwiftDatastore's entities.

There can to be passed an optional and nonoptional `Object`.
``` Swift
class Office: DatastoreObject {
    @Relationship.ToOne var emplyee: Employee
}

class Employee: DatastoreObject {
    @Relationship.ToOne var office: Office
}

// ...

office.employee = employee

employee.office = office
```

### `ToMany`
It represents `one-to-many` relationship which is `Set<Object>`.

``` Swift
class Company: DatastoreObject {
    @Relationship.ToMany var emplyees: Employee
}

class Employee: DatastoreObject {
    @Relationship.ToOne var company: Company
}

// ...

company.employees = [employee1, employee2, ...]
company.employess.insert(employee7)

employee.company = company
```

⚠️ There mustn't to be passed an optional value. You can only remove object from the set.

``` Swift
company.employess.remove(employee)
```

***

## Using SwiftDatastore's
You must create SwiftDatastore instacne. One instacne represents one store which stores objects from one datamodel.
``` Swift
let swiftDatastore = try SwiftDatastore(storeName: "yourAppStoreName", datamodelName: "MyAppDatamodel")
```
⚠️ Creating SwiftDatastore instance may throw an exception.

It creates `SQLite file` with name: `"yourAppStoreName"` which stores objects from `xcdatamodel` with name `"MyAppDatamodel"`.
It allows you to create more than one store for different model in one app.

### SwiftDatastoreContext
To create `SwiftDatastoreContext` instance you must:
``` Swift
let datastoreContext = swiftDatastore.newContext()
```

ℹ️ Each Context works on copy of objects which are saved in database.
If you create two contexts in empty datastore and on the first context create an object, this object will be availiabe on the second context  only when you perfrom save changes on the first context.

⚠️ Every operation on `Context` <ins>**must be called on it's private queue**</ins> like `privateQueueConcurrencyType of ManagedObjectContext`. Because of that, each `Context` allows to call methods only inside closure the perform method what guarantees performing operations on context's private queue. Performing methods or modify objects outside of closures of these methods may cause runs what even may *crash* your app.

### Child Context
SwiftDatastore is based on the `CoreData` framework. For this reason it apply `CoreData's parent-child concurrency mechanism`. It allows you to make changes in child context like: update, delete, insert objects. Then you save changes into parent as all. Because of that saving changes is more safly then making a lot of changes on one context.

To create `SwiftDatastoreContext` instance you must:
``` Swift
let parentContext = swiftDatastore.newContext()
let childContext = parentContext.createNewChildContext()
```

***

## SwiftDatastore's operations
### `perform`
Code below this method is executing immediately without waiting for code inside the closure finish executing. 

This method perform block of code you pass in first closure. Becasue of some opertaions may throw an exception: 
- The `success` closure is called when performing the closure will end without any exeptions. 
- The `failure` closure is called when performing the closure will be broken by an exception. You can handle an error you will get. In this case the `success` closure isn't called.

``` Swift
datastoreContext.perform { context in
    // code inside the closure
} success {

} failure { error in

}
```

You can also use method with completion. This construction is intended only for safe operations like: getting and setting values of `DatastoreObjcet`'s properties because it can perform only opertaions which don't throw exceptions.
``` Swift
datastoreContext.perform { context in
    // code inside the closure
} completion {

}
```

⛔️ Never use `try!` to perform throwing methods. In a case of any exception it may crash your app!


### `createObject`
Creates and returns a new instance of `DatastoreObject`.

You can create a new object **only** using this method.

This method is generic so you need to pass `Type` of object you want to create.

This method may throw an exception when you try to create DatastoreObject which entity name is invalid.
``` Swift
datastoreContext.perform { context in
    let employee: Employee = try context.createObject()
}
```

### `deleteObject`
It deletes a single `DatastoreObject` object from `datastore`.

``` Swift
datastoreContext.perform { context in
    context.deleteObject(employee)
}
```

### `saveChanges`
If context is a child context it saves changes into its parent. Otherwise it saves local changes into SQL database.
 
⚠️ You are responsible of saving changes. If you don't save changes and terminate your app, changes will disappear.

``` Swift
datastoreContext.perform { context in
    try viewContext.saveChnages()
}
```

### `revertChanges`
This method reverts <ins>**unsaved**</ins> changes.

``` Swift
datastoreContext.perform { context in
    let employee = try context.createObject()

    employee.name = "Tom"
    employee.salary = 3000

    try context.save()

    employee.salary = 4000

    context.revertChnages()

    print(employee.salary) // output: 3000
}
```

### `fetch`
It fetches objects from datastore.

This method is generic so must pass type of object you want to fetch.
``` Swift
datastoreContext.perform { context in
    let employees: [Employee] = try context.fetch(where: (\.$age > 30),
                                                  orderBy: [.asc(\.$name), .desc(\.$salary)],
                                                  offset: 10,
                                                  limit: 20)
}
```

### `fetchFirst`
Fetches the first object which meets conditions.

You can use this method to find e.g. max, min of value in datastore using the `orderBy` parameter.

This method is generic so you have to pass type of object you want to fetch.

ℹ️ Return value is always optional.
``` Swift
datastoreContext.perform { context in
    let employee: Employee? = try context.fetchFirst(where: (\.$age > 30), 
                                                     orderBy: desc(\.$salary)])
}
// It returns Employee who has the highest (max) salary.
```

### `fetchProperties`
Fetches properties which keyPaths you passed as method's paramters.

Parameter `propertiesToFetch` is required and is an array of `PropertyToFetch`. `PropertyToFetch` struct ensures that entered key is correct.

Return value is an array of `Dictionary<String, Any?>`.

If you pass empty `propertiesToFetch` array this method will do nothing and return empty array.

ℹ️ This method returns properties values which objects has been saved in SQLite database.
``` Swift
datastoreContext.perform { context in
    let properties = try context.fetchProperties(Employee.self,
                                                 orderBy: [.asc(\.$salary)],
                                                 propertiesToFetch: [.init(\.$salary),
                                                                            .init(\.$id)])
    let firstSalary = fetchedProperties.first?["salary"] as? Float
}
```

### `count`
Returns the number of objects which meet conditions in datastore.
``` Swift
datastoreContext.perform { context in   
    let numberOfEmployees = try context.count(where: (\.$age > 30))
    // It returns number of Employees where age > 30.
}

```

### `convert existing object`
This method converts object between Datastore's Contexts.

You should use this method when you need to use object on different datastore then this which created or fetched this object.

⛔️ This method needs object which has been saved in SQLite database. When you try convert unsaved object this method throws a exception.

Example below shows how you can convert object from ViewContext into Context and update its property.

``` Swift
var carOnViewContext: Car = try! viewContext.fetchFirst(orderBy: [.asc(\.$salary)])

datastoreContext.perform { context
    let car = try context.convert(existingObject: carOnViewContext)

    car.numberOfOwners += 1

    try context.saveChanges()
}
```

### `deleteMany`
It deletes many objects and optionally returns number of deleted objects.

As the first parameter you have to pass object's type you want to delete.

Parameter `where` is required.

After calling this method, property `willBeDeleted` returns ture. If you call `saveChanges` after that it returns false.

⚠️ This method deletes objects **directly** from SQLite database so it doesn't delete objects which have not saved yet. For the same reason you <ins>don't need to</ins> call `saveChanges()` after call this method.

``` Swift
datastoreContext.perform { context
    let numberOfDeleted = try context.deleteMany(Employee.self, where: (\.$surname ^= "Smith"))
}
```

### `updateMany`
It updates many objects and optionally returns number of updated objects.

As the first parameter you have to pass object's type you want to update.

Parameter `where` is not required.

Parameter `propertiesToUpdate` is required and is an array of PropertyToUpdate. `PropertyToUpdate` struct ensures that entered value is the same type as it's key.

If you pass empty `propertiesToUpdate` array this method will do nothing and return 0.

⚠️ This method updates objects **directly** in SQLite database so it doesn't update objects which have not saved yet. For the same reason you <ins>don't need to</ins> call `saveChanges()` after call this method.

``` Swift
datastoreContext.perform { context
    let numberOfUpdated = try context.updateMany(Employee.self,
                                                 where: \.$surname |= "Smith",
                                                 propertiesToUpdate: [.init(\.$age,
                                                                      .init(\.$name, "Jim")])
}
```

### `refresh`
This method causes refreshing any objects which have been updated and deleted on the context from changes has made. Values of these objects is revering to last state from SQLite database or from context's parent if exists. 

⚠️ This method doesn't apply changes made on another context. 

``` Swift
var savedChanges: SwiftCoredataSavedChanges!

datastoreContext1.perform { context in
    savedChanges = try viewContext.saveChnages()
} success {

    datastoreContext1.perform { context in
       context.refresh(with: savedChanges)
    }
}
```

***

## Using ViewContext
It's created to cowork with UI components. 

⚠️ Every operation on `ViewContext` must be called on **main queue** (main thread).

To create `Datastore's ViewContext` instance you must:
``` Swift
let viewContext = swiftDatastore.sharedViewContext
```

It allows you to call operations and get objects values without using closures when it's not neccessary. But it's you are responsible to call methods on `mainQueue` using `DispatchQueue.main`.

Example how to use methods:

``` Swift
// mainQueue

let employees: [Employee] = try viewContext.fetch(where: (\.$age > 30),
                                                  orderBy: [.asc(\.$name), .desc(\.$salary)],
                                                  offset: 10,
                                                  limit: 20)

nameLabel.text = employee[0].name 
```

ℹ️ It's highly recommended to use `offset` and `limit` to increase performance.

***

## Using FetchedObjectsController
⚠️ Every operation on `ViewContext` must be called on **main queue** (main thread).

Configuration is simillar to initialization `NSFetchedResultsController`.
You need to pass `viewContext`, `where`, `orderBy`, `groupBy`. Then call `performFetch` method.

Parameter `orderBy` is required.

ℹ️ If you don't pass `groupBy`, you will get a **single** section with all fetched objects.

``` Swift
let fetchedObjectsController = FetchedObjectsController<Employee>(
    context: managedObjectContext,
    where: \.$age > 22 || \.$age <= 60,
    orderBy: [.desc(\.$name), .asc(\.$age)],
    groupBy: \.$salary)

fetchedObjectsController.performFetch()
```

### `numberOfSections`
Returns number of fetched sections which are created by passed `groupBy` keyPath.
``` Swift
let numberOfSections = fetchedObjectsController.numberOfSections
```

### `numberOfObjects`
Returns number of fetched objects in specific section.

ℹ️ If you pass sections index which doesn't exist this method returns 0.
``` Swift
let numberOfObjects = fetchedObjectsController.numberOfObjects(inSection: 1)
```

### `getObject`
Returns object at specific IndexPath.

⛔️ If you pass IndexPath which doesn't exist this method runs `fatalError`.
``` Swift
let indexPath = IndexPath(row: 1, section: 3)

let objectAtIndexPath = fetchedObjectsController.getObject(at indexPath: indexPath)
```

### `sectionName`
This method returns section name for passed section index.
Because of gorupBy parameter may be any type, this  method returns section name as String. You can convert it to type you need.

``` Swift
let sectionName = fetchedObjectsController.sectionName(inSection: 0)
```

### `observeChanges`
This method is called every time when object which you passed as FetchedObjectsController's Generic Type has changed.

Change type:
- `inserted` - when object has been inserted.
- `updated` - when object has been updated.
- `deleted` - when object has been deleted.
- `moved` - when object has changed its position in fetched section.

ℹ️ This method informs about one change. For example: when object of type `Employee` will be inserted and than deleted this method is called twice.

``` Swift
fetchedObjectsController.observeChanges { change in
    switch change {
    case .inserted(employee, indexPath):
        // do something after insert
    case .updated(employee, indexPath):
        // do something after update
    case .deleted(indexPath):
        // do something after delete
    case .moved(employee, sourceIndexPath, destinationIndexPath):
        // do something after move
    }
}
```

You can aso Use `Combine's changesPublisher` and subscribe changes.

```Swift
fetchedObjectsController.
    .changesPublisher
    .sink { change
        switch change {
        case .inserted(employee, indexPath):
            // do something after insert
        case .updated(employee, indexPath):
            // do something after update
        case .deleted(indexPath):
            // do something after delete
        case .moved(employee, sourceIndexPath, destinationIndexPath):
            // do something after move
        }
    }
    .store(in: &cancellable)
```

***

## OrderBy
It's a wrapper to `CoreData's NSSortDescriptor.`
It's enum which contains two cases: 
- `asc` - ascending,
- `desc` - descending.

To use it you have to pass keyPath to DatastoreObject's ManagedObjectType.

``` Swift
extension PersonManagedObject {
    @NSManaged public var age: Int16
    @NSManaged public var name: String
}

final class Person: DatastoreObject {
    @Attribute.Optional var age: Int?
    @Attribute.NotOptional var name: String
}

let persons: [Person] = context.fetch(orderBy: [.asc(\.$name), .desc(\.$age)])
// It returns array of Persosns where age is ascending and age is descending.
```

## Where
It's a wrapper to `CoreData's NSPredicate.`. You can use prepared operators:
- `>` - greater than
- `>=` - greater than or equal to
- `<` - less than
- `<=` - less than or equal to
- `==` - equal to
- `!=` - not equal to
- `?=` - contains (string)
- `^=` - begins with (string)
- `|=` - ends with (string)
- `&&` - and
- `||` - or

``` Swift
extension PersonManagedObject {
    @NSManaged public var age: Int16
    @NSManaged public var name: String
}

final class Person: DatastoreObject {
    @Attribute.Optional var age: Int?
    @Attribute.NotOptional var name: String
}

let persons: [Person] = context.fetch(where: \.$age >= 18 && (\.$name ^= "T") || (\.$name |= "e"))
// It returns array of Persosns where age is great than 18 and name begins with "T" or ends with "e".
```

## Observe
You can observe changes of any `Attribute` and `Relationship`.
The closure is performed every time when a value of observed property changes no matter either the change is done on observed instance of `DatastoreObject` or on another instance but with the same `DatastoreObjectID` in the same `SwiftDatastoreContext`.

⚠️ You can add only one observer per one instance of `DatastoreObject`. If you add more then one only the last one will be performed.

``` Swift
employee.$name.observe { newValue in
    // New value of Optional Attribute may be nil or specific value.
}
```

You can also use `Combine's` newValuePublisher to subscribe any newValue.

``` Swift
employee.$position
    .newValuePublisher
    .sink { newValue in
        // do something after change
    }
    .store(in: &cancellable)
```