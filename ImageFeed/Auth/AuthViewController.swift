import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthentificate(_ vc: AuthViewController)
}

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
            assertionFailure("Failed to prepare for \(segueWebViewIdentifier)")
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
}

extension AuthViewController: WebViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthentificateWithCode code: String) {
        //TODO: Will be made later
        oauth2Service.fetchOAuthToken(code: code, completion: {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                print("Ошибка при авторизации")
                break
            case .success:
                self.delegate?.didAuthentificate(self)
            }
        })
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true, completion: nil)
    }
}
