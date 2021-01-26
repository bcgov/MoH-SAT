@isTest
public class BenefitsResponseTest {
    @isTest
    public static void BenefitsResponseTest() {
        BenefitsResponse br = new BenefitsResponse();
        
        BenefitsResponse.PlanIExpenditure pie = new BenefitsResponse.PlanIExpenditure();
        pie.amount = 0.0;
        pie.year = '2000';

        BenefitsResponse.PlanEligibility pe = new BenefitsResponse.PlanEligibility();
        pe.terminationDate = '2000/01/01';
        pe.authorityCode = '2000/01/01';
        pe.authorityValue = '1';
        pe.authorityDesc = '';
        pe.effectiveDate = '2000/01/01';

        BenefitsResponse.PRACRestricts pracr = new BenefitsResponse.PRACRestricts();
        pracr.terminationDate = '2000/01/01';
        pracr.practitionerName = '';
        pracr.practitionerDesc = '';
        pracr.pracitionerId = '';
        pracr.effectiveDate = '';
        pracr.pracitionerRefId = '';

        BenefitsResponse.PharmRestricts pr = new BenefitsResponse.PharmRestricts();
        pr.terminationDate = '2000/01/01';
        pr.pharmacyId = '';
        pr.pharmacyName = '';
        pr.effectiveDate = '2000/01/01';

        BenefitsResponse.RestrctedClaimant rc = new BenefitsResponse.RestrctedClaimant();
        rc.pracRestricts = new List<BenefitsResponse.PRACRestricts>();
        rc.pracRestricts.add(pracr);

        rc.pharmRestricts = new List<BenefitsResponse.PharmRestricts>();
        rc.pharmRestricts.add(pr);

        br.clientName = '';
        br.requestUUID = '';
        br.planIExpenditure = pie;
        br.planEligibility = new List<BenefitsResponse.PlanEligibility>();
        br.planEligibility.add(pe);
        br.restrictedClaimant = rc;
        CalloutResponse error = new CalloutResponse();
        error.errorCode = 200;
        error.errorMessage = '';
        br.error = error;
    }
}