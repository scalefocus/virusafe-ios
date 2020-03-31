//
//  LocalizableStrings.swift
//  COVID-19
//
//  Created by Gandi Pirkov on 26.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation
import UpnetixLocalizer

enum Constants {
    enum Strings {
        static var newVersionAlertTitle = Localizer.shared.getString(key: "Common.new_version_label")
        static var newVersionAlertDescription = Localizer.shared.getString(key: "Common.new_version_msg")
        static var newVersionAlertUpdateButtonTitle = Localizer.shared.getString(key: "Common.update_label")
        static var newVersionAlertOkButtonTitle = Localizer.shared.getString(key: "Common.continue_label")
        static var errorConnectionWithServerFailed = Localizer.shared.getString(key: "Common.something_went_wrong")
        static var mobileNumberLabelТext = "Телефон" //Localizer.shared.getString(key: "")
        static var mobileNumberIndentificationLabelТext = Localizer.shared.getString(key: "Common.verification_code_title").replacingOccurrences(of: "\\n", with: "\n")
        static var mobileNumberVerificationТext = Localizer.shared.getString(key: "Common.verification_code_title").replacingOccurrences(of: "\\n", with: "\n")
        static var mobileNumberEnterPinText =  "Въведете код" //Localizer.shared.getString(key: "verification_code_title")
        static var mobileNumberErrorWrongPinText = "Грешка. Проверете кода и опитайте отново." //Localizer.shared.getString(key: "")
        static var mobileNumberSuccessfulPinText = "Кодът беше изпратен успешно" //Localizer.shared.getString(key: "")
        static var mobileNumberIncorrectLengthText = "Невалидна дължина" //Localizer.shared.getString(key: "")
        static var generalErrorIncorrectFormatText = Localizer.shared.getString(key: "Common.field_invalid_format_msg")
        static var mobileNumberNoCodeReceivedButton = "Не получих код" //Localizer.shared.getString(key: "")
        static var registrationScreenTitle = Localizer.shared.getString(key: "Common.registration_title")
        static var registrationScreenPhoneTextFieldPlaceholder = Localizer.shared.getString(key: "Common.mobile_hint")
        static var registrationScreenPhoneTextFieldEmpty = Localizer.shared.getString(key: "Common.field_empty_msg")
        static var registrationScreenPhoneTextFieldInvalidLenght = Localizer.shared.getString(key: "Common.field_length_error_msg")
        static var registrationScreenGeneralErrorText = "Грешка. Проверете дали сте свързани с Интернет и опитайте отново." //Localizer.shared.getString(key: "")
        static var registrationScreenInvalindNumberErrorText =  "Грешка. Невалиден телефонен номер." //Localizer.shared.getString(key: "")
        static var registrationScreenInvalindPersonalNumberErrorText =  "Грешка. Невалиден граждански номер." //Localizer.shared.getString(key: "")
        static var generalWarningText = Localizer.shared.getString(key: "Common.warning_label")
        static var genaralAgreedText = Localizer.shared.getString(key: "Common.ok_label")
        static var registrationScreenTOSText = "За да бъде запазена регистрацията Ви е необходимо да сте съгласни с Общите условия на приложението." //Localizer.shared.getString(key: "")
        static var registrationScreenTocText = "общите условия" //Localizer.shared.getString(key: "")
        static var homeScreenStartingScreenText = "Начален екран" //Localizer.shared.getString(key: "")
        static var homeScreenEnterSymptomsText = "Въведете вашите симптоми" //Localizer.shared.getString(key: "")
        static var homeScreenStartCapitalText = "НАЧАЛО" //Localizer.shared.getString(key: "")
        static var generalTosText = Localizer.shared.getString(key: "Common.terms_n_conditions_label")
        static var healthStatusPopulateAllFiendsErrorText = Localizer.shared.getString(key: "Common.warning_msg")
        static var healthStatusPopulateErrorAlreadyEnteredSymptomsText = "Вече попълнихте симптомите си по-рано днес. Може да го направите пак след 1 час и 20 минути." //Localizer.shared.getString(key: "")
        static var healthStatusTooManyRequestsErrorText =  "Моля опитайте отново след" //Localizer.shared.getString(key: "")
        static var healthStatusUnknownErrorText = "Възникна грешка. Опитайте по-късно." //Localizer.shared.getString(key: "")
        static var healthStatusHealthStatuText = "Здравен статус" //Localizer.shared.getString(key: "")
        static var confirmationReadyWithExcalamationMarkText = "Готово!" //Localizer.shared.getString(key: "")
        static var generalBackText = "Назад" //Localizer.shared.getString(key: "")
        static var generalTextForTourAnswerText = "Благодарим Ви, че сте отговорни!" //Localizer.shared.getString(key: "")
        static var generalAgreeIText = Localizer.shared.getString(key: "Common.i_agree_label")
        static var generalPersonalInfoText = Localizer.shared.getString(key: "Common.my_personal_data")
        static var egnDescriptionText = "Ако желаете да използваме данните Ви за допълнителен анализ и да Ви изпращаме персонализирани съвети, моля въведете единния си граждански номер." //Localizer.shared.getString(key: "")
        static var egnRequestText = "Въведете вашите лични данни" //Localizer.shared.getString(key: "")
        static var egnRequestPlaceholderText = Localizer.shared.getString(key: "Common.identification_number_hint")
        static var egnPreexistingConditionsText = Localizer.shared.getString(key: "Common.chronical_conditions_hint")
        static var egnSkipText = Localizer.shared.getString(key: "Common.skip_label")
        static var generalConfirmText = Localizer.shared.getString(key: "Common.confirm_label")
        static var dateFormatHours = Localizer.shared.getString(key: "Common.hours_label")
        static var dateFormatMinutes = Localizer.shared.getString(key: "Common.minutes_label")
        static var dateFormatLittleMoreTime = "малко" //Localizer.shared.getString(key: "")
        static var homeScreenMySymptomsText = Localizer.shared.getString(key: "Common.how_do_you_feel_today")
        static var homeScreenHowItWorksText = Localizer.shared.getString(key: "Common.how_it_works")
        static var homeScreenMyPersonalInfoText = Localizer.shared.getString(key: "Common.my_personal_data")
        static var homeScreenLearnMoreAboutCOVIDText = "НАУЧИ ПОВЕЧЕ ЗА КОРОНА ВИРУСА" //Localizer.shared.getString(key: "")
        static var homeScreenMyPersonalContributionText = Localizer.shared.getString(key: "Common.my_contribution_title")

        static var webviewScreenTitleNews = "НОВИНИ" //Localizer.shared.getString(key: "")
        static var webviewScreenTitleLearnMore = "НАУЧИ ПОВЕЧЕ..." //Localizer.shared.getString(key: "")

        static var invalidTokenAlertTitle = "ИЗТЕКЛА СЕСИЯ" //Localizer.shared.getString(key: "")
        static var invalidTokenAlertMessage = Localizer.shared.getString(key: "Common.redirect_to_registration_msg")

        static var egnAgeText = Localizer.shared.getString(key: "Common.age_hint")

        static var confirmEmptyFieldsAlertMessage = Localizer.shared.getString(key: "Common.personal_data_empty_field_msg")
        static var invalidEgnOrIdNumberAlertMessage = Localizer.shared.getString(key: "Common.invalid_egn_msg")
        static let chooseLanguageTitle = "Избор на език" //Localizer.shared.getString(key: "")

    }
}
