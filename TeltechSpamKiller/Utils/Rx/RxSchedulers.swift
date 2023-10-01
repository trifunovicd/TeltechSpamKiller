//
//  RxSchedulers.swift
//  TeltechSpamKiller
//
//  Created by DTech on 29.09.2023..
//

import RxSwift

public class RxSchedulers {
    static let concurentBackgroundScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
}
