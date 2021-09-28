# Environment Setup
    
### Install Node.js
Install Node.js https://nodejs.org/en/ (requires IT approval).

### Sign-up for Github
Signup for a github account at https://github.com and send send your github username to the repository administrator.

### Install Git.
Download and install with default settings: https://git-scm.com/


### Install Visual Studio Code
Download and install Visual Studio Code from https://code.visualstudio.com/

### Install Salesforce Extensions for Visual Studio Code
Click the "Install" button for the [Salesforce Extension Pack](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode)

### Install Salesforce CLI 
Open git bash and run the following command to install Salesforce CLI:

```
$ npm install sfdx-cli --global
```

Close and re-open git bash to run the following steps.

### Setup Git once 
Replace name and email with your own.

```
$ git config --global user.name "John Doe"
$ git config --global user.email john.doe@gov.bc.ca
```

### Authenticate Salesforce CLI with the BCHealth production org

The following command opens the browser where you are prompted to log in to https://bchealth.my.salesforce.com with your credentials, and authorize the Salesforce CLI. You may close the tab once you are on the home page and proceed with the next step.
 
```
$ sfdx force:auth:web:login --instanceurl https://bchealth.my.salesforce.com --setalias devhub -d --setdefaultdevhubusername
```

### Clone the SAT project repository
```
$ cd c:
$ mkdir Development
$ cd Development
$ git clone https://github.com/bcgov/MoH-SAT
$ cd MoH-SAT
```

### Run setup script.

```
$ ./dev-setup.sh
```

The above command will run a script that:
- creates a scratch org with a default alias named `sat-dev`,
- uploads source code in current git branch to the scratch org,
- populates the scratch org with test data: patients, providers, DECs, cases, drugs, and drug configuration.
- opens the scratch org on a new browser tab.

