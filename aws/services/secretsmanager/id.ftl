[#ftl]

[#-- Resources --]
[#assign AWS_SECRETS_MANAGER_SECRET_RESOURCE_TYPE = "secret" ]
[@addServiceResource
    provider=AWS_PROVIDER
    service=AWS_SECRETS_MANAGER_SERVICE
    resource=AWS_SECRETS_MANAGER_SECRET_RESOURCE_TYPE
/]
