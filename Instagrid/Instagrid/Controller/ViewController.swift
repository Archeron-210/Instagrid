
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
        // on créé le geste Swipe Up en précisant la target, et l'action à réaliser,
        // puis la direction du swipe, et on ajoute le geste :
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp(_:)))
        swipeUp.direction = .up
        layoutView.addGestureRecognizer(swipeUp)
        // pareil pour Swipe Left :
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        swipeLeft.direction = .left
        layoutView.addGestureRecognizer(swipeLeft)
    }
    // fonction qui permet d'adapter les éléments d'interface suivant l'orientation du device :
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        orientationChange()
    }
    // fonction qui s'execute au changement d'orientation :
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
    // le style par défaut :
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
    // fonction qui rend à la vue sa position initiale :
    func reverseTranslation() {
        UIView.animate(withDuration: 0.5) {
            self.layoutView.transform = .identity
        }
    }
    // fonction qui va permettre le partage sur les réseaux sociaux :
    func shareImage() {
        // on stocke déjà ce que l'on veut exporter :
        let activityItems = [exportImage()]
        // puis on créé une instance de UIActivityViewController qui prend en paramètre
        // ce que l'on souhaite partager, et les supports de partages désirés,
        // ici à nil pour obtenir les options automatiques qui peuvent partager des images :
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        // on précise ensuite dans une closure l'action à réaliser quand le partage a été effectué,
        // ici l'animation de retour :
        activityController.completionWithItemsHandler = { activity, completed, items, error in
            self.reverseTranslation()
        }
        self.present(activityController, animated: true)
    }
    
    // fonction qui permet de transformer notre layoutView en une image à exporter :
    func exportImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: layoutView.bounds.size)
        let image = renderer.image { ctx in
            layoutView.drawHierarchy(in: layoutView.bounds, afterScreenUpdates: true)
        }
        return image
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
