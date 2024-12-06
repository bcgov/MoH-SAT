public with sharing class EmpiIntegration {

    public static Patient getPatient(String phn) {
        String patientPHN = '';
        if (phn != null) {
          patientPHN = phn.deleteWhitespace();
        }
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
        id.root = '2.16.840.1.113883.3.51.1.1.1';
        id.extension = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(DateTime.now().getTime().format())));

        creationTime = new Empi.TS();
        creationTime.value = Datetime.now().format('YYYYMMddHHmmss');

        versionCode = new Empi.CS();
        versionCode.code = 'V3PR1';

        interactionId = new Empi.II();
        interactionId.extension = 'HCIM_IN_GetDemographics';
        interactionId.root = '2.16.840.1.113883.3.51.1.1.2';
        
        // Processing Code. "P" for Production, "T" for Training, "D" for Debug
        processingCode = new Empi.CS();
        processingCode.code = 'P';

        // Processing Mode Code. "T" for Online Processing
        processingModeCode = new Empi.CS();
        processingModeCode.code = 'T';

        // Accept Ack. always "NE" (never send)
        acceptAckCode = new Empi.CS();
        acceptAckCode.code = 'NE';

        receiver = new Empi.MCCI_MT000100_Receiver();
        receiver.typeCode = 'RCV';
        receiver.device = new Empi.MCCI_MT000100_Device();
        receiver.device.id = new Empi.II();
        receiver.device.classCode = 'DEV';
        receiver.device.determinerCode = 'INSTANCE';
        receiver.device.id.root = '2.16.840.1.113883.3.51.1.1.4';
        receiver.device.id.extension = '192.168.0.1';
        receiver.device.asAgent = new Empi.MCCI_MT000100_Agent();
        receiver.device.asAgent.classCode = 'AGNT';
        receiver.device.asAgent.representedOrganization = new Empi.MCCI_MT000100_Organization();
        receiver.device.asAgent.representedOrganization.classCode = 'ORG';
        receiver.device.asAgent.representedOrganization.determinerCode = 'INSTANCE';
        receiver.device.asAgent.representedOrganization.id = new Empi.II();
        receiver.device.asAgent.representedOrganization.id.root = '2.16.840.1.113883.3.51.1.1.3';
        receiver.device.asAgent.representedOrganization.id.extension = 'HCIM';

        sender = new Empi.MCCI_MT000100_Sender();
        sender.typeCode = 'SND';
        sender.device = new Empi.MCCI_MT000100_Device();
        sender.device.determinerCode = 'INSTANCE';
        sender.device.classCode = 'DEV';
        sender.device.id = new Empi.II();
        sender.device.id.root = '2.16.840.1.113883.3.51.1.1.5';
        sender.device.id.extension = 'MOH_CRS';
        sender.device.asAgent = new Empi.MCCI_MT000100_Agent();
        sender.device.asAgent.classCode = 'AGNT';
        sender.device.asAgent.representedOrganization = new Empi.MCCI_MT000100_Organization();
        sender.device.asAgent.representedOrganization.id = new Empi.II();
        sender.device.asAgent.representedOrganization.determinerCode = 'INSTANCE';
        sender.device.asAgent.representedOrganization.classCode = 'ORG';
        sender.device.asAgent.representedOrganization.id.root = '2.16.840.1.113883.3.51.1.1.3';
        sender.device.asAgent.representedOrganization.id.extension = 'PHARM_SA';

        controlActProcess = new Empi.HCIM_IN_GetDemographics_QUQI_MT020001_ControlActProcess();
        controlActProcess.classCode = 'ACCM';
        controlActProcess.moodCode = 'EVN';
        controlActProcess.dataEnterer = new Empi.QUQI_MT020001_DataEnterer();
        controlActProcess.dataEnterer.typeCode = 'CST';
        controlActProcess.dataEnterer.assignedPerson = new Empi.COCT_MT090100_AssignedPerson();
        controlActProcess.dataEnterer.assignedPerson.classCode = 'ENT';
        controlActProcess.dataEnterer.assignedPerson.id = new Empi.II();
        controlActProcess.dataEnterer.assignedPerson.id.root = '2.16.840.1.113883.3.51.1.1.7';
        controlActProcess.dataEnterer.assignedPerson.id.extension = UserInfo.getUserEmail();
        controlActProcess.queryByParameter = new Empi.HCIM_IN_GetDemographics_QUQI_MT020001_QueryByParameter();
        controlActProcess.queryByParameter.queryByParameterPayload = new Empi.HCIM_IN_GetDemographics_QueryByParameterPayload();
        controlActProcess.queryByParameter.queryByParameterPayload.person_id = new Empi.HCIM_IN_GetDemographics_Person_id();
        controlActProcess.queryByParameter.queryByParameterPayload.person_id.value = new Empi.II();
        controlActProcess.queryByParameter.queryByParameterPayload.person_id.value.root = '2.16.840.1.113883.3.51.1.1.6.1';
        controlActProcess.queryByParameter.queryByParameterPayload.person_id.value.extension = phn;
        controlActProcess.queryByParameter.queryByParameterPayload.person_id.value.assigningAuthorityName = 'MOH_CRS';
        
        Empi.QUPA_AR101102_Port stub = new Empi.QUPA_AR101102_Port();
        stub.endpoint_x = 'callout:empi/HCIM.Services.Secured/Synchronous/QUPA_AR101102.svc'; // TEST
        stub.timeout_x = 60000;
        
        Patient p = new Patient();
        p.phn = phn;
        p.deceased = false;
        //if (!Test.isRunningTest()) {
            Empi.HCIM_IN_GetDemographicsResponse res = stub.HCIM_IN_GetDemographics(id, creationTime, versionCode, interactionId, processingCode, processingModeCode, acceptAckCode, receiver, sender, controlActProcess);

            p.notes = res.controlActProcess.queryAck.queryResponseCode.code;
            System.debug(p.notes);

            if (null != res.controlActProcess.subject) {
                System.debug(res.controlActProcess.subject[0].target.identifiedPerson.birthTime);
                if (res.controlActProcess.subject[0].target.identifiedPerson.birthTime != null
                    && res.controlActProcess.subject[0].target.identifiedPerson.birthTime.value != null) {
                    String birthTime = res.controlActProcess.subject[0].target.identifiedPerson.birthTime.value;
                    String year = birthTime.substring(0, 4);
                    String month = birthTime.substring(4, 6);
                    String day = birthTime.substring(6, 8);
                    p.dob = Date.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day));
                }
                if (res.controlActProcess.subject[0].target.identifiedPerson.administrativeGenderCode != null) {
                    p.gender = res.controlActProcess.subject[0].target.identifiedPerson.administrativeGenderCode.code;
                }

                if (res.controlActProcess.subject[0].target.identifiedPerson.deceasedInd != null) {
                    p.deceased = res.controlActProcess.subject[0].target.identifiedPerson.deceasedInd.value == 'true' ? true : false;
                }
                p.names = new List<Patient.PersonName>();
                if (res.controlActProcess.subject[0].target.identifiedPerson.name != null) {
                    for (Integer i =0;i < res.controlActProcess.subject[0].target.identifiedPerson.name.size();i++) {
                      Patient.PersonName personName = new Patient.PersonName();
                      personName.familyName = res.controlActProcess.subject[0].target.identifiedPerson.name[i].family;
                      personName.type = res.controlActProcess.subject[0].target.identifiedPerson.name[i].use;
                      if (res.controlActProcess.subject[0].target.identifiedPerson.name[i].use == 'L') {
                        personName.declared = true;

                        personName.givenNames = new List<String>();
                        for (Integer s=0;s < res.controlActProcess.subject[0].target.identifiedPerson.name[i].given.size();s++) {
                          String given = res.controlActProcess.subject[0].target.identifiedPerson.name[i].given[s];
                          personName.givenNames.add(given);
                        }
                      } else {
                        personName.declared = false;
                      }
                      p.names.add(personName);
                    }
                }
            }
        //}
        return p;
    }
}