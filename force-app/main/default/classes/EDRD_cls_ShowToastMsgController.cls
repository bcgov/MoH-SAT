/**********************************************************************************************
* @Author:      Accenture
* @Date:        15/07/2024
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
               15-Jan24     EDRD-731           Accenture      Controller to pass boolean value
***********************************************************************************************/
public class EDRD_cls_ShowToastMsgController {    
/**
* @author: Deepak
* @date: 15/07/2024
* @description: The purpose of this method is return boolean to eDRD_LC_ShowToastMessageOnCase component
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    @AuraEnabled
    public static Boolean isAttachmentPresent(String caseId){
        List<ContentDocumentLink> cDLList = [SELECT Id FROM ContentDocumentLink where LinkedEntityId =: caseId];
        return !(cDLList.isEmpty());
    }
}