//
//  NumbersViewModel.swift
//  interview
//
//  Created by juan ledesma on 09/03/2022.
//

import Foundation

class NumbersViewModel {
    private var numbersService: NumbersService

//    private(set) var numbersData: EmployeesResponse? {
//        didSet {
//            self.bindEmployeeViewModelToController()
//        }
//    }

//    var bindEmployeeViewModelToController : (() -> ()) = {}

    init() {
        self.numbersService = NumbersService()

    }

    func getNumberFactData(with input: Int, completion: @escaping (String?) -> Void) {
        numbersService.getNumberFactFromApi(for: input) { [weak self] result in
            completion(result)
        }
    }
}
