//
//  CircularScrollingDemoViewController.swift
//  CircularScrollingDemo
//
//  Created by JiangNan on 2018/8/2.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import UIKit

class CircularScrollingDemoViewController: UIViewController {

    @IBOutlet var cScrollView: CircularScrollView!
    
    var numberOfCards: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCards()
    }
    
    private func addCards() {
    
    }
}
