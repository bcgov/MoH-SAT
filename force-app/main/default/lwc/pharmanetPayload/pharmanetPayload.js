import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPnetSars from '@salesforce/apex/PharmanetPayloadController.getPnetSars';
import markPushedToPharmanet from '@salesforce/apex/PharmanetPayloadController.markPushedToPharmanet';
import FLD_PUSHED_TO_PNET from '@salesforce/schema/Case.Pushed_to_Pnet__c';

export default class PharmanetPayload extends LightningElement {
  @api recordId;

  record;
  pnetSars;

  @wire(getRecord, {recordId: '$recordId', fields: [FLD_PUSHED_TO_PNET]})
  async wiredRecord({ error, data }) {
    if (data) {
      this.record = data;
      this.pnetSars = await getPnetSars({ recordId: this.recordId });
    }
    if (error) {
      this.showError(error.body.message);
    }
  }

  get isDisabled() {
    return !this.hasPnetSars || this.isPushedToPnet;
  }

  get isPushedToPnet() {
    return getFieldValue(this.record, FLD_PUSHED_TO_PNET);
  }

  get hasPnetSars() {
    return this.pnetSars && this.pnetSars.length > 0;
  }

  get patientId() {
    let sar = this.pnetSars[0].saRecord;
    return sar.phn;
  }

  get practitionerId() {
    let sar = this.pnetSars[0].saRecord;
    return `${sar.saRequester.practIdRef}-${sar.saRequester.practId}`
  }

  async handleSubmit() {
    let forms = this.template.querySelectorAll('c-pnet-sa-form');
    let allSuccess = this.hasPnetSars;

    for (const form of forms) {
      let success = await form.submit();
      if (!success) allSuccess = false;
    }
    
    if (allSuccess) await this.markPushedToPnet();
  }

  async markPushedToPnet() {
    try {
      await markPushedToPharmanet({recordId: this.recordId});
      getRecordNotifyChange([{recordId: this.recordId}]);
    } catch (error) {
      this.showError(error.body.message);
    }
  }

  showError(message) {
    this.dispatchEvent(new ShowToastEvent({
        title: 'Error',
        message: message,
        mode: "dismissable",
        variant: "error"
    }));
  }
}