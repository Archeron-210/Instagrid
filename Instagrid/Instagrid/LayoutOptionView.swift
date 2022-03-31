
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
        // on créé le nom de la notification qui va être envoyée au controller :
        let name = Notification.Name(rawValue: "LayoutStyle")
        switch sender {
        case layoutOneButton:
            // on créé la notification en attribuant la clé "style" à la valeur "layout1", puis on la poste :
            let notification = Notification(name: name, object: nil, userInfo: ["style": "layout1"])
            NotificationCenter.default.post(notification)
            setLayoutStyle(style: .layout1)
        case layoutTwoButton:
            // la même chose ici puis pour le 3eme cas :
            let notification = Notification(name: name, object: nil, userInfo: ["style": "layout2"])
            NotificationCenter.default.post(notification)
            setLayoutStyle(style: .layout2)
        case layoutThreeButton:
            let notification = Notification(name: name, object: nil, userInfo: ["style": "layout3"])
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
