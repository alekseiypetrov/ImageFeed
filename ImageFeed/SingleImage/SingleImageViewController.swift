import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    var imageUrl: URL?
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        imageView.kf.setImage(
            with: imageUrl,
            completionHandler: {[weak self] result in
                guard let self else { return }
                switch result {
                case .failure:
                    self.dismiss(animated: true, completion: nil)
                case .success(let imageResult):
                    let image = imageResult.image
                    self.imageView.frame.size = image.size
                    self.rescaleAndCenterImageInScrollView(image: image)
                }
            })
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else { return }
        let activityView = UIActivityViewController(
            activityItems: [image, "ImageFeed (YP)"],
            applicationActivities: nil
        )
        present(activityView, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        // max(maxZoomScale, min(minZoomScale, max(hScale, vScale)))
        // min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}


extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        let yInset = max(0, (scrollView.bounds.size.height - imageView.frame.size.height) / 2)
        let xInset = max(0, (scrollView.bounds.size.width - imageView.frame.size.width) / 2)
        scrollView.contentInset = UIEdgeInsets(top: yInset, left: xInset, bottom: yInset, right: xInset)
    }
}
