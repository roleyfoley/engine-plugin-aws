[#ftl]
[#macro aws_lg_cf_deployment_generationcontract_solution occurrence ]
     [@addDefaultGenerationContract subsets="template" /]
[/#macro]

[#macro aws_lg_cf_deployment_solution occurrence ]
    [@debug message="Entering" context=occurrence enabled=false /]

    [#local componentLogGroupId = formatComponentLogGroupId(tier, component)]
    [#if deploymentSubsetRequired("lg", true) &&
            isPartOfCurrentDeploymentUnit(componentLogGroupId)]
        [@createLogGroup
            id=componentLogGroupId
            name=formatComponentLogGroupName(tier, component) /]
    [/#if]
[/#macro]
