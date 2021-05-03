import { LightningElement, api, wire } from 'lwc';
import verifyPatientInformationx from '@salesforce/apex/ODRIntegration.verifyPatientInformationx';

export default class PatientInformation extends LightningElement {
  @api recordId;
  verified = false;
  loaded = false;
  data = null;
  deceased = false;
  patientFullNameDisplay = '';

  @wire(verifyPatientInformationx, { recordId: '$recordId' }) mapObjectToData({error,data}) {
    if (data) {
      console.log("PatientInformation:", data);
      this.data = data;

      // Re-work deceased
      this.deceased = this.data.deceased == true ? 'Yes' : 'No';

      let patientFullNameDisplay = '';

      if (this.data != null && this.data.names != null && this.data.names.length > 0) {
        this.data.names.forEach(item => {
          if (item.declared == true) {
            item.givenNames.forEach(given => {
              patientFullNameDisplay += given + ' ';
            });
            patientFullNameDisplay += item.familyName;
          }
        });
      }

      this.patientFullNameDisplay = patientFullNameDisplay;

      this.loaded = true;
    }
  }
}