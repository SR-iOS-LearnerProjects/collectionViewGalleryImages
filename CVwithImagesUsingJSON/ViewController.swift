//
//  ViewController.swift
//  CVwithImagesUsingJSON
//
//  Created by Sridatta Nallamilli on 23/12/19.
//  Copyright © 2019 Sridatta Nallamilli. All rights reserved.
//

import UIKit

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType,
                mimeType.hasPrefix("image"),
                let data = data,
                error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

struct Hero: Decodable {
    let localized_name: String
    let img: String
}

class ViewController: UIViewController {

    var heroes = [Hero]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        getData()
    }
    
    func getData() {
        let url = URL(string: "https://api.opendota.com/api/heroStats")
        URLSession.shared.dataTask(with: url!) { ( data, response, error ) in
            if error == nil {
                do {
                    self.heroes = try JSONDecoder().decode([Hero].self, from: data!)
                } catch {
                    print("JSON Parse Error!!!")
                }
                
                DispatchQueue.main.async {
//                    print(self.heroes.count)
                    self.collectionView.reloadData()
                }
                
            }
        }.resume()

    }
}

//MARK: collection
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return heroes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! CollectionViewCell
        
        cell.nameLbl.text = heroes[indexPath.row].localized_name.capitalized
        
        let defaultLink = "https://api.opendota.com"
        let appendingLink = heroes[indexPath.row].img
        let completeLink = defaultLink + appendingLink

        cell.imgLbl.downloaded(from: completeLink)
        
        cell.imgLbl.clipsToBounds = true
        cell.imgLbl.layer.cornerRadius = cell.imgLbl.frame.height / 2
        cell.imgLbl.contentMode = .scaleAspectFill
        
        return cell
    }
    
        
}
