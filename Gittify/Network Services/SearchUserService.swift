//
//  SearchUserService.swift
//  Gittify
//
//  Created by Ebubechukwu Dimobi on 12.08.2020.
//  Copyright © 2020 blazeapps. All rights reserved.
//

import Foundation
import RxSwift

struct SearchUserService {
    
    
    func fetchUsers(with userName: String, page: Int)-> Observable<SearchUserData>{
        
        return Observable.create { (observer) -> Disposable in
            
            print("here")
            
            let completeQueryURL = EndPoints.SearchUsers.topUrl + userName + EndPoints.SearchUsers.midUrl + String(page) + EndPoints.SearchUsers.endUrl
            
            if let url = URL(string: completeQueryURL){
                
                let session = URLSession(configuration: .default)
                let task = session.dataTask(with: url) { (data, response, error) in
                    
                    if error != nil{
                        print("Newtwork Problem \(error!)")
                        observer.onError(error!)
                        return
                    }
                    
                    if let safeData = data{
                        
                        let decoder = JSONDecoder()
                        
                        do{
                            
                            let decodedSearchUserData = try decoder.decode(SearchUserData.self, from: safeData)
                            observer.onNext(decodedSearchUserData)
                            
                        }catch{
                            
                            print("could not parse Json---\(error)")
                            observer.onError(error)
                        }
                        
                    }else {
                        print("Data is empty")
                        observer.onError(NSError(domain: "Data is empty", code: -1, userInfo: nil))
                    }
                }
                task.resume()
                
                return Disposables.create {
                    task.cancel()
                }
            }
            
            return Disposables.create { }
        }
        
    }
    
}
