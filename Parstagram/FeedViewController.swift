//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Brayam Corral on 2/24/21.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var posts = [PFObject]()
    var refreshControl: UIRefreshControl!
    var numberOfPosts: Int! = 1
    
    func loadPosts(){
        let query = PFQuery(className: "Posts")
        query.order(byDescending: "createdAt")
        query.includeKey("author")
        
        query.limit = numberOfPosts
        
        query.findObjectsInBackground{ (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    func loadMorePosts(){
        let query = PFQuery(className: "Posts")
        query.order(byDescending: "createdAt")
        query.includeKey("author")
        
        numberOfPosts = numberOfPosts + 1;
        query.limit = numberOfPosts
        
        query.findObjectsInBackground{ (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func onRefresh() {
        
        loadPosts()
        print("REFRESHED")
        // remove spinning refresh symbol
        self.refreshControl.endRefreshing()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        // Add Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadPosts()
    }
    
    // happens when user scrolls and is about to reach end
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt IndexPath: IndexPath) {
        if IndexPath.row + 1 == posts.count{
            loadMorePosts()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        let post = posts[indexPath.row]
        
        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        
        cell.captionLabel.text = post["caption"] as! String
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        cell.photoView.af_setImage(withURL: url)
        
        return cell
        
    }
}
