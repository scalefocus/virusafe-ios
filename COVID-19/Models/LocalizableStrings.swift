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
        static let newVersionAlertTitle = "Нова версия"
        static let newVersionAlertDescription = "Има обновления по приложението."
        static let newVersionAlertUpdateButtonTitle = "Обнови"
        static let newVersionAlertOkButtonTitle = "Продължи"
        static let errorConnectionWithServerFailed = "Опа! Нещо се обърка."
        static let mobileNumberLabelТext = "Телефон"
        static let mobileNumberIndentificationLabelТext = "Въведете верификационния код, изпратен на номер: "
        static let mobileNumberVerificationТext = "Верификация"
        static let mobileNumberEnterPinText =  "Въведете код"
        static let mobileNumberErrorWrongPinText = "Грешка. Проверете кода и опитайте отново."
        static let mobileNumberSuccessfulPinText = "Кодът беше изпратен успешно"
        static let mobileNumberIncorrectLengthText = "Невалидна дължина"
        static let generalErrorIncorrectFormatText = "Невалиден формат"
        static let mobileNumberNoCodeReceivedButton = "Не получих код"
        static let registrationScreenTitle = "Регистрация"
        static let registrationScreenPhoneTextFieldPlaceholder = "Мобилен номер (08XXXXXXXX)" //"Телефонен номер"
        static let registrationScreenPhoneTextFieldEmpty = "Полето не може да е празно"
        static let registrationScreenPhoneTextFieldInvalidLenght = "Полето трябва да съдържа повече символи"
        static let registrationScreenPhoneTextFieldInvalidFormat = "Невалиден формат"
        static let registrationScreenGeneralErrorText = "Грешка. Проверете дали сте свързани с Интернет и опитайте отново."
        static let registrationScreenInvalindNumberErrorText =  "Грешка. Невалиден телефонен номер."
        static let registrationScreenInvalindPersonalNumberErrorText =  "Грешка. Невалиден граждански номер."
        static let generalWarningText = "Внимание"
        static let genaralAgreedText = "Добре"
        static let registrationScreenTOSText = "За да бъде запазена регистрацията Ви е необходимо да сте съгласни с Общите условия на приложението."
        static let iAgreeWithText = "Съгласен съм с"
        static let registrationScreenTocText = "общите условия"
        static let homeScreenStartingScreenText = "Начален екран"
        static let homeScreenEnterSymptomsText = "Въведете вашите симптоми"
        static let homeScreenStartCapitalText = "НАЧАЛО"
        static let generalTosText = "Условия за ползване"
        static let healthStatusPopulateAllFiendsErrorText = "За да запазите промените е нужно да попълните всички точки от въпросника."
        static let healthStatusPopulateErrorAlreadyEnteredSymptomsText = "Вече попълнихте симптомите си по-рано днес. Може да го направите пак след 1 час и 20 минути."
        static let healthStatusTooManyRequestsErrorText =  "Моля опитайте отново след"
        static let healthStatusUnknownErrorText = "Възникна грешка. Опитайте по-късно."
        static let healthStatusHealthStatuText = "Здравен статус"
        static let confirmationReadyWithExcalamationMarkText = "Готово!"
        static let generalBackText = "Назад"
        static let generalTextForTourAnswerText = "Благодарим Ви, че сте отговорни!"
        static let generalAgreeIText = "Съгласен съм"
        static let generalPersonalInfoText = "Лични данни"
        static let egnDescriptionText = "Ако желаете да използваме данните Ви за допълнителен анализ и да Ви изпращаме персонализирани съвети, моля въведете единния си граждански номер."
        static let egnRequestText = "Въведете вашите лични данни"
        static let egnRequestPlaceholderText = "ЕГН/ЛНЧ"
        static let egnPreexistingConditionsText = "Хронични заболявания"
        static let egnSkipText = "Пропусни"
        static let egnSubmitText = "Потвърди"
        static let dateFormatHours = "часа"
        static let dateFormatMinutes = "минути"
        static let dateFormatLittleMoreTime = "малко"
        static let homeScreenMySymptomsText = "КАК СЕ ЧУВСТВАШ ДНЕС?"
        static let homeScreenHowItWorksText = "КАК РАБОТИ ViruSafe"
        static let homeScreenMyPersonalInfoText = "МОИТЕ ЛИЧНИ ДАННИ"
        static let homeScreenLearnMoreAboutCOVIDText = "НАУЧИ ПОВЕЧЕ ЗА КОРОНА ВИРУСА"
        static let homeScreenMyPersonalContributionText = "Моят личен принос"

        static let webviewScreenTitleNews = "НОВИНИ"
        static let webviewScreenTitleLearnMore = "НАУЧИ ПОВЕЧЕ..."

        static let invalidTokenAlertTitle = "ИЗТЕКЛА СЕСИЯ"
        static let invalidTokenAlertMessage = "Моля да въведете още веднъж телефонния си номер и код за верификация. Това може да се наложи с цел повторна верификация."

        static let egnAgeText = "Години"

        static let confirmEmptyFieldsAlertMessage = "Сигурни ли сте, че искате да продължите? Не сте попълнили следните полета:"
        static let invalidEgnOrIdNumberAlertMessage = "Невалидно ЕГН или ЛНЧ"
        static let chooseLanguageTitle = "Избор на език"
    }
}
