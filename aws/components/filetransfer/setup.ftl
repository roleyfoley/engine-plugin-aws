[#ftl]
[#macro aws_filetransfer_cf_generationcontract_solution occurrence ]
    [@addDefaultGenerationContract subsets=[ "prologue", "template", "epilogue" ] /]
[/#macro]

[#macro aws_filetransfer_cf_setup_solution occurrence ]
    [@debug message="Entering" context=occurrence enabled=false /]

    [#local core = occurrence.Core]
    [#local solution = occurrence.Configuration.Solution]
    [#local resources = occurrence.State.Resources]

    [#local transferServerId = resources["transferserver"].Id ]
    [#local transferServerName = resources["transferserver"].Name ]

    [#local securityGroupId = resources["sg"].Id ]
    [#local securityGroupName = resources["sg"].Name ]
    [#local securityGroupPorts = resources["sg"].Ports ]

    [#local lgId = resources["lg"].Id ]

    [#local logRoleId = resources["logRole"].Id ]

    [#local networkProfile = getNetworkProfile(solution.Profiles.Network)]
    [#local loggingProfile = getLoggingProfile(solution.Profiles.Logging)]

    [#local occurrenceNetwork = getOccurrenceNetwork(occurrence) ]
    [#local networkLink = occurrenceNetwork.Link!{} ]

    [#local networkLinkTarget = getLinkTarget(occurrence, networkLink ) ]

    [#if ! networkLinkTarget?has_content ]
        [@fatal message="Network could not be found" context=networkLink /]
        [#return]
    [/#if]

    [#local networkConfiguration = networkLinkTarget.Configuration.Solution]
    [#local networkResources = networkLinkTarget.State.Resources ]

    [#local vpcId = networkResources["vpc"].Id ]

    [#local certificateId = "" ]
    [#if isPresent(solution.Certificate) ]
        [#local certificateObject = getCertificateObject(solution.Certificate, segmentQualifiers ) ]
        [#local hostName = getHostName(certificateObject, subOccurrence) ]
        [#local primaryDomainObject = getCertificatePrimaryDomain(certificateObject) ]
        [#local certificateId = formatDomainCertificateId(certificateObject, hostName) ]
    [/#if]

    [#if deploymentSubsetRequired("prologue", false) ]
        [@addToDefaultBashScriptOutput
            content=
                [
                    r'case ${STACK_OPERATION} in',
                    r'  delete)',
                    r'    info "Removing security group from transfer vpc endpoint..."',
                    r'    manage_transfer_security_groups' +
                    r'     "' + regionId + r'" ' +
                    r'     "${STACK_OPERATION}" ' +
                    r'     "${STACK_NAME}" ' +
                    r'     "' + securityGroupId + r'" ' +
                    r'     "' + transferServerId + r'" || return $?',
                    r'     ;;',
                    r'esac'
                ]
        /]
    [/#if]

    [#local eipIds = []]
    [#list resources["Zones"] as zone, zoneResources ]
        [#if (zoneResources["eip"]!{})?has_content ]
            [#local eipId = zoneResources["eip"].Id ]
            [#local eipName = zoneResources["eip"].Name ]

            [#local eipIds += [ eipId ] ]
            [#if deploymentSubsetRequired("eip", true) &&
                    isPartOfCurrentDeploymentUnit(eipId)]

                [@createEIP
                    id=eipId
                    tags=getOccurrenceCoreTags(occurrence, eipName)
                /]

            [/#if]
        [/#if]
    [/#list]

    [#if deploymentSubsetRequired("iam", true) &&
            isPartOfCurrentDeploymentUnit(logRoleId) ]
        [@createRole
            id=logRoleId
            trustedServices=[ "transfer.amazonaws.com" ]
            policies=[
                getPolicyDocument(
                    cwLogsProducePermission("/aws/transfer/"),
                    "logging"
                )
            ]
        /]
    [/#if]

    [#if deploymentSubsetRequired(FILETRANSFER_COMPONENT_TYPE, true) ]

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
            inboundPorts=securityGroupPorts
        /]

        [#local ingressNetworkRule = {
                "Ports" : securityGroupPorts,
                "IPAddressGroups" : solution.IPAddressGroups
        }]

        [@createSecurityGroupIngressFromNetworkRule
            occurrence=occurrence
            groupId=securityGroupId
            networkRule=ingressNetworkRule
        /]

        [#if getExistingReference(transferServerId)?has_content]
            [@createLogSubscriptionFromLoggingProfile
                occurrence=occurrence
                logGroupId=lgId
                logGroupName={
                    "Fn::Join": [
                        "/",
                        [
                            "aws",
                            "transfer",
                            getReference(transferServerId, NAME_ATTRIBUTE_TYPE)
                        ]
                    ]
                }
                loggingProfile=loggingProfile
            /]
        [/#if]

        [#if multiAZ!false ]
            [#local resourceZones = zones ]
        [#else]
            [#local resourceZones = [ zones[0] ]]
        [/#if]

        [#local subnets = resourceZones?map( zone -> getSubnets(core.Tier, networkResources, zone.Id)[0] ) ]
        [#local vpcDetails =
                    getTransferServerVpcDetails(
                        eipIds,
                        subnets,
                        vpcId
                    )]

        [@createTransferServer
            id=transferServerId
            protocols=solution.Protocols
            vpcDetails=vpcDetails
            logRoleId=logRoleId
            certificateId=certificateId
            tags=getOccurrenceCoreTags(occurrence, transferServerName, "", false)
        /]

    [/#if]

    [#if deploymentSubsetRequired("epilogue", false) ]
        [@addToDefaultBashScriptOutput
            content=
                [
                    r'case ${STACK_OPERATION} in',
                    r'  create|update)',
                    r'    info "Assigning security group to transfer vpc endpoint..."',
                    r'    manage_transfer_security_groups' +
                    r'     "' + regionId + r'" ' +
                    r'     "${STACK_OPERATION}" ' +
                    r'     "${STACK_NAME}" ' +
                    r'     "' + securityGroupId + r'" ' +
                    r'     "' + transferServerId + r'" || return $?',
                    r'     ;;',
                    r'esac'
                ]
        /]
    [/#if]
[/#macro]
