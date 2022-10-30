//
//  Where.swift
//  Datastore
//
//  Created by Kukułka Tomasz on 15/08/2022.
//

import Foundation

public struct Where<T> where T: DatastoreObject {
    let predicate: NSPredicate

    init(predicate: NSPredicate) {
        self.predicate = predicate
    }
    
    init<R, V, C>(
        keyPath: KeyPath<R, V>,
        value: C,
        type: NSComparisonPredicate.Operator
    ) where R: DatastoreObject, V: EntityPropertyKeyPath {
        self.init(predicate: NSComparisonPredicate(
            leftExpression: NSExpression(forKeyPath: keyPath.keyPathString),
            rightExpression: NSExpression(forConstantValue: value),
            type: type))
    }
}

// MARK: GreaterThan
public func > <R, V>(lhs: KeyPath<R, V>,
                     rhs: V.KeyPathType) -> Where<R> where R: DatastoreObject, V: EntityPropertyKeyPath {
    Where(keyPath: lhs, value: rhs, type: .greaterThan)
}

// MARK: GreaterThanOrEqualTo
public func >= <R, V>(lhs: KeyPath<R, V>,
                      rhs: V.KeyPathType) -> Where<R> where R: DatastoreObject, V: EntityPropertyKeyPath {
    Where(keyPath: lhs, value: rhs, type: .greaterThanOrEqualTo)
}

// MARK: LessThan
public func < <R, V>(lhs: KeyPath<R, V>,
                     rhs: V.KeyPathType) -> Where<R> where R: DatastoreObject, V: EntityPropertyKeyPath {
    Where(keyPath: lhs, value: rhs, type: .lessThan)
}

// MARK: LessThanOrEqualTo
public func <= <R, V>(lhs: KeyPath<R, V>,
                      rhs: V.KeyPathType) -> Where<R> where R: DatastoreObject, V: EntityPropertyKeyPath {
    Where(keyPath: lhs, value: rhs, type: .lessThanOrEqualTo)
}

// MARK: EqualTo
public func == <R, V>(lhs: KeyPath<R, V>,
                      rhs: V.KeyPathType?) -> Where<R> where R: DatastoreObject, V: EntityPropertyKeyPath {
    Where(keyPath: lhs, value: rhs, type: .equalTo)
}

// MARK: NotEqualTo
public func != <R, V>(lhs: KeyPath<R, V>,
                      rhs: V.KeyPathType?) -> Where<R> where R: DatastoreObject, V: EntityPropertyKeyPath {
    Where(keyPath: lhs, value: rhs, type: .notEqualTo)
}

// MARK: Compound
public func && <T>(lhs: Where<T>, rhs: Where<T>) -> Where<T> where T: DatastoreObject {
    return Where<T>(predicate: NSCompoundPredicate(type: .and,
                                                   subpredicates: [lhs.predicate, rhs.predicate]))
}

public func || <T>(lhs: Where<T>, rhs: Where<T>) -> Where<T> where T: DatastoreObject {
    return Where<T>(predicate: NSCompoundPredicate(type: .or,
                                                   subpredicates: [lhs.predicate, rhs.predicate]))
}

fileprivate extension NSComparisonPredicate {
    convenience init(leftExpression: NSExpression, rightExpression: NSExpression, type: Operator) {
        self.init(leftExpression: leftExpression,
                  rightExpression: rightExpression,
                  modifier: .direct,
                  type: type)
    }
}

