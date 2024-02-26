/**********************************************************************************************
* @Author:      Accenture
* @Date:        30/01/2024
* @Description: The purpose of this class is to create methods which can be used by different trigger event
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
***********************************************************************************************/
public with sharing class EDRD_cls_CarePgmEnrolleeHandler {
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
        Map<Id, Account> accountList = new Map<Id, Account>([Select Id,FirstName,LastName
                                                             FROM Account
                                                             WHERE ID =:accountIds]);
        String countInString;
        for(CareProgramEnrollee carePgmEnrollee: carePgmEnrolleeList){
            if(carePgmEnrollee.CareProgramId == careProgramId){
                recordCount = recordCount+1;
                countInString = String.valueOf(recordCount).leftPad(5, '0');
                String firstName = accountList.get(carePgmEnrollee.AccountId).FirstName !=null ? accountList.get(carePgmEnrollee.AccountId).FirstName : '';
                String lastName = accountList.get(carePgmEnrollee.AccountId).LastName !=null ? accountList.get(carePgmEnrollee.AccountId).LastName : '';
                carePgmEnrollee.Name = countInString +'-'+firstName.LEFT(1)+lastName.LEFT(1);
            }
        }        
    }
}