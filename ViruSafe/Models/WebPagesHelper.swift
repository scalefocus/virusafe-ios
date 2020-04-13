//
//  WebPagesHelper.swift
//  ViruSafe
//
//  Created by Aleksandar Sergeev Petrov on 8.04.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

final class StaticContentPage {
    static var shared = StaticContentPage()
    private init() { }
    // Default
    var url: String = "https://htmlpreview.github.io/?https://github.com/scalefocus/ViruSafe-static-pages/blob/master/bg/about-covid.html"
}

final class AppInfoPage {
    static var shared = AppInfoPage()
    private init() { }
    // Deafult
    var url: String = "https://htmlpreview.github.io/?https://github.com/scalefocus/ViruSafe-static-pages/blob/master/bg/virusafe-why.html"
}

final class StatisticsPage {
    static var shared = StatisticsPage()
    private init() { }
    // Default
    var url: String = "https://covid19esri.uslugi.io/arcgis/apps/opsdashboard/index.html#/dc93c0e402f24571b503e4515515de63"
}
