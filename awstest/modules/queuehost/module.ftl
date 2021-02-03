[#ftl]

[@addModule
    name="queuehost"
    description="Testing module for the aws queuehost component"
    provider=AWSTEST_PROVIDER
    properties=[]
/]

[#macro awstest_module_queuehost  ]

    [#-- Base queuehost --]
    [@loadModule
        blueprint={
            "Tiers" : {
                "app" : {
                    "Components" : {
                        "queuehostbase" : {
                            "queuehost" : {
                                "Instances" : {
                                    "default" : {
                                        "deployment:Unit" : "aws-queuehost-base"
                                    }
                                },
                                "Engine" : "rabbitmq",
                                "EngineVersion" : "1.0.0",
                                "Processor" : {
                                    "Type" : "queue.m3.micro"
                                },
                                "Profiles" : {
                                    "Testing" : [ "queuehostbase" ]
                                },
                                "RootCredentials" : {
                                    "SecretStore" : {
                                        "Tier" : "app",
                                        "Component" : "queuehostsecretstore",
                                        "Instance" : "",
                                        "Version" :""
                                    }
                                }
                            }
                        },
                        "queuehostsecretstore" : {
                            "secretstore" : {
                                "Instances" : {
                                    "default" : {
                                        "deployment:Unit" : "aws-queuehost-secretstore"
                                    }
                                },
                                "Engine" : "aws:secretsmanager"
                            }
                        }
                    }
                }
            },
            "TestCases" : {
                "queuehostbase" : {
                    "OutputSuffix" : "template.json",
                    "Structural" : {
                        "CFN" : {
                            "Resource" : {
                                "queueHost" : {
                                    "Name" : "mqBrokerXappXqueuehostbase",
                                    "Type" : "AWS::AmazonMQ::Broker"
                                },
                                "securityGroup" : {
                                    "Name" : "securityGroupXmqBrokerXappXqueuehostbase",
                                    "Type" : "AWS::EC2::SecurityGroup"
                                },
                                "rootSecret" : {
                                    "Name" : "secretXappXqueuehostbaseXroot",
                                    "Type" : "AWS::SecretsManager::Secret"
                                }
                            },
                            "Output" : [
                                "mqBrokerXappXqueuehostbaseXdns",
                                "securityGroupXmqBrokerXappXqueuehostbase",
                                "secretXappXqueuehostbaseXroot"
                            ]
                        }
                    }
                }
            },
            "TestProfiles" : {
                "queuehostbase" : {
                    "queuehost" : {
                        "TestCases" : [ "queuehostbase" ]
                    }
                }
            }
        }
    /]
[/#macro]
