//
//  File.swift
//  
//
//  Created by Nishith on 07/03/21.
//

import Foundation

struct Queue<T> {

    init(_ array: [T]) {
        array.forEach { enqueue($0) }
    }

    fileprivate var list: [T] = []

    var isEmpty: Bool {
        return list.isEmpty
    }


    mutating func enqueue(_ element: T) {
        list.append(element)
    }

    @discardableResult mutating func dequeue() -> T? {
        guard !list.isEmpty else { return nil }
        return list.removeFirst()
    }
}
