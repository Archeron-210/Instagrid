
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var swipeLabel: UILabel!
    @IBOutlet weak var layoutOneButton: UIButton!
    @IBOutlet weak var layoutOneSelected: UIImageView!
    @IBOutlet weak var layoutTwoButton: UIButton!
    @IBOutlet weak var layoutTwoSelected: UIImageView!
    @IBOutlet weak var layoutThreeButton: UIButton!
    @IBOutlet weak var layoutThreeSelected: UIImageView!
    @IBOutlet weak var layoutView: LayoutView!
    
    var tmpButton: UIButton?
    
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
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        tmpButton = sender
        let picker = UIImagePickerController()
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    @IBAction func selectLayout(_ sender: UIButton) {
        switch sender {
        case layoutOneButton:
            layoutView.setStyle(.layout1)
            layoutOneSelected.isHidden = false
            layoutTwoSelected.isHidden = true
            layoutThreeSelected.isHidden = true
        case layoutTwoButton:
            layoutView.setStyle(.layout2)
            layoutTwoSelected.isHidden = false
            layoutOneSelected.isHidden = true
            layoutThreeSelected.isHidden = true
        case layoutThreeButton:
            layoutView.setStyle(.layout3)
            layoutThreeSelected.isHidden = false
            layoutTwoSelected.isHidden = true
            layoutOneSelected.isHidden = true
        default:
            break
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            tmpButton?.setBackgroundImage(image, for: .normal)
            tmpButton = nil
            picker.dismiss(animated: true)
        }
    }
}

