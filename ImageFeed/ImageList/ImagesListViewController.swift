import UIKit

class ImagesListViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imageName = photosName[indexPath.row] + ".jpg"
        guard let image = UIImage(named: imageName) else {
            return
        }
        cell.customImageView.image = image
        cell.dateTitle.text = dateFormatter.string(from: Date.now)
        
        if indexPath.row % 2 == 0 {
            cell.likeButton.tintColor = UIColor(red: 245.0 / 255.0, green: 107.0 / 255.0, blue: 108.0 / 255.0, alpha: 1.0)
        } else {
            cell.likeButton.tintColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        }
    }
}


extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
}


extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        return
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageName = photosName[indexPath.row] + ".jpg"
        guard let image = UIImage(named: imageName) else {
            return CGFloat(200.0)
        }
        
        let imageInset = UIEdgeInsets(top: 11, left: 20, bottom: 11, right: 20)
        let imageViewWidth = tableView.bounds.width - imageInset.left - imageInset.right
        
        let scale = imageViewWidth / image.size.width
        let imageHieght = image.size.height * scale + imageInset.top + imageInset.bottom
        return CGFloat(imageHieght)
    }
}
