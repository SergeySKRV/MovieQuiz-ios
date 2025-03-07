//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Сергей Скориков on 08.02.2025.
//

import Foundation
import UIKit

struct AlertModel {
    //MARK: - Public Properties
    let title: String
    let message: String
    let buttonText: String
    let completion: (UIAlertAction) -> Void
}
