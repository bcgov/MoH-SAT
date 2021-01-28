public with sharing class EmpiIntegration {

    public static void getPatient(String phn) {
        Empi.II id;
        Empi.TS creationTime;
        Empi.CS versionCode;
        Empi.II interactionId;
        Empi.CS processingCode;
        Empi.CS processingModeCode;
        Empi.CS acceptAckCode;
        Empi.MCCI_MT000100_Receiver receiver;
        Empi.MCCI_MT000100_Sender sender;
        Empi.HCIM_IN_GetDemographics_QUQI_MT020001_ControlActProcess controlActProcess;

        id = new Empi.II();
        id.extension = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(DateTime.now().getTime().format())));

        creationTime = new Empi.TS();
        creationTime.value = Datetime.now().format('YYYYMMddHHmmss.SSSSZ');

        versionCode = new Empi.CS();
        versionCode.code = 'V3PR1';

        interactionId = new Empi.II();
        interactionId.extension = 'HCIM_IN_GetDemographics';
        
        // Processing Code. "P" for Production, "T" for Training, "D" for Debug
        processingCode = new Empi.CS();
        processingCode.code = 'D';

        // Processing Mode Code. "T" for Online Processing
        processingModeCode = new Empi.CS();
        processingModeCode.code = 'T';

        // Accept Ack. always "NE" (never send)
        acceptAckCode = new Empi.CS();
        acceptAckCode.code = 'NE';

        receiver = new Empi.MCCI_MT000100_Receiver();
        receiver.device = new Empi.MCCI_MT000100_Device();
        receiver.device.id = new Empi.II();
        receiver.device.id.extension = '192.168.0.1';
        receiver.device.asAgent = new Empi.MCCI_MT000100_Agent();
        receiver.device.asAgent.representedOrganization = new Empi.MCCI_MT000100_Organization();
        receiver.device.asAgent.representedOrganization.id = new Empi.II();
        receiver.device.asAgent.representedOrganization.id.extension = 'HCIM';

        sender = new Empi.MCCI_MT000100_Sender();
        sender.device = new Empi.MCCI_MT000100_Device();
        sender.device.id = new Empi.II();
        sender.device.id.extension = 'MOH_CRS';
        sender.device.asAgent = new Empi.MCCI_MT000100_Agent();
        sender.device.asAgent.representedOrganization = new Empi.MCCI_MT000100_Organization();
        sender.device.asAgent.representedOrganization.id = new Empi.II();
        sender.device.asAgent.representedOrganization.id.extension = 'PHARM_SA';

        controlActProcess = new Empi.HCIM_IN_GetDemographics_QUQI_MT020001_ControlActProcess();
        controlActProcess.dataEnterer = new Empi.QUQI_MT020001_DataEnterer();
        controlActProcess.dataEnterer.assignedPerson = new Empi.COCT_MT090100_AssignedPerson();
        controlActProcess.dataEnterer.assignedPerson.id = new Empi.II();
        controlActProcess.dataEnterer.assignedPerson.id.extension = UserInfo.getUserEmail();
        controlActProcess.queryByParameter = new Empi.HCIM_IN_GetDemographics_QUQI_MT020001_QueryByParameter();
        controlActProcess.queryByParameter.queryByParameterPayload = new Empi.HCIM_IN_GetDemographics_QueryByParameterPayload();
        controlActProcess.queryByParameter.queryByParameterPayload.person_id = new Empi.HCIM_IN_GetDemographics_Person_id();
        controlActProcess.queryByParameter.queryByParameterPayload.person_id.value = new Empi.II();
        controlActProcess.queryByParameter.queryByParameterPayload.person_id.value.extension = phn;
        controlActProcess.queryByParameter.queryByParameterPayload.person_id.value.assigningAuthorityName = 'MOH_CRS';
        
        Empi.QUPA_AR101102_Port stub = new Empi.QUPA_AR101102_Port();
        
        // empi.endpoint_x = 'https://hcim.ehealth.gov.bc.ca/HCIM.Services.Secured/QUPA_AR101102.asmx'; // PROD
        stub.endpoint_x = 'https://hiat2.hcim.ehealth.gov.bc.ca/HCIM.Services.Secured/QUPA_AR101102.asmx'; // TEST
        stub.clientCertName_x = 'cert_empi';
        stub.HCIM_IN_GetDemographics(id, creationTime, versionCode, interactionId, processingCode, processingModeCode, acceptAckCode, receiver, sender, controlActProcess);

    }
    
}
