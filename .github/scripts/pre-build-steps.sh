#!/bin/sh

# Decrypt large files
project_dir=$(pwd)
fonts_dir="$project_dir/COVID-19/Settings/Fonts"
mkdir $fonts_dir
# --batch to prevent interactive command --yes to assume "yes" for questions
gpg --quiet --batch --yes --decrypt --passphrase="$FONTS_PASSPHRASE" .fonts/fonts.gpg | tar x -C $fonts_dir

# Certs
base64 -D -o 'COUNCIL_OF_MINISTERS_Distribution_Certificate.p12' <<< $PROD_BG_CERT
base64 -D -o 'Upnetix_Distribution_Certificate.p12' <<< $UPNETIX_CERT

# NOTE: Consider saving all files in base64
# pros: escaping, e.g. chars as ',",\, etc.
# cons: more bytes,secrets can keep up to 64kb

# Flex
# NOTE: Folders and Files Exist. Files contain dummy data.
echo $LOCALIZATION_SERVICES_DEVELOPMENT_BG >| "$project_dir/COVID-19/Settings/Development/Localization-settings.plist"
echo $LOCALIZATION_SERVICES_DEVELOPMENT_MK >| "$project_dir/COVID-19/Settings/NorthMacedonia/Localization-settings.plist"
echo $LOCALIZATION_SERVICES_PRODUCTION_BG >| "$project_dir/COVID-19/Settings/Production/Localization-settings.plist"

# Other Secrets
# NOTE: Folders Exist.
echo $OTHER_SERVICES_DEVELOPMENT_BG > "$project_dir/COVID-19/Settings/Development/Secrets.plist"
echo $OTHER_SERVICES_DEVELOPMENT_MK > "$project_dir/COVID-19/Settings/NorthMacedonia/Secrets.plist"
echo $OTHER_SERVICES_PRODUCTION_BG > "$project_dir/COVID-19/Settings/Production/Secrets.plist"

# Firebase
mkdir "$project_dir/COVID-19/Firebase/BG Upnetix"
mkdir "$project_dir/COVID-19/Firebase/MK Upnetix"
mkdir "$project_dir/COVID-19/Firebase/BG Gov"

echo $FIREBASE_CONFIG_DEVELOPMENT_BG > "$project_dir/COVID-19/Firebase/BG Upnetix/GoogleService-Info.plist"
echo $FIREBASE_CONFIG_DEVELOPMENT_MK > "$project_dir/COVID-19/Firebase/MK Upnetix/GoogleService-Info.plist"
echo $FIREBASE_CONFIG_PRODUCTION_BG > "$project_dir/COVID-19/Firebase/BG Gov/GoogleService-Info.plist"

echo $FIREBASE_REMOTE_CONFIG_DEFAULTS_DEVELOPMENT_BG > "$project_dir/COVID-19/Firebase/BG Upnetix/RemoteConfigDefaults.plist"
echo $FIREBASE_REMOTE_CONFIG_DEFAULTS_DEVELOPMENT_MK > "$project_dir/COVID-19/Firebase/MK Upnetix/RemoteConfigDefaults.plist"
echo $FIREBASE_REMOTE_CONFIG_DEFAULTS_PRODUCTION_BG > "$project_dir/COVID-19/Firebase/BG Gov/RemoteConfigDefaults.plist"
