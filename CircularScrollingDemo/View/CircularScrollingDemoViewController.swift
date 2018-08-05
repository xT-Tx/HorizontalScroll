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
    var pagingEnabled: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cScrollView.isPagingEnabled = pagingEnabled
        addCards()
    }
    
    private func addCards() {
    
        let size = cScrollView.bounds.size
        var origin = CGPoint.zero
        var cards = [UIView]()
        
        for index in 0..<numberOfCards {
            origin.x = CGFloat(index) * size.width
            let container = UIView(frame: CGRect(origin: origin, size: size))
            cards.append(container)
            
            let numberLabel = UILabel(frame: container.bounds)
            numberLabel.textColor = .black
            numberLabel.font = UIFont.boldSystemFont(ofSize: 50)
            numberLabel.textAlignment = .center
            numberLabel.text = String(index + 1)
            
            numberLabel.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(numberLabel)
            numberLabel.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
            numberLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
            numberLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
            numberLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        }
        
        cScrollView.addCards(cards)
    }
}
