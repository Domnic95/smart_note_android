import UIKit
import GoogleMobileAds
import google_mobile_ads

final class ListTileNativeAdFactory: NSObject, FLTNativeAdFactory {
  func createNativeAd(
    _ nativeAd: GADNativeAd,
    customOptions: [AnyHashable: Any]? = nil
  ) -> GADNativeAdView? {
    // Programmatic layout that matches your XIB design, but avoids XIB/KVC crashes
    // when the GoogleMobileAds module name resolution fails on-device.
    let nativeAdView = GADNativeAdView(frame: .zero)
    nativeAdView.backgroundColor = .white

    let adBadge = UILabel()
    adBadge.translatesAutoresizingMaskIntoConstraints = false
    adBadge.text = "Ad"
    adBadge.textAlignment = .center
    adBadge.font = .systemFont(ofSize: 11, weight: .semibold)
    adBadge.textColor = .white
    adBadge.backgroundColor = UIColor(red: 1, green: 0.8, blue: 0.4, alpha: 1)

    let iconView = UIImageView()
    iconView.translatesAutoresizingMaskIntoConstraints = false
    iconView.contentMode = .scaleAspectFit

    let headlineLabel = UILabel()
    headlineLabel.translatesAutoresizingMaskIntoConstraints = false
    headlineLabel.font = .systemFont(ofSize: 17)
    headlineLabel.textColor = .darkText
    headlineLabel.numberOfLines = 1

    let bodyLabel = UILabel()
    bodyLabel.translatesAutoresizingMaskIntoConstraints = false
    bodyLabel.font = .systemFont(ofSize: 14)
    bodyLabel.textColor = .darkText
    bodyLabel.numberOfLines = 0

    let ctaButton = UIButton(type: .system)
    ctaButton.translatesAutoresizingMaskIntoConstraints = false
    ctaButton.titleLabel?.font = .systemFont(ofSize: 18)
    ctaButton.backgroundColor = .link
    ctaButton.setTitleColor(.white, for: .normal)
    ctaButton.isUserInteractionEnabled = false

    nativeAdView.addSubview(adBadge)
    nativeAdView.addSubview(iconView)
    nativeAdView.addSubview(headlineLabel)
    nativeAdView.addSubview(bodyLabel)
    nativeAdView.addSubview(ctaButton)

    NSLayoutConstraint.activate([
      // Ad badge
      adBadge.topAnchor.constraint(equalTo: nativeAdView.topAnchor),
      adBadge.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor),
      adBadge.heightAnchor.constraint(equalToConstant: 15),
      adBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 15),

      // Icon
      iconView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 15),
      iconView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 25),
      iconView.widthAnchor.constraint(equalToConstant: 40),
      iconView.heightAnchor.constraint(equalToConstant: 40),

      // Headline
      headlineLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
      headlineLabel.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 15),
      headlineLabel.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -15),
      headlineLabel.heightAnchor.constraint(equalToConstant: 20.5),

      // Body
      bodyLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
      bodyLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 5),
      bodyLabel.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -10),

      // CTA
      ctaButton.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 20),
      ctaButton.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -20),
      ctaButton.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 25),
      ctaButton.heightAnchor.constraint(equalToConstant: 50),
      nativeAdView.bottomAnchor.constraint(greaterThanOrEqualTo: ctaButton.bottomAnchor, constant: 20),
    ])

    // Wire up required asset views.
    nativeAdView.iconView = iconView
    nativeAdView.headlineView = headlineLabel
    nativeAdView.bodyView = bodyLabel
    nativeAdView.callToActionView = ctaButton

    // Populate values.
    headlineLabel.text = nativeAd.headline

    bodyLabel.text = nativeAd.body
    bodyLabel.isHidden = nativeAd.body == nil

    iconView.image = nativeAd.icon?.image
    iconView.isHidden = nativeAd.icon == nil

    // Your requested CTA behavior.
    ctaButton.setTitle(nativeAd.callToAction, for: .normal)
    ctaButton.isHidden = nativeAd.callToAction == nil

    nativeAdView.nativeAd = nativeAd
    return nativeAdView
  }
}
