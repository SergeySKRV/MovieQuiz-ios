//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Сергей Скориков on 02.03.2025.
//
import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    //MARK: - Private Properties
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    private let statisticService: StatisticServiceProtocol!
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = .zero
    private var currentQuestion: QuizQuestion?
    private var correctAnswers: Int = .zero
    
    //MARK: - Initializers
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    //MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
            self?.viewController?.hideLoadingIndicator()
        }
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.hideLoadingIndicator()
        if let serviceError = error as? MoviesLoaderError {
            switch serviceError {
            case .invalidAPIKey:
                viewController?.showNetworkError(message: "Неверный API ключ. Обратитесь к администратору.")
            case .rateLimitExceeded:
                viewController?.showNetworkError(message: "Превышено количество запросов к серверу. Попробуйте позже.")
            case .serverError(let message):
                viewController?.showNetworkError(message: message ?? "Произошла ошибка на сервере.")
            case .emptyMoviesList:
                viewController?.showNetworkError(message: "Список фильмов пуст. Попробуйте еще раз.")
            case.imageLoadingFailed:
                viewController?.showNetworkError(message: "Не удалось загрузить изображение. Попробуйте еще раз.")
            }
        } else {
            viewController?.showNetworkError(message: error.localizedDescription)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didStartLoadingNextQuestion() {
        viewController?.showLoadingIndicator()
    }
    
    func didFinishLoadingNextQuestion(_ question: QuizQuestion?    ) {
        viewController?.hideLoadingIndicator()
    }
    
    //MARK: - Public Methods
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = .zero
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func makeResultsMessage() -> String {
          statisticService.store(correct: correctAnswers, total: questionsAmount)
          
          let bestGame = statisticService.bestGame
          
          let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
          let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
          let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total)"
          + " (\(bestGame.date.dateTimeString))"
          let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
          
          let resultMessage = [
              currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
          ].joined(separator: "\n")
          
          return resultMessage
      }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    //MARK: - Private Methods
    private func didAnswer(isYes: Bool){
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        viewController?.changeStateButton(isEnabled: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            viewController?.self.changeStateButton(isEnabled: true)
            self.proceedToNextQuestionOrResults()
        }
    }
    
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            let text = correctAnswers == self.questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}

