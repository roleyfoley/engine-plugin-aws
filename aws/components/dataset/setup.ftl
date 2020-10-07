[#ftl]
[#macro aws_dataset_cf_deployment_generationcontract_application occurrence ]
    [@addDefaultGenerationContract subsets=[ "prologue" ] /]
[/#macro]

[#macro aws_dataset_cf_deployment_application occurrence ]
    [#if deploymentSubsetRequired("prologue", false)]
        [@addToDefaultBashScriptOutput
            [
                "info \"Dataset deployment. Nothing to Do...\""
            ]
        /]
    [/#if]
[/#macro]
