# Developer Tips
## Integrate Scratch Org with External Systems. 
_Integrate your scratch org with test instances of ODR, EMPI, EMPI_EDRD, ODR_EDRD or Filescan Connect Web Service._
### Install the needed certificates:
- Download moh_dev_certs.jks from [SAT Developer Home](https://proactionca.ent.cgi.com/confluence/pages/viewpage.action?pageId=132851398).
- Go to Setup > Identity > Certificate and Key Management > Create a self-signed certificate `dev_cert` from Key 4096 and save.
- Go to Setup > Identity > Identity Provider > Enable. Choose `dev_cert` and save.
- Go to Setup > Certificate and Key Management > and click "Import from Keystore" 
- Upload the jks file. Enter "JKS Password" listed in moh-dev-certs.txt on [SAT Developer Home](https://proactionca.ent.cgi.com/confluence/pages/viewpage.action?pageId=132851398).
### Create the needed Named Credentials
_The names of these Named Credentials are CASE SENSITIVE as they are api names that are referenced in code. Please match this carefullly, especially for EMPI as the Label and Name do not match._

The most recent versions of the files for SAT Certificates can be found at this location:
[SAT Developer Home](https://proactionca.ent.cgi.com/confluence/pages/viewpage.action?pageId=132851398).

Go to Setup > Named Credentials.

Create new Legacy Named Credential "EMPI"
- Label: EMPI
- Name: empi
- URL: https://hiat3.hcim.ehealth.gov.bc.ca 
- Certificate: "empidevsat"
- Identity Type: Anonymous
- Athenticaion Protocol: No Authentication needed

Create new Legacy Named Credential "EMPI_EDRD"
- Label: EMPI_EDRD
- Name: empi_edrd
- URL: https://hiat3.hcim.ehealth.gov.bc.ca 
- Certificate: "pharm_edrd"
- Identity Type: Anonymous
- Athenticaion Protocol: No Authentication needed

Create new Legacy Named credential "FilescanConnectWs"
- Label: FilescanConnectWs
- Name: FilescanConnectWs
- URL: https://filescan-dev.hlth.gov.bc.ca
- Certificate to "fcws". 
- Identity Type: Anonymous
- Athenticaion Protocol: No Authentication needed

Create new Legacy Named Credential "ODR Credentials"
- Label: ODR Credentials
- Name: ODR_Credentials
- URL: https://odrdev.hlth.gov.bc.ca
- Certificate: "odrdevcert"

Create new Legacy Named Credential "ODR_EDRD"
- Label: ODR_EDRD
- Name: ODR_EDRD
- URL: https://odrdev.hlth.gov.bc.ca
- Certificate: "odrdevcert"
- Identity Type: Named Principal
- Authentication Protocol:Password Authentication

- Username: _Refer to CERT-DEV-ODR in [moh-dev-certs.txt](https://hlth.sp.gov.bc.ca/sites/HLTHSP/HSIMT/SP/SAT/_layouts/15/DocIdRedir.aspx?ID=F2RWFFZUCM2Q-797944229-1598)_
- Password: _Refer to CERT-DEV-ODR in [moh-dev-certs.txt](https://hlth.sp.gov.bc.ca/sites/HLTHSP/HSIMT/SP/SAT/_layouts/15/DocIdRedir.aspx?ID=F2RWFFZUCM2Q-797944229-1598)_

## Receive Accuroute Emails on Scratch Org
_Receive fax job status emails from the developer instance of Filescan Connect Web Service (filescan-dev.hlth.gov.bc.ca)_

Go to Setup > Email Services

Open "FcEmailService" > click "New Email Address", and enter these values:
- Email Address Name: "FcEmailservice"
- Email Address: "FcEmailservice"
- Active: true
- Context User: "User User" _(scratch org user)_
- Accept Email From: _(empty)_

Save.
## Salesforce CLI commands

```
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
```

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
```
$ code .
```

Pull all recent changes to `main`, create a new branch for a new ticket, then create a scratch org for it.
```
$ git checkout main
$ git pull
$ git checkout -b ESA-<ticket number>
$ ./dev-setup.sh
```  

### Submit changes for release
Run commands
```
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
