//
//  MultipeerSettingsViewController.swift
//  NearbyInteraction-Sandbox
//
//  Created by Eduard on 15.08.2022.
//

import UIKit

protocol MultipeerSettingsViewControllerDelegate: AnyObject {
    func didChangeStateVisibility(isHidden: Bool)
    func didChangeDistanceVisibility(isHidden: Bool)
}

final class MultipeerSettingsViewController: UIViewController {
    public weak var delegate: MultipeerSettingsViewControllerDelegate?
}
