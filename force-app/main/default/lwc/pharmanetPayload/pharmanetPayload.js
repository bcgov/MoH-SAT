import { LightningElement, api, wire } from 'lwc';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPnetSars from '@salesforce/apex/PharmanetPayloadController.getPnetSars';
import markPushedToPharmanet from '@salesforce/apex/PharmanetPayloadController.markPushedToPharmanet';
import FLD_PUSHED_TO_PNET from '@salesforce/schema/Case.Pushed_to_Pnet__c';
export default class PharmanetPayload extends LightningElement {
  @api recordId;

  @wire(getRecord, {recordId: '$recordId', fields: [FLD_PUSHED_TO_PNET]})
  record;

  pnetSars;

  @wire(getPnetSars, {recordId: '$recordId'})
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

  get patientId() {
    let sar = this.pnetSars[0].saRecord;
    return sar.phn;
  }

  get practitionerId() {
    let sar = this.pnetSars[0].saRecord;
    return `${sar.saRequester.practIdRef}-${sar.saRequester.practId}`
  }

  async handleSubmit() {
    await this.template.querySelectorAll('c-pnet-sa-form').forEach(async form => {
      await form.submit();
    });
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
    console.log(message);
    this.dispatchEvent(new ShowToastEvent({
        title: 'Error',
        message: message,
        mode: "dismissable",
        variant: "error"
    }));
  }
}