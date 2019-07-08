//
//  IndividualController.swift
//  WikipediaAlamoFire
//
//  Created by Connor Lagana on 7/5/19.
//  Copyright © 2019 Connor Lagana. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class IndividualController: UIViewController {
    
    var name = ""
    var fileName = ""
    let urlWiki = "https://en.wikipedia.org/w/api.php"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let paramsText: [String : Any] =
            ["action": "query",
             "titles": name,
             "prop": "extracts",
             "explaintext": true,
             "format": "json"]
        
        setupUI()
        getIndividualData(url: urlWiki, parameters: paramsText)
        getNameOfPic(term: name)
    }
    
    let titleView: UILabel = {
        let tv = UILabel()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "Title Goes Here"
        tv.font = .boldSystemFont(ofSize: 32)
        return tv
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let scrollArticleView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isSelectable = false
        tv.allowsEditingTextAttributes = false
        tv.text = "Scroll article text view goes in this area right here as you can probably tell by now it has multiple lines"
        tv.font = .systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(titleView)
        view.addSubview(imageView)
        view.addSubview(scrollArticleView)
        
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 340).isActive = true
        
        titleView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10).isActive = true
        titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        
        scrollArticleView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 10).isActive = true
        scrollArticleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        scrollArticleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        scrollArticleView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        titleView.text = name
//        title
        
    }
    
    func getIndividualData(url: String, parameters: [String: Any]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                
                let wikiJSON: JSON = JSON(response.result.value!)
                //                        print("this is the getWikiText JSON", wikiJSON)
                
                self.updateIndy(json: wikiJSON)
                
            }
            else {
                print("error")
                
            }
        }
        
    }
    
    func updateIndy(json: JSON) {
        
        guard let simpleText = json["query"]["pages"].dictionary?.values.first?["extract"].string else { return }
        guard let simpleTitle = json["query"]["pages"].dictionary?.values.first?["title"].string else { return }
        
        if simpleText.isEmpty == true {
            scrollArticleView.text = "There was an error. Please try a different Wikipedia Article"
        }
        else {
            scrollArticleView.text = simpleText
        }
        
    }
    
    func getNameOfPic(term: String) {
        let newName = term.replacingOccurrences(of: " ", with: "%20")
        Alamofire.request("https://en.wikipedia.org/w/api.php?action=query&prop=pageimages&titles=\(newName)&format=json").responseJSON { (resp) in
            if resp.result.isSuccess {
                let json: JSON = JSON(resp.result.value!)
                
                self.updateNamePic(json: json)
            }
        }
    }
    
    func updateNamePic(json: JSON) {
        var image = json["query"]["pages"].dictionaryValue.values.first?["pageimage"].string
        
        let file = "File:\(image!)"
        
        fileName = file
        
        getPicData(term: fileName)
    }
    
    func getPicData(term: String) {
        Alamofire.request("https://en.wikipedia.org/w/api.php?action=query&titles=\(term)&prop=imageinfo&iiprop=url&format=json").responseJSON { (resp) in
            if resp.result.isSuccess {
                let json: JSON = JSON(resp.result.value!)
                
                self.updatePic(json: json)
            }
        }
    }
    
    func updatePic(json: JSON) {
        guard let pic = json["query"]["pages"]["-1"]["imageinfo"][0]["url"].url else { return }
        
        imageView.sd_setImage(with: pic)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
