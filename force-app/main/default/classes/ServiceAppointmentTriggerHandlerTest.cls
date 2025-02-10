/**********************************************************************************************
* @Author:      Accenture
* @Date:        26/12/2024
* @Description: The purpose of this class is cover the coverage for ServiceAppointmentTriggerHandler
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
               26-Dec24     EDRD-309           Accenture      insert/update the name based on record
               08 Feb  -   EDRD-338		    -  Accenture   -  method is to Prevent users from selecting the Account records other than committee for EDRD Meetings.
***********************************************************************************************/
@isTest
public class ServiceAppointmentTriggerHandlerTest {
/**
* @author: Accenture
* @date: 26/12/2024
* @description: The purpose of this method is to cover Testcoverage of insertSAName
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    @isTest
    public static void insertSANameTest(){
        Account patientAccount = TestFactory.createEDRDACAccount('Ophthalmology Subcommittee');
        insert patientAccount;
        DateTime startDateTime = DateTime.newInstance(2023, 8, 21, 14, 30, 0);
        DateTime endDateTime = DateTime.newInstance(2023, 10, 21, 14, 30, 0);
        ServiceAppointment sapRec = new ServiceAppointment(Status = 'Planned', ParentRecordId = patientAccount.Id,EarliestStartTime = startDateTime , DueDate = endDateTime );
        test.startTest();
        insert sapRec;
        test.stopTest();
        Assert.areEqual([SELECT Id, EDRD_Name__c  FROM ServiceAppointment WHERE Id =: sapRec.Id].get(0).EDRD_Name__c, 'Ophthalmology Subcommittee - 2023-08-21', 'Name matched');
        Assert.areNotEqual([SELECT Id, EDRD_Name__c  FROM ServiceAppointment WHERE Id =: sapRec.Id].get(0).EDRD_Name__c, Null, 'Name should not be null');
    }
    
/**
* @author: Accenture
* @date: 26/12/2024
* @description: The purpose of this method is to cover Testcoverage of updateSAName
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    @isTest
    public static void updateSANameTest(){
        
        Account patientAccount = TestFactory.createEDRDACAccount('Ophthalmology Subcommittee');
        insert patientAccount;
        DateTime startDateTime = DateTime.newInstance(2023, 8, 21, 14, 30, 0);
        DateTime endDateTime = DateTime.newInstance(2023, 10, 21, 14, 30, 0);
        DateTime updatedStartDateTime = DateTime.newInstance(2022, 8, 21, 14, 30, 0);
        ServiceAppointment sapRec = new ServiceAppointment(Status = 'Planned', ParentRecordId = patientAccount.Id,EarliestStartTime = startDateTime , DueDate = endDateTime );
        insert sapRec;
        test.startTest();
        sapRec.EarliestStartTime = updatedStartDateTime;
        update sapRec;
        test.stopTest();
        Assert.areEqual([SELECT Id, EDRD_Name__c  FROM ServiceAppointment WHERE Id =: sapRec.Id].get(0).EDRD_Name__c, 'Ophthalmology Subcommittee - 2022-08-21', 'Name matched');
        Assert.areNotEqual([SELECT Id, EDRD_Name__c  FROM ServiceAppointment WHERE Id =: sapRec.Id].get(0).EDRD_Name__c,Null, 'Name should not be null');
    }
    
/**
* @author: Accenture
* @date: 26/12/2024
* @description: The purpose of this method is to cover Testcoverage of validateEDRDCommitteeMeeting
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/  
    @isTest
    public static void validateEDRDCommitteeMeetingTest(){
        Account committeeAccount = TestFactory.createEDRDACAccount('Ophthalmology Subcommittee');
        committeeAccount.IsActive = false;
        insert committeeAccount;
        Account patientAccount = TestFactory.newPatient('Test Patient');
        insert patientAccount;
        ServiceAppointment invalidserviceApp = TestFactory.createEDRDCommitteeMeeting(patientAccount.Id);
        ServiceAppointment inActiveserviceApp = TestFactory.createEDRDCommitteeMeeting(committeeAccount.Id);
        
        Test.StartTest();
        try {
            insert invalidServiceApp;
            System.assert(false, 'Expected an error when associating a non-committee account.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('meeting record can only be related to an EDRD committee'), 
                'Error message should indicate that the meeting must be related to an EDRD committee account.');
        }      

        try {
            insert inActiveserviceApp;
            System.assert(false, 'Expected an error when ParentRecordId is inactive.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('meeting record can only'), 
                'Error message should indicate that the meeting must be related to an EDRD committee account.');
        }        
        Test.stopTest();
    }
}