
import UIKit
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var swipeLabel: UILabel!
    @IBOutlet weak var layoutView: LayoutView!
    @IBOutlet weak var layoutOptions: LayoutOptionView!
    
    // on créé une variable selectedButton qui est un UIButton et qui représente le bouton sur lequel on a appuyé :
    private var selectedButton: UIButton?
    
    
    // MARK: - Lifecycle
    
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
        // on reçoit ici la notification :
        let name = Notification.Name(rawValue: "LayoutStyle")
        NotificationCenter.default.addObserver(self, selector: #selector(selectLayout(_:)), name: name, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         // on demande l'autorisation a l'utilisateur d'acceder a ses photos
        PHPhotoLibrary.requestAuthorization { (status) in
            // on ne fait rien avec cette autorisation pour le moment.
        }
    }
    
    // fonction qui permet d'adapter les éléments d'interface suivant l'orientation de l'appareil :
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        orientationChange()
    }
    
    
    // MARK: - Actions
    

    // Fonction appelée quand on reçoit la notification émise du LayoutOptionView,
    // qui va permettre d'afficher le layout selon le style choisi grâce à un switch :
    @objc func selectLayout(_ notification: Notification) {
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
    
    // tous les boutons font la même chose, ils sont tous reliés à cette action :
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
                // la translation s'applique a partir du centre de layoutView.
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
    
    
    // MARK: - UIImagePickerControllerDelegate
    
    // fonction du protocole appelée par le picker qui prend en paramètre le picker et un dictionnaire clé/valeur :
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // on créé une variable image dans laquelle on déballe l'image choisie par l'utilisateur
        // s'il y a bien une image :
        if let image = info[.originalImage] as? UIImage {
            // on change le mode d'affichage de l'image du bouton en scaleAspectFill
            selectedButton?.imageView?.contentMode = .scaleAspectFill
            // on set l'image selectionnée sur le bouton pour qu'il l'affiche en état normal :
            selectedButton?.setImage(image, for: .normal)
            // on repasse la valeur de selectedButton a nil pour éviter les erreurs sur un bouton
            // précédemment séléctionné :
            selectedButton = nil
            // on enlève le picker avec son animation de dismiss :
            picker.dismiss(animated: true)
        }
    }
    
    
    // MARK: - Private func
    
    // le style par défaut :
    private func setDefaultStyle() {
        layoutView.setStyle(.layout1)
        layoutOptions?.setLayoutStyle(style: .layout1)
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
    
    // fonction qui va permettre le partage sur les réseaux sociaux :
    private func shareImage() {
        // on vérifie la permission d'enregistrer des images et
        // on stocke le resultat true ou false dans canSaveImage :
        let canSaveImage = checkAuthorizationStatus()
        // si c'est false, on lance l'animation de retour et on sort avec return :
        if canSaveImage == false {
            reverseTranslation()
            return
        }
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
        // on l'affiche :
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
    
    // alerte qui indique à l'utilisateur qu'on a besoin des droits :
    private func accessAlert() {
        let alertController = UIAlertController(title: "Warning", message: "We need access to your gallery", preferredStyle: .alert)
        // on créé le bouton qui va ensuite masquer l'alerte et demander les autorisations :
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            PHPhotoLibrary.requestAuthorization { (status) in }
        }))
        // on l'affiche :
        present(alertController, animated: true, completion: nil)
    }
    
    // alerte qui indique à l'utilisateur qu'il manque les autorisations nécessaires :
    private func needAccessAlert() {
        let alertController = UIAlertController(title: "Authorization denied", message: "Go to Settings > Instagrid and grant access to your photos to continue", preferredStyle: .alert)
        // on créé le bouton qui va envoyer l'utilisateur dans ses paramètres et ensuite masquer l'alerte :
        alertController.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { (action) in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }))
        // on l'affiche :
        present(alertController, animated: true, completion: nil)
    }
    
    // fonction qui permet de transformer notre layoutView en une image à exporter :
    private func exportImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: layoutView.bounds.size)
        let image = renderer.image { ctx in
            layoutView.drawHierarchy(in: layoutView.bounds, afterScreenUpdates: true)
        }
        return image
    }
    
    // fonction qui rend à la vue sa position initiale :
    private func reverseTranslation() {
        UIView.animate(withDuration: 0.5) {
            self.layoutView.transform = .identity
        }
    }
}
