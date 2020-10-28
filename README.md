# Special Authority Transformation

## Developer setup
This requires [SFDX CLI](https://developer.salesforce.com/tools/sfdxcli) installed and authenticated with a DevHub org with the alias, `devhub`.

```
$ ./dev-setup.bat
```

## Common Commands
Delete scratch org.
```
$ sfdx force:org:delete -u sat-dev
```

List changes between project and scratch org (command must be executed at the project root directory).
```
$ ..\project-root> sfdx force:source:status
```

Pull changes from scratch org into project.
```
$ ..\project-root> sfdx force:source:pull
```

Push changes in project to scratch org.
```
$ ..\project-root> sfdx force:source:push
```

## References
[Salesforce Development with Visual Studio Code](https://developer.salesforce.com/tools/vscode/)

[Lightning Web Components Library and Documentation](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/)
