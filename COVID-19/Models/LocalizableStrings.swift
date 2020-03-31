//
//  LocalizableStrings.swift
//  COVID-19
//
//  Created by Gandi Pirkov on 26.03.20.
//  Copyright © 2020 Upnetix AD. All rights reserved.
//

import Foundation

enum Constants {
    enum Strings {
        static var newVersionAlertTitle = "Нова версия" //Localizer.shared.getString(key: "")
        static var newVersionAlertDescription = "Има обновления по приложението." //Localizer.shared.getString(key: "")
        static var newVersionAlertUpdateButtonTitle = "Обнови" //Localizer.shared.getString(key: "")
        static var newVersionAlertOkButtonTitle = "Продължи" //Localizer.shared.getString(key: "")
        static var errorConnectionWithServerFailed = "Опа! Нещо се обърка." //Localizer.shared.getString(key: "")
        static var mobileNumberLabelТext = "Телефон" //Localizer.shared.getString(key: "")
        static var mobileNumberIndentificationLabelТext = "Въведете верификационния код, изпратен на номер: " //Localizer.shared.getString(key: "")
        static var mobileNumberVerificationТext = "Верификация" //Localizer.shared.getString(key: "")
        static var mobileNumberEnterPinText =  "Въведете код" //Localizer.shared.getString(key: "")
        static var mobileNumberErrorWrongPinText = "Грешка. Проверете кода и опитайте отново." //Localizer.shared.getString(key: "")
        static var mobileNumberSuccessfulPinText = "Кодът беше изпратен успешно" //Localizer.shared.getString(key: "")
        static var mobileNumberIncorrectLengthText = "Невалидна дължина" //Localizer.shared.getString(key: "")
        static var generalErrorIncorrectFormatText = "Невалиден формат" //Localizer.shared.getString(key: "")
        static var mobileNumberNoCodeReceivedButton = "Не получих код" //Localizer.shared.getString(key: "")
        static var registrationScreenTitle = "Регистрация" //Localizer.shared.getString(key: "")
        static var registrationScreenPhoneTextFieldPlaceholder = "Мобилен номер (08XXXXXXXX)" //Localizer.shared.getString(key: "")
        static var registrationScreenPhoneTextFieldEmpty = "Полето не може да е празно" //Localizer.shared.getString(key: "")
        static var registrationScreenPhoneTextFieldInvalidLenght = "Полето трябва да съдържа повече символи" //Localizer.shared.getString(key: "")
        static var registrationScreenPhoneTextFieldInvalidFormat = "Невалиден формат" //Localizer.shared.getString(key: "")
        static var registrationScreenGeneralErrorText = "Грешка. Проверете дали сте свързани с Интернет и опитайте отново." //Localizer.shared.getString(key: "")
        static var registrationScreenInvalindNumberErrorText =  "Грешка. Невалиден телефонен номер." //Localizer.shared.getString(key: "")
        static var registrationScreenInvalindPersonalNumberErrorText =  "Грешка. Невалиден граждански номер." //Localizer.shared.getString(key: "")
        static var generalWarningText = "Внимание" //Localizer.shared.getString(key: "")
        static var genaralAgreedText = "Добре" //Localizer.shared.getString(key: "")
        static var registrationScreenTOSText = "За да бъде запазена регистрацията Ви е необходимо да сте съгласни с Общите условия на приложението." //Localizer.shared.getString(key: "")
        static var iAgreeWithText = "Съгласен съм с" //Localizer.shared.getString(key: "")
        static var registrationScreenTocText = "общите условия" //Localizer.shared.getString(key: "")
        static var homeScreenStartingScreenText = "Начален екран" //Localizer.shared.getString(key: "")
        static var homeScreenEnterSymptomsText = "Въведете вашите симптоми" //Localizer.shared.getString(key: "")
        static var homeScreenStartCapitalText = "НАЧАЛО" //Localizer.shared.getString(key: "")
        static var generalTosText = "Условия за ползване" //Localizer.shared.getString(key: "")
        static var healthStatusPopulateAllFiendsErrorText = "За да запазите промените е нужно да попълните всички точки от въпросника." //Localizer.shared.getString(key: "")
        static var healthStatusPopulateErrorAlreadyEnteredSymptomsText = "Вече попълнихте симптомите си по-рано днес. Може да го направите пак след 1 час и 20 минути." //Localizer.shared.getString(key: "")
        static var healthStatusTooManyRequestsErrorText =  "Моля опитайте отново след" //Localizer.shared.getString(key: "")
        static var healthStatusUnknownErrorText = "Възникна грешка. Опитайте по-късно." //Localizer.shared.getString(key: "")
        static var healthStatusHealthStatuText = "Здравен статус" //Localizer.shared.getString(key: "")
        static var confirmationReadyWithExcalamationMarkText = "Готово!" //Localizer.shared.getString(key: "")
        static var generalBackText = "Назад" //Localizer.shared.getString(key: "")
        static var generalTextForTourAnswerText = "Благодарим Ви, че сте отговорни!" //Localizer.shared.getString(key: "")
        static var generalAgreeIText = "Съгласен съм" //Localizer.shared.getString(key: "")
        static var generalPersonalInfoText = "Лични данни" //Localizer.shared.getString(key: "")
        static var egnDescriptionText = "Ако желаете да използваме данните Ви за допълнителен анализ и да Ви изпращаме персонализирани съвети, моля въведете единния си граждански номер." //Localizer.shared.getString(key: "")
        static var egnRequestText = "Въведете вашите лични данни" //Localizer.shared.getString(key: "")
        static var egnRequestPlaceholderText = "ЕГН/ЛНЧ" //Localizer.shared.getString(key: "")
        static var egnPreexistingConditionsText = "Хронични заболявания" //Localizer.shared.getString(key: "")
        static var egnSkipText = "Пропусни" //Localizer.shared.getString(key: "")
        static var egnSubmitText = "Потвърди" //Localizer.shared.getString(key: "")
        static var dateFormatHours = "часа" //Localizer.shared.getString(key: "")
        static var dateFormatMinutes = "минути" //Localizer.shared.getString(key: "")
        static var dateFormatLittleMoreTime = "малко" //Localizer.shared.getString(key: "")
        static var homeScreenMySymptomsText = "КАК СЕ ЧУВСТВАШ ДНЕС?" //Localizer.shared.getString(key: "")
        static var homeScreenHowItWorksText = "КАК РАБОТИ ViruSafe" //Localizer.shared.getString(key: "")
        static var homeScreenMyPersonalInfoText = "МОИТЕ ЛИЧНИ ДАННИ" //Localizer.shared.getString(key: "")
        static var homeScreenLearnMoreAboutCOVIDText = "НАУЧИ ПОВЕЧЕ ЗА КОРОНА ВИРУСА" //Localizer.shared.getString(key: "")
        static var homeScreenMyPersonalContributionText = "Моят личен принос" //Localizer.shared.getString(key: "")

        static var webviewScreenTitleNews = "НОВИНИ" //Localizer.shared.getString(key: "")
        static var webviewScreenTitleLearnMore = "НАУЧИ ПОВЕЧЕ..." //Localizer.shared.getString(key: "")

        static var invalidTokenAlertTitle = "ИЗТЕКЛА СЕСИЯ" //Localizer.shared.getString(key: "")
        static var invalidTokenAlertMessage = "Моля да въведете още веднъж телефонния си номер и код за верификация. Това може да се наложи с цел повторна верификация." //Localizer.shared.getString(key: "")

        static var egnAgeText = "Години" //Localizer.shared.getString(key: "")

        static var confirmEmptyFieldsAlertMessage = "Сигурни ли сте, че искате да продължите? Не сте попълнили следните полета:" //Localizer.shared.getString(key: "")
        static var invalidEgnOrIdNumberAlertMessage = "Невалидно ЕГН или ЛНЧ" //Localizer.shared.getString(key: "")
        static let chooseLanguageTitle = "Избор на език" //Localizer.shared.getString(key: "")

    }
}
