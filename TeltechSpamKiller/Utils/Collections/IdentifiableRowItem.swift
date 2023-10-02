//
//  IdentifiableRowItem.swift
//  TeltechSpamKiller
//
//  Created by DTech on 30.09.2023..
//

import Foundation
import RxDataSources

public class IdentifiableRowItem<DataType>: IdentifiableType, Equatable {
    public let identity: String
    public var item: DataType
    
    init(identity: String, item: DataType) {
        self.identity = identity
        self.item = item
    }
    
    public static func == (lhs: IdentifiableRowItem<DataType>, rhs: IdentifiableRowItem<DataType>) -> Bool {
        lhs.identity == rhs.identity
    }
}
