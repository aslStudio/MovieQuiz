import Foundation

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private let statisticService: StatisticServiceProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    
    private var isEnabled: Bool = true
    var correctAnswers = 0
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewControllerProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        self.statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: model.image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func yesButtonClicked() {
        self.didAnswer(value: true)
    }
    
    func noButtonClicked() {
        self.didAnswer(value: false)
    }
    
    func showNextQuestionOrResults() {
        guard let controller = viewController else {
            return
        }
        
        if self.isLastQuestion() {
          self.statisticService?.store(
            correct: self.correctAnswers,
            total: self.questionsAmount
          )
          
          var resultRows: [String] = []
          
          resultRows.append(
            "Ваш результат: \(self.correctAnswers)/\(self.questionsAmount)"
          )
            if let gamesCount = self.statisticService?.gamesCount {
              resultRows.append(
                "Количество сыгранных квизов: \(gamesCount)"
              )
          }
            if let bestResult = self.statisticService?.bestGame {
              resultRows.append(
                "Рекорд: \(bestResult.correct)/\(bestResult.total) (\(bestResult.date.dateTimeString))"
              )
          }
            if let accuarancy = self.statisticService?.totalAccuracy {
              resultRows.append(
                "Средняя точность: \(String(format: "%.2f", accuarancy))%"
              )
          }
          
          let result = QuizResultsViewModel(
              title: "Этот раунд окончен!",
              text: resultRows.joined(separator: "\n"),
              buttonText: "Сыграть ещё раз"
          )
          
         controller.showResult(result: result)
      } else {
          self.switchToNextQuestion()
                  
          self.questionFactory?.requestNextQuestion()
      }
    }
    
    private func didAnswer(value: Bool) {
        if !isEnabled {
            return
        }
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        guard let controller = viewController else {
            return
        }
        
        self.showAnswerResult(
            isCorrect: self.checkQuestion(
                question: currentQuestion,
                value: value,
            )
        )
    }
    
    internal func showAnswerResult(isCorrect: Bool) {
        isEnabled = false
        
        self.viewController?.highlightBorder(isCorrect: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.viewController?.resetBorder()
            self.showNextQuestionOrResults()
            self.isEnabled = true
        }
    }
    
    func checkQuestion(question: QuizQuestion, value: Bool) -> Bool {
        let res = question.correctAnswer == value
        correctAnswers += res ? 1 : 0
        
        return res
    }
}
