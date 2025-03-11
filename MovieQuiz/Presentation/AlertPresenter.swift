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
    func showResultsAlert(alert model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: model.buttonText,
            style: .default,
            handler: { _ in model.completion()}
        )
        
        guard let viewController else { return }
        alert.view.accessibilityIdentifier = "Game results"
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
}
