[#ftl]

[#-- Resources --]
[#assign AWS_EFS_RESOURCE_TYPE = "efs" ]
[#assign AWS_EFS_MOUNT_TARGET_RESOURCE_TYPE = "efsMountTarget" ]
[#assign AWS_EFS_ACCESS_POINT_RESOURCE_TYPE = "efsAccessPoint" ]

[#function formatEFSId tier component extensions...]
    [#return formatComponentResourceId(
        AWS_EFS_RESOURCE_TYPE
        tier,
        component,
        extensions)]
[/#function]

[#function formatDependentEFSMountTargetId resourceId extensions...]
    [#return formatDependentResourceId(
                AWS_EFS_MOUNT_TARGET_RESOURCE_TYPE
                resourceId,
                extensions)]
[/#function]
