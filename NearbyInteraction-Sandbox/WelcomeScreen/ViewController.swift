//
//  ViewController.swift
//  NearbyInteraction-Sandbox
//
//  Created by Eduard on 09.06.2022.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // MARK: - Actions
    @IBAction func didTapMultipeerButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MultipeerViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MultipeerViewController") as! MultipeerViewController
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func didTapServerButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "ServerViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ServerViewController") as! ServerViewController
        navigationController?.pushViewController(vc, animated: true)
    }
}

