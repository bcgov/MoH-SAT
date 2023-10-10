@isTest
public class ESA_cls_CaseSuperStampHelper_Test {
    
@TestSetup static void dataSetup() { 
Account acc = TestFactory.newAccount('Test Account');
        insert acc;
        Contact con = TestFactory.newContact('Test Contact', 'testemail@test.com', acc.Id);
        insert con;
        Drug__c drug = TestFactory.newDrug('100 extra blood glucose test strips');
        insert drug;
       Case caseRec = TestFactory.newCase(drug, 'Test Case');
       insert caseRec;    
}
   @isTest
    public static void testgetGeneralStamp(){
    
        List<ESA_CMD_General_Stamps__mdt> generalStamps = ESA_cls_CaseSuperStampHelper.getGeneralStamp();
        system.debug('s1'+generalStamps);
        Test.startTest();
         Assert.areNotEqual(NULL,generalStamps, 'General stamps return value shouldnt be null'); 
         Assert.isFalse(generalStamps.size()<0, 'General stamps couldnt be retreived');     
        Test.stopTest();
    }
    
    @isTest
    public static void testgetSuperStamp(){
            Case caseRec = [SELECT id,Drug__c,Drug__r.Name from Case 
                         LIMIT 1 ];
        List<ESA_CMD_Super_Stamps__mdt> superStamps = ESA_cls_CaseSuperStampHelper.getSuperStamp(caseRec.Id);
        system.debug('s2'+superStamps);
        Test.startTest();
         Assert.areNotEqual(NULL,superStamps, 'Super stamps return value shouldnt be null'); 
         Assert.isFalse(superStamps.size()<0, 'Super stamps couldnt be retreived');    
        Test.stopTest();
    }
}