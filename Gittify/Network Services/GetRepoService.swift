//
//  GetRepoService.swift
//  Gittify
//
//  Created by Ebubechukwu Dimobi on 13.08.2020.
//  Copyright © 2020 blazeapps. All rights reserved.
//

import Foundation
import RxSwift

struct GetRepoService {
    
    func fetchRepoData(with topURL: String, page: Int)-> Observable<[RepoData]>{
        
        return Observable.create { (observer) -> Disposable in
            
            let completeQueryURL = topURL + EndPoints.ForRepos.midURL + String(page) + EndPoints.ForRepos.endURL
            
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
                            
                            let decodedRepoData = try decoder.decode([RepoData].self, from: safeData)
                            observer.onNext(decodedRepoData)
                            
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
