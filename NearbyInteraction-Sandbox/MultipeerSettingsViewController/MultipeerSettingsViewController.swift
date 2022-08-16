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
    // MARK: - IBOutlets
    @IBOutlet private var connectionStateSwitch: UISwitch!
    @IBOutlet private var distanceSwitch: UISwitch!

    // MARK: - Public
    public weak var delegate: MultipeerSettingsViewControllerDelegate?

    func configure(connectionStateVisible: Bool, distanceStateVisible: Bool) {
        connectionStateSwitch.isOn = connectionStateVisible
        distanceSwitch.isOn = distanceStateVisible
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        connectionStateSwitch.addTarget(self, action: #selector(didTapConnectionSwitch(_:)), for: .valueChanged)
        distanceSwitch.addTarget(self, action: #selector(didTapDistanceSwitch(_:)), for: .valueChanged)
    }

    // MARK: - Actions
    @objc func didTapConnectionSwitch(_ control: UISwitch) {
        delegate?.didChangeStateVisibility(isHidden: !control.isOn)
    }

    @objc func didTapDistanceSwitch(_ control: UISwitch) {
        delegate?.didChangeDistanceVisibility(isHidden: !control.isOn)
    }
}
