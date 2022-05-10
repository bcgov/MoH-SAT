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

replace_group_id() {
   while IFS=, read -r src_grp_id src_grp_name; do
      if [ "$dest_grp_name" = "$src_grp_name" ]; then
         sed -i -e "s/$src_grp_id/$dest_grp_id/g" .tmp/drugs.csv .tmp/stepactions.csv;
      fi
   done < .tmp/groups-src.csv
}

replace_group_ids() {
   while IFS=, read -r dest_grp_id dest_grp_name; do
      if [ "$dest_grp_name" != "DeveloperName" ]; then
         replace_group_id $grp_name $grp_id
      fi
   done < .tmp/groups-dest.csv
}

replace_user_ids() {
   dest_user_id=$(sfdx force:user:display -u $destination --json 2> /dev/null | grep -o '005[a-zA-Z0-9]*')
   sed -i -e "s/^005[a-zA-Z0-9]*,/$dest_user_id,/g" .tmp/drugs.csv .tmp/stepactions.csv;
}

check_destination() {
   result=$(sfdx force:user:display -u $destination --json 2> /dev/null);
   instanceUrl=`echo $result | sed -e 's/^.*"instanceUrl"[ ]*:[ ]*//' -e 's/\,.*//'`
   if [[ "$instanceUrl" == *"bchealth.my.salesforce.com"* ]]; then
      echo "ERROR: Cannot set production as destination. $destination points to bchealth.my.salesforce.com."
      exit 1;
   fi 
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

check_destination

mkdir ./.tmp
echo "Exporting data from $source..."
sfdx force:data:soql:query -q "$(< ./scripts/soql/drugs.soql)" -r csv -u $source > .tmp/drugs.csv 2> /dev/null
sfdx force:data:soql:query -q "$(< ./scripts/soql/diagnosis.soql)" -r csv -u $source > .tmp/diagnosis.csv 2> /dev/null
sfdx force:data:soql:query -q "$(< ./scripts/soql/steps.soql)" -r csv -u $source > .tmp/steps.csv 2> /dev/null
sfdx force:data:soql:query -q "$(< ./scripts/soql/stepcriteria.soql)" -r csv -u $source > .tmp/stepcriteria.csv 2> /dev/null
sfdx force:data:soql:query -q "$(< ./scripts/soql/stepactions.soql)" -r csv -u $source > .tmp/stepactions.csv 2> /dev/null
sfdx force:data:soql:query -q "$(< ./scripts/soql/producthealthcategories.soql)" -r csv -u $source > .tmp/producthealthcategories.csv 2> /dev/null
sfdx force:data:soql:query -q "$(< ./scripts/soql/rdpdescriptions.soql)" -r csv -u $source > .tmp/rdpdescriptions.csv 2> /dev/null
sfdx force:data:soql:query -q "$(< ./scripts/soql/groups.soql)" -r csv -u $source > .tmp/groups-src.csv 2> /dev/null
sfdx force:data:soql:query -q "$(< ./scripts/soql/groups.soql)" -r csv -u $destination > .tmp/groups-dest.csv 2> /dev/null

echo "Matching Queue IDs between $source and $destination..."
replace_group_ids;

echo "Replacing all user-owned drugs and step actions to current user in $source..."
replace_user_ids

echo "Cleaning drug management data in $destination..."
echo "delete [select id from Step_Action__c]; delete [select id from Step_Criteria__c]; delete [select id from Step__c]; delete [select id from Diagnosis__c]; delete [select id from Product_Health_Category__c]; delete [select id from RDP_Code_Description__c];" >> .tmp/clean-drugs.apex
sfdx force:apex:execute -u $destination -f .tmp/clean-drugs.apex 2> /dev/null

echo "Uploading drug management data to $destination..."
sfdx force:data:bulk:upsert -u $destination -s Drug__c -f .tmp/drugs.csv -i Drug_Code__c -w 5  2> /dev/null
sfdx force:data:bulk:upsert -u $destination -s Diagnosis__c -f .tmp/diagnosis.csv -i Id -w 5  2> /dev/null
sfdx force:data:bulk:upsert -u $destination -s Step__c -f .tmp/steps.csv -i Id -w 5  2> /dev/null
sfdx force:data:bulk:upsert -u $destination -s Step_Criteria__c -f .tmp/stepcriteria.csv -i Id -w 5  2> /dev/null
sfdx force:data:bulk:upsert -u $destination -s Step_Action__c -f .tmp/stepactions.csv -i Id -w 5  2> /dev/null
sfdx force:data:bulk:upsert -u $destination -s Product_Health_Category__c -f .tmp/producthealthcategories.csv -i Id -w 5  2> /dev/null
sfdx force:data:bulk:upsert -u $destination -s RDP_Code_Description__c -f .tmp/rdpdescriptions.csv -i Id -w 5  2> /dev/null
rm -rf ./.tmp