[#ftl]

[@addModule
    name="s3"
    description="Testing module for the aws s3 component"
    provider=AWSTEST_PROVIDER
    properties=[]
/]

[#macro awstest_module_s3  ]

    [#-- Base S3 - No default parameters --]
    [@loadModule
        blueprint={
            "Tiers" : {
                "app" : {
                    "Components" : {
                        "s3base" : {
                            "s3" : {
                                "Instances" : {
                                    "default" : {
                                        "deployment:Unit" : "aws-s3-base"
                                    }
                                },
                                "Profiles" : {
                                    "Testing" : [ "s3base" ]
                                }
                            }
                        },
                        "s3notify" : {
                            "s3" : {
                                "Instances" : {
                                    "default" : {
                                        "deployment:Unit" : "aws-s3-notify"
                                    }
                                },
                                "Profiles" : {
                                    "Testing" : [ "s3notify" ]
                                },
                                "Notifications" : {
                                    "sqsCreate" : {
                                        "Links" : {
                                            "s3notifyqueue" : {
                                                "Tier" : "app",
                                                "Component" : "s3notifyqueue",
                                                "Instance" : "",
                                                "Version" : ""
                                            }
                                        },
                                        "aws:QueuePermissionMigration" : true
                                    }
                                }
                            }
                        },
                        "s3notifyqueue" : {
                            "sqs" : {
                                "Instances" : {
                                    "default" : {
                                        "deployment:Unit" : "aws-s3-notify"
                                    }
                                },
                                "Links" : {
                                    "s3Notify" :{
                                        "Tier" : "app",
                                        "Component" : "s3notify",
                                        "Instance" : "",
                                        "Version" : "",
                                        "Direction" : "inbound",
                                        "Role" : "invoke"
                                    }
                                }
                            }
                        }
                    }
                }
            },
            "TestProfiles" : {
                "s3base" : {
                    "s3" : {
                        "TestCases" : [ "s3base" ]
                    }
                },
                "s3notify" : {
                    "s3" : {
                        "TestCases" : [ "s3notify" ]
                    }
                }
            },
            "TestCases" : {
                "s3base" : {
                    "OutputSuffix" : "template.json",
                    "Structural" : {
                        "CFN" : {
                            "Resource" : {
                                "s3Bucket" : {
                                    "Name" : "s3XappXs3base",
                                    "Type" : "AWS::S3::Bucket"
                                }
                            },
                            "Output" : [
                                "s3XappXs3base",
                                "s3XappXs3baseXname",
                                "s3XappXs3baseXarn",
                                "s3XappXs3baseXregion"
                            ]
                        }
                    }
                },
                "s3notify" : {
                    "OutputSuffix" : "template.json",
                    "Structural" : {
                        "CFN" : {
                            "Resource" : {
                                "s3Bucket" : {
                                    "Name" : "s3XappXs3notify",
                                    "Type" : "AWS::S3::Bucket"
                                },
                                "sqsQueue" : {
                                    "Name" : "sqsXappXs3notifyqueue",
                                    "Type" : "AWS::SQS::Queue"
                                },
                                "sqsQueuePolicy" : {
                                    "Name" : "sqsPolicyXappXs3notifyqueue",
                                    "Type" : "AWS::SQS::QueuePolicy"
                                }
                            },
                            "Output" : [
                                "s3XappXs3notify",
                                "s3XappXs3notifyXname",
                                "s3XappXs3notifyXarn",
                                "s3XappXs3notifyXregion"
                            ]
                        },
                        "JSON" : {
                            "Match" : {
                                "S3NotificationsCreateEvent" : {
                                    "Path"  : "Resources.s3XappXs3notify.Properties.NotificationConfiguration.QueueConfigurations[0].Event",
                                    "Value" : "s3:ObjectCreated:*"
                                },
                                "S3NotificationsCreateEvent" : {
                                    "Path"  : "Resources.s3XappXs3notify.Properties.NotificationConfiguration.QueueConfigurations[0].Queue",
                                    "Value" : "arn:aws:iam::123456789012:mock/sqsXappXs3notifyqueueXarn"
                                }
                            }
                        }
                    }
                }
            }
        }
    /]
[/#macro]
