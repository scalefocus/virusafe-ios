//
//  WebViewController.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 25.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import UIKit
import WebKit

enum Source {
    case content
    case about
    case notification(String)
    case statistics

    var urlString: String {
        switch self {
        case .content:
            return StaticContentPage.shared.url
        case .about:
            return AppInfoPage.shared.url
        case .notification(let string):
            return string
        case .statistics:
            return StatisticsPage.shared.url

        }
    }

    var description: String {
        switch self {
        case .content:
            return "learn_more_web_view_title".localized()
        case .about:
            return "how_it_works".localized()
        case .notification:
            return "news_label".localized()
        case .statistics:
            return "statistics_label".localized()
        }
    }
}

class WebViewController: UIViewController {

    private var webView: WKWebView? {
        return view as? WKWebView
    }

    // MARK: Lifecycle

    override func loadView() {
        let webView = WKWebView()
        // ??? Configuration
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private var isNavigationBarHiddenInitially: Bool = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupUI()

        isNavigationBarHiddenInitially = navigationController?.isNavigationBarHidden ?? false
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(isNavigationBarHiddenInitially, animated: false)
    }

    // MARK: Load

    func load(source: Source) {
        guard let url = URL(string: source.urlString) else {
            assertionFailure("Invalid url: \(source.urlString)")
            return
        }
        let request = URLRequest(url: url)
        webView?.load(request)
        title = source.description
    }

    // MARK: Setup UI

    private func setupUI() {
        // Setup webview
        //e.g. webView.allowsBackForwardNavigationGestures = true
    }

}

// MARK: WKUIDelegate

extension WebViewController: WKUIDelegate {
    // Do something if needed
}

// MARK: WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        LoadingIndicatorManager.startActivityIndicator(.gray, in: view)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        LoadingIndicatorManager.stopActivityIndicator(in: view)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        LoadingIndicatorManager.stopActivityIndicator(in: view)
    }
}
