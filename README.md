# Special Authority Transformation

## Developer setup
This requires [SFDX CLI](https://developer.salesforce.com/tools/sfdxcli) installed and authenticated with a DevHub org with the alias, `devhub`.

```
$ ./dev-setup.bat
```

## Common Salesforce CLI Commands
Delete scratch org.
```
$ sfdx force:org:delete -u sat-dev
```

List changes between project and scratch org.
```
$ ..\MoH-SAT> sfdx force:source:status
```

Pull changes from scratch org into project.
```
$ ..\MoH-SAT> sfdx force:source:pull
```

Push changes in project to scratch org.
```
$ ..\MoH-SAT> sfdx force:source:push
```

## Miscellaneous Commands
Reset local main branch. This wipes out any local changes in `main`.
```
$ ../MoH-SAT> git fetch --all
$ ../MoH-SAT> git checkout main
$ ../MoH-SAT> git reset --hard origin/main
```

Create a new feature branch from `main`.
```
$ ../MoH-SAT> git checkout main
$ ../MoH-SAT> git pull
$ ../MoH-SAT> git checkout -b <name_of_branch>
```

## References
[Salesforce Development with Visual Studio Code](https://developer.salesforce.com/tools/vscode/)

[Lightning Web Components Library and Documentation](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/)
