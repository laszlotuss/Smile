import UIKit
import Smile

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let label = UILabel(frame: view.bounds)
    label.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    label.text = category(emoji: "😀")?.description
    label.numberOfLines = 0
    view.addSubview(label)
  }
}

