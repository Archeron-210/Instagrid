
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
    
    // on créé une variable selectedButton qui est un UIButton et qui représente le bouton sur lequel on a appuyé :
    var selectedButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orientationChange()
        setDefaultStyle()
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp(_:)))
        swipeUp.direction = .up
        layoutView.addGestureRecognizer(swipeUp)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        swipeLeft.direction = .left
        layoutView.addGestureRecognizer(swipeLeft)
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
    
    private func setDefaultStyle() {
        layoutView.setStyle(.layout1)
        layoutOneSelected.isHidden = false
        layoutTwoSelected.isHidden = true
        layoutThreeSelected.isHidden = true
    }
    
   // tous les boutons sont connectés à cette même méthode, on effectue un switch pour déterminer
    // quel bouton doit avoir quel effet :
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
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        // on précise que le sender est le bouton qui vient d'être tapé :
        selectedButton = sender
        // on créé une variable picker qui est un UIImagePickerController :
        let picker = UIImagePickerController()
        // on précise que le delegate du picker est bien notre ViewController avec self :
        picker.delegate = self
        // on présente sur la page le picker, et on active l'animation de son affichage :
        self.present(picker, animated: true)
    }
    
    @objc func swipeUp(_ sender: UISwipeGestureRecognizer) {
        if UIDevice.current.orientation.isPortrait {
            UIView.animate(withDuration: 0.5) {
                // le résultat du calcul pour faire disparaitre la LayoutView :
                // La translation en y = la taille de l'ecran divisée par 2 + la taille de la vue divisée par 2
                // On applique la translation a partir du centre de layoutView.
                let translationY = -(self.view.bounds.height/2 + self.layoutView.bounds.height/2)
                // on applique la translation :
                self.layoutView.transform = CGAffineTransform(translationX: 0, y: translationY)
            } completion: { (success) in
                self.shareImage()
            }
        }
    }
    
    @objc func swipeLeft(_ sender: UISwipeGestureRecognizer) {
        if UIDevice.current.orientation.isLandscape {
            UIView.animate(withDuration: 0.5) {
                // le résultat du calcul avec la translation en x cette fois pour faire disparaitre la LayoutView :
                let translationX = -(self.view.bounds.width/2 + self.layoutView.bounds.width/2)
                // on applique la translation :
                self.layoutView.transform = CGAffineTransform(translationX: translationX, y: 0)
            } completion: { (success) in
                self.shareImage()
            }
        }
    }
    
    func reverseTranslation() {
        UIView.animate(withDuration: 0.5) {
            self.layoutView.transform = .identity
        }
    }
    
    func shareImage() {
        let activityItems = [exportImage()]
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityController.completionWithItemsHandler = { activity, completed, items, error in
            self.reverseTranslation()
        }
        self.present(activityController, animated: true)
    }
    
    func exportImage() -> UIImage {
        // exporter le collage en une image
        return UIImage()
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    // fonction du protocole appelée par le picker qui prend en paramètre le picker et un dictionnaire clé/valeur :
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // on créé une variable image dans laquelle on déballe l'image choisie par l'utilisateur
        // s'il y a bien une image :
        if let image = info[.originalImage] as? UIImage {
            // on set l'image selectionnée sur le bouton pour qu'il l'affiche en état normal :
            selectedButton?.setBackgroundImage(image, for: .normal)
            // on repasse la valeur de selectedButton a nil pour éviter les erreurs sur un bouton
            // précédemment séléctionné :
            selectedButton = nil
            // on enlève le picker avec son animation de dismiss :
            picker.dismiss(animated: true)
        }
    }
}
