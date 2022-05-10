import { LightningElement, api, track ,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTemplates from '@salesforce/apex/FolderUtility.getTemplates';
import sendFax from '@salesforce/apex/FaxService.sendFax';

const FIELDS = [
  'Case.Fax_Sent_Date__c',
  'Case.Provider_Fax__c'
];

export default class FaxTemplateChooser extends LightningElement {
  @api recordId;
  isDisabled = true;
  data = null;
  value = '';
  templateName = '';
  faxNumber = '';
  options = [ ];

  @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
  record;
  
  get faxSentDate() {
    return this.record.data ? this.record.data.fields.Fax_Sent_Date__c.value : null;
  }

  get providerFax() {
    return this.record.data ? this.record.data.fields.Provider_Fax__c.value : null;
  }
  
  @track error;
  async connectedCallback() {
    getTemplates()
    .then(data => {
      this.options = data.map(item => {
        return {
          label: item.Name,
          value: item.Id
        }
      });
    });
  }
  async sendFax(){
    let success = true;
      try {
        await sendFax({
          caseId:this.recordId,
          templateId:this.value
        });
        debugger;
        this.showSuccess(`Fax sent to Accuroute for ${this.providerFax}`);
      } 
      catch (error) {
        this.showError(error.body.message);
        success = false;
    }

    return success;
}

  showSuccess(message) {
        this.showToast('Success', message, 'success');
  }

  showError(message) {
      this.showToast('Error', message, 'error');
  }

  showToast(title, message, variant) {
      this.dispatchEvent(new ShowToastEvent({
          title: title,
          message: message,
          mode: "sticky",
          variant: variant
      }));
  }
  

  handleChange(event) {
    this.value = event.detail.value;
    this.templateName = this.options.filter(item => item.value == event.detail.value)[0].label;
    this.isDisabled = false;
  }

  generatePDF(event) {
    window.open('/apex/PDFGenerator?id=' + this.recordId + '&templateId=' + this.value)
  }
}