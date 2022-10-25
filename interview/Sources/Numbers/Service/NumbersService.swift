//
//  NumbersService.swift
//  interview
//
//  Created by juan ledesma on 09/03/2022.
//

import Foundation

final class NumbersService {

    private let baseStringUrl = "http://numbersapi.com/"

    func getNumberFactFromApi(for input: Int, completion: @escaping (String?) -> Void) {

        let requestUrl = URL(string: (baseStringUrl + "\(input)"))
        guard let url = requestUrl else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) {(data, _, _) in
            guard let data = data else {
                completion(nil)
                return
            }

            let numbersStringResult = String(decoding: data, as: UTF8.self)
            completion(numbersStringResult)

        }.resume()
    }
}
