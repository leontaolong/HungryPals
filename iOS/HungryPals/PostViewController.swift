//
//  PostViewController.swift
//  HungryPals
//
//  Created by Ranhao Xu on 3/4/18.
//  Copyright © 2018 UW iSchool. All rights reserved.
//

import UIKit

class PostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var postsTable: UITableView!
    
    let postRepo = PostRepository.shared
    var posts: [Post]? = nil
    var users: [User]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        posts = UIApplication.shared.postRepository.getPosts()
        users = UIApplication.shared.postRepository.getUsers()
        
        // Do any additional setup after loading the view.
        postsTable.dataSource = self
        postsTable.delegate = self
        //postsTable.separatorStyle = UITableViewCellSeparatorStyle.none
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts!.count;
    }
    
    private func maskRoundedImage(image: UIImage, radius: CGFloat) -> UIImage {
        let imageView: UIImageView = UIImageView(image: image)
        let layer = imageView.layer
        layer.masksToBounds = true
        layer.cornerRadius = radius
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return roundedImage!
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let post = posts![index]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        cell.textLabel?.text = post.getCreator().getUsername()
        //cell.textLabel?.font = UIFont(name: "Lato", size: 18)
        cell.detailTextLabel?.text = "Wants to eat \(post.getCuisine())\nAt \(post.getStartTime().toString()) - \(post.getEndTime().toString()), Today"
        
        let imageUrl = URL(string: post.getCreator().getProfilePic())!
        let imageData = try! Data(contentsOf: imageUrl)
        //let imageUI = UIImage(data: imageData)!
        cell.imageView?.image = maskRoundedImage(image: UIImage(data: imageData)!, radius: CGFloat(160))
        //cell.imageView?.topAnchor.constraint(equalTo: cell.topAnchor, constant: 50).isActive = true
        //cell.imageView?.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: 50).isActive = true
        
        //cell.imageView?.image = UIImage(data: imageData)!
        //cell.imageView?.frame = CGRect(x:0, y:0, width:50, height: 50)
        
        //cell.imageView?.layer.cornerRadius = 160;
        //cell.imageView?.layer.masksToBounds = true;
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts![indexPath.row]
        NSLog("User selected row at \(post.getRestaurant())")
        //performSegue(withIdentifier: "showQuestion", sender: subject)
    }
}
