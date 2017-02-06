//
//  ImageProvider.swift
//  MatrixClient
//
//  Created by Avery Pierce on 2/5/17.
//  Copyright © 2017 Avery Pierce. All rights reserved.
//

import Foundation
import MatrixSDK

struct UnknownError : Error {
    var localizedDescription: String {
        return "error object was unexpectedly nil"
    }
}

/// Downloads images and provides them.
class ImageProvider {
    
    var semaphores: [URL: DispatchSemaphore] = [:]
    var cache: [URL: NSImage] = [:]
    
    func semaphore(for url: URL) -> DispatchSemaphore {
        if let semaphore = self.semaphores[url] { return semaphore }
        let newSemaphore = DispatchSemaphore(value: 1)
        self.semaphores[url] = newSemaphore
        return newSemaphore
    }
    
    func image(for url: URL, completion: @escaping (_ response: MXResponse<NSImage>) -> Void) {
        
        // Get the semaphore for this url
        let semaphore = self.semaphore(for: url)
        
        // This operation needs to be performed on a background thread
        let queue = DispatchQueue(label: "Image Provider")
        queue.async {
            
            // Wait until any downloads are complete
            semaphore.wait()
            
            // If the image already exists in the cache, return it.
            if let image = self.cache[url] {
                completion(.success(image))
                semaphore.signal()
                return
            }
            
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                // The request is complete, so make sure to signal
                defer { semaphore.signal() }
                
                // Create a result object from the URLSession response
                let result: MXResponse<NSImage>
                if let data = data, let image = NSImage(data: data) {
                    self.cache[url] = image
                    result = .success(image)
                } else if let error = error {
                    result = .failure(error)
                } else {
                    result = .failure(UnknownError())
                }
                
                // Perform the completion block on the main thread.
                DispatchQueue.main.async { completion(result) }
            }.resume()
        }
        
        
    }
}
