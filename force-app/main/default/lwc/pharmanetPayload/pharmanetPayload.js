import { LightningElement, api, track } from 'lwc';
import getSAApprovalRequestsx from '@salesforce/apex/ODRIntegration.getSAApprovalRequestsx';
import getSAStatus from '@salesforce/apex/ODRIntegration.getSAStatus';

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
    if (data && data.error == null) {
      this.data = data;
    } else {
      this.isError = true;
      this.error = data.error.errorMessage;
    }
    
    this.hasData = this.data.length > 0;
    this.loaded = true;
  }
}