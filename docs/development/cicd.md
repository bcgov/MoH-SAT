# Release Management
Use these commands for production deployments or if Github Actions are not running.

## Package upgrade
Increments the build number for the current major.minor.patch version defined in sfdx-project.json.

Run this command in the branch being upgraded (e.g., `main` or `release/x.y.z`)
```
sfdx force:package:version:create -v devhub -d force-app -f config/project-scratch-def.json -x -p "Special Authority App" -w 15 -c
```
Commit the sfdx-project.json file where the new package version ID is inserted.

## Package installation
Run any manual pre-install steps.

Deploy package dependencies in source control.
```
$ ../MoH-SAT> sfdx force:source:deploy -p dev-app-pre -u <sandbox>
```

Install package version.
```
$ ../MoH-SAT> sfdx force:package:install -p 04t... -u <sandbox> -b 15 -w 15
```

Re-deploy objects and queues in package.
```
$ ../MoH-SAT> sfdx force:source:deploy -p force-app/main/default/objects,force-app/main/default/queues -u <sandbox> -w 15
```

Deploy post-install package configuration in source control. 
```
$ ../MoH-SAT> sfdx force:source:deploy -p dev-app-post -u <sandbox>
```

Deploy destructive changes listed in source control. Remove `-o` parameter if deploying to production. 
```
$ ../MoH-SAT> sfdx force:mdapi:deploy -d destructiveChanges -u <sandbox> -o -g -l RunLocalTests -w 15
```

Run any manual post-install steps.

## Production Deployment Guide
### Pre Deployment
Run this command to release a package version so it can be installed on production. This step is required for production installations.
```
$ ../MoH-SAT> sfdx force:package:version:promote -p 04t... -v <devhub>
```

### Post Deployment
Each package version released requires a unique version number thereforce once a released packaged is installed on production, its version number must be "bumped" up so subsequent builds of the package are associated to the new version. 

For the Special Authority application, bumping up the version number can be done by editing the _major_, _minor_, or _version_ components of the `versionNumber` attribute of the "Special Authority App" entry in the list of `packageDirectories`. Commit the sfdx-project.json file to the repository once edited.

