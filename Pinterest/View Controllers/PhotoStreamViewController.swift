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
import AVFoundation

class PhotoStreamViewController: UICollectionViewController {
  
  var photos = Photo.allPhotos(isSearch: false)
  var refresher:UIRefreshControl!
  var tableForRandSearch: [String] = ["cat","dog", "child", "fun", "harry potter", "dark vador"]
  var timer: Timer = Timer()
  var searchBar:UISearchBar = UISearchBar()
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    UINavigationBar.appearance().largeTitleTextAttributes = [
      NSAttributedStringKey.foregroundColor: UIColor.white,
      
    ]
    self.collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
    if let layout = collectionView?.collectionViewLayout as? ImagesLayout {
      layout.delegate = self
    }
    if let patternImage = UIImage(named: "Pattern") {
      view.backgroundColor = UIColor(patternImage: patternImage)
    }
    collectionView?.backgroundColor = .clear
    collectionView?.contentInset = UIEdgeInsets(top: 23, left: 16, bottom: 10, right: 16)
    
    self.refresher = UIRefreshControl()
    let attributes = [NSAttributedStringKey.foregroundColor: UIColor.red]
    let attributedTitle = NSAttributedString(string: "Reloading data", attributes: attributes)
    
    self.refresher.attributedTitle = attributedTitle
    self.refresher.tintColor = UIColor.red
    self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
    self.collectionView!.addSubview(refresher)
  }
  
  @objc func loadData() {
    //code to execute during refresher
    let number = Int(arc4random_uniform(5))
    let string = tableForRandSearch[number]
    print(string)
    photos = Photo.allPhotos(isSearch: true ,string: string, rating: "R")
    print(photos)
    self.collectionView?.reloadData()
    self.collectionViewLayout.invalidateLayout()
    self.refresher?.endRefreshing()        //Call this to stop refresher
  }
  
}

extension PhotoStreamViewController: UICollectionViewDelegateFlowLayout, UISearchBarDelegate  {
  
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return photos.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnnotatedPhotoCell", for: indexPath as IndexPath) as! AnnotatedPhotoCell
    cell.photo = photos[indexPath.item]
    return cell
  }
  
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
    return CGSize(width: itemSize, height: itemSize)
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    var supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:"Header", for: indexPath as IndexPath) as UICollectionReusableView
    
    
    searchBar.searchBarStyle = UISearchBarStyle.minimal
    searchBar.placeholder = " Search a gif ..."
    searchBar.isTranslucent = false
    
    let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
    textFieldInsideSearchBar?.textColor = UIColor.white
    
    let frame = CGRect(x: 0, y: 0, width: 380, height: 60)
    searchBar.frame = frame
    
    searchBar.delegate = self
    
    supplementaryView.addSubview(searchBar)
    
    return supplementaryView
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText != ""{
      print("after every text gets changed")
      timer.invalidate()
      timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(output), userInfo: searchText, repeats: false)
    }
    

  }
  
  @objc func output(){
    if timer.userInfo != nil{
      var searchText: String = timer.userInfo as! String
      if searchText.count > 1{
        print(searchText)
        searchBar.text = "It's searching....."
        var ratingSearch: String = "g"
        if(searchText.contains(" #")){
          ratingSearch = searchText.substring(from: searchText.index(of: "#")!)
          ratingSearch.removeFirst()
          searchText = searchText.substring(to: searchText.index(of: "#")!)
          searchText.removeLast()
          
        }
        photos = Photo.allPhotos(isSearch: true ,string: searchText, rating: ratingSearch)
        self.collectionView?.reloadData()
        self.collectionViewLayout.invalidateLayout()
        searchBar.text = ""
      }
      
    }
    timer.invalidate()
  }
  
}

extension PhotoStreamViewController: ImagesLayoutDelegate {
  func collectionView(_ collectionView: UICollectionView,
                      heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
    
    return photos[indexPath.item].image.size.height
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      widthForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
    
    return photos[indexPath.item].image.size.width
  }
}
