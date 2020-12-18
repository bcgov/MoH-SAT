import { LightningElement, api, track } from 'lwc';
import getSAApprovalRequest from '@salesforce/apex/ODRIntegration.getSAApprovalRequest';
import postSAApproval from '@salesforce/apex/ODRIntegration.postSAApproval';

export default class PharmanetPayload extends LightningElement {
  @api recordId;
  verified = false;
  loaded = false;
  data = null;

  @track error;
  connectedCallback() {
    getSAApprovalRequest({recordId: this.recordId})
    .then(data => {
      if (data && data.error == null) {
        console.log('xxx',data);
        if (data) {
          console.log("PharmanetPayload:", data);
          this.data = data;
          this.loaded = true;
        }
      }
    })
  }

  handleClick(event) {
    console.log("SA APPROVAL", this.recordId);
    postSAApproval({recordId: this.recordId});
  }
}