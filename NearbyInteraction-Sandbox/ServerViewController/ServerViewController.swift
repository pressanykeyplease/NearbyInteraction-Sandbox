//
//  ServerViewController.swift
//  NearbyInteraction-Sandbox
//
//  Created by Eduard on 09.06.2022.
//

import NearbyInteraction
import UIKit

final class ServerViewController: UIViewController {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        nearbySession.delegate = self
        uploadDiscoveryToken { [weak self] in
            self?.fetchDiscoveryTokens()
        }
    }

    // MARK: - Private properties
    private let nearbySession = NISession()
    private var nearbyObjects: [NINearbyObject] = []
}

// MARK: - Private methods
private extension ServerViewController {
    func uploadDiscoveryToken(completion: @escaping () -> Void) {
        guard let discoveryToken = nearbySession.discoveryToken,
              let data = try? NSKeyedArchiver.archivedData(withRootObject: discoveryToken, requiringSecureCoding: true) else { return }
        APIManager.shared.uploadDiscoveryToken(data, completion: completion)
    }

    func fetchDiscoveryTokens() {
        APIManager.shared.fetchDiscoveryTokens { tokens in
            tokens.filter({
                $0 != self.nearbySession.discoveryToken
            }).forEach { token in
                let config = NINearbyPeerConfiguration(peerToken: token)
                self.nearbySession.run(config)
            }
        }
    }
}

// MARK: - NISessionDelegate
extension ServerViewController: NISessionDelegate {
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        print("Nearby objects: \(nearbyObjects.map({ $0.distance }))")
    }
}
