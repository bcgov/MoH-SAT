import { LightningElement, api, track } from 'lwc';
import getSAApprovalRequestsx from '@salesforce/apex/ODRIntegration.getSAApprovalRequestsx';
import getSAStatus from '@salesforce/apex/ODRIntegration.getSAStatus';
import postSAApprovalx from '@salesforce/apex/ODRIntegration.postSAApprovalx';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PharmanetPayload extends LightningElement {
  @api recordId;
  verified = false;
  loaded = false;
  data = null;
  hasData = false;
  isError = false;
  isDisabled = false;
  error = {};

  @track error;
  async connectedCallback() {
    // Check if SA Status for this record is already submitted to PNET
    this.isDisabled = await getSAStatus({recordId: this.recordId});

    let data = await getSAApprovalRequestsx({recordId: this.recordId});
    console.log("PAY:", data);
    if (data && data.error == null) {
      if (data) {
        console.log("PharmanetPayload:", data);
        this.data = data;
      }
    } else {
      this.isError = true;
      this.error = data.error.errorMessage;
    }
    this.hasData = this.data.length > 0;
    console.log("hasData", this.hasData);
    this.loaded = true;
  }

  // async handleClick(event) {
  //   console.log("SA APPROVAL", this.recordId);
  //   let data = await postSAApprovalx({recordId: this.recordId});
  //   // Iterate through all the errors
  //   console.log('data:', data);
  //   for(let i = 0;i<data.length;i++) {
  //     console.log("error:", data[i]);
  //     if (data[i].error && !data[i].error.status) {
  //       const event = new ShowToastEvent({
  //         title: 'Pharmanet Error',
  //         variant: 'error',
  //         message: data[i].error.errorMessage
  //       });
  //       this.dispatchEvent(event);
  //     } else {
  //       const event = new ShowToastEvent({
  //         title: 'Success',
  //         variant: 'success',
  //         message: data[i].statusMessage
  //       });
  //       this.dispatchEvent(event);
  //     }
  //   }
  // }
}