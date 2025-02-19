#!/bin/bash

# Ensure that both source and destination orgs are provided
if [ $# -ne 2 ]; then
  echo "Usage: $0 <source-org> <destination-org>"
  exit 1
fi

# Get the source and destination org arguments
source_org=$1
destination_org=$2

# Create the Export directory if it doesn't exist
mkdir -p Export

# First data export command
sf data export bulk --query "select OwnerId, Approval_Details__c, Auto_Adjudication_Requirements__c, Auto_Push_to_Pharmanet__c, Auto_Validate_Patient__c, Auto_Validate_Provider__c, Brand_Drug_Name__c, CDEC_Recommendation__c, Criteria_Website__c, DBC_R_R__c, Drug_Code__c, Drug_Review_Results__c, Form__c, Health_Canada_monograph__c, PharmaNet_RDP_code__c, Pharmacist_Notes__c, Practitioner_Exemptions__c, Special_Notes__c, Strength__c, Tech_Sheet__c, Name from Drug__c where Drug_Code__c != null order by Drug_Code__c asc" --output-file Export\drugs.csv --result-format csv --wait 10 --target-org $source_org

sf data upsert bulk -s Drug__c -f Export/drugs.csv -i Drug_Code__c -w 5 -o $destination_org

# Second data export command
sf data export bulk --query " select Drug__r.Drug_Code__c,Diagnosis__c,Hierarchy__c from Diagnosis__c where Drug__r.Drug_Code__c != null order by Drug__r.Drug_Code__c asc" --output-file Export\diagnosis.csv --result-format csv --wait 10 --target-org $source_org

sf data upsert bulk -s Diagnosis__c -f Export/diagnosis.csv -i Id -w 5 -o $destination_org

# Third data export command
sf data export bulk --query "select External_ID__c,Name,Drug__r.Drug_Code__c,Order__c,Description__c,Criteria_Logic__c,Always_Run__c from Step__c where Drug__r.Drug_Code__c != null order by Drug__r.Drug_Code__c asc" --output-file Export/steps.csv --result-format csv --wait 10 --target-org $source_org

sf data upsert bulk -s Step__c -f Export/steps.csv -i Id -w 5 -o $destination_org

# Fourth data export command
sf data export bulk --query "select Step__r.External_ID__c,Object_Name__c,Field_Name__c,Operator__c,Order__c,Question_ID__c,String_Value__c,Boolean_Value__c from Step_Criteria__c where Step__r.Drug__r.Drug_Code__c != null and Step__r.External_ID__c != NULL order by Step__r.External_ID__c asc" --output-file Export/stepcriteria.csv --result-format csv --wait 10 --target-org $source_org

sf data upsert bulk -s Step_Criteria__c -f Export/stepcriteria.csv -i Id -w 5 -o $destination_org

# Fifth data export command
sf data export bulk --query "select OwnerId, Step__r.External_ID__c, Order__c, RecordType.Name, Adjudication_Status__c, Days_Supply__c, Duration_Unit__c, Duration__c, Excluded_Plans__c, Justification_Codes__c, Key_Type__c, Pharmanet_Code__c, Price_Percent__c, SA_Type__c from Step_Action__c where Step__r.Drug__r.Drug_Code__c != null and Step__r.External_ID__c != NULL order by Step__r.External_ID__c asc" --output-file Export/stepactions.csv --result-format csv --wait 10 --target-org $source_org

sf data upsert bulk -s Step_Action__c -f Export/stepactions.csv -i Id -w 5 -o $destination_org

# Sixth data export command
sf data export bulk --query "select Id,DeveloperName from Group where Type='Queue'" --output-file Export/groups.csv --result-format csv --wait 10 --target-org $source_org

sf data upsert bulk -s Group -f Export/groups.csv -i Id -w 5 -o $destination_org

# Seventh data export command
sf data export bulk --query "select Name, DINs__c from Product_Health_Category__c order by Name asc" --output-file Export/producthealthcategories.csv --result-format csv --wait 10 --target-org $source_org

sf data upsert bulk -s Product_Health_Category__c -f Export/producthealthcategories.csv -i Id -w 5 -o $destination_org

# Eighth data export command
sf data export bulk --query "select Name, Description__c from RDP_Code_Description__c order by Name asc" --output-file Export/rdpdescriptions.csv --result-format csv --wait 10 --target-org $source_org

sf data upsert bulk -s RDP_Code_Description__c -f Export/rdpdescriptions.csv -i Id -w 5 -o $destination_org

echo "Data export and upsert completed."
