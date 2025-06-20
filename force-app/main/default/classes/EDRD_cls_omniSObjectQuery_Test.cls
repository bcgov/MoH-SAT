@isTest
private class EDRD_cls_omniSObjectQuery_Test {

    @isTest
    static void testMedicationNamesMethod() {
        // Create test data
        Medication med1 = new Medication(Name = 'Ibuprofen', Status = 'Active');
        Medication med2 = new Medication(Name = 'Acetaminophen', Status = 'Active');
        insert new List<Medication>{ med1, med2 };

        // Prepare method input
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        // Call class under test
        EDRD_cls_omniSObjectQuery instance = new EDRD_cls_omniSObjectQuery();
        Boolean result = instance.invokeMethod('MedicationNames', input, outMap, options);

        // Assert
        System.assert(result, 'Method should return true');
        System.assert(outMap.containsKey('options'), 'Output map should contain options key');
        List<Object> optionsList = (List<Object>)outMap.get('options');
        System.assertEquals(2, optionsList.size(), 'Should return 2 active medications');
    }

    @isTest
    static void testRenewalMedicationNamesMethod() {
        // Create test data with One_time_Dose__c = false
        Medication med1 = new Medication(Name = 'Amoxicillin', Status = 'Active', One_time_Dose__c = false);
        Medication med2 = new Medication(Name = 'Azithromycin', Status = 'Active', One_time_Dose__c = true); // should be excluded
        insert new List<Medication>{ med1, med2 };

        // Prepare method input
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        // Call class under test
        EDRD_cls_omniSObjectQuery instance = new EDRD_cls_omniSObjectQuery();
        Boolean result = instance.invokeMethod('RenewalMedicationNames', input, outMap, options);

        // Assert
        System.assert(result, 'Method should return true');
        System.assert(outMap.containsKey('options'), 'Output map should contain options key');
        List<Object> optionsList = (List<Object>)outMap.get('options');
        System.assertEquals(1, optionsList.size(), 'Only one medication should be returned');
    }
}
