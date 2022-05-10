# Release Management

## Package upgrade
_Creates a new build for the current package version number._

Run this command on the branch being upgraded (e.g., `main` or `release/x.y.z`)
```
$ sfdx force:package:version:create -v devhub -d force-app -f config/project-scratch-def.json -x -p "Special Authority App" -w 15 -c
```
When finished, a new package version ID for the new build is inserted in sfdx-project.json. Commit and push the sfdx-project.json to the remote branch.

## Deployment
_These steps comprise all tasks and CLI commands needed to perform a deployment from source control to a sandbox (or production)._

Perform any manual pre-deployment tasks necessary.

Deploy package dependencies in source control.
```
$ sfdx force:source:deploy -p dev-app-pre -u <sandbox>
```

Install package version.
```
$ sfdx force:package:install -p 04t... -u <sandbox> -b 15 -w 15
```

Re-deploy objects and queues in package.
```
$ sfdx force:source:deploy -p force-app/main/default/objects,force-app/main/default/queues -u <sandbox> -w 15
```

Deploy unpackaged metadata. 
```
$ sfdx force:source:deploy -p dev-app-post -u <sandbox>
```

Deploy destructive changes. Remove `-o` parameter if deploying to production. 
```
$ sfdx force:mdapi:deploy -d destructiveChanges -u <sandbox> -o -g -l RunLocalTests -w 15
```

Perform any manual post-deployment tasks necessary.

## Production Deployment Guide
### Pre Deployment
Run this command to mark a package version build as "released" which is required when installing a package to production.
```
$ sfdx force:package:version:promote -p 04t... -v <devhub>
```

### Post Deployment
Once a package version build is marked as released, no other build can be released with that same version number. Therefore, the version number must be "bumped up" to indicate that subsequent builds of the package correspond to the next version number. 

For the Special Authority application, bumping up the version number is a manual task performed by editing the _major_, _minor_, or _version_ components of the `versionNumber` attribute of the "Special Authority App" entry in the list of `packageDirectories`. Example:

```javascript
{
    "packageDirectories": [
        ...
        {
            ...
            "package": "Special Authority App",
            "versionName": "Version 11",
            "versionNumber": "11.0.1.NEXT" // Bump to 11.0.2, 11.1.0, 12.0.0, etc. 
        },
        ...
    ],
    ...
}
```
Commit and push the sfdx-project.json file back to the repository once the version nubmer is bumped up. 

This is typically done immediately after a production deployment to ensure new development builds correspond to the next version number.
## Github Administration

### Authentication to release environments
:warning: **DO NOT USE SFDX AUTH URLS FOR A PRODUCTION USER WITH SYSTEM ADMINISTRATOR RIGHTS.**

Github Actions use Sfdx Auth Url in order to connect to:
- the devhub org for requesting scratch orgs (for pull request build checks), and
- a release sandbox for software deployments. 

Occasionally, Sfdx Auth Urls can expire in which case a repo Admin must udpate them by following these steps.

Authorize local Salesforce CLI with production or a release sandox. Replace "my_alias" with your own. This step can be skipped if CLI is already authorized.
```
$ sfdx force:auth:web:login -r <my url for production or sandbox> -a my_alias
```

Display org details in verbose mode.
```
$ sfdx force:org:display -r my_alias --verbose

KEY              VALUE
───────────────  ──────────────────────────────
...              ...
Alias            my_alias
...              ...
Sfdx Auth Url    <redacted_string>
...              ...
```
Copy the full Sfdx Auth Url value.

Go to the repo's Settings > Secrets > Actions

In the list of Repository Secrets, click "Update" on the SALESFORCE_*_AUTH entry being updated. 

Paste the copied Sfdx Auth Url value in the text box and click "Update secret".

:warning: **DO NOT USE SFDX AUTH URLS FOR A PRODUCTION USER WITH SYSTEM ADMINISTRATOR RIGHTS.**
