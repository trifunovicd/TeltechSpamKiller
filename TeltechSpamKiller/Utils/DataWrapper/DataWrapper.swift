//
//  DataWrapper.swift
//  TeltechSpamKiller
//
//  Created by DTech on 30.09.2023..
//

import Foundation

public struct DataWrapper<T> {
    let data: T?
    let error: Error?
    let page: Int
    
    init(data: T?, error: Error?, page: Int) {
        self.data = data
        self.error = error
        self.page = page
    }
}
