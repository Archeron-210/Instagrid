
import UIKit

class LayoutOptionView: UIView {

    // MARK: - Outlets

    @IBOutlet var layoutOneButton: UIButton!
    @IBOutlet var layoutOneSelected: UIImageView!
    @IBOutlet var layoutTwoButton: UIButton!
    @IBOutlet var layoutTwoSelected: UIImageView!
    @IBOutlet var layoutThreeButton: UIButton!
    @IBOutlet var layoutThreeSelected: UIImageView!

    // MARK: - Keys

    private enum Keys: String {
        // all strings used in this class are stocked here to avoid errors:
        case layout1 = "layout1"
        case layout2 = "layout2"
        case layout3 = "layout3"
        case style = "style"
        case name = "LayoutStyle"
    }

    // MARK: - Functions

    // all buttons are connected to this method, the switch allows to determine which button does what :
    @IBAction func selectLayout(_ sender: UIButton) {
        // notifies which sender has been tapped :
        switch sender {
        case layoutOneButton:
            createAndPostNotification(key: .style, value: .layout1)
            setLayoutStyle(style: .layout1)
        case layoutTwoButton:
            createAndPostNotification(key: .style, value: .layout2)
            setLayoutStyle(style: .layout2)
        case layoutThreeButton:
            createAndPostNotification(key: .style, value: .layout3)
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

    // MARK: - Private

    private func createAndPostNotification(key: Keys, value: Keys) {
        let name = Notification.Name(rawValue: Keys.name.rawValue)
        let notification = Notification(name: name, object: nil, userInfo: [key.rawValue: value.rawValue])
        NotificationCenter.default.post(notification)
    }
}
