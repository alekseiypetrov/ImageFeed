import Foundation
@testable import ImageFeed

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    weak var presenter: WebViewPresenterProtocol?
    var didCalledLoadRequest: Bool = false
    
    func load(request: URLRequest) {
        didCalledLoadRequest = true
    }
    
    func setProgressValue(_ newValue: Float) { }
    
    func setProgressHidden(_ isHidden: Bool) { }
}
