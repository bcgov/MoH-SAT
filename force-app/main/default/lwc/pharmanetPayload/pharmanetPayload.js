import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSAApprovalRequestsx from '@salesforce/apex/ODRIntegration.getSAApprovalRequestsx';
import FLD_PUSHED_TO_PNET from '@salesforce/schema/Case.Pushed_to_Pnet__c';
export default class PharmanetPayload extends LightningElement {
  @api recordId;

  @wire(getRecord, {recordId: '$recordId', fields: [FLD_PUSHED_TO_PNET]})
  record;

  pnetSars;

  @wire(getSAApprovalRequestsx, {recordId: '$recordId'})
  wireRecords({ error, data }) {
    if (data) {
      this.pnetSars = data;
    }
    if (error) {
      this.showError(error.body.message);
    }
  }

  get isDisabled() {
    return this.record && this.record.data.fields.Pushed_to_Pnet__c.value;
  }

  async handleSubmit() {
    await this.template.querySelectorAll('c-pnet-sa-form').forEach(async form => {
      await form.submit();
    });
  }

  showError(message) {
    console.log(message);
    this.dispatchEvent(new ShowToastEvent({
        title: 'Error',
        message: message,
        mode: "dismissable",
        variant: "error"
    }));
  }
}