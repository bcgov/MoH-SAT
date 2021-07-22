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
  allSubmissionsFailed;

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
    return !this.hasPnetSars || this.isPushedToPnet || this.allSubmissionsFailed;
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

  get hasPractitionerId() {
    let sar = this.pnetSars[0].saRecord;
    return sar.saRequester.practId != null;
  }

  get practitionerId() {
    let sar = this.pnetSars[0].saRecord;
    return `${sar.saRequester.practIdRef}-${sar.saRequester.practId}`
  }

  get pharmacyId() {
    let sar = this.pnetSars[0].saRecord;
    return sar.saRequester.pharmacyId
  }

  get decCode() {
    let sar = this.pnetSars[0].saRecord;
    return sar.saRequester.decCode
  }

  async handleSubmit() {
    let forms = this.template.querySelectorAll('c-pnet-sa-form');
    let results = [];

    for (const form of forms) {
      results.push(await form.submit());
    }

    this.handleResults(results);
  }
  
  async handleResults(results) {
    if (this.hasPnetSars && results.every(result=>result===true)) await this.markPushedToPnet();
    if (results.every(result=>result===false)) this.allSubmissionsFailed = true;
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