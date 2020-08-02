[#ftl]
[@addResourceGroupInformation
    type=DATAFEED_COMPONENT_TYPE
    attributes=[
        {
            "Names" : "WAFLogFeed",
            "Description" : "Set up this datafeed to capture WAF Logs",
            "Type" : BOOLEAN_TYPE,
            "Default" : false
        }
    ]
    provider=AWS_PROVIDER
    resourceGroup=DEFAULT_RESOURCE_GROUP
    services=
        [
            AWS_CLOUDWATCH_SERVICE,
            AWS_IDENTITY_SERVICE,
            AWS_KINESIS_SERVICE
        ]
/]
