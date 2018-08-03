//
//  ViewController.swift
//  CircularScrollingDemo
//
//  Created by JiangNan on 2018/8/2.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var textField: UITextField!
    
    @IBAction func presentDemoVC(_ sender: Any) {
        guard let number = textField.text, !number.isEmpty else { return }
        guard let demoVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DemoViewController") as? CircularScrollingDemoViewController else { return }
        
        let numberOfCards = Int(number) ?? 1
        demoVC.numberOfCards = numberOfCards
        present(demoVC, animated: true, completion: nil)
    }
    

    @IBAction func goBack(segue: UIStoryboardSegue) {
        
    }
}

