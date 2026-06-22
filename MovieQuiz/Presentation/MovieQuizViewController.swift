import UIKit

final class MovieQuizViewController: UIViewController {
    private let questions: [QuizQuestion] = generateMocks()
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        show(
            quiz: convert(model: questions[0])
        )
    }
    
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        showAnswerResult(
            isCorrect: checkQuestion(
                index: currentQuestionIndex,
                value: true,
            )
        )
    }
    
    
    @IBAction func noButtonClicked(_ sender: UIButton) {
        showAnswerResult(
            isCorrect: checkQuestion(
                index: currentQuestionIndex,
                value: false,
            )
        )
    }
    
    private func checkQuestion(index: Int, value: Bool) -> Bool {
        let res = questions[index].correctAnswer == value
        correctAnswers += res ? 1 : 0
        
        return res
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
      return QuizStepViewModel(
        image: UIImage(named: model.image) ?? UIImage(),
        question: model.text,
        questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
      )
    }
    
    private func show(quiz step: QuizStepViewModel) {
        self.imageView.image = step.image
        self.counterLabel.text = step.questionNumber
        self.textLabel.text = step.question
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = isCorrect
            ? UIColor.ypGreen.cgColor
            : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 6
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.imageView.layer.borderWidth = 0
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
      if currentQuestionIndex == questions.count - 1 {
          let result = QuizResultsViewModel(
              title: "Этот раунд окончен!",
              text: "Ваш результат: \(correctAnswers)/\(questions.count)",
              buttonText: "Сыграть ещё раз")
          showResult(result: result)
      } else {
          currentQuestionIndex += 1
                  
          let nextQuestion = questions[currentQuestionIndex]
          let viewModel = convert(model: nextQuestion)
          
          show(quiz: viewModel)
      }
    }
    
    private func showResult(result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)

        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            // заново показываем первый вопрос
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
        }

        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)
    }
}

struct QuizResultsViewModel {
  let title: String
  let text: String
  let buttonText: String
}

struct QuizStepViewModel {
  let image: UIImage
  let question: String
  let questionNumber: String
}

private struct QuizQuestion {
  let image: String
  let text: String
  let correctAnswer: Bool
}

private func generateMocks() -> [QuizQuestion] {
    return [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
