[#ftl]
[#include "setContext.ftl"]

[#-- Special processing --]
[#switch deploymentUnit]
    [#case "eip"]
    [#case "iam"]
    [#case "lg"]
        [#if !(deploymentUnitSubset?has_content)]
            [#assign allDeploymentUnits = true]
            [#assign deploymentUnitSubset = deploymentUnit]
            [#assign ignoreDeploymentUnitSubsetInOutputs = true]
        [/#if]
        [#break]
[/#switch]

[#assign componentLevel="solution" ]
[@cfTemplate
    level=componentLevel
    compositeLists=solutionList /]
