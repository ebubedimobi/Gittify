//
//  GetMoreInfoService.swift
//  Gittify
//
//  Created by Ebubechukwu Dimobi on 13.08.2020.
//  Copyright © 2020 blazeapps. All rights reserved.
//

import Foundation
import RxSwift

struct GetMoreInfoService {
    
    
    func fetchMoreInfo(with completeQueryURL: String)-> Observable<ExtraUserData>{
        
        return Observable.create { (observer) -> Disposable in
            
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
                            
                            let decodedExtraUserData = try decoder.decode(ExtraUserData.self, from: safeData)
                            observer.onNext(decodedExtraUserData)
                            
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
