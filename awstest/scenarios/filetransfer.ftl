[#ftl]

[#-- Get stack output --]
[#macro awstest_scenario_filetransfer ]

    [#-- Base SFTP File Transfer Server --]
    [@addScenario
        blueprint={
            "Tiers" : {
                "app" : {
                    "Components" : {
                        "filetransferbase" : {
                            "filetransfer" : {
                                "Instances" : {
                                    "default" : {
                                        "DeploymentUnits" : ["aws-filetransfer-base"]
                                    }
                                },
                                "Protocols" : [ "sftp" ],
                                "Profiles" : {
                                    "Testing" : [ "filetransferbase" ]
                                }
                            }
                        }
                    }
                }
            },
            "TestCases" : {
                "filetransferbase" : {
                    "OutputSuffix" : "template.json",
                    "Structural" : {
                        "CFN" : {
                            "Resource" : {
                                "transferServer" : {
                                    "Name" : "transferServerXappXfiletransferbase",
                                    "Type" : "AWS::Transfer::Server"
                                },
                                "securityGroup" : {
                                    "Name" : "securityGroupXtransferServerXappXfiletransferbase",
                                    "Type" : "AWS::EC2::SecurityGroup"
                                }
                            },
                            "Output" : [
                                "transferServerXappXfiletransferbase",
                                "transferServerXappXfiletransferbaseXarn",
                                "transferServerXappXfiletransferbaseXname"
                            ]
                        }
                    }
                }
            },
            "TestProfiles" : {
                "filetransferbase" : {
                    "filetransfer" : {
                        "TestCases" : [ "filetransferbase" ]
                    }
                }
            }
        }
    /]
[/#macro]
