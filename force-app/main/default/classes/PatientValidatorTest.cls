@isTest
public class PatientValidatorTest {
    @isTest
    public static void PatientValidatorTest() {
        Drug__c drug = TestFactory.newDrug('Drug 1');
        drug.Adjudication_Strategy__c = 'Criteria';
        drug.Criteria_Logic__c = 'AND(1, 2)';
        insert drug;

        Adjudication_Criteria__c ac1 = TestFactory.newCriteria(drug, 1, 'Case', 'Origin', null, 'equals', 'Fax');
        Adjudication_Criteria__c ac2 = TestFactory.newCriteria(drug, 2, 'Case', 'Priority', null, 'equals', 'Medium');
        insert new Adjudication_Criteria__c[] {ac1, ac2};

        Case saCase = TestFactory.newCase(drug, 'Test case 1');
        saCase.Origin = 'Fax';
        saCase.Priority = 'Low';
        saCase.Patient_Validated_Date__c = DateTime.now();
        insert saCase;

        PatientValidator pvalidator = new PatientValidator();

        SpecialAuthorityRequest sar = new SobjectSarBuilder(saCase.Id).build();
        pvalidator.execute(sar, null);
    }
  }