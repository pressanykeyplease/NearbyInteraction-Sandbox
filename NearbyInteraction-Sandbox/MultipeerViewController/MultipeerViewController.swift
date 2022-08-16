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
    @IBOutlet private var statusLabel: UILabel!
    @IBOutlet private var distanceLabel: UILabel!
    @IBOutlet private var tapButton: UIButton!
    @IBOutlet private var cancelButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"), style: .plain, target: self, action: #selector(didTapSettingsButton))
        peerID = MCPeerID(displayName: deviceName)
        multipeerSession = MCSession(peer: getPeerID(), securityIdentity: nil, encryptionPreference: .none)
        multipeerSession?.delegate = self
        startBrowser()
    }

    // MARK: - Actions
    @IBAction func didTapActionButton(_ sender: Any) {
        sharedTokenWithPeer = false
        stopBrowsingAndAdvertising()
        isSender = true
        startAdvertiser()
    }

    @IBAction func didTapCancelButton(_ sender: Any) {
        if let connectedPeer = multipeerSession?.connectedPeers.first {
            multipeerSession?.cancelConnectPeer(connectedPeer)
            multipeerSession?.disconnect()
        }
        if nearbySession != nil {
            nearbySession?.invalidate()
            nearbySession = nil
        }
        stopBrowsingAndAdvertising()
        startBrowser()
        isSender = false
    }

    @objc func didTapSettingsButton() {
        let storyboard = UIStoryboard(name: "MultipeerSettingsViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MultipeerSettingsViewController") as! MultipeerSettingsViewController
        vc.delegate = self
        present(vc, animated: true, completion: nil)
        vc.configure(connectionStateVisible: !statusLabel.isHidden, distanceStateVisible: !distanceLabel.isHidden)
    }
    
    // MARK: - Private constants
    let serviceType = "nisandbox"
    let nearbyTresholdDistance: Float = 0.15

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
    var isSender = false
}

// MARK: - Private methods
private extension MultipeerViewController {
    func startAdvertiser() {
        advertiser = MCNearbyServiceAdvertiser(peer: getPeerID(), discoveryInfo: nil, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
        style(for: .advertising)
    }

    func startBrowser() {
        browser = MCNearbyServiceBrowser(peer: getPeerID(), serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
        style(for: .browsing)
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

    func send(message: SandboxDTO) {
        guard let connectedPeersCount = multipeerSession?.connectedPeers.count,
              let connectedPeers = multipeerSession?.connectedPeers,
              let messageData = try? JSONEncoder().encode(message),
              connectedPeersCount > 0 else {
            return
        }
        do {
            try self.multipeerSession?.send(messageData, toPeers: connectedPeers, with: .reliable)
        } catch { }
    }

    func peerDidShareDiscoveryToken(peer: MCPeerID, token: NIDiscoveryToken) {
        if isSender {
            let config = NINearbyPeerConfiguration(peerToken: token)
            guard nearbySession != nil else { fatalError("Nearby session is nil") }
            nearbySession?.run(config)
        } else {
            let config = NINearbyPeerConfiguration(peerToken: token)
            nearbySession = NISession()
            nearbySession?.delegate = self
            nearbySession?.run(config)
            guard let discoveryToken = nearbySession?.discoveryToken else { fatalError("Discovery token not exist") }
            send(discoveryToken)
        }
    }

    func isNearby(_ distance: Float) -> Bool {
        distance <= nearbyTresholdDistance
    }
}

// MARK: - Style
private extension MultipeerViewController {
    func style(for state: MultipeerConnectionState) {
        DispatchQueue.main.async {
            switch state {
            case .browsing:
                self.styleForBrowsingState()
            case .advertising:
                self.styleForAdvertisingState()
            case .connecting:
                self.styleForConnectingState()
            case .connected:
                self.styleForConnectedState()
            }
        }
    }

    func styleForBrowsingState() {
        statusLabel.text = ""
        statusLabel.textColor = .black
        tapButton.isHidden = false
        cancelButton.isHidden = true
    }

    func styleForAdvertisingState() {
        statusLabel.text = "Searching for device"
        statusLabel.textColor = .black
        tapButton.isHidden = true
        cancelButton.isHidden = false
    }

    func styleForConnectingState() {
        guard isSender else { return }
        statusLabel.text = "Connecting to device"
        statusLabel.textColor = .orange
        tapButton.isHidden = true
        cancelButton.isHidden = false
    }

    func styleForConnectedState() {
        guard isSender else { return }
        statusLabel.text = "Connected to device. Tap to pass data."
        statusLabel.textColor = .green
        tapButton.isHidden = true
        cancelButton.isHidden = false
    }
}

// MARK: - MCSessionDelegate
extension MultipeerViewController: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        addPeer(name: peerID.displayName)
        switch state {
        case .connected:
            if isSender {
                nearbySession = NISession()
                nearbySession?.delegate = self
                guard let discoveryToken = nearbySession?.discoveryToken else {
                    fatalError("Discovery token not exist")
                }
                if !sharedTokenWithPeer {
                    send(discoveryToken)
                }
            } else {
            }
            style(for: .connected)
        case .connecting:
            style(for: .connecting)
        case .notConnected:
            style(for: .browsing)
        @unknown default:
            break
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let discoveryToken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data) {
            peerDidShareDiscoveryToken(peer: peerID, token: discoveryToken)
        } else if let dto = try? JSONDecoder().decode(SandboxDTO.self, from: data) {
            switch dto.type {
            case .messageTransferType:
                showAlert(title: "Tapped by \(dto.info ?? "unknown")")
                send(message: SandboxDTO(type: .messageReceivedConfirmation, info: deviceName))
                nearbySession?.invalidate()
                nearbySession = nil
                stopBrowsingAndAdvertising()
                startBrowser()
            case .messageReceivedConfirmation:
                showAlert(title: "Tapped \(dto.info ?? "unknown")")
                nearbySession?.invalidate()
                nearbySession = nil
                stopBrowsingAndAdvertising()
                startBrowser()
            }
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
        distanceLabel.text = String(format:"%.2f m", distance)
        if isNearby(distance), isSender {
            send(message: SandboxDTO(type: .messageTransferType, info: deviceName))
            isSender = false
        }
    }
}

// MARK: - MultipeerSettingsViewControllerDelegate
extension MultipeerViewController: MultipeerSettingsViewControllerDelegate {
    func didChangeStateVisibility(isHidden: Bool) {
        statusLabel.isHidden = isHidden
    }

    func didChangeDistanceVisibility(isHidden: Bool) {
        distanceLabel.isHidden = isHidden
    }
}
