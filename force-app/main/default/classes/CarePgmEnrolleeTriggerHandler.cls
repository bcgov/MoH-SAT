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
    public static void updateEnrolleeName(List<CareProgramEnrollee> carePgmEnrolleeList) {
    CareProgram careProgram = [SELECT Id FROM CareProgram WHERE Name = 'EDRD' LIMIT 1 FOR UPDATE];

    Id careProgramId = careProgram.Id;

    Integer recordCount = [SELECT COUNT() FROM CareProgramEnrollee WHERE CareProgramId = :careProgramId];

    Set<String> usedSequenceNumbers = new Set<String>();

    for (CareProgramEnrollee existingEnrollee : [SELECT Name FROM CareProgramEnrollee WHERE CareProgramId = :careProgramId AND Name != null]) {
        if (existingEnrollee.Name.contains('-')) {
            usedSequenceNumbers.add(existingEnrollee.Name.substringBefore('-'));
        }
    }

    Set<Id> accountIds = new Set<Id>();

    for (CareProgramEnrollee cpe : carePgmEnrolleeList) {
        if (cpe.AccountId != null) {
            accountIds.add(cpe.AccountId);
        }
    }

    Map<Id, Account> accIdVsRec = new Map<Id, Account>([SELECT Id, FirstName, LastName FROM Account WHERE Id IN :accountIds]);

    for (CareProgramEnrollee enrollee : carePgmEnrolleeList) {
        if (enrollee.CareProgramId == careProgramId) {
            String countInString;

            do {
                recordCount++;
                countInString = String.valueOf(recordCount).leftPad(5, '0');
            } while (usedSequenceNumbers.contains(countInString));

            usedSequenceNumbers.add(countInString);

            Account account = accIdVsRec.get(enrollee.AccountId);
            String firstName = account?.FirstName ?? '';
            String lastName = account?.LastName ?? '';

            enrollee.Name = countInString + '-' + firstName.left(1) + lastName.left(1);
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