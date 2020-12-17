[#ftl]
[#macro aws_adaptor_cf_deployment_generationcontract_application occurrence ]
    [@addDefaultGenerationContract subsets=["prologue", "config", "epilogue" ] /]
[/#macro]

[#macro aws_adaptor_cf_deployment_application occurrence ]
    [@debug message="Entering" context=occurrence enabled=false /]

    [#local core = occurrence.Core ]
    [#local solution = occurrence.Configuration.Solution ]
    [#local resources = occurrence.State.Resources ]
    [#local attributes = occurrence.State.Attributes ]

    [#-- Baseline component lookup --]
    [#local baselineLinks = getBaselineLinks(occurrence, [ "OpsData", "AppData" ] )]

    [#local codeSrcBucket = getRegistryEndPoint("scripts", occurrence)]
    [#local codeSrcPrefix = formatRelativePath(
                                getRegistryPrefix("scripts", occurrence),
                                    getOccurrenceBuildProduct(occurrence, productName),
                                    getOccurrenceBuildScopeExtension(occurrence),
                                    getOccurrenceBuildUnit(occurrence),
                                    getOccurrenceBuildReference(occurrence))]

    [#local buildSettings = occurrence.Configuration.Settings.Build ]
    [#local buildRegistry = buildSettings["BUILD_FORMATS"].Value[0] ]

    [#local asFiles = getAsFileSettings(occurrence.Configuration.Settings.Product) ]

    [#local contextLinks = getLinkTargets(occurrence) ]
    [#local _context =
        {
            "DefaultEnvironment" : defaultEnvironment(occurrence, contextLinks, baselineLinks),
            "Environment" : {},
            "ContextSettings" : {},
            "Links" : contextLinks,
            "BaselineLinks" : baselineLinks,
            "DefaultCoreVariables" : false,
            "DefaultEnvironmentVariables" : true,
            "DefaultLinkVariables" : false,
            "DefaultBaselineVariables" : false
        }
    ]
    [#local _context = invokeExtensions( occurrence, _context )]

    [#local EnvironmentSettings =
        {
            "Json" : {
                "Escaped" : false
            }
        }
    ]

    [#local finalEnvironment = getFinalEnvironment(occurrence, _context, EnvironmentSettings) ]
    [#if deploymentSubsetRequired("config", false)]
        [@addToDefaultJsonOutput
            content=finalEnvironment.Environment
        /]
    [/#if]

    [#if deploymentSubsetRequired("epilogue", false) ]
        [@addToDefaultBashScriptOutput
            content=
                getBuildScript(
                    "src_zip",
                    regionId,
                    buildRegistry,
                    productName,
                    occurrence,
                    buildRegistry + ".zip"
                ) +
                [
                    "addToArray src \"$\{tmpdir}/src/\"",
                    "unzip \"$\{src_zip}\" -d \"$\{src}\""
                ] +
                asFiles?has_content?then(
                     findAsFilesScript("settingsFiles", asFiles),
                     []
                ) +
                getLocalFileScript(
                    "config",
                    "$\{CONFIG}",
                    configFileName
                )
            section="1-Start"
        /]
    [/#if]
[/#macro]
