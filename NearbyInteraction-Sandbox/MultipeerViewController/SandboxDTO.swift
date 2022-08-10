//
//  SandboxDTO.swift
//  NearbyInteraction-Sandbox
//
//  Created by Eduard on 10.08.2022.
//

struct SandboxDTO: Codable {
    let version: String
    let type: SandboxDTOOperationType
    let amount: Float?
    let receiverID: String?
    let code: Int?
    let token: String?
}

enum SandboxDTOOperationType: String, Codable {
    case text
    case emoji
    case messageReceivedConfirmation
}
