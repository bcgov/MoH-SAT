call sfdx force:org:create -v devhub -a sat-dev -f config/project-scratch-def.json -d 30 -s
call sfdx force:source:push
call sfdx force:user:permset:assign -n SA_Administrator
call sfdx force:apex:execute -f scripts/apex/set-user-role.apex
call sfdx force:data:bulk:upsert -s Drug__c -f data\drugs.csv -i API_Name__c -w 5
call sfdx force:data:bulk:upsert -s Account -f data\accounts.csv -i Id -w 5