//
//  NetworkMockingSession.swift
//  NetworkHandler
//
//  Created by Michael Redig on 6/17/19.
//  Copyright © 2019 Red_Egg Productions. All rights reserved.
//

import Foundation
import NetworkHandler

struct NetworkMockingSession: NetworkLoader {

	// MARK: - Properties
	let mockData: Data?
	let mockError: Error?
	let mockResponseCode: Int
	var mockDelay: TimeInterval

	// MARK: - Init
	init(mockData: Data?, mockError: Error?, mockResponseCode: Int = 200, mockDelay: TimeInterval = 0.1) {
		self.mockData = mockData
		self.mockError = mockError
		self.mockResponseCode = mockResponseCode
		self.mockDelay = mockDelay
	}

	// MARK: - Public
	public func loadData(with request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask? {
		guard let url = request.url else { completion(nil, nil, nil); return nil }
		let mockResponse = HTTPURLResponse(url: url, statusCode: mockResponseCode, httpVersion: "HTTP/2", headerFields: nil)

		DispatchQueue.global().asyncAfter(deadline: .now() + mockDelay) {
			completion(self.mockData, mockResponse, self.mockError)
		}

		return nil
	}
}

// MARK: - Network Controller

extension NetworkController {
    func mockData() throws -> Data {
        let previousDate = Date().incremented(false, by: .month)
        let mockEntryReps = [
            FoodEntryRepresentation(
                foodCategory: .vegetable,
                foodName: "Celery sticks",
                foodAmount: 5,
                dateFed: Date(),
                identifier: 1),
            FoodEntryRepresentation(
                foodCategory: .treats,
                foodName: "Cake",
                foodAmount: 1,
                dateFed: Date(),
                identifier: 2),
            FoodEntryRepresentation(
                foodCategory: .fruit,
                foodName: "Apple",
                foodAmount: 2,
                dateFed: Date(),
                identifier: 3),
            FoodEntryRepresentation(
                foodCategory: .wholeGrains,
                foodName: "Oatmeal",
                foodAmount: 2,
                dateFed: Date(),
                identifier: 4),
            FoodEntryRepresentation(
                foodCategory: .meat,
                foodName: "Steak",
                foodAmount: 2,
                dateFed: previousDate,
                identifier: 5)
        ]
        return try JSONEncoder().encode(mockEntryReps)
    }
}
