//
//  ViewModelType.swift
//  TeltechSpamKiller
//
//  Created by DTech on 29.09.2023..
//

import Foundation

public protocol ViewModelType {
    associatedtype Dependencies
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
