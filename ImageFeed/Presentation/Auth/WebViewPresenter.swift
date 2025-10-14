import Foundation

protocol WebViewPresenterProtocol: AnyObject {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {
    
    // MARK: - Private Properties
    
    private let authHelper: AuthHelperProtocol
    
    // MARK: - Public Properties
    
    weak var view: WebViewViewControllerProtocol?
    
    // MARK: - Initializer
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
        guard let request = authHelper.authRequest() else {
            print("[WebViewPresenter/viewDidLoad]: Возникла ошибка при создании запроса для загрузки страницы авторизации.")
            return
        }
        print("[WebViewPresenter/viewDidLoad]: Запрос для загрузки страницы авторизации успешно сформирован.")
        didUpdateProgressValue(0)
        view?.load(request: request)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1) <= 0.0001
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}
