//
//  ViewModel.swift
//
//
//  Created by Vadim Marchenko on 09.04.2024.
//

import Foundation

protocol Viewable: ObservableObject {
    associatedtype T where T: ViewModel
    var viewModel: T { get }
}

protocol ViewModel { }