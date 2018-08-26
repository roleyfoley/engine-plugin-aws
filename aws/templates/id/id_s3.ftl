[#-- S3 --]

[#-- Resources --]
[#assign AWS_S3_RESOURCE_TYPE = "s3" ]
[#assign AWS_S3_BUCKET_POLICY_RESOURCE_TYPE="bucketpolicy" ]

[#function formatS3Id ids...]
    [#return formatResourceId(
            AWS_S3_RESOURCE_TYPE,
            ids)]
[/#function]

[#-- TODO: Remove when use of "container" is removed --]
[#function formatContainerS3Id type extensions...]
    [#return formatContainerResourceId(
                AWS_S3_RESOURCE_TYPE,
                type,
                extensions)]
[/#function]

[#function formatSegmentS3Id type extensions...]
    [#return formatSegmentResourceId(
                AWS_S3_RESOURCE_TYPE,
                type,
                extensions)]
[/#function]

[#function formatOccurrenceS3Id occurrence extensions...]
    [#return formatComponentResourceId(
                AWS_S3_RESOURCE_TYPE,
                occurrence.Core.Tier,
                occurrence.Core.Component,
                occurrence,
                extensions)]
[/#function]

[#function formatProductS3Id type extensions...]
    [#return formatProductResourceId(
                AWS_S3_RESOURCE_TYPE,
                type,
                extensions)]
[/#function]

[#function formatAccountS3Id type extensions...]
    [#return formatAccountResourceId(
                AWS_S3_RESOURCE_TYPE,
                type,
                extensions)]
[/#function]

[#function formatBucketPolicyId ids...]
    [#return formatResourceId(
                AWS_S3_BUCKET_POLICY_RESOURCE_TYPE,
                ids)]
[/#function]

[#function formatDependentBucketPolicyId resourceId extensions...]
    [#return formatDependentResourceId(
                AWS_S3_BUCKET_POLICY_RESOURCE_TYPE,
                resourceId,
                extensions)]
[/#function]

[#function formatS3NotificationsQueuePolicyId s3Id queue]
    [#return formatDependentPolicyId(
                s3Id,
                queue)]
[/#function]


[#-- Components --]
[#assign S3_COMPONENT_TYPE = "s3" ]

[#assign componentConfiguration +=
    {
        S3_COMPONENT_TYPE : [
            {
                "Name" : "Lifecycle",
                "Children" : [
                    {
                        "Name" : "Expiration",
                        "Types" : [STRING_TYPE, NUMBER_TYPE],
                        "Description" : "Provide either a date or a number of days"
                    },
                    {
                        "Name" : "Offline",
                        "Types" : [STRING_TYPE, NUMBER_TYPE],
                        "Description" : "Provide either a date or a number of days"
                    },
                    {
                        "Name" : "Versioning",
                        "Type" : BOOLEAN_TYPE,
                        "Default" : false
                    }
                ]
            },
            { 
                "Name" : "Website",
                "Children" : [
                    {
                        "Name": "Index",
                        "Type" : STRING_TYPE,
                        "Default": "index.html"
                    },
                    {
                        "Name": "Error",
                        "Type" : STRING_TYPE,
                        "Default": ""
                    }
                ]
            },
            {
                "Name" : "PublicAccess",
                "Children" : [
                    {
                        "Name" : "Enabled",
                        "Type" : BOOLEAN_TYPE,
                        "Default" : false
                    },
                    {
                        "Name" : "Permissions",
                        "Type" : STRING_TYPE,
                        "Values" : ["ro", "wo", "rw"],
                        "Default" : "ro"
                    },
                    {
                        "Name" : "IPAddressGroups",
                        "Type" : ARRAY_OF_STRING_TYPE,
                        "Default" : [ "_localnet" ]
                    },
                    {
                        "Name" : "Prefix",
                        "Type" : STRING_TYPE,
                        "Default" : ""
                    }
                ]
            },
            {
                "Name" : "Style",
                "Type" : STRING_TYPE,
                "Description" : "TODO(mfl): Think this can be removed"
            },
            {
                "Name" : "Notifications",
                "Type" : OBJECT_TYPE
            }
        ]
    }]
    
[#function getS3State occurrence]
    [#local core = occurrence.Core]
    [#local solution = occurrence.Configuration.Solution]

    [#local id = formatOccurrenceS3Id(occurrence)]
    [#local name = formatOccurrenceBucketName(occurrence) ]

    [#return
        {
            "Resources" : {
                "bucket" : {
                    "Id" : id,
                    "Name" :
                        firstContent(
                            getExistingReference(id, NAME_ATTRIBUTE_TYPE),
                            name),
                    "Type" : AWS_S3_RESOURCE_TYPE
                }
            } +
            solution.PublicAccess.Enabled?then(
                {
                    "bucketpolicy" : {
                        "Id" : formatResourceId(AWS_S3_BUCKET_POLICY_RESOURCE_TYPE, core.Id),
                        "Type" : AWS_S3_BUCKET_POLICY_RESOURCE_TYPE
                    }
                },
                {}
            ),
            "Attributes" : {
                "NAME" : getExistingReference(id, NAME_ATTRIBUTE_TYPE),
                "FQDN" : getExistingReference(id, DNS_ATTRIBUTE_TYPE),
                "INTERNAL_FQDN" : getExistingReference(id, DNS_ATTRIBUTE_TYPE),
                "WEBSITE_URL" : getExistingReference(id, URL_ATTRIBUTE_TYPE),
                "ARN" : getExistingReference(id, ARN_ATTRIBUTE_TYPE),
                "REGION" : regionId
            },
            "Roles" : {
                "Inbound" : {},
                "Outbound" : {
                    "all" : s3AllPermission(id),
                    "produce" : s3ProducePermission(id),
                    "consume" : s3ConsumePermission(id)
               }
            }
        }
    ]
[/#function]
