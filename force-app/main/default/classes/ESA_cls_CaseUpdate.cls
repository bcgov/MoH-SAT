/** 
 * @author: accenture_sat_team
 * @description: This class will be called from Step Action apex calss when the Case Update step action executed in the Adjucation process
 * which gets triggered when Adjudication button clicked or automatic adjucation during case creation.
 * @param: SpecialAuthorityRequest & StepAction 
 * @return:  ActionResult instance 
**/
public with sharing class ESA_cls_CaseUpdate implements Action {
    public ActionResult execute(SpecialAuthorityRequest sar, StepAction actionParams) {
        if(String.isNotBlank(actionParams.subject)){
            sar.saCase.Subject = actionParams.subject;
        }
        if(String.isNotBlank(actionParams.description)){
            sar.saCase.Description = actionParams.description;
        }
        sar.saCase.ESA_Approval_Time__c = actionParams.duration;
        sar.saCase.ESA_Approval_Time_Unit__c = actionParams.durationUnit;
        if(String.isNotBlank(actionParams.rationale)){
            if(String.isNotBlank(sar.saCase.Rationale__c)){
                sar.saCase.Rationale__c = sar.saCase.Rationale__c + '<br/>'+actionParams.rationale;
            }
            else{
                sar.saCase.Rationale__c =actionParams.rationale;
            }
        }
        sar.saCase.Max_Days_Supply__c = String.Valueof(actionParams.daysSupply);
        return new ActionResult();
    }
}