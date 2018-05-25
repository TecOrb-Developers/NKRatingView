//
//  ViewController.swift
//  NKStarViewDemo
//
//  Created by TecOrb on 25/05/18.
//  Copyright © 2018 Nakul Sharma. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var ratingView : NKRatingView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: NKRatingViewDelegate{
    func ratingView(ratingView: NKRatingView, didUpdate rating: Double) {
        print("rating updated: \(rating)")
    }
    
    func ratingView(ratingView: NKRatingView, isUpdating rating: Double) {
        print("updating rating : \(rating)")
    }
}

