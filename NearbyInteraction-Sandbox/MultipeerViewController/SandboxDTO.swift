//
//  SandboxDTO.swift
//  NearbyInteraction-Sandbox
//
//  Created by Eduard on 10.08.2022.
//

struct SandboxDTO: Codable {
    let type: SandboxDTOOperationType
    let description: String?
}

enum SandboxDTOOperationType: String, Codable {
    case paymentTransferMessage
    case messageReceivedConfirmation
}
