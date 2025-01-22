#!/bin/bash

help() {
   echo ""
   echo "USAGE:"
   echo "  $0 [-a <string>] [-d <integer>]"
   echo ""
   echo "OPTIONS:"
   echo -e " -a Alias. Set a custom alias for scratch org. Default: 'dev-scratch'."
   echo -e " -d Duration. Set a custom duration for a scratch org. Default: 7, min: 1, max: 30."
   echo ""
   echo "EXAMPLES:"
   echo -e "\t $ $0 -a feature-x -d 20"
   exit 1 # Exit script after printing help
}

verbose=true;
duration=15;
alias='dev-scratch';

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

sf org create scratch --definition-file config/project-scratch-def.json --alias $alias --set-default --target-dev-hub devhub
sf data update record -u $alias -s Organization -w "Name='Special Authority Scratch Org'" -v "TimeZoneSidKey='America/Los_Angeles'"
sf data update record -u $alias -s User -w "Name='User User'" -v "TimeZoneSidKey='America/Los_Angeles'"

echo "Installing OmniStudio managed package"

sf package install --package "04t4W000003CjY5" --target-org $alias -w 15 --noprompt 

echo "Installing Health Cloud managed package"

sf package install --package "04t4W000002V2Ub" --target-org $alias -w 15 --noprompt 

echo "Set deployment user standard security"

sf org assign permsetlicense --name OmniStudio --target-org $alias
sf org assign permsetlicense --name HealthCloudGA_HealthCloudPsl --target-org $alias
sf org assign permset --name HealthCloudFoundation --target-org $alias
sf org assign permset --name DocGenDesigner --target-org $alias
sf org assign permset --name DocGenUser --target-org $alias
sf org assign permset --name BREDesigner --target-org $alias
sf org assign permset --name BRERuntime --target-org $alias
sf org assign permsetlicense --name BREDesigner --target-org $alias
sf org assign permsetlicense --name BRERuntime --target-org $alias


echo "Uploading source code..."

sf project deploy start --source-dir dev-app-pre --target-org $alias 
sf project deploy start --source-dir force-app --target-org $alias --ignore-conflicts
sf project deploy start --source-dir force-app/main/default/objects --target-org $alias
sf project deploy start --source-dir force-app/main/default/queues --target-org $alias
sf project deploy start --source-dir OmniStudio-Components --target-org $alias
sf project deploy start --source-dir dev-app-post --target-org $alias --ignore-conflicts
#sfdx force:source:tracking:reset -u $alias --noprompt 
sf project reset tracking --target-org $alias --noprompt 
#dx force:source:push -u $alias 
sf project deploy start --target-org $alias

echo "Assigning permissions..."

sf org assign permset --name SA_Administrator --target-org $alias
sf org assign permset --name EDRD_PS_Operational_Support --target-org $alias
sf apex run --file scripts/apex/scratchorg-set-current-user.apex --target-org $alias

echo "Uploading data..."

sf force data bulk upsert --sobject Drug__c --file data/drugs.csv --external-id Drug_Code__c --wait 5 --target-org $alias
sf force data bulk upsert --sobject Account --file data/accounts.csv --external-id Id --wait 5 --target-org $alias
sf force data bulk upsert --sobject Account --file data/decs.csv --external-id Id --wait 5 --target-org $alias
sf force data bulk upsert --sobject Case --file data/cases.csv --external-id Id --wait 5 --target-org $alias
sf data import tree --files data/comm-plan.json --target-org $alias
sf apex run --target-org $alias --file scripts/apex/scratchorg-add-comm-users.apex
sf apex run --target-org $alias --file scripts/apex/scratchorg-assign-cases-to-ecs.apex
sf apex run --target-org $alias --file scripts/apex/scratchorg-add-comm-users.apex
sf apex run --target-org $alias --file scripts/apex/scratchorg-assign-cases-to-queue.apex
sf apex run --target-org $alias --file scripts/apex/scratchorg-add-form-questions.apex
sf force data bulk upsert --sobject Diagnosis__c --file data/diagnosis.csv --external-id Id --wait 5 --target-org $alias
sf force data bulk upsert --sobject Product_Health_Category__c --file data/producthealthcategories.csv --external-id Id --wait 5 --target-org $alias
sf force data bulk upsert --sobject Step__c --file data/steps.csv --external-id Id --wait 5 --target-org $alias
sf force data bulk upsert --sobject Step_Criteria__c --file data/stepcriteria.csv --external-id Id --wait 5 --target-org $alias
sf force data bulk upsert --sobject Step_Action__c --file data/stepactions.csv --external-id Id --wait 5 --target-org $alias
sf apex run --target-org $alias --file scripts/apex/scratchorg-assign-drug-default-queues.apex

echo "$alias is ready."

sf org open --target-org $alias