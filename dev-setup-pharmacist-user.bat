call sfdx force:user:create -a pharmacist-user -f config/test-pharmacist-user.json
call sfdx force:apex:execute -u sat-dev -f scripts/apex/set-test-pharmacist-role.apex
