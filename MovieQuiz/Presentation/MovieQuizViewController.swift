import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showResult(result: QuizResultsViewModel)
    
    func highlightBorder(isCorrect: Bool)
    func resetBorder()
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    private var alertPresenter = AlertPresenter()
    private var presenter: MovieQuizPresenter?
    
    @IBOutlet weak private var imageView: UIImageView?
    @IBOutlet weak private var counterLabel: UILabel?
    @IBOutlet weak private var textLabel: UILabel?
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
       
        imageView?.layer.cornerRadius = 20

        showLoadingIndicator()
        
        presenter = MovieQuizPresenter(
            viewController: self
        )
    }
    
    internal func showLoadingIndicator() {
        activityIndicator?.isHidden = false
        activityIndicator?.startAnimating()
    }
    
    internal func hideLoadingIndicator() {
        activityIndicator?.isHidden = true
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
    }
    
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
    }
    
    internal func show(quiz step: QuizStepViewModel) {
        self.imageView?.image = UIImage(data: step.image) ?? UIImage()
        self.counterLabel?.text = step.questionNumber
        self.textLabel?.text = step.question
    }
    
    internal func highlightBorder(isCorrect: Bool) {
        imageView?.layer.masksToBounds = true
        imageView?.layer.borderWidth = 8
        imageView?.layer.borderColor = isCorrect
            ? UIColor.ypGreen.cgColor
            : UIColor.ypRed.cgColor
        imageView?.layer.cornerRadius = 20
    }
    
    internal func resetBorder() {
        self.imageView?.layer.borderWidth = 0
    }
    
    internal func showResult(result: QuizResultsViewModel) {
        let model = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self = self else { return }

            self.presenter?.restartGame()
        }
        
        alertPresenter.show(in: self, model: model)
    }
    
    internal func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз"
        ) { [weak self] in
            guard let self = self else { return }
            
            self.presenter?.retryLoadData()
        }
        
        alertPresenter.show(in: self, model: model)
    }
}
