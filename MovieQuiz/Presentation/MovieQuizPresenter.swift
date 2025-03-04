//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Сергей Скориков on 02.03.2025.
//
import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = .zero
    var currentQuestion: QuizQuestion?
    var correctAnswers: Int = .zero
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewController?
    var statisticService: StatisticServiceProtocol?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
        statisticService = StatisticServiceImplementation()

    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
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
    
   func didAnswer(isYes: Bool){
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
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
    
    
    
    func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            if let statisticService = statisticService {
                statisticService.store(correct: correctAnswers, total: questionsAmount)
                
                let gamesCount = statisticService.gamesCount
                let bestGame = statisticService.bestGame
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.YY HH:mm"
                
                let text = """
                            Ваш результат: \(correctAnswers)/\(questionsAmount)
                            Количество сыгранных квизов: \(gamesCount)
                            Ваш рекорд: \(bestGame.correct)/\(bestGame.total) (\(dateFormatter.string(from: bestGame.date)))
                            Средняя точность: (\(String(format: "%.2f", statisticService.totalAccuracy))%)
                        """
                
                let viewModel = QuizResultsViewModel(
                    title: "Этот раунд окончен",
                    text: text,
                    buttonText: "Сыграть еще раз")
                    viewController?.show(quiz: viewModel)
            }
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        viewController?.changeStateButton(isEnabled: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            viewController?.self.changeStateButton(isEnabled: true)
            self.proceedToNextQuestionOrResults()
            
        }
    }
}
