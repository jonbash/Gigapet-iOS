//
//  NetworkResultHandler.swift
//  Gigapet
//
//  Created by Jon Bash on 2020-01-10.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation
import NetworkHandler

typealias NetworkCompletion = (NetworkError?) -> Void

struct NetworkResultHandler {
    private let localHandler: (
        Result<[FoodEntryRepresentation], NetworkError>,
        NetworkCompletion
        ) -> Void
    private let completion: NetworkCompletion

    init(
        handler: @escaping (
            Result<[FoodEntryRepresentation], NetworkError>,
            NetworkCompletion)
        -> Void,
        completion: @escaping NetworkCompletion
    ) {
        self.localHandler = handler
        self.completion = completion
    }

    func handleResults(_ result: Result<[FoodEntryRepresentation], NetworkError>) {
        localHandler(result, completion)
    }
}
