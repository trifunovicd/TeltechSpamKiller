//
//  APIClient.swift
//  TeltechSpamKiller
//
//  Created by DTech on 01.10.2023..
//

import Foundation
import RxSwift

public class APIClient {
    public static let shared = APIClient()
    private let disposeBag = DisposeBag()
    
    private init() {}
    
    private var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    func performRequest<T: Decodable>(_ url: String) -> Single<T> {
        return Single<T>.create { [unowned self] single -> Disposable in
            
            guard let bundlePath = Bundle.main.path(forResource: url, ofType: "json"),
                  let jsonData = try? String(contentsOfFile: bundlePath).data(using: .utf8),
                  let decodedData = try? decoder.decode(T.self, from: jsonData) else {
                
                single(.failure(NetworkError.parseError))
                return Disposables.create()
            }
            
            single(.success(decodedData))
            return Disposables.create()
        }
    }
}
