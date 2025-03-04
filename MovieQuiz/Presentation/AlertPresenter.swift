//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Сергей Скориков on 08.02.2025.
//
import Foundation
import UIKit

final class AlertPresenter {
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    func present (alertModel: AlertModel) {
        guard let viewController else { return }
        
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: alertModel.buttonText,
            style: .default
        )  { _ in
            alertModel.completion()
        }
        
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
}
