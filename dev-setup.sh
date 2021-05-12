#!/bin/bash

help() {
   echo ""
   echo "Usage: $0 -a <string>"
   echo -e "\t-a Set an alias for scratch org. Default 'sat-dev'."
   exit 1 # Exit script after printing help
}

verbose=true;
alias='sat-dev';

while getopts a: opt 
do
   case "$opt" in
   (a) alias="$OPTARG" ;;
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
dx force:org:create -v devhub -a $alias -f config/project-scratch-def.json -d 7 -s
dx force:data:record:update -u $alias -s Organization -w "Name='Special Authority Scratch Org'" -v "TimeZoneSidKey='America/Los_Angeles'"
dx force:data:record:update -u $alias -s User -w "Name='User User'" -v "TimeZoneSidKey='America/Los_Angeles'"

echo "Uploading source code..."
dx force:source:push -u $alias 

echo "Assigning permissions..."
dx force:user:permset:assign -u $alias -n SA_Administrator
dx force:apex:execute -u $alias -f scripts/apex/set-current-user.apex

echo "Uploading data..."
dx force:data:bulk:upsert -u $alias -s Drug__c -f data/drugs.csv -i Drug_Code__c -w 5 
dx force:data:bulk:upsert -u $alias -s Account -f data/accounts.csv -i Id -w 5 
dx force:data:bulk:upsert -u $alias -s Case -f data/cases.csv -i Id -w 5
dx force:data:tree:import -p data/comm-plan.json
dx force:apex:execute -u $alias -f scripts/apex/add-comm-users.apex
dx force:apex:execute -u $alias -f scripts/apex/assign-cases-to-ecs.apex
dx force:apex:execute -u $alias -f scripts/apex/assign-cases-to-queue.apex
dx force:apex:execute -u $alias -f scripts/apex/add-form-questions.apex
dx force:data:bulk:upsert -u $alias -s Adjudication_Criteria__c -f data/adjudicationcriteria.csv -i Id -w 5
dx force:data:bulk:upsert -u $alias -s Diagnosis__c -f data/diagnosis.csv -i Id -w 5
dx force:data:bulk:upsert -u $alias -s Drug_Template__c -f data/drugtemplates.csv -i Id -w 5
dx force:data:bulk:upsert -u $alias -s Product_Health_Category__c -f data/producthealthcategories.csv -i Id -w 5
dx force:apex:execute -u $alias -f scripts/apex/assign-drug-default-queues.apex

echo "$alias is ready."
dx force:org:open -u $alias;