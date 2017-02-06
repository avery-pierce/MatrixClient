//
//  MatrixExtensions.swift
//  MatrixClient
//
//  Created by Avery Pierce on 2/5/17.
//  Copyright © 2017 Avery Pierce. All rights reserved.
//

import Foundation
import MatrixSDK

extension URL {
    func resolvingMatrixUrl() -> URL {
        
        if  let urlString = MatrixSessionManager.shared.session?.matrixRestClient?.url(ofContent: self.absoluteString),
            let url = URL(string: urlString) {
            
            return url
        } else {
            return self
        }
    }
}
