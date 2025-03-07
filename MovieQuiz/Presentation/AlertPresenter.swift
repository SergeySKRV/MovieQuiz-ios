//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Сергей Скориков on 08.02.2025.
//
import Foundation
import UIKit

final class AlertPresenter {
    //MARK: - Private Properties
    weak var viewController: UIViewController?
    
    //MARK: - Initialization
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    //MARK: - Public Methods
    func showResultsAlert(_ alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: alertModel.buttonText,
            style: .default
        ) { alertAction in alertModel.completion(alertAction) }
        
        guard let viewController else { return }
        alert.view.accessibilityIdentifier = "Game results"
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
}
