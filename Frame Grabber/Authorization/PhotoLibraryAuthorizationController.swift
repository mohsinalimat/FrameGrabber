import UIKit
import Photos
import SafariServices

class PhotoLibraryAuthorizationController: UIViewController {

    static var needsAuthorization: Bool {
        PHPhotoLibrary.authorizationStatus() != .authorized
    }

    var didAuthorizeHandler: (() -> ())?

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var button: UIButton!
    @IBOutlet private var privacyButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }

    @IBAction private func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization(openingSettingsIfNeeded: true) { status, _ in
            self.updateViews()

            if status == .authorized {
                self.didAuthorizeHandler?()
            }
        }
    }

    @IBAction private func showPrivacyPolicy() {
        guard let url = About.privacyPolicyURL else { return }
        let safariController = SFSafariViewController(url: url)
        safariController.preferredControlTintColor = Style.Color.mainTint
        present(safariController, animated: true)
    }

    private func configureViews() {
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1, size: 36, weight: .semibold)

        button.tintColor = .systemBackground
        button.backgroundColor = Style.Color.mainTint
        button.layer.cornerRadius = Style.Size.buttonCornerRadius
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.minimumScaleFactor = 0.8

        privacyButton.titleLabel?.adjustsFontForContentSizeCategory = true
        privacyButton.titleLabel?.minimumScaleFactor = 0.8

        updateViews()
    }

    private func updateViews() {
        titleLabel.text = NSLocalizedString("authorization.title", value: "Welcome to\nFrame Grabber", comment: "Photo library authorization title")

        switch PHPhotoLibrary.authorizationStatus() {
        case .denied, .restricted:
            messageLabel.text = NSLocalizedString("authorization.deniedMessage", value: "Frame Grabber extracts full-resolution video frames as images. You can allow access to your videos in Settings.", comment: "Photo library authorization denied message")
            button.setTitle(NSLocalizedString("authorization.deniedAction", value: "Open Settings", comment: "Photo library authorization denied action"), for: .normal)

        // Mostly for `notDetermined` but also as fallback if we land in `authorized` state.
        default:
            messageLabel.text = NSLocalizedString("authorization.notDeterminedMessage", value: "Frame Grabber extracts full-resolution video frames as images. Get started by allowing access to your videos.", comment: "Photo library authorization default message")
            button.setTitle(NSLocalizedString("authorization.notDeterminedAction", value: "Get Started", comment: "Photo library authorization default action"), for: .normal)
        }
    }
}
