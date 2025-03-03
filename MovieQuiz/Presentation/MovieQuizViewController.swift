import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    //MARK: - Outlets
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    //MARK: - Properties
    private let presenter = MovieQuizPresenter()
    private var correctAnswers: Int = .zero
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol?
    private lazy var alertPresenter = AlertPresenter(viewController: self)
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        activityIndicator.hidesWhenStopped = true
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    //MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.hideLoadingIndicator()
            self?.show(quiz: viewModel)
        }
    }
    
    func didFailToLoadData(with error: Error) {
        hideLoadingIndicator()
        if let serviceError = error as? MoviesLoaderError {
            switch serviceError {
            case .invalidAPIKey:
                showNetworkError(message: "Неверный API ключ. Обратитесь к администратору.")
            case .rateLimitExceeded:
                showNetworkError(message: "Превышено количество запросов к серверу. Попробуйте позже.")
            case .serverError(let message):
                showNetworkError(message: message ?? "Произошла ошибка на сервере.")
            case .emptyMoviesList:
                showNetworkError(message: "Список фильмов пуст. Попробуйте еще раз.")
            }
        } else {
            showNetworkError(message: error.localizedDescription)
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        
        questionFactory?.requestNextQuestion()
    }
    
    func didStartLoadingNextQuestion() {
        showLoadingIndicator()
    }
    
    func didFinishLoadingNextQuestion(_ question: QuizQuestion?    ) {
        hideLoadingIndicator()
    }
    
    //MARK: - Actions
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
    
    //MARK: - Private methods
    private func showLoadingIndicator() {
        
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            activityIndicator.stopAnimating()
        }
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self else { return }
            
            self.correctAnswers = 0
            self.presenter.resetQuestionIndex()
            self.showLoadingIndicator()
            self.questionFactory?.loadData()
        }
        
        alertPresenter.present(alertModel: model)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        changeStateButton(isEnabled: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.changeStateButton(isEnabled: true)
            self?.showNextQuestionOrResult()
            self?.imageView.layer.borderWidth = 0
        }
    }
    
    private func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    private func showNextQuestionOrResult() {
        if presenter.isLastQuestion() {
            if let statisticService = statisticService {
                statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
                
                let gamesCount = statisticService.gamesCount
                let bestGame = statisticService.bestGame
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.YY HH:mm"
                
                let text = """
                            Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
                            Количество сыгранных квизов: \(gamesCount)
                            Ваш рекорд: \(bestGame.correct)/\(bestGame.total) (\(dateFormatter.string(from: bestGame.date)))
                            Средняя точность: (\(String(format: "%.2f", statisticService.totalAccuracy))%)
                        """
                
                let viewModel = QuizResultsViewModel(
                    title: "Этот раунд окончен",
                    text: text,
                    buttonText: "Сыграть еще раз")
                show(quiz: viewModel)
            }
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let completion = {
            self.presenter.resetQuestionIndex()
               self.correctAnswers = 0
               self.questionFactory?.requestNextQuestion()
           }
           let alertModel = AlertModel(
               title: result.title,
               message: result.text,
               buttonText: result.buttonText,
               completion: completion)
           
           alertPresenter.present(alertModel: alertModel)
        }
    }

