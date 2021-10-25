#!/bin/bash

help() {
   echo ""
   echo "USAGE:"
   echo "  $0 [-a <string>] [-d <integer>]"
   echo ""
   echo "OPTIONS:"
   echo -e " -s Source org. Alias of org where drug settings are exported from."
   echo -e " -d Destination org. Alias of org where drug settings are imported into."
   exit 1 # Exit script after printing help
}

verbose=true;

while getopts s:d: opt 
do
   case "$opt" in
   (s) source="$OPTARG" ;;
   (d) destination="$OPTARG" ;;
   (?) help ;;
   esac
done

mkdir ./.tmp
sfdx force:data:soql:query -q "$(< ./scripts/soql/drugs.soql)" -r csv -u $source > .tmp/drugs.csv 
sfdx force:data:soql:query -q "$(< ./scripts/soql/diagnosis.soql)" -r csv -u $source > .tmp/diagnosis.csv
sfdx force:data:soql:query -q "$(< ./scripts/soql/steps.soql)" -r csv -u $source > .tmp/steps.csv
sfdx force:data:soql:query -q "$(< ./scripts/soql/stepcriteria.soql)" -r csv -u $source > .tmp/stepcriteria.csv
sfdx force:data:soql:query -q "$(< ./scripts/soql/stepactions.soql)" -r csv -u $source > .tmp/stepactions.csv

sfdx force:data:bulk:upsert -u $destination -s Drug__c -f .tmp/drugs.csv -i Drug_Code__c -w 5
sfdx force:data:bulk:upsert -u $destination -s Diagnosis__c -f .tmp/diagnosis.csv -i Id -w 5
sfdx force:data:bulk:upsert -u $destination -s Step__c -f .tmp/steps.csv -i Id -w 5
sfdx force:data:bulk:upsert -u $destination -s Step_Criteria__c -f .tmp/stepcriteria.csv -i Id -w 5
sfdx force:data:bulk:upsert -u $destination -s Step_Action__c -f .tmp/stepactions.csv -i Id -w 5
rm -rf ./.tmp