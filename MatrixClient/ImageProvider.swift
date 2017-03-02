/*
 Copyright 2017 Avery Pierce
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation
import SwiftMatrixSDK

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
