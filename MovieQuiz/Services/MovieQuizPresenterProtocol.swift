//
//  MovieQuizPresenterProtocol.swift
//  MovieQuiz
//
//  Created by Сергей Скориков on 06.03.2025.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    //MARK: - Public Methods
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    func changeStateButton(isEnabled: Bool)
}
