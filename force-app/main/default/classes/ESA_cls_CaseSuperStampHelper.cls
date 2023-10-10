/**********************************************************************************************
* @Author:      Vasanthi 
* @Date:        3 Oct 2023
* @Description: This class is used as a controller for esa_LC_SuperStamps component to retreive custom metadata   
***********************************************************************************************/
public without sharing class  ESA_cls_CaseSuperStampHelper {
@AuraEnabled(Cacheable = true)
    public static List<ESA_CMD_General_Stamps__mdt> getGeneralStamp(){
        List<ESA_CMD_General_Stamps__mdt> generalStamps = [Select id,ESA_Stamp_Text__c from ESA_CMD_General_Stamps__mdt ];
        return generalStamps;        
    }
    
 @AuraEnabled(Cacheable = true)
    public static List<ESA_CMD_Super_Stamps__mdt> getSuperStamp(id caseId){
        List<Case> currentCase = [select id,Drug__c,Drug__r.Name from Case where id =: caseId];
        List<ESA_CMD_Super_Stamps__mdt> superStamps = new List<ESA_CMD_Super_Stamps__mdt>();
        if(currentCase.size()>0){
        superStamps = [Select id,ESA_Drug_Name__c,ESA_Super_Stamp__c from ESA_CMD_Super_Stamps__mdt where ESA_Drug_Name__c =: currentCase[0].Drug__r.Name];
        }
        return superStamps;                 
    }   
}