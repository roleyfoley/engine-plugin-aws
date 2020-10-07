[#ftl]

[#-- Intial seeding of settings data based on input data --]
[#macro awstest_input_mock_blueprint_seed ]
    [@addBlueprint
        blueprint={
            "DeploymentGroups" : {
                "segment" : {
                    "ResourceSets" : {
                        "iam" : {
                            "Enabled" : false
                        },
                        "lg" : {
                            "Enabled" : false
                        },
                        "eip" : {
                            "Enabled" : false
                        },
                        "s3" : {
                            "Enabled" : false
                        },
                        "cmk" : {
                            "Enabled" : false
                        }
                    }
                },
                "solution" : {
                    "ResourceSets" : {
                        "eip" : {
                            "Enabled" : false
                        },
                        "iam" : {
                            "Enabled" : false
                        },
                        "lg" : {
                            "Enabled" : false
                        }
                    }
                },
                "application" : {
                    "ResourceSets" : {
                        "iam" : {
                            "Enabled" : false
                        },
                        "lg" : {
                            "Enabled" : false
                        }
                    }
                }
            }
        }
    /]
[/#macro]
