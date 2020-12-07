[#ftl]
[#macro aws_queuehost_cf_deployment_generationcontract occurrence ]
    [@addDefaultGenerationContract subsets="template" /]
[/#macro]

[#macro aws_queuehost_cf_deployment occurrence ]
    [@debug message="Entering" context=occurrence enabled=false /]

    [#-- Component State helpers --]
    [#local core = occurrence.Core ]
    [#local solution = occurrence.Configuration.Solution ]
    [#local resources = occurrence.State.Resources ]

    [#-- Baseline component lookup --]
    [#local baselineLinks = getBaselineLinks(occurrence, [ "Encryption" ] )]
    [#local baselineComponentIds = getBaselineComponentIds(baselineLinks)]
    [#local cmkKeyId = baselineComponentIds["Encryption"]!"" ]

    [#-- Network Lookup --]
    [#local networkLink = getOccurrenceNetwork(occurrence).Link!{} ]
    [#local networkLinkTarget = getLinkTarget(occurrence, networkLink ) ]
    [#if ! networkLinkTarget?has_content ]
        [@fatal message="Network could not be found" context=networkLink /]
        [#return]
    [/#if]
    [#local networkConfiguration = networkLinkTarget.Configuration.Solution]
    [#local networkResources = networkLinkTarget.State.Resources ]
    [#local vpcId = networkResources["vpc"].Id ]

    [#-- Resources and base configuration --]
    [#local brokerId = resources["broker"].Id ]
    [#local brokerFullName = resources["broker"].Name ]
    [#local brokerShortName = resources["broker"].ShortName ]
    [#local brokerPorts = resources["broker"].Ports]
    [#local securityGroupId = resources["sg"].Id ]
    [#local securityGroupName = resources["sg"].Name ]

    [#local engine = solution.Engine]
    [#local engineVersion = solution.EngineVersion ]

    [#local networkProfile = getNetworkProfile(solution.Profiles.Network)]

    [#local hibernate = solution.Hibernate.Enabled && isOccurrenceDeployed(occurrence)]

    [#-- Link Processing --]
    [#list solution.Links?values as link]
        [#if link?is_hash]
            [#local linkTarget = getLinkTarget(occurrence, link) ]

            [@debug message="Link Target" context=linkTarget enabled=false /]

            [#if !linkTarget?has_content]
                [#continue]
            [/#if]

            [#local linkTargetCore = linkTarget.Core ]
            [#local linkTargetConfiguration = linkTarget.Configuration ]
            [#local linkTargetResources = linkTarget.State.Resources ]
            [#local linkTargetAttributes = linkTarget.State.Attributes ]

            [#if deploymentSubsetRequired(QUEUEHOST_COMPONENT_TYPE, true)]
                [@createSecurityGroupRulesFromLink
                    occurrence=occurrence
                    groupId=cacheSecurityGroupId
                    linkTarget=linkTarget
                    inboundPorts=[ port ]
                /]
            [/#if]

        [/#if]
    [/#list]

    [#-- Secret Management --]
    [#local secretStoreLink = getLinkTarget(occurrence, solution.RootCredentials.SecretStore) ]
    [@setupComponentSecret
        occurrence=occurrence
        secretStoreLink=secretStoreLink
        kmsKeyId=cmkKeyId
        secretComponentResources=resources["rootCredentials"]
        secretComponentConfiguration=
            solution.RootCredentials.Secret + {
                "Generated" : {
                    "Content" : { "username" : solution.RootCredentials.Username },
                    "SecretKey" : "password"
                }
            }
        componentType=QUEUEHOST_COMPONENT_TYPE
    /]

    [#-- Output Generation --]
    [#if deploymentSubsetRequired(QUEUEHOST_COMPONENT_TYPE, true)]

        [#-- Network Security --]
        [@createSecurityGroup
            id=securityGroupId
            name=securityGroupName
            vpcId=vpcId
            occurrence=occurrence
        /]

        [@createSecurityGroupRulesFromNetworkProfile
            occurrence=occurrence
            groupId=securityGroupId
            networkProfile=networkProfile
            inboundPorts=brokerPorts
        /]

        [#local ingressNetworkRule = {
                "Ports" : brokerPorts,
                "IPAddressGroups" : solution.IPAddressGroups
        }]

        [@createSecurityGroupIngressFromNetworkRule
            occurrence=occurrence
            groupId=securityGroupId
            networkRule=ingressNetworkRule
        /]


        [#if !hibernate]

            [#-- Monitoring and Alerts --]
            [#list solution.Alerts?values as alert ]

                [#local monitoredResources = getMonitoredResources(core.Id, resources, alert.Resource)]
                [#list monitoredResources as name,monitoredResource ]

                    [@debug message="Monitored resource" context=monitoredResource enabled=false /]

                    [#switch alert.Comparison ]
                        [#case "Threshold" ]
                            [@createAlarm
                                id=formatDependentAlarmId(monitoredResource.Id, alert.Id )
                                severity=alert.Severity
                                resourceName=core.FullName
                                alertName=alert.Name
                                actions=getCWAlertActions(occurrence, solution.Profiles.Alert, alert.Severity )
                                metric=getMetricName(alert.Metric, monitoredResource.Type, core.ShortFullName)
                                namespace=getResourceMetricNamespace(monitoredResource.Type, alert.Namespace)
                                description=alert.Description!alert.Name
                                threshold=alert.Threshold
                                statistic=alert.Statistic
                                evaluationPeriods=alert.Periods
                                period=alert.Time
                                operator=alert.Operator
                                reportOK=alert.ReportOk
                                unit=alert.Unit
                                missingData=alert.MissingData
                                dimensions=getResourceMetricDimensions(monitoredResource, resources)
                            /]
                        [#break]
                    [/#switch]
                [/#list]
            [/#list]

            [#-- Component Specific Resources --]
            [@createAmazonMqBroker
                id=brokerId
                name=brokerShortName
                engineType=engine
                engineVersion=engineVersion
                instanceType=solution.Processor.Type
                multiAz=multiAZ
                encrypted=solution.Encrypted
                kmsKeyId=cmkKeyId
                subnets=getSubnets(core.Tier, networkResources )
                securityGroupId=securityGroupId
                tags=getOccurrenceCoreTags(occurrence, brokerFullName)
                users=[
                    getAmazonMqUser(
                        getSecretManagerSecretRef(resources["rootCredentials"]["secret"].Id, "username"),
                        getSecretManagerSecretRef(resources["rootCredentials"]["secret"].Id, "password")
                    )
                ]
                autoMinorVersionUpdate=solution.AutoMinorUpgrade
                logging=true
                maintenanceWindow=
                    getAmazonMqMaintenanceWindow(
                        solution.MaintenanceWindow.DayOfTheWeek,
                        solution.MaintenanceWindow.TimeOfDay,
                        solution.MaintenanceWindow.TimeZone
                    )
            /]

        [/#if]
    [/#if]
[/#macro]
