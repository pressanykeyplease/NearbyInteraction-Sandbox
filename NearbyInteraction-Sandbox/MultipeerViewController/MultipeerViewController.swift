//
//  MultipeerViewController.swift
//  NearbyInteraction-Sandbox
//
//  Created by Eduard on 16.06.2022.
//

import MultipeerConnectivity
import NearbyInteraction
import UIKit

final class MultipeerViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet var distanceLabel: UILabel!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        nearbySession = NISession()
        nearbySession?.delegate = self
        peerID = MCPeerID(displayName: deviceName)
        multipeerSession = MCSession(peer: getPeerID(), securityIdentity: nil, encryptionPreference: .none)
        multipeerSession?.delegate = self
        startBrowser()
    }

    // MARK: - Actions
    @IBAction func didTapStartAdvertiser(_ sender: Any) {
        stopBrowsingAndAdvertising()
        startAdvertiser()
    }
    
    // MARK: - Private constants
    let serviceType = "nisandbox"

    // MARK: - Private
    var nearbySession: NISession?
    var multipeerSession: MCSession?
    var peerID: MCPeerID?
    var browser: MCNearbyServiceBrowser?
    var advertiser: MCNearbyServiceAdvertiser?
    let deviceName = UIDevice.current.name
    var peers: [MCPeerID] = []
    var connectedPeer: MCPeerID?
    var sharedTokenWithPeer = false
    var peerDisplayName: String?
}

// MARK: - Private methods
private extension MultipeerViewController {
    func startAdvertiser() {
        advertiser = MCNearbyServiceAdvertiser(peer: getPeerID(), discoveryInfo: nil, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    func startBrowser() {
        browser = MCNearbyServiceBrowser(peer: getPeerID(), serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }

    func stopBrowsingAndAdvertising() {
        if let unwrappedBrowser = browser {
            unwrappedBrowser.stopBrowsingForPeers()
        }
        if let unwrappedAdvertiser = advertiser {
            unwrappedAdvertiser.stopAdvertisingPeer()
        }
        multipeerSession?.disconnect()
    }

    func addPeer(name: String) {
        for peer in peers {
            if peer.displayName == name {
                return
            }
        }
        let newPeer = MCPeerID.init(displayName: name)
        peers.append(newPeer)
    }

    func getPeerID() -> MCPeerID {
        if let peerId = self.peerID {
            return peerId
        } else {
            let peerId = MCPeerID(displayName: deviceName)
            self.peerID = peerId
            return peerId
        }
    }

    func send(_ discoveryToken: NIDiscoveryToken) {
        guard let connectedPeersCount = multipeerSession?.connectedPeers.count,
              let connectedPeers = multipeerSession?.connectedPeers,
              let messageData = try? NSKeyedArchiver.archivedData(withRootObject: discoveryToken, requiringSecureCoding: true),
              connectedPeersCount > 0 else {
            return
        }
        do {
            try self.multipeerSession?.send(messageData, toPeers: connectedPeers, with: .reliable)
        } catch { }
    }

    func peerDidShareDiscoveryToken(peer: MCPeerID, token: NIDiscoveryToken) {
        let config = NINearbyPeerConfiguration(peerToken: token)
        guard nearbySession != nil else { fatalError("Nearby session is nil") }
        nearbySession?.run(config)
    }
}

// MARK: - MCSessionDelegate
extension MultipeerViewController: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        addPeer(name: peerID.displayName)
        switch state {
        case .connected:
            guard let discoveryToken = nearbySession?.discoveryToken else {
                fatalError("Discovery token not exist")
            }
            if !sharedTokenWithPeer {
                send(discoveryToken)
            }
        case .connecting:
            break
        case .notConnected:
            break
        @unknown default:
            break
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let discoveryToken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data) {
            peerDidShareDiscoveryToken(peer: peerID, token: discoveryToken)
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }

    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension MultipeerViewController: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, multipeerSession)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension MultipeerViewController: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        guard let unwrappedSession = multipeerSession else { return }
        browser.invitePeer(peerID, to: unwrappedSession, withContext: nil, timeout: 10.0)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
    }
}


// MARK: - NISessionDelegate
extension MultipeerViewController: NISessionDelegate {
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        guard let distance = nearbyObjects.first?.distance else { return }
        distanceLabel.text = String(distance)
    }
}
