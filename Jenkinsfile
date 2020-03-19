/**
    This pipeline performs the following actions
    • Set timeout to 60 minutes
    • Build iOS - Build the iOS app without codesigning
    • Metrics
        - Run static code analysis and push the results to SonarQube
        - Allowed to fail
    • Build and Deploy iOS - Compiles the iOS project and pushes to TestFlight
    • Archive IPA File - archive the IPA file and upload to Jenkins

    Branching structure:
    - develop   - builds the project
    - master    - builds the project, runs metrics and deploys to TestFlight
**/
pipeline {
    agent { label 'macos' }
    options {
        timeout(time: 60, unit: 'MINUTES')
        ansiColor('xterm')
    }
    stages {


        stage('Build, sign and deploy iOS Firebase App Distribution') {
            when { expression { BRANCH_NAME ==~ 'master' || BRANCH_NAME ==~ 'develop' || BRANCH_NAME.startsWith('PR-') } }
            steps {
                echo 'Building, signing and deploying iOS...'
                sh '''#!/bin/bash -l
                    # unlock keychain
                    security -v unlock-keychain -p "imperiamobile" "/Users/jenkins/Library/Keychains/login.keychain-db"

                    # update fastlane
                    gem update fastlane

                    # build and deploy for crashlytics
                    rm -rf Pods/ Podfile.lock
                    pod install --repo-update
                    fastlane deploy deploymentPlatform:AppCenter
                '''
            }
        }

        stage('Metrics & Deploy to SonarQube') {
            when { expression { BRANCH_NAME.startsWith('PR-') || BRANCH_NAME ==~ 'master' || BRANCH_NAME ==~ 'stage' } }
            steps {
                echo 'Building, signing and deploying iOS...'
                sh '''#!/bin/bash -l
                    fastlane metrics
                '''
            }
        }
    }
}
