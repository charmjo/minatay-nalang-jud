//
//  Main.swift
//  Charm_Relator_FE_8905384
//
//  Created by Charm Johannes Relator on 2023-12-03.
//

import UIKit

class Main: UIViewController {
    // TODO: Put some constraints on this one
    
    // MARK: Globals
    var dest : String?;
    
    // MARK: External Events
    @IBAction func showDestinationPrompt(_ sender: Any) {
        showAlert()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//         Get the new view controller using segue.destination.
//         Pass the selected object to the new view controller.
        if segue.identifier == "goToNews" {
            guard let vc = segue.destination as? News else { return }
            vc.dest = dest;
        } else if segue.identifier == "goToDirections" {
            
        } else if segue.identifier == "goToWeather" {
            
        }
        
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func showAlert () {
        let alert = UIAlertController(title: "Where would you like to go?", message: "Please enter your destination", preferredStyle: .alert);
        alert.addTextField { field in
            field.placeholder = "Waterloo";
            field.returnKeyType = .continue;
        }
        alert.addAction(UIAlertAction(title: "News", style: .default, handler: { _ in
            guard self.segueToOtherView(alert.textFields,"goToNews") else {
                return;
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Directions", style: .default, handler: { _ in
            guard self.segueToOtherView(alert.textFields,"goToDirections") else {
                return;
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Weather", style: .default, handler: { _ in
            guard self.segueToOtherView(alert.textFields,"goToNews") else {
                return;
            }

        }))

        self.present(alert, animated: true)
    }
    
    func segueToOtherView (_ fields: [UITextField]?, _ ctrlIdentifier: String) -> Bool {
        guard let field = fields, field.count == 1 else {
            return false;
        }
        
        let txtLocField = field[0]
        guard let textLoc = txtLocField.text, !textLoc.isEmpty else {
            return false;
        }
        self.dest = textLoc;
        
        // TODO: segue action to News
        print(ctrlIdentifier)
        self.performSegue(withIdentifier: ctrlIdentifier, sender: self);
        
        
        
        return true;
    }

}
