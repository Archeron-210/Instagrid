
import UIKit
import Photos

class ViewController: UIViewController {
    
    // MARK: - Outlets

    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var swipeLabel: UILabel!
    @IBOutlet weak var layoutView: LayoutView!
    @IBOutlet weak var layoutOptions: LayoutOptionView!

    // MARK: - Property

    private var selectedButton: UIButton?
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orientationChange()
        setDefaultStyle()
        createSwipeUpWithActionAndDirection()
        createSwipeLeftWithActionAndDirection()

        // Notifications observer:
        let name = Notification.Name(rawValue: "LayoutStyle")
        NotificationCenter.default.addObserver(self, selector: #selector(selectLayout(_:)), name: name, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // ask user authorization to access their library:
        PHPhotoLibrary.requestAuthorization { (status) in
            // nothing is done with it for now.
        }
    }

    // allows to adapt interface elements style with device orientation:
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        orientationChange()
    }

    // MARK: - Action

    // all buttons are linked to this action:
    @IBAction func buttonTapped(_ sender: UIButton) {
        // selected button takes the sender as its value:
        selectedButton = sender
        // create a UIImagePickerController:
        let picker = UIImagePickerController()
        // declare ViewController as picker's delegate :
        picker.delegate = self
        // display picker:
        self.present(picker, animated: true)
    }

    // MARK: - Private

    // called when notification is observed, allows to display the correct layout from chosen style with a switch:
    @objc private func selectLayout(_ notification: Notification) {
        if let style = notification.userInfo?["style"] as? String {
            switch style {
            case "layout1":
                layoutView.setStyle(.layout1)
            case "layout2":
                layoutView.setStyle(.layout2)
            case "layout3":
                layoutView.setStyle(.layout3)
            default:
                return
            }
        }
    }

    private func setDefaultStyle() {
        layoutView.setStyle(.layout1)
        layoutOptions?.setLayoutStyle(style: .layout1)
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

    private func shareImage() {
        // check authorization to save images:
        guard checkAuthorizationStatus() else {
            reverseTranslation()
            return
        }
        // stock what should be exported:
        let activityItems = [exportImage()]
        // instanciate UIActivityViewController with items to export in its parameters, appilcationActivities is nil to display default option that can share images:
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        // add in a closure the return animation of the view to its initial position:
        activityController.completionWithItemsHandler = { activity, completed, items, error in
            self.reverseTranslation()
            self.successAlert()
        }
        // and display:
        self.present(activityController, animated: true)
    }
    
    private func checkAuthorizationStatus() -> Bool {
        let readWriteStatus = PHPhotoLibrary.authorizationStatus()
        switch readWriteStatus {
        case .notDetermined:
            accessAlert()
            return false
        case .authorized:
            return true
        default:
            needAccessAlert()
            return false
        }
    }

    // allows to transform layoutView in a UIImage to export:
    private func exportImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: layoutView.bounds.size)
        let image = renderer.image { ctx in
            layoutView.drawHierarchy(in: layoutView.bounds, afterScreenUpdates: true)
        }
        return image
    }
    


    // MARK: - Gestures & Translations

    private func createSwipeUpWithActionAndDirection() {
        // create gesture with action:
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp(_:)))
        // give direction of swipe:
        swipeUp.direction = .up
        // add gesture to the view:
        layoutView.addGestureRecognizer(swipeUp)
    }

    private func createSwipeLeftWithActionAndDirection() {
        // create gesture with action:
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        // give direction of swipe:
        swipeLeft.direction = .left
        // add gesture to the view:
        layoutView.addGestureRecognizer(swipeLeft)
    }

    @objc private func swipeUp(_ sender: UISwipeGestureRecognizer) {
        if UIDevice.current.orientation.isPortrait {
            UIView.animate(withDuration: 0.5) {
               // translation calculus:
                let translationY = -(self.view.bounds.height/2 + self.layoutView.bounds.height/2)
                // the translation itself:
                self.layoutView.transform = CGAffineTransform(translationX: 0, y: translationY)
            } completion: { (success) in
                self.shareImage()
            }
        }
    }

    @objc private func swipeLeft(_ sender: UISwipeGestureRecognizer) {
        if UIDevice.current.orientation.isLandscape {
            UIView.animate(withDuration: 0.5) {
                // translation calculus:
                let translationX = -(self.view.bounds.width/2 + self.layoutView.bounds.width/2)
                // the translation itself:
                self.layoutView.transform = CGAffineTransform(translationX: translationX, y: 0)
            } completion: { (success) in
                self.shareImage()
            }
        }
    }

    // give the view its initial position :
    private func reverseTranslation() {
        UIView.animate(withDuration: 0.5) {
            self.layoutView.transform = .identity
        }
    }

    // MARK: - Alerts

    private func successAlert() {
        let alert = UIAlertController(title: "✓", message: "Success !", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    private func accessAlert() {
        let alertController = UIAlertController(title: "⚠︎", message: "We need access to your gallery", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            PHPhotoLibrary.requestAuthorization { (status) in }
        }))
        present(alertController, animated: true, completion: nil)
    }

    private func needAccessAlert() {
        let alertController = UIAlertController(title: "Authorization denied", message: "Go to Settings > Instagrid and grant access to your photos to continue", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { (action) in
            // allows to go directly in user's phone parameters:
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }))
        present(alertController, animated: true, completion: nil)
    }
}

    // MARK: - ImagePicker management

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey:Any]) {
        // check and unwrap the image chosen by the user:
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        // change the content mode of the button's image:
        selectedButton?.imageView?.contentMode = .scaleAspectFill
        // set chosen image in button's image:
        selectedButton?.setImage(image, for: .normal)
        // then selectedButton value is passed as nil to avoid mistakes:
        selectedButton = nil
        // dissmiss th picker:
        picker.dismiss(animated: true)
    }
}
