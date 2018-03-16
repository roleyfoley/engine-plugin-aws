[#-- ECS --]

[#assign ECS_RESOURCE_TYPE = "ecs" ]

[#assign ECS_COMPONENT_TYPE = "ecs" ]
[#assign SERVICE_COMPONENT_TYPE = "service" ]
[#assign TASK_COMPONENT_TYPE = "task" ]

[#function formatECSRoleId tier component]
    [#-- TODO: Use formatDependentRoleId() --]
    [#return formatComponentRoleId(
                tier,
                component)]
[/#function]

[#function formatECSServiceRoleId tier component]
    [#-- TODO: Use formatDependentRoleId() --]
    [#return formatComponentRoleId(
                tier,
                component,
                "service")]
[/#function]

[#function formatECSSecurityGroupId tier component]
    [#return formatComponentSecurityGroupId(
                tier,
                component)]
[/#function]

[#assign
    containerChildrenConfiguration = [
        {
            "Name" : "Cpu",
            "Default" : ""
        },
        {
            "Name" : "Links",
            "Subobjects" : true,
            "Children" : linkChildrenConfiguration
        },
        {
            "Name" : "LocalLogging",
            "Default" : false
        },
        {
            "Name" : "LogDriver"
        },
        {
            "Name" : ["MaximumMemory", "MemoryMaximum", "MaxMemory"]
        },
        {
            "Name" : ["MemoryReservation", "Memory", "ReservedMemory"],
            "Mandatory" : true
        },
        {
            "Name" : "Ports",
            "Subobjects" : true,
            "Children" : [
                "Container",
                {
                    "Name" : "DynamicHostPort",
                    "Default" : false
                },
                {
                    "Name" : "ELB",
                    "Default" : ""
                },
                {
                    "Name" : "LB",
                    "Children" : [
                        {
                            "Name" : "Component",
                            "Mandatory" : true
                        },
                        "Instance",
                        {
                            "Name" : "LinkName",
                            "Default" : "lb"
                        },
                        {
                            "Name" : "Path",
                            "Default" : ""
                        },
                        {
                            "Name" : "Port",
                            "Default" : ""
                        },
                        {
                            "Name" : "PortMapping",
                            "Default" : ""
                        },
                        {
                            "Name" : "Priority",
                            "Default" : 100
                        },
                        {
                            "Name" : "TargetGroup",
                            "Default" : ""
                        },
                        {
                            "Name" : "Tier",
                            "Mandatory" : true
                        },
                        "Version"
                    ]
                }
            ]
        },
        {
            "Name" : "Version",
            "Default" : ""
        }
    ]
]

[#assign componentConfiguration +=
    {
        ECS_COMPONENT_TYPE : {
            "Attributes" : [
                {
                    "Name" : "ClusterWideStorage",
                    "Default" : false
                },
                {
                    "Name" : "FixedIP",
                    "Default" : false
                },
                {
                    "Name" : "LogDriver",
                    "Default" : "awslogs"
                }
            ],
            "Components" : [
                {
                    "Type" : SERVICE_COMPONENT_TYPE,
                    "Component" : "Services",
                    "Link" : "Service"
                },
                {
                    "Type" : TASK_COMPONENT_TYPE,
                    "Component" : "Tasks",
                    "Link" : "Task"
                }
            ]
        },
        SERVICE_COMPONENT_TYPE : [
            {
                "Name" : "Containers",
                "Subobjects" : true,
                "Children" : containerChildrenConfiguration
            },
            {
                "Name" : "DesiredCount",
                "Default" : -1
            },
            {
                "Name" : "UseTaskRole",
                "Default" : true
            }
        ],
        TASK_COMPONENT_TYPE : [
            {
                "Name" : "Containers",
                "Subobjects" : true,
                "Children" : containerChildrenConfiguration
            },
            {
                "Name" : "UseTaskRole",
                "Default" : true
            } 
        ]
    }
]
    
[#function getECSState occurrence]
    [#local core = occurrence.Core ]
    [#return
        {
            "Resources" : {
                "cluster" : {
                    "Id" : formatResourceId(ECS_RESOURCE_TYPE, core.Id),
                    "Name" : core.FullName
                },
                "securityGroup" : {
                    "Id" : formatECSSecurityGroupId(core.Tier, core.Component)
                },
                "role" : {
                    "Id" : formatECSRoleId(core.Tier, core.Component)
                },
                "serviceRole" : {
                    "Id" : formatECSServiceRoleId(core.Tier, core.Component)
                },
                "instanceProfile" : {
                    "Id" : formatEC2InstanceProfileId(core.Tier, core.Component)
                },
                "autoScaleGroup" : {
                    "Id" : formatEC2AutoScaleGroupId(core.Tier, core.Component)
                },
                "launchConfig" : {
                    "Id" : formatEC2LaunchConfigId(core.Tier, core.Component)
                },
                "logGroup" : {
                    "Id" : formatComponentLogGroupId(core.Tier, core.Component)
                }
            },
            "Attributes" : {},
            "Roles" : {
                "Inbound" : {},
                "Outbound" : {}
            }
        }
    ]
[/#function]

[#function getServiceState occurrence]
    [#local core = occurrence.Core ]
    [#return
        {
            "Resources" : {
                "service" : {
                    "Id" : formatResourceId("ecsService", core.Id)
                },
                "task" : {
                    "Id" : formatResourceId("ecsTask", core.Id)
                }
            },
            "Attributes" : {},
            "Roles" : {
                "Inbound" : {},
                "Outbound" : {}
            }
        }
    ]
[/#function]

[#function getTaskState occurrence]
    [#local core = occurrence.Core ]
    [#return
        {
            "Resources" : {
                "task" : {
                    "Id" : formatResourceId("ecsTask", core.Id)
                }
            },
            "Attributes" : {},
            "Roles" : {
                "Inbound" : {},
                "Outbound" : {}
            }
        }
    ]
[/#function]

[#-- Container --]

[#function formatContainerFragmentId occurrence container]
    [#return formatName(
                getContainerId(container),
                occurrence.Core.Instance.Id,
                occurrence.Core.Version.Id)]
[/#function]

[#function formatContainerSecurityGroupIngressId resourceId container portRange]
    [#return formatDependentSecurityGroupIngressId(
                resourceId,
                getContainerId(container),
                portRange)]
[/#function]
