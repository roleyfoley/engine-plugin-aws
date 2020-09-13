#!groovy

def slackChannel = '#devops-framework'

pipeline {
    options {
        durabilityHint('PERFORMANCE_OPTIMIZED')
    }

    agent {
        label 'hamlet-latest'
    }

    stages {
        stage('Run AWS Template Tests') {
            environment {
                GENERATION_PLUGIN_DIRS="${WORKSPACE}"
            }
            steps {
                sh '''#!/usr/bin/env bash
                    ./test/run_aws_template_tests.sh
                '''
            }
        }

        stage('Trigger Docker Build') {
            when {
                branch 'master'
            }

            steps {
                build (
                    job: '../docker-hamlet/master',
                    wait: false
                )
            }
        }
    }

    post {
        failure {
            slackSend (
                message: "*Failure* | <${BUILD_URL}|${JOB_NAME}>",
                channel: "${slackChannel}",
                color: "#D20F2A"
            )
        }
    }
}
