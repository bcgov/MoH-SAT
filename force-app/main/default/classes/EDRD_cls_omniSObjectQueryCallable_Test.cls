/**********************************************************************************************
* @Author:      Accenture 
* @Date:        06/09/2024
* @Description: The purpose of this class is to cover Code coverage of EDRD_cls_omniSObjectQueryCallable
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
***********************************************************************************************/
@isTest
public class EDRD_cls_omniSObjectQueryCallable_Test {
    
    @TestSetUp
    public static void createTestData() {
        List<Medication> MedicationRecList = TestFactory.createMedication(3, 'pegcetacoplan');
        MedicationRecList.get(0).Status = 'Active';
        MedicationRecList.get(0).One_time_Dose__c = false;
        MedicationRecList.get(1).Name = 'risdiplam';
        MedicationRecList.get(1).Status = 'Active';
        MedicationRecList.get(1).One_time_Dose__c = true;
        MedicationRecList.get(2).Name = 'triheptanoin';
        MedicationRecList.get(2).Status = 'Active';
        MedicationRecList.get(2).One_time_Dose__c = false;
        insert MedicationRecList;
    }
    
/**
* @author: Sachin
* @date: 06 Sept 2024
* @description: The purpose of this method is to cover Testcoverage of MedicationName
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/     
    @isTest
    public static void testMedicationNames(){        
        List<Medication> medicationList = [SELECT Id, Status, Name, One_time_Dose__c FROM Medication
                                           WHERE Status = 'Active' ORDER BY Name LIMIT 3];
        
        Map<String, Object> args = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        args.put('input', input);
        args.put('output', output);
        args.put('options', options);
        
        EDRD_cls_omniSObjectQueryCallable clsQuery = new EDRD_cls_omniSObjectQueryCallable();
        
        Test.startTest();
        clsQuery.call('MedicationNames', args);
        Test.stopTest();        
        
        List<Map<String, String>> uiOptions = (List<Map<String, String>>)output.get('options');
        
        Assert.areEqual(3, uiOptions.size(), 'Medication Exists');
        Assert.areEqual('pegcetacoplan', uiOptions[0].get('value'));
        Assert.areEqual('risdiplam', uiOptions[1].get('value'));
        Assert.areEqual('triheptanoin', uiOptions[2].get('value'));
        Assert.areNotEqual(null, uiOptions, 'Null');
    }
    
/**
* @author: Sachin
* @date: 06 Sept 2024
* @description: The purpose of this method is to cover Testcoverage of RenewalMedicationName
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/    
    @isTest
    public static void testRenewalMedicationName(){
        
        Map<String, Object> args = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>(); 
        args.put('input', input);
        args.put('output', output);
        args.put('options', options);
        
        List<Medication> medicationList = [SELECT Id, Status, Name, One_time_Dose__c FROM Medication
                                           WHERE Status = 'Active' ORDER BY Name LIMIT 3];
        
        EDRD_cls_omniSObjectQueryCallable clsQuery = new EDRD_cls_omniSObjectQueryCallable();
        
        Test.startTest();
        clsQuery.call('RenewalMedicationNames', args);
        Test.stopTest();
        
        List<Map<String, String>> uiOptions = (List<Map<String, String>>)output.get('options');
        
        Assert.areEqual(2, uiOptions.size(), 'Medication Exists');
        Assert.areEqual('pegcetacoplan', uiOptions[0].get('value'));
        Assert.areEqual('triheptanoin', uiOptions[1].get('value'));
        Assert.areNotEqual(null, uiOptions, 'Null');
    }         
}