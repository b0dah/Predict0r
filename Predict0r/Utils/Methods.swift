//
//  Methods.swift
//  Predict0r
//
//  Created by Иван Романов on 31.05.2021.
//

import Foundation
import UIKit

public func readPlistData<T: Decodable>(filename: String, type: T.Type) -> Decodable? {
    
    // Do any additional setup after loading the view.
        let url = Bundle.main.url(forResource: filename, withExtension: "plist")!
    
        do {
            let data = try Data(contentsOf: url)
            let result = try PropertyListDecoder().decode(T.self, from: data)
            return result
        } catch { print(error) }
    
    return nil
}
