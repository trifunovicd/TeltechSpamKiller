//
//  NetworkError.swift
//  TeltechSpamKiller
//
//  Created by DTech on 30.09.2023..
//

import Foundation

public enum NetworkError: Error, Equatable {
    case generalError
    case parseError
    case extensionError
}
