import UIKit
import ProgressHUD

final class AuthViewController: UIViewController {
    private let segueWebViewIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    weak var delegate: AuthViewControllerDelegate?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == segueWebViewIdentifier else {
            super.prepare(for: segue, sender: sender)
            return
        }
        guard let webViewController = segue.destination as? WebViewViewController else {
            assertionFailure("Failed to prepare for \(segueWebViewIdentifier).")
            return
        }
        webViewController.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButton()
    }
    
    private func configureButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_bar_back")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_bar_back")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
    
    private func showAuthErrorAlert(completion: (() -> Void)?) {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )
        self.present(alert, animated: true, completion: completion)
    }
}

extension AuthViewController: WebViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthentificateWithCode code: String) {
        UIBlockingProgressHUD.show()
        oauth2Service.fetchOAuthToken(code: code, completion: {[weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            switch result {
            case .success:
                print("[Auth/webViewViewController]: Авторизация прошла успешно, начинается перенаправление к галерее.")
                vc.dismiss(animated: true) { [weak self] in
                    guard let self else { return }
                    self.delegate?.didAuthentificate(self)
                }
            case .failure(let error):
                print("[Auth/webViewViewController]: \(type(of: error)) Произошла ошибка при авторизации: \(error).")
                self.showAuthErrorAlert(completion: {vc.dismiss(animated: true)})
            }
        })
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
