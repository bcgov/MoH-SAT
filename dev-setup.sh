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
duration=7;
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
dx force:org:create -v devhub -a $alias -f config/project-scratch-def.json -d $duration -s
dx force:data:record:update -u $alias -s Organization -w "Name='Special Authority Scratch Org'" -v "TimeZoneSidKey='America/Los_Angeles'"
dx force:data:record:update -u $alias -s User -w "Name='User User'" -v "TimeZoneSidKey='America/Los_Angeles'"

echo "Uploading source code..."
dx force:source:push -u $alias 

echo "Assigning permissions..."
dx force:user:permset:assign -u $alias -n SA_Administrator
dx force:apex:execute -u $alias -f scripts/apex/scratchorg-set-current-user.apex

echo "Uploading data..."
dx force:data:bulk:upsert -u $alias -s Drug__c -f data/drugs.csv -i Drug_Code__c -w 5 
dx force:data:bulk:upsert -u $alias -s Account -f data/accounts.csv -i Id -w 5 
dx force:data:bulk:upsert -u $alias -s Account -f data/decs.csv -i Id -w 5 
dx force:data:bulk:upsert -u $alias -s Case -f data/cases.csv -i Id -w 5
dx force:data:tree:import -u $alias -p data/comm-plan.json
dx force:apex:execute -u $alias -f scripts/apex/scratchorg-add-comm-users.apex
dx force:apex:execute -u $alias -f scripts/apex/scratchorg-assign-cases-to-ecs.apex
dx force:apex:execute -u $alias -f scripts/apex/scratchorg-assign-cases-to-queue.apex
dx force:apex:execute -u $alias -f scripts/apex/scratchorg-add-form-questions.apex
dx force:data:bulk:upsert -u $alias -s Diagnosis__c -f data/diagnosis.csv -i Id -w 5
dx force:data:bulk:upsert -u $alias -s Product_Health_Category__c -f data/producthealthcategories.csv -i Id -w 5
dx force:data:bulk:upsert -u $alias -s Step__c -f data/steps.csv -i Id -w 5
dx force:data:bulk:upsert -u $alias -s Step_Criteria__c -f data/stepcriteria.csv -i Id -w 5
dx force:data:bulk:upsert -u $alias -s Step_Action__c -f data/stepactions.csv -i Id -w 5
dx force:apex:execute -u $alias -f scripts/apex/scratchorg-assign-drug-default-queues.apex

echo "$alias is ready."
dx force:org:open -u $alias;