//
//  APIManager.swift
//  NearbyInteraction-Sandbox
//
//  Created by Eduard on 09.06.2022.
//

import Alamofire
import NearbyInteraction

final class APIManager {
    static let shared = APIManager()

    // MARK: - Public
    func uploadDiscoveryToken(_ token: Data, completion: @escaping () -> Void) {
        AF.upload(token, to: url).responseDecodable(of: String.self) { _ in
            completion()
        }
    }

    func fetchDiscoveryTokens(completion: @escaping ([NIDiscoveryToken]) -> ()) {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let stringArray = try? JSONDecoder().decode([String].self, from: data) else { return }
            let tokens = stringArray
                .compactMap { Data(base64Encoded: $0) }
                .compactMap { try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: $0) }
            completion(tokens)
        }
        task.resume()
    }

    func deleteTokens(completion: @escaping() -> ()) {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "DELETE"
        let task = URLSession.shared.dataTask(with: request) { _, _, _ in
            completion()
        }
        task.resume()
    }

    // MARK: - Private
    private let url = "https://test"
}

