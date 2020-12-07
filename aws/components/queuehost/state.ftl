[#ftl]
[#macro aws_queuehost_cf_state occurrence parent={} ]
    [#local core = occurrence.Core]
    [#local solution = occurrence.Configuration.Solution ]

    [#local id = formatResourceId(AWS_AMAZONMQ_BROKER_RESOURCE_TYPE, core.Id) ]
    [#local securityGroupId = formatDependentSecurityGroupId(id)]

    [#local ports = [ "rabbitmq", "https", "rabbitmq-ui" ]]

    [#local segmentSeedId = formatSegmentSeedId() ]
    [#local segmentSeed = getExistingReference(segmentSeedId)]

    [#assign componentState =
        {
            "Resources" : {
                "broker" : {
                    "Id" : id,
                    "Name" : core.FullName,
                    "ShortName" : formatName( core.ShortFullName, segmentSeed)?truncate_c(50, ''),
                    "Type" : AWS_AMAZONMQ_BROKER_RESOURCE_TYPE,
                    "Ports" : ports,
                    "Monitored" : true
                },
                "sg" : {
                    "Id" : securityGroupId,
                    "Name" : core.FullName,
                    "Type" : AWS_VPC_SECURITY_GROUP_RESOURCE_TYPE
                },
                "rootCredentials" : getComponentSecretResoures(
                    occurrence,
                    "root",
                    "root",
                    "Root credentials for broker"
                 )
            },
            "Attributes" : {
                "ENGINE" : solution.Engine,
                "URL" : getExistingReference(id, URL_ATTRIBUTE_TYPE)
            },
            "Roles" : {
                "Inbound" : {
                    "networkacl" : {
                        "SecurityGroups" : securityGroupId,
                        "Description" : core.FullName
                    }
                },
                "Outbound" : {
                    "networkacl" : {
                        "Ports" : ports,
                        "SecurityGroups" : securityGroupId,
                        "Description" : core.FullName
                    }
                }
            }
        }
    ]
[/#macro]
