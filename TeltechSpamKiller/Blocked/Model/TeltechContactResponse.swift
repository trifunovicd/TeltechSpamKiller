//
//  TeltechContactResponse.swift
//  TeltechSpamKiller
//
//  Created by DTech on 01.10.2023..
//

import Foundation

struct TeltechContactResponse: Codable {
    let suspicious: [String]
    let scam: [String]
}
