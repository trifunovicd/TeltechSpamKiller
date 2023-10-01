//
//  TeltechContactsRepository.swift
//  TeltechSpamKiller
//
//  Created by DTech on 01.10.2023..
//

import Foundation
import RxSwift

protocol TeltechContactsRepositoring {
    var apiClient: APIClient { get }
    
    func getContacts() -> Single<TeltechContactResponse>
}

class TeltechContactsRepository: TeltechContactsRepositoring {
    var apiClient: APIClient
    
    init(apiClient: APIClient = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    func getContacts() -> Single<TeltechContactResponse> {
        return apiClient.performRequest(NetworkConstants.Endpoint.teltechContacts)
    }
}
