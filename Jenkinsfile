pipeline{
    agent{
        label "docker && linux"
    }
    environment { 
        registry = "xuvin/xteve"
        registryCredential = 'docker-xuvin-cred'
        pushOverAPIUserKey = credentials('po-userkey')
        pushOverAPIAPPToken = credentials('jenkins-po-key')
        repoUSER = "xteve-project"
        repoNAME = "xTeVe"
        repoPATH = "${repoUSER}/${repoNAME}"
        newVersion = "PLACEHOLDER"
    }
    stages{
        stage("Clone"){
            steps{
                script{
                    newVersion = sh(label: 'Get Latest Release Version',script: 'curl --silent "https://api.github.com/repos/${repoPATH}/releases" | grep \'"tag_name":\' | sed -E \'s/.*"([^"]+)".*/\\1/\' | cut -c 2- | sed \'s/.\\{5\\}$//\' | awk \'NR==1{print $1}\'', returnStdout: true).trim()
                }
                echo "Running ${env.BUILD_ID} on ${env.JENKINS_URL} for Version ${newVersion}"
                // checkout scm
                git 'https://github.com/demenzio/docker.xteve.git'
            }
            post{
                success{
                    echo "====> Clone - Success"
                }
                failure{
                    echo "====> Clone - Failure"
                }
            }
        }
        stage("Build"){
            steps{
                sh (label: "Building Container ${registry}:${newVersion}", script: "docker build --pull --no-cache -f v2.Dockerfile -t ${registry}:${newVersion} .")
            }
            post{
                success{
                    echo "====> Build - Success"
                }
                failure{
                    echo "====> Build - Failure"
                }
            }
        }
        stage("Test"){
            steps{
                sh (label: "Starting Test Container of ${registry}:${newVersion}", script: "docker run -it -d --name test-build${env.BUILD_ID}-xteve ${registry}:${newVersion} /bin/sh")
                sh (label: "Execute Test Command in ${registry}:${newVersion}", script: "docker exec test-build${env.BUILD_ID}-xteve bash -c 'echo ContainerisRunning'")
                //VERSION CHECK MISSING
                sh (label: "Stopping Test Container of ${registry}:${newVersion}", script: "docker stop test-build${env.BUILD_ID}-xteve")
            }            
            post{
                cleanup{
                    sh (label: "Removing Test Containers of ${registry}", script: "docker rm -f test-build${env.BUILD_ID}-xteve")                 
                }
                success{
                    echo "====> Test - Passed"
                }
                failure{
                    echo "====> Test - Failure"
                }
            }
        }
        stage("Push"){
            steps{
                script{
                    docker.withRegistry( '', 'docker-xuvin-cred' ) {
                        sh (label: "Tagging ${registry}:${newVersion} as latest", script: "docker tag ${registry}:${newVersion} ${registry}:latest")
                        sh (label: "Pushing ${registry}:${newVersion} as latest to Docker Hub", script: "docker push ${registry}:${newVersion} && docker push ${registry}:latest")
                    }
                }
            }
            post{
                success{
                    echo "====> Push - Success"
                }
                failure{
                    echo "====> Push - Failure"
                }
            }
        }
        stage("Clean Up"){
            steps{
                sh (label: "Removing Created Docker Images with Tag ${registry}:${newVersion}", script: "docker rmi -f ${registry}:${newVersion} && docker rmi -f ${registry}:latest || exit 0")
            }
            post{
                success{
                    echo "====> Cleaned Up - Success"
                }
                failure{
                    echo "====> Cleaned up - Failure"
                }
            }
        }   
    }
    post{
        success{
            sh (label: 'Sending Notification with Status 0', script: 'curl -s --form-string "token=${pushOverAPIAPPToken}" --form-string "user=${pushOverAPIUserKey}" --form-string "priority=0" --form-string "title=${registry} - Status 0" --form-string "message=Build for ${registry} - Completed" https://api.pushover.net/1/messages.json', returnStdout: true)
        }
        failure{
            sh (label: 'Sending Notification with Status 2', script: 'curl -s --form-string "token=${pushOverAPIAPPToken}" --form-string "user=${pushOverAPIUserKey}" --form-string "priority=2" --form-string "retry=30" --form-string "expire=10800" --form-string "title=${registry} - Status 2" --form-string "message=Build for ${registry} - Failure" https://api.pushover.net/1/messages.json', returnStdout: true)
            sh (label: "Removing all created images of ${registry}:${newVersion}", script: "docker rmi -f ${registry}:${newVersion} && docker rmi -f ${registry}:latest || exit 0")
        }
        aborted{
            sh (label: 'Sending Notification with Status 1', script: 'curl -s --form-string "token=${pushOverAPIAPPToken}" --form-string "user=${pushOverAPIUserKey}" --form-string "priority=1" --form-string "title=${registry} - Status 1" --form-string "message=Build for ${registry} - Aborted" https://api.pushover.net/1/messages.json', returnStdout: true)
            sh (label: "Removing all created images of ${registry}:${newVersion}", script: "docker rmi -f ${registry}:${newVersion} && docker rmi -f ${registry}:latest || exit 0")
        }
    }
}