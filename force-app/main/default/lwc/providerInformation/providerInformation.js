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
      this.data = {};
      this.data['firstName'] = data.firstName;
      this.data['middleInitial'] = data.middleInitial;
      this.data['lastName'] = data.lastName;
      this.data['dateofBirth'] = data.dateofBirth;
      this.data['status'] = data.status;
      this.data['effectiveDate'] = data.effectiveDate;
      this.data['verified'] = data.verified;
      this.data['name'] = "";
      if (data.firstName) {
        this.data.name += data.firstName;
      }
      if (data.middleInitial) {
        this.data.name += ' ' + data.middleInitial;
      }
      if (data.lastName) {
        this.data.name += ' ' + data.lastName;
      }
      this.loaded = true;
    }
  }
}