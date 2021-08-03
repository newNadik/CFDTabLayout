//
//  ViewController.swift
//  TabLayoutExample
//
//  Created by Nadiia Ivanova on 31/07/2021.
//

import UIKit
import CFDTabLayout

class ViewController: UIViewController {

    @IBOutlet weak var tabLayout: CFDTabLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabLayout.delegate = self
        // Do any additional setup after loading the view.
    }


}

extension ViewController: CFDTabLayoutProtocol {
    
    func numberOfPages(in tabLayout: CFDTabLayout) -> Int {
        return 5
    }
        
    func tabLayout(_ tabLayout: CFDTabLayout, viewControllerAt index: Int) -> UIViewController {
        let vc = UIViewController()
        switch index {
        case 0:
            vc.view.backgroundColor = .orange
            break
        case 1:
            vc.view.backgroundColor = .yellow
            break
        case 2:
            vc.view.backgroundColor = .green
            break
        case 3:
            vc.view.backgroundColor = .blue
            break
        case 4:
            vc.view.backgroundColor = .purple
            break
        default:
            break
        }
        return vc
    }
        
    func tabLayout(_ tabLayout: CFDTabLayout, titleAt index: Int) -> String {
        return "Tab \(index + 1)"
    }
}
