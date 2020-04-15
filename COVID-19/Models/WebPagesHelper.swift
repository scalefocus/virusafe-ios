//
//  WebPagesHelper.swift
//  COVID-19
//
//  Created by Aleksandar Sergeev Petrov on 8.04.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

final class StaticContentPage {
    static var shared = StaticContentPage()
    private init() { }
    var url: String = "url_about_covid".localized()
}

final class AppInfoPage {
    static var shared = AppInfoPage()
    private init() { }
    var url: String = "url_virusafe_why".localized()
}

final class StatisticsPage {
    static var shared = StatisticsPage()
    private init() { }
    var url: String = "https://covid19esri.uslugi.io/arcgis/apps/opsdashboard/index.html#/dc93c0e402f24571b503e4515515de63" // TODO: Get it from somewhere
}
