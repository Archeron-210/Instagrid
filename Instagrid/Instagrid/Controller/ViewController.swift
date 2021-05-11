//
//  ViewController.swift
//  Instagrid
//
//  Created by Archeron on 03/05/2021.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var swipeLabel: UILabel!
    @IBOutlet weak var layoutOneButton: UIButton!
    @IBOutlet weak var layoutTwoButton: UIButton!
    @IBOutlet weak var layoutThreeButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orientationChange()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        orientationChange()
    }
    
    private func orientationChange() {
        if UIDevice.current.orientation.isLandscape {
            arrowImage.image = #imageLiteral(resourceName: "Arrow Left")
            swipeLabel.text = "Swipe left to share"
        }
        else {
            arrowImage.image = #imageLiteral(resourceName: "Arrow Up")
            swipeLabel.text = "Swipe up to share"
        }
    }

}

