package com.silverdeveloper.smartnoteapp

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.RatingBar
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

/**
 * Native-ad factory for the "listTile" factoryId.
 *
 * Renders a compact list-tile ad card:
 *   - Orange "Ad" badge + icon + headline / advertiser + rating in a row
 *   - 2-line body underneath
 *   - Full-width red Install button
 *
 * MediaView is bound but kept invisible (see the layout XML). The previous
 * version of this factory dynamically made the MediaView visible and resized
 * it to 150dp whenever the ad carried media, which on test campaigns
 * produced a giant Google Ads logo that overflowed the 170dp Flutter
 * SizedBox. We always keep the MediaView hidden now and leave the card at
 * its natural compact height.
 */
class ListTileNativeAdFactory(private val context: Context) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val nativeAdView = LayoutInflater.from(context)
            .inflate(R.layout.list_tile_native_ad, null) as NativeAdView

        val mediaView = nativeAdView.findViewById<MediaView>(R.id.native_ad_media)
        val iconView = nativeAdView.findViewById<ImageView>(R.id.native_ad_icon)
        val ratingView = nativeAdView.findViewById<RatingBar>(R.id.native_ad_rating)
        val advertiserView = nativeAdView.findViewById<TextView>(R.id.native_ad_advertiser)
        val headlineView = nativeAdView.findViewById<TextView>(R.id.native_ad_headline)
        val bodyView = nativeAdView.findViewById<TextView>(R.id.native_ad_body)
        val ctaButton = nativeAdView.findViewById<Button>(R.id.native_ad_button)

        // --- Headline (required) ---
        headlineView.text = nativeAd.headline
        nativeAdView.headlineView = headlineView

        // --- Body ---
        if (nativeAd.body != null) {
            bodyView.visibility = View.VISIBLE
            bodyView.text = nativeAd.body
        } else {
            bodyView.visibility = View.GONE
        }
        nativeAdView.bodyView = bodyView

        // --- Icon ---
        val icon = nativeAd.icon
        if (icon != null) {
            iconView.visibility = View.VISIBLE
            iconView.setImageDrawable(icon.drawable)
        } else {
            iconView.visibility = View.GONE
        }
        nativeAdView.iconView = iconView

        // --- Advertiser ---
        val advertiser = nativeAd.advertiser
        if (advertiser != null) {
            advertiserView.visibility = View.VISIBLE
            advertiserView.text = advertiser
        } else {
            advertiserView.visibility = View.GONE
        }
        nativeAdView.advertiserView = advertiserView

        // --- Star rating ---
        val starRating = nativeAd.starRating
        if (starRating != null && starRating > 0.0) {
            ratingView.visibility = View.VISIBLE
            ratingView.rating = starRating.toFloat()
        } else {
            ratingView.visibility = View.GONE
        }
        nativeAdView.starRatingView = ratingView

        // --- Call to action ---
        // The whole NativeAdView receives taps; keep the button non-interactive
        // so a tap goes through to the SDK's click handler.
        val cta = nativeAd.callToAction
        if (cta != null) {
            ctaButton.text = cta
        }
        ctaButton.isClickable = false
        ctaButton.isFocusable = false
        nativeAdView.callToActionView = ctaButton

        // --- MediaView ---
        // Bind it so the SDK can attach media assets (without this binding,
        // the test campaign fails with LoadAdError "Internal error"), but
        // leave it at its layout-default visibility="invisible" — never show
        // the giant test ad logo / video poster.
        nativeAdView.mediaView = mediaView

        // Finalise: must be called after all asset views are assigned.
        nativeAdView.setNativeAd(nativeAd)
        return nativeAdView
    }
}
