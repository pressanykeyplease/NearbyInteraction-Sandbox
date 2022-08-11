//
//  UIViewController+alert.swift
//  NearbyInteraction-Sandbox
//
//  Created by Eduard on 16.06.2022.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message ?? "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
