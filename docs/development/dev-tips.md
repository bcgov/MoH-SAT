# Developer Tips

## Salesforce CLI commands

```bash
# Open the org configured as default alias
$ sfdx force:org:open

# Open the org with the given alias.
$ sfdx force:org:open -u temp_org

# Delete the given org.
$ sfdx force:org:delete -u <alias>

# Delete the given org and skip prompt.
$ sfdx force:org:delete -u <alias> -p

# Upload local file changes to scratch org
$ sfdx force:source:push

# Download scratch org changes to local file system
$ sfdx force:source:pull

# List changes between local file system and scratch org.
$ sfdx force:source:status

# List orgs authenticated to SFDX CLI
$ sfdx force:org:list

# display information about an org, including expiration date.
$ sfdx force:org:display [-u alias] 

```  

## Git commands
```bash

# Switch to a branch 
$ git checkout <branch_name>

# Create a new branch and switch to it
$ git checkout -b branch_name 

# Download changes from remote branch to local branch
$ git pull

# See what changes have been staged, which haven’t and which files aren’t being tracked by git
$ git status 

# Displays the last 10 commits made on the current branch.
$ git log --oneline -10

# Reset current branch to match its remote branch. 
$ git clean -fd
$ git reset --hard

```

## Miscellaneous tips

Opens the current directory in Visual Studio Code
```bash
$ code .
```

Pull all recent changes to `main`, create a new branch for a new ticket, then create a scratch org for it.
```bash
$ git checkout main
$ git pull
$ git checkout -b ESA-<ticket number>
$ ./dev-setup.sh
```  

### Submit changes for release
Run commands
```bash
$ sfdx force:source:pull
$ code .
```
Use VS Code Source Control panel to carefully inspect changed files.

Stage files to be committed.

Add a commit message. Commit.

Push branch to remote repository.

On the remote repository (github.com), create a pull request from your branch to main.

Wait for “build check” to finish.

Merge feature branch to main.

Delete feature branch.

### Setup SSL certificates in your scratch org. 
_Perform these steps to integrate your scratch org with ODR, EMPI, of Filescan Connect Web Service._

Download [moh_dev_certs.jks](https://hlth.sp.gov.bc.ca/sites/HLTHSP/HSIMT/SP/SAT/_layouts/15/DocIdRedir.aspx?ID=F2RWFFZUCM2Q-797944229-1597).

Go to Setup > Identity > Identity Provider > Enable. Choose `dev_cert` and save.

Go to Setup > Certificate and Key Management > and click "Import from Keystore" 

Upload the jks file. Enter "JKS Password" listed in [moh-dev-certs.txt](https://hlth.sp.gov.bc.ca/sites/HLTHSP/HSIMT/SP/SAT/_layouts/15/DocIdRedir.aspx?ID=F2RWFFZUCM2Q-797944229-1597)

Go to Setup > Named Credentials.

Edit "EMPI" named credential and set its certificate to "EMPI". Save.

Edit "FilescanConnectWs" named credential and set its certificate to "fcws". Save.

Edit "ODR Credentials" named credential and edit as follows:
- URL: https://t1specauthsvc.maximusbc.ca
- Certificate: odr
- Username: pnetsauser
- Password: Refer to *CERT-DEV-ODR" listed in [moh-dev-certs.txt](https://hlth.sp.gov.bc.ca/sites/HLTHSP/HSIMT/SP/SAT/_layouts/15/DocIdRedir.aspx?ID=F2RWFFZUCM2Q-797944229-1597)

### Setup Filescan Email Service
_Perform these steps to receive emails from the developer instance of Filescan Connect Web Service (filescan-dev.hlth.gov.bc.ca)_

Go to Setup > Email Services

Open "FcEmailService" > click "New Email Address", and enter these valus:
- Email Address Name: "FcEmailService"
- Email Address: "FcEmailService"
- Active: true
- Context User: "User User" _(scratch org user)_
- Accept Email From: _(empty)_
Save.
