//
//  APICaller.swift
//  Infinite Scroll
//
//  Created by Misha on 16.07.2022.
//

import Foundation

class APICaller {
    
    private var counter = 0
    
    private var isAlive = true
    
    var isPaginating = false
    
    func fetchData(pagination: Bool = false, completion: @escaping (Result<[Int], Error>) -> Void) {
        if pagination {
            isPaginating = true
        }
        DispatchQueue.main.async {
            var newData: [Int] = [0,1]
            var originalData: [Int] = [0,1]
            //Пока страница не заполнится, счётчик будет прибавлять 1 и добавлять в массив
//            while pagination == true {
//                self.counter += 1
//                print(self.counter)
//                originalData.append(self.counter)
//                newData.append(self.counter)
//
////                if  self.counter == 100 {
////                    break
////                }
//            }
                 
            completion(.success(pagination ? newData : originalData))
            if pagination {
                self.isPaginating = false
            }
        }
    }
}
 
