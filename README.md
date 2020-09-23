 ###  Powershell script for creating sites structure in IIS for .Net Core applications.
----

Powershell script for creating sites in IIS with ApplicationPools and Authentication setup.

It's maybe usefull when needs to create IIS sites for many .Net Core applications (for example microservices), setup many ApplicationPools for each application and set Authentication. And then cleanup all sites and application pools installed before.
Also can be created many configuration files for separated sites sets.

Description
----
```services_conf.json```
Configuration file in JSON format. Contains information about sites names, ports, paths, application pools, auth and child sites including virtual directories.

```services_setup.ps1```
Script for creating IIS sites, application pools and set authentication.  Has 3 input parameters: user login, user password, config file name. Application pools will be created with custom account identity (user login and password).

```services_cleanup.ps1```
Script for deleting IIS sites and application pools by configuration file. Has 1 input parameter: config file name.

Examples:
----
**For setup:**
```powershell
PS> ./services_setup.ps1 login pass services_conf.json
```

**For cleanup:**
```powershell
PS> ./services_cleaup.ps1 services_conf.json
```

License
----

MIT



