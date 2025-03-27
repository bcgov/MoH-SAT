/**********************************************************************************************
* @Author:      Accenture
* @Date:        30/01/2024
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
               30-Jan24     EDRD-624           Accenture      update the name based on record count 
               11-Jul24     EDRD-764           Accenture      update the Account Ref. No based on CPE Name
***********************************************************************************************/
public with sharing class CarePgmEnrolleeTriggerHandler {
    /**
* @author: Accenture
* @date: 30/01/2024
* @description: The purpose of this method is update the name based on record count
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    public static void updateEnrolleeName(List<CareProgramEnrollee> carePgmEnrolleeList){
        Integer recordCount = [SELECT COUNT() FROM CareProgramEnrollee WHERE CareProgram.Name = 'EDRD'];
        Id careProgramId = [SELECT Id FROM CareProgram WHERE Name = 'EDRD' LIMIT 1].get(0).Id;
        Set<Id> accountIds = new Set<Id>();
        for(CareProgramEnrollee cpe :carePgmEnrolleeList){
            accountIds.add(cpe.AccountId);
        }
        Map<Id, Account> accIdVsRec = new Map<Id, Account>([Select Id,FirstName,LastName
                                                             FROM Account
                                                             WHERE ID =:accountIds]);
        String countInString;
        for(CareProgramEnrollee carePgmEnrollee: carePgmEnrolleeList){
            if(carePgmEnrollee.CareProgramId == careProgramId){
                recordCount = recordCount+1;
                countInString = String.valueOf(recordCount).leftPad(5, '0');
                String firstName = accIdVsRec?.get(carePgmEnrollee.AccountId)?.FirstName ?? '';
                String lastName = accIdVsRec?.get(carePgmEnrollee.AccountId)?.LastName ?? '';
                carePgmEnrollee.Name = countInString +'-'+firstName.LEFT(1)+lastName.LEFT(1);
            }
        }        
    }
    
/**
* @author: Deepak
* @date: 11/07/2024
* @description: The purpose of this method is update the Account Ref. No based on CPE Name
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/ 
    public static void updateEnrolleeNameOnAcc(List<CareProgramEnrollee> carePgmEnrolleeList){
        List<Account> accList = new List<Account>();
        List<CareProgramEnrollee> cPEList =[SELECT Id, CareProgram.Name FROM CareProgramEnrollee 
                                            WHERE Id IN: carePgmEnrolleeList and CareProgram.Name = 'EDRD'];        
        for(CareProgramEnrollee carePgmEnrollee: carePgmEnrolleeList){
            accList.add(new Account(Id = carePgmEnrollee.AccountId, EDRD_Ref_No__pc = carePgmEnrollee.Name));
        }          
        if(!accList.isEmpty()){
           new Elevated().updateAccount(accList);
        }
    }
/*---------------------------------------------------------------------
Class Name : Elevated
Purpose : This is Elevated class to get the salesforce data on System mode.
Version : 1.0
Devloper Name : Accenture.
Date : 26/March/2025
--------------------------------------------------------------------------*/
public without sharing class Elevated
{
    public void updateAccount(List<Account> accList){
        update accList;
    } 
 }
}