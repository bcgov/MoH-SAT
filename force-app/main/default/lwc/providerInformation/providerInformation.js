import { LightningElement, api, wire } from 'lwc';
import verifyCollegeInformation from '@salesforce/apex/ODRIntegration.verifyCollegeInformation';

export default class ProviderInformation extends LightningElement {
  @api recordId;
  verified = false;
  loaded = false;
  data = null;

  @wire(verifyCollegeInformation, { recordId: '$recordId', collegeNumber: '', collegeName: '' }) mapObjectToData({error,data}) {
    if (data) {
      console.log("ProviderInformation:", data);
      this.data = data;
      this.loaded = true;
    }
  }
}