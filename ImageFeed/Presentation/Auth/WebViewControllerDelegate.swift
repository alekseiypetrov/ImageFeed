protocol WebViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthentificateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
