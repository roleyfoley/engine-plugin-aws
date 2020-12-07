[#ftl]

[#assign AMAZONMQ_BROKER_OUTPUT_MAPPINGS =
    {
        REFERENCE_ATTRIBUTE_TYPE : {
            "UseRef" : true
        },
        URL_ATTRIBUTE_TYPE : {
            "Value" : {
                "Fn::Join" : [
                    ";",
                    {
                        "Fn::GetAtt" : [
                            "mqBrokerXmgmtXrabbithutch",
                            "AmqpEndpoints"
                        ]
                    }
                ]
            }
        },
        ARN_ATTRIBUTE_TYPE : {
            "Attribute" : "Arn"
        }
    }
]

[@addOutputMapping
    provider=AWS_PROVIDER
    resourceType=AWS_AMAZONMQ_BROKER_RESOURCE_TYPE
    mappings=AMAZONMQ_BROKER_OUTPUT_MAPPINGS
/]


[#function getAmazonMqMaintenanceWindow dayofWeek timeofDay timeZone="UTC" ]
    [#return
        {
            "DayOfWeek" : dayofWeek,
            "TimeOfDay" : timeofDay,
            "TimeZone" : timeZone
        }
    ]
[/#function]

[#function getAmazonMqUser username password ]
    [#return
        {
            "Username" : username,
            "Password" : password
        }
    ]
[/#function]

[#macro createAmazonMqBroker id name
            engineType
            engineVersion
            instanceType
            multiAz
            encrypted
            kmsKeyId
            subnets
            securityGroupId
            tags
            users=[]
            autoMinorVersionUpdate=false
            logging=true
            maintenanceWindow={}
            dependencies=[]  ]

    [#switch engineType?lower_case ]
        [#case "rabbit" ]
        [#case "rabbitmq" ]
            [#local engineType = "RABBITMQ" ]
            [#break]

        [#default]
            [@fatal message="Unkown AmazonMq Broker Engine" context={ "id" : id, "engineType" : engineType } /]
    [/#switch]

    [@cfResource
        id=id
        type="AWS::AmazonMQ::Broker"
        properties={
            "BrokerName" : name,
            "SubnetIds" : multiAz?then(
                                subnets,
                                [ subnets[0] ]
            ),
            "SecurityGroups" : [ getReference(securityGroupId) ],
            "Users" : asArray(users),
            "Logs" : {
                "General" : logging
            },
            "EngineType" : engineType,
            "EngineVersion" : engineVersion,
            "AutoMinorVersionUpgrade" : autoMinorVersionUpdate,
            "DeploymentMode" : multiAz?then(
                                "CLUSTER_MULTI_AZ",
                                "SINGLE_INSTANCE"
            ),
            "HostInstanceType" : instanceType,
            "MaintenanceWindowStartTime" : maintenanceWindow,
            "PubliclyAccessible" : false
        } +
        attributeIfTrue(
            "EncryptionOptions",
            encrypted,
            {
                "KmsKeyId" : getReference(kmsKeyId),
                "UseAwsOwnedKey" : false
            }
        )
        outputs=AMAZONMQ_BROKER_OUTPUT_MAPPINGS
        dependencies=dependencies
        tags=tags
    /]
[/#macro]
