import { LightningElement, api, wire } from 'lwc';
import verifyPatientInformation from '@salesforce/apex/ODRIntegration.verifyPatientInformation';

export default class PatientInformation extends LightningElement {
  @api recordId;
  verified = false;
  loaded = false;
  data = null;

  @wire(verifyPatientInformation, { recordId: '$recordId' }) mapObjectToData({error,data}) {
    if (data) {
      console.log("PatientInformation:", data);
      this.data = data;
      this.loaded = true;
    }
  }
}