[#ftl]

[#-- Get stack output --]
[#function aws_input_whatif_stackoutput_filter outputFilter ]
    [#return {
        "Account" : (outputFilter.Account)!accountObject.ProviderId,
        "Region" : outputFilter.Region,
        "DeploymentUnit" : outputFilter.DeploymentUnit
    }]
[/#function]

[#macro aws_input_whatif_stackoutput id="" deploymentUnit="" level="" region="" account=""]

    [#local compositeOutput = getCFCompositeStackOutputs(id, deploymentUnit, level, region, account) ]

    [@debug message="compositeOutput" context=compositeOutput enabled=true /]

    [#if compositeOutput?has_content ]
        [@addStackOutputs compositeOutput /]
    [#else]
        [#local mockOutput = getAWSCFMockStackOutputs(id, deploymentUnit, level, region, account)]
        [@addStackOutputs mockOutput /]
        [@debug message="MockedOutput" context=mockOutput enabled=true /]
    [/#if]

[/#macro]
