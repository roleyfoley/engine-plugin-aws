[#ftl]

[@addResourceGroupInformation
    type=SECRETSTORE_COMPONENT_TYPE
    attributes=[
        {
            "Names": "Engine",
            "Values" : [ "secretsmanager" ],
            "Default" : "secretsmanager"
        },
        {
            "Names" : "SaveToCMDB",
            "Description" : "Save secrets to CMDB as KMS encyrpted strings",
            "type" : BOOLEAN_TYPE,
            "Default" : true
        }
    ]
    provider=AWS_PROVIDER
    resourceGroup=DEFAULT_RESOURCE_GROUP
    services=
        [
            AWS_SECRETS_MANAGER_SERVICE
        ]
/]

[#macro setupComponentSecret
            occurrence
            secretStoreLink
            kmsKeyId
            secretComponentResources={}
            secretComponentConfiguration={}
            componentType=""
            secretString="" ]

    [#local secretStoreCore = secretStoreLink.Core ]
    [#local secretStoreSolution = secretStoreLink.Configuration.Solution ]
    [#local secretStoreResources = secretStoreLink.State.Resources ]

    [#if secretStoreCore.Type != SECRETSTORE_COMPONENT_TYPE ]
        [@fatal
            message="Secret Store link is to the wrong component"
            detail="Secret store must be a ${SECRETSTORE_COMPONENT_TYPE} component"
            context={
                "Id" : secretStoreCore.Id,
                "Type" : secretStoreCore.Type
            }
        /]

    [#else]
        [#local resources = secretComponentResources?has_content?then(
                            secretComponentResources,
                            occurrence.State.Resources
        )]

        [#local solution = secretComponentConfiguration?has_content?then(
                                secretComponentConfiguration,
                                occurrence.Configuration.Solution.Secret
        )]

        [#local componentType = componentType?has_content?then(
                                componentType,
                                occurrence.Core.Type
        )]

        [#local generateSecret = (solution.Source == "generated") ]

        [#switch secretStoreSolution.Engine ]
            [#case "aws:secretsmanager" ]
                [#if deploymentSubsetRequired(componentType, true) ]

                    [#local secretPolicy = getSecretsManagerPolicyFromComponentConfig(solution)]
                    [@createSecretsManagerSecret
                        id=resources["secret"].Id
                        name=resources["secret"].Name
                        tags=getOccurrenceCoreTags(occurrence, resources["secret"].Name)
                        kmsKeyId=kmsKeyId
                        description=resources["secret"].Description
                        generateSecret=generateSecret
                        generateSecretPolicy=secretPolicy
                        secretString=secretString
                    /]
                [/#if]
                [#break]
        [/#switch]
    [/#if]
[/#macro]
