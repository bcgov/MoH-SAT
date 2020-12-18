import { LightningElement, api, track } from 'lwc';
import getSAApprovalRequest from '@salesforce/apex/ODRIntegration.getSAApprovalRequest';
import postSAApproval from '@salesforce/apex/ODRIntegration.postSAApproval';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PharmanetPayload extends LightningElement {
  @api recordId;
  verified = false;
  loaded = false;
  data = null;
  isError = false;
  error = {};

  @track error;
  connectedCallback() {
    getSAApprovalRequest({recordId: this.recordId})
    .then(data => {
      if (data && data.error == null) {
        if (data) {
          console.log("PharmanetPayload:", data);
          this.data = data;
        }
      } else {
        this.isError = true;
        this.error = data.error.errorMessage;
      }
      this.loaded = true;
    })
  }

  handleClick(event) {
    console.log("SA APPROVAL", this.recordId);
    postSAApproval({recordId: this.recordId})
    .then(data => {
      if (data.error) {
        const event = new ShowToastEvent({
          title: 'Pharmanet Error',
          message: data.error.errorMessage
        });
        this.dispatchEvent(event);
      }
    })
  }
}