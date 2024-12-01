#!/bin/bash

help() {
   echo ""
   echo "USAGE:"
   echo "  $0 [-a <string>] [-d <integer>]"
   echo ""
   echo "OPTIONS:"
   echo -e " -a Alias. Set a custom alias for scratch org. Default: 'sat-dev'."
   echo -e " -d Duration. Set a custom duration for a scratch org. Default: 7, min: 1, max: 30."
   echo ""
   echo "EXAMPLES:"
   echo -e "\t $ $0 -a feature-x -d 20"
   exit 1 # Exit script after printing help
}

verbose=true;
duration=15;
alias='sat-dev';

while getopts a:d: opt 
do
   case "$opt" in
   (a) alias="$OPTARG" ;;
   (d) duration="$OPTARG" ;;
   (?) help ;;
   esac
done

dx() { 
    if [ "$verbose" = true ]
    then
      # Print command and run.
      echo "\$ sfdx ${@/eval/}" ; sfdx "$@" ;
      status=$?
    else
      # Suppress sfdx's output, and read the status property of the resulting JSON output instead. 
      result=$(sfdx "$@" --json 2> /dev/null);
      status=`echo $result | sed -e 's/^.*"status"[ ]*:[ ]*//' -e 's/\,.*//'`
    fi
    
    # Exit early on error.
    if [ $status -eq 1 ]
    then 
      if [ "$verbose" = false ]
      then
        message=`echo $result | sed -e 's/^.*"message"[ ]*:[ ]*//' -e 's/\,.*//'`
        echo " Error $message on \"$@\""
      fi

      exit 1;
    fi
}

echo "Creating scratch org, \"$alias\"..."
# dx force:org:create -v devhub -a $alias -f config/project-scratch-def.json -d $duration -s
sf org create scratch --definition-file config/project-scratch-def.json --alias $alias --set-default --target-dev-hub devhub
#dx force:data:record:update -u $alias -s Organization -w "Name='Special Authority Scratch Org'" -v "TimeZoneSidKey='America/Los_Angeles'"
sf  data update record -u $alias -s Organization -w "Name='Special Authority Scratch Org'" -v "TimeZoneSidKey='America/Los_Angeles'"

#dx force:data:record:update -u $alias -s User -w "Name='User User'" -v "TimeZoneSidKey='America/Los_Angeles'"
sf data update record -u $alias -s User -w "Name='User User'" -v "TimeZoneSidKey='America/Los_Angeles'"

echo "Installing OmniStudio managed package"
sf package install --package "04t4W000003CjY5" --target-org $alias -w 15 --noprompt 

echo "Installing Health Cloud managed package"
sf package install --package "04t4W000002V2Ub" --target-org $alias -w 15 --noprompt 

echo "Set deployment user standard security"
#sfdx force:user:permsetlicense:assign -u $alias -n "OmniStudio"
sf org assign permsetlicense --name OmniStudio --target-org $alias

#sfdx force:user:permsetlicense:assign -u $alias -n "OmniStudio User"

#sf org assign permsetlicense --name OmniStudio User --target-org $alias

#sf org assign permsetlicense --name OmniStudioUser --target-org $alias
#sfdx force:user:permset:assign -u $alias -n OmniStudioAdmin

#sf org assign permset --name OmniStudioAdmin --target-org $alias
#sfdx force:user:permset:assign -u $alias -n OmniStudioExecution
#sf org assign permset --name OmniStudioExecution --target-org $alias 
#sfdx force:user:permsetlicense:assign -u $alias -n "Health Cloud"

sf org assign permsetlicense --name HealthCloudGA_HealthCloudPsl --target-org $alias
#sfdx force:user:permsetlicense:assign -u $alias -n "Health Cloud Platform"

#sf org assign permsetlicense --name Health Cloud Platform --target-org $alias
#sfdx force:user:permset:assign -u $alias -n HealthCloudFoundation

sf org assign permset --name HealthCloudFoundation --target-org $alias

echo "Uploading source code..."
#sfdx force:source:deploy -p dev-app-pre -u $alias

sf project deploy start --source-dir dev-app-pre --target-org $alias 
#sfdx force:source:deploy -p force-app -u $alias

sf project deploy start --source-dir force-app --target-org $alias --ignore-conflicts
#sfdx force:source:deploy -p force-app/main/default/objects,force-app/main/default/queues -u $alias -w 15
#sfdx force:source:deploy -p force-app/main/default/objects -u $alias

sf project deploy start --source-dir force-app/main/default/objects --target-org $alias
#sfdx force:source:deploy -p force-app/main/default/queues -u $alias

sf project deploy start --source-dir force-app/main/default/queues --target-org $alias
#sfdx force:source:deploy -p OmniStudio-Components -u $alias

