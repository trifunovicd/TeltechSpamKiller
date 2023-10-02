//
//  IdentifiableSectionItem.swift
//  TeltechSpamKiller
//
//  Created by DTech on 30.09.2023..
//

import Foundation
import RxDataSources

public struct IdentifiableSectionItem<DataType>: IdentifiableType, AnimatableSectionModelType, Equatable {
    public typealias Element = IdentifiableRowItem<DataType>
    
    public let identity: String
    public var items: [Element]
    
    init(identity: String, items: [Element]) {
        self.identity = identity
        self.items = items
    }
    
    public init(original: IdentifiableSectionItem<DataType>, items: [IdentifiableRowItem<DataType>]) {
        self = original
        self.items = items
    }
    
    public static func == (lhs: IdentifiableSectionItem<DataType>, rhs: IdentifiableSectionItem<DataType>) -> Bool {
        lhs.identity == rhs.identity
    }
}
