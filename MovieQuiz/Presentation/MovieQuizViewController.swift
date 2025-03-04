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
    private var questionFactory: QuestionFactory?
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
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
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
        presenter.yesButtonClicked()
    }
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    //MARK: - Private methods
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
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
    
    func show(quiz step: QuizStepViewModel) {
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
            guard let self else { return }
            self.changeStateButton(isEnabled: true)
            self.presenter.correctAnswers = self.correctAnswers
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResult()
            self.imageView.layer.borderWidth = 0
        }
    }
    
    private func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    func show(quiz result: QuizResultsViewModel) {
        print("show(quiz result:) called with title: \(result.title)")
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
       
        DispatchQueue.main.async {
            print("Presenting alert on main thread")
            self.alertPresenter.present(alertModel: alertModel)
        }
    }
    }

