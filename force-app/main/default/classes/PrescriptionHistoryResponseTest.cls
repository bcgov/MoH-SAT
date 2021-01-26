@isTest
public class PrescriptionHistoryResponseTest {
    @isTest
    public static void PrescriptionHistoryResponseTest() {
        PrescriptionHistoryResponse phr = new PrescriptionHistoryResponse();
        phr.clientName = '';
        phr.requestUUID = '';
        phr.AdverseReactions = new List<PrescriptionHistoryResponse.AdverseReactions>();

        PrescriptionHistoryResponse.Comment cmt = new PrescriptionHistoryResponse.Comment();
        cmt.dateEntered = '';
		cmt.practitionerName = '';
		cmt.text = '';
		cmt.practitionerRefId = '';
        cmt.practitionerId = '';

        PrescriptionHistoryResponse.PaymentAddress pa = new PrescriptionHistoryResponse.PaymentAddress();
        pa.country = '';
		pa.province = '';
		pa.city = '';
        pa.addrLine1 = '';
        pa.postalCode = '';
        
        PrescriptionHistoryResponse.PrescriberInfo pi = new PrescriptionHistoryResponse.PrescriberInfo();
		pi.licenseNo = '';
		pi.code = '';
		pi.phoneNumber = '';
		pi.name = '';
        pi.faxNumber = '';
        
        PrescriptionHistoryResponse.AdverseReactions adv = new PrescriptionHistoryResponse.AdverseReactions();
        adv.dinpin = 123456;
		adv.drugStrength = '';
		adv.genericName = '';
		adv.doseForm = '';
		adv.dateReported = '';
		adv.comment = cmt;
        adv.reportedBy = '';
        phr.adverseReactions.add(adv);

        PrescriptionHistoryResponse.DispensingPharmacy dp = new PrescriptionHistoryResponse.DispensingPharmacy();
        dp.pharmacyId = '';
		dp.phoneNumber = '';
		dp.name = '';
		dp.faxNumber = '';
		dp.siteAddress = pa;

        PrescriptionHistoryResponse.MedRecords mr = new PrescriptionHistoryResponse.MedRecords();
        mr.rxNumber = 123456;
		mr.quantity = 25.0;
		mr.refills = 1;
		mr.dinpin = 1;
		mr.directions = '';
		mr.drugStrength = '';
        mr.genericName = '';
        mr.daysSupply = 25.0;
        mr.dateDispensed = '';
        mr.prescriberInfo = pi;
        mr.rxStatus = '';
        mr.dispensingPharmacy = dp;

        PrescriptionHistoryResponse.MedHistory mh = new PrescriptionHistoryResponse.MedHistory();
        mh.totalRecords = 1;
        mh.totalPages = 1;
        mh.medRecords = new List<PrescriptionHistoryResponse.MedRecords>();
        mh.medRecords.add(mr);

        phr.medHistory = mh;

        CalloutResponse cor = new CalloutResponse();
        cor.errorCode = 200;
        cor.errorMessage = '';
        phr.error = cor;
    }
}