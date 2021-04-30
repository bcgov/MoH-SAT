call sfdx force:org:create -v devhub -a sat-build -f config/project-scratch-def.json -d 7 -s
call sfdx force:source:push -u sat-build
call sfdx force:user:permset:assign -u sat-build -n SA_Administrator
call sfdx force:apex:execute -u sat-build -f scripts/apex/set-current-user.apex
call sfdx force:data:bulk:upsert -u sat-build -s Drug__c -f data/drugs.csv -i Drug_Code__c -w 5
call sfdx force:data:bulk:upsert -u sat-build -s Account -f data/accounts.csv -i Id -w 5
call sfdx force:data:bulk:upsert -u sat-build -s Case -f data/cases.csv -i Id -w 5
call sfdx force:data:tree:import -p data/comm-plan.json
call sfdx force:apex:execute -u sat-build -f scripts/apex/add-comm-users.apex
call sfdx force:apex:execute -u sat-build -f scripts/apex/assign-cases-to-ecs.apex
call sfdx force:apex:execute -u sat-build -f scripts/apex/assign-cases-to-queue.apex
call sfdx force:apex:execute -u sat-build -f scripts/apex/add-form-questions.apex
call sfdx force:data:bulk:upsert -u sat-build -s Adjudication_Criteria__c -f data/adjudicationcriteria.csv -i Id -w 5;
call sfdx force:data:bulk:upsert -u sat-build -s Diagnosis__c -f data/diagnosis.csv -i Id -w 5
call sfdx force:data:bulk:upsert -u sat-build -s Product_Health_Category__c -f data/producthealthcategories.csv -i Id -w 5;
call sfdx force:data:bulk:upsert -u sat-build -s Drug_Template__c -f data/drugtemplates.csv -i Id -w 5;
call sfdx force:apex:execute -u sat-build -f scripts/apex/assign-drug-default-queues.apex
call sfdx force:org:open -u sat-build