sf project deploy start --source-dir OmniStudio-Components --target-org $alias
#sfdx force:source:deploy -p dev-app-post -u $alias

sf project deploy start --source-dir dev-app-post --target-org $alias --ignore-conflicts

#sfdx force:source:tracking:reset -u $alias --noprompt 
sf project reset tracking --target-org $alias --noprompt 
#dx force:source:push -u $alias 
sf project deploy start --target-org $alias

echo "Assigning permissions..."
#sfdx force:user:permset:assign -u $alias -n SA_Administrator

sf org assign permset --name SA_Administrator --target-org $alias
#sfdx force:user:permset:assign -u $alias -n EDRD_PS_Operational_Support

sf org assign permset --name EDRD_PS_Operational_Support --target-org $alias
#sfdx force:apex:execute -u $alias -f scripts/apex/scratchorg-set-current-user.apex
sf apex run --file scripts/apex/scratchorg-set-current-user.apex --target-org $alias

echo "Uploading data..."
#dx force:data:bulk:upsert -u $alias -s Drug__c -f data/drugs.csv -i Drug_Code__c -w 5 
sf force data bulk upsert --sobject Drug__c --file data/drugs.csv --external-id Drug_Code__c --wait 5 --target-org $alias
#dx force:data:bulk:upsert -u $alias -s Account -f data/accounts.csv -i Id -w 5 
sf force data bulk upsert --sobject Account --file data/accounts.csv --external-id Id --wait 5 --target-org $alias
#dx force:data:bulk:upsert -u $alias -s Account -f data/decs.csv -i Id -w 5 
sf force data bulk upsert --sobject Account --file data/decs.csv --external-id Id --wait 5 --target-org $alias
#dx force:data:bulk:upsert -u $alias -s Case -f data/cases.csv -i Id -w 5
sf force data bulk upsert --sobject Case --file data/cases.csv --external-id Id --wait 5 --target-org $alias
#dx force:data:tree:import -u $alias -p data/comm-plan.json
sf data import tree --files data/comm-plan.json --target-org $alias
#dx force:apex:execute -u $alias -f scripts/apex/scratchorg-add-comm-users.apex
sf apex run --target-org $alias --file scripts/apex/scratchorg-add-comm-users.apex
#dx force:apex:execute -u $alias -f scripts/apex/scratchorg-assign-cases-to-ecs.apex
sf apex run --target-org $alias --file scripts/apex/scratchorg-assign-cases-to-ecs.apex
sf apex run --target-org $alias --file scripts/apex/scratchorg-add-comm-users.apex
#sf apex run --target-org $alias --file scripts/apex/scratchorg-add-comm-users.apex
#dx force:apex:execute -u $alias -f scripts/apex/scratchorg-assign-cases-to-queue.apex
sf apex run --target-org $alias --file scripts/apex/scratchorg-assign-cases-to-queue.apex
#dx force:apex:execute -u $alias -f scripts/apex/scratchorg-add-form-questions.apex
sf apex run --target-org $alias --file scripts/apex/scratchorg-add-form-questions.apex
#dx force:data:bulk:upsert -u $alias -s Diagnosis__c -f data/diagnosis.csv -i Id -w 5
sf force data bulk upsert --sobject Diagnosis__c --file data/diagnosis.csv --external-id Id --wait 5 --target-org $alias
#dx force:data:bulk:upsert -u $alias -s Product_Health_Category__c -f data/producthealthcategories.csv -i Id -w 5
sf force data bulk upsert --sobject Product_Health_Category__c --file data/producthealthcategories.csv --external-id Id --wait 5 --target-org $alias
#dx force:data:bulk:upsert -u $alias -s Step__c -f data/steps.csv -i Id -w 5
sf force data bulk upsert --sobject Step__c --file data/steps.csv --external-id Id --wait 5 --target-org $alias
#dx force:data:bulk:upsert -u $alias -s Step_Criteria__c -f data/stepcriteria.csv -i Id -w 5
sf force data bulk upsert --sobject Step_Criteria__c --file data/stepcriteria.csv --external-id Id --wait 5 --target-org $alias
#dx force:data:bulk:upsert -u $alias -s Step_Action__c -f data/stepactions.csv -i Id -w 5
sf force data bulk upsert --sobject Step_Action__c --file data/stepactions.csv --external-id Id --wait 5 --target-org $alias
#dx force:apex:execute -u $alias -f scripts/apex/scratchorg-assign-drug-default-queues.apex
sf apex run --target-org $alias --file scripts/apex/scratchorg-assign-drug-default-queues.apex

echo "$alias is ready."
#dx force:org:open -u $alias;
sf org open --target-org $alias