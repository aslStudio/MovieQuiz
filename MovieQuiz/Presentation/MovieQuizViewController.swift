import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol?
    private var alertPresenter = AlertPresenter()
    
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    
    private var correctAnswers = 0
    private var isEnabled = true
    
    @IBOutlet weak private var imageView: UIImageView?
    @IBOutlet weak private var counterLabel: UILabel?
    @IBOutlet weak private var textLabel: UILabel?
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
       
        imageView?.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()

        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    private func showLoadingIndicator() {
        activityIndicator?.isHidden = false
        activityIndicator?.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator?.isHidden = true
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        if !isEnabled {
            return
        }
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        showAnswerResult(
            isCorrect: checkQuestion(
                question: currentQuestion,
                value: true,
            )
        )
    }
    
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        if !isEnabled {
            return
        }
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        showAnswerResult(
            isCorrect: checkQuestion(
                question: currentQuestion,
                value: false,
            )
        )
    }
    
    private func checkQuestion(question: QuizQuestion, value: Bool) -> Bool {
        let res = question.correctAnswer == value
        correctAnswers += res ? 1 : 0
        
        return res
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    } 
    
    private func show(quiz step: QuizStepViewModel) {
        self.imageView?.image = step.image
        self.counterLabel?.text = step.questionNumber
        self.textLabel?.text = step.question
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        isEnabled = false
        
        imageView?.layer.masksToBounds = true
        imageView?.layer.borderWidth = 8
        imageView?.layer.borderColor = isCorrect
            ? UIColor.ypGreen.cgColor
            : UIColor.ypRed.cgColor
        imageView?.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.imageView?.layer.borderWidth = 0
            self.showNextQuestionOrResults()
            self.isEnabled = true
        }
    }
    
    private func showNextQuestionOrResults() {
      if currentQuestionIndex == questionsAmount - 1 {
          statisticService?.store(
            correct: correctAnswers,
            total: questionsAmount
          )
          
          var resultRows: [String] = []
          
          resultRows.append(
            "Ваш результат: \(correctAnswers)/\(questionsAmount)"
          )
          if let gamesCount = statisticService?.gamesCount {
              resultRows.append(
                "Количество сыгранных квизов: \(gamesCount)"
              )
          }
          if let bestResult = statisticService?.bestGame {
              resultRows.append(
                "Рекорд: \(bestResult.correct)/\(bestResult.total) (\(bestResult.date.dateTimeString))"
              )
          }
          if let accuarancy = statisticService?.totalAccuracy {
              resultRows.append(
                "Средняя точность: \(String(format: "%.2f", accuarancy))%"
              )
          }
          
          let result = QuizResultsViewModel(
              title: "Этот раунд окончен!",
              text: resultRows.joined(separator: "\n"),
              buttonText: "Сыграть ещё раз"
          )
          
          showResult(result: result)
      } else {
          currentQuestionIndex += 1
                  
          questionFactory?.requestNextQuestion()
      }
    }
    
    private func showResult(result: QuizResultsViewModel) {
        let model = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self = self else { return }

            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            questionFactory?.requestNextQuestion()
        }
        
        alertPresenter.show(in: self, model: model)
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter.show(in: self, model: model)
    }
}

