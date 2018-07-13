/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

struct Photo {
  
  var caption: String
  var comment: String
  var image: UIImage
  var urlGif: URL
  var isJpg: Bool = true
  
  
  init(caption: String, comment: String, image: UIImage, urlGif: URL) {
    self.caption = caption
    self.comment = comment
    self.image = image
    self.urlGif = urlGif
  }
  
  init?(dictionary: [String: String]) {
    guard let caption = dictionary["Caption"], let urlGif = URL(string: dictionary["UrlGif"]!), let comment = dictionary["Comment"], let photo = dictionary["Photo"],
      let image = UIImage(named: photo) else {
        return nil
    }
    self.init(caption: caption, comment: comment, image: image, urlGif: urlGif)
  }

  static func allPhotos(isSearch: Bool, string: String = "", rating: String = "") -> [Photo] {
    var photos = [Photo]()
    var urlString: String = ""
    if isSearch {
      urlString = "http://api.giphy.com/v1/gifs/search?api_key=7BJxl5yzWVq821HRxpyHBhPL5308ENrv&q=" + string + "&rating=" + rating
    }else{
      urlString = "http://api.giphy.com/v1/gifs/trending?api_key=7BJxl5yzWVq821HRxpyHBhPL5308ENrv"
    }
    
    guard let url = URL(string: urlString) else { return photos}
    let semaphore = DispatchSemaphore(value: 0)
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      if error != nil {
        print(error!.localizedDescription)
      }
      
      guard let data = data else { return }
      //Implement JSON decoding and parsing
      do {
        //Decode retrived data with JSONDecoder and assing type of Article object
        let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        if let json = json as? NSDictionary{
          let jsonData = json["data"] as! NSArray
          
          for gifData in jsonData  {
            let data: NSDictionary = gifData as! NSDictionary
            let jsonImages = data["images"] as! NSDictionary
            let jsonImageJpg = jsonImages["480w_still"] as! NSDictionary
            let jsonImageGif = jsonImages["original_mp4"] as! NSDictionary
            
            let urlStrGif = jsonImageGif["mp4"] as! String
            let urlGif = URL(string: urlStrGif)
            
            let title = data["title"]
            
            let urlStr = jsonImageJpg["url"] as! String
            let imageUrl:URL = URL(string: urlStr)!
            let imageData:NSData = NSData(contentsOf: imageUrl)!
            let image = UIImage(data: imageData as Data)
            let photo = Photo(caption: title as! String, comment: title as! String, image: image!, urlGif: urlGif!)
            photos.append(photo)
          }
          
          let jsonDataGood = jsonData[0] as! NSDictionary
          
          semaphore.signal()
        }
        
        
      } catch let jsonError {
        print(jsonError)
      }
      
      }.resume()
    
     semaphore.wait()
    return photos
  }
  
  
  
  
}
