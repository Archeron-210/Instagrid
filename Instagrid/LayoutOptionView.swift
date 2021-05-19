
import UIKit

class LayoutOptionView: UIView {

    @IBOutlet var layoutOneButton: UIButton!
    @IBOutlet var layoutOneSelected: UIImageView!
    @IBOutlet var layoutTwoButton: UIButton!
    @IBOutlet var layoutTwoSelected: UIImageView!
    @IBOutlet var layoutThreeButton: UIButton!
    @IBOutlet var layoutThreeSelected: UIImageView!
    
    // tous les boutons sont connectés à cette même méthode, on effectue un switch pour déterminer
    // quel bouton doit avoir quel effet :
    @IBAction func selectLayout(_ sender: UIButton) {
        switch sender {
        case layoutOneButton:
            // la notification qui sera envoyée au controller :
            let name = Notification.Name(rawValue: "LayoutStyle1")
            let notification = Notification(name: name)
            NotificationCenter.default.post(notification)
            setLayoutStyle(style: .layout1)
        case layoutTwoButton:
            let name = Notification.Name(rawValue: "LayoutStyle2")
            let notification = Notification(name: name)
            NotificationCenter.default.post(notification)
            setLayoutStyle(style: .layout2)
        case layoutThreeButton:
            let name = Notification.Name(rawValue: "LayoutStyle3")
            let notification = Notification(name: name)
            NotificationCenter.default.post(notification)
            setLayoutStyle(style: .layout3)
        default:
            break
        }
    }
    
    func setLayoutStyle(style: Style) {
        switch style {
        case .layout1:
            layoutOneSelected.isHidden = false
            layoutTwoSelected.isHidden = true
            layoutThreeSelected.isHidden = true
        case .layout2:
            layoutTwoSelected.isHidden = false
            layoutOneSelected.isHidden = true
            layoutThreeSelected.isHidden = true
        case .layout3:
            layoutThreeSelected.isHidden = false
            layoutTwoSelected.isHidden = true
            layoutOneSelected.isHidden = true
            
        }
    }
}
