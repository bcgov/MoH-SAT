import { LightningElement, api, track ,wire } from 'lwc';
import getTemplates from '@salesforce/apex/FolderUtility.getTemplates';
import sendFax from '@salesforce/apex/FaxService.sendFax';
import queryFaxSentDate from '@salesforce/apex/FaxService.queryFaxSentDate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getSObjectValue } from '@salesforce/apex';
import Fax_Sent_Date__c from '@salesforce/schema/Case.Fax_Sent_Date__c';
import Provider_Fax__c from '@salesforce/schema/Case.Provider_Fax__c'


export default class FaxTemplateChooser extends LightningElement {
  @api recordId;
  isDisabled = true;
  data = null;
  value = '';
  templateName = '';
  faxNumber = '';
  options = [ ];

  
  @wire(queryFaxSentDate,{caseId:'$recordId'})record;
  get getRecord() {
    return this.record.data ? getSObjectValue(this.record.data, Fax_Sent_Date__c) : '';
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
        this.showSuccess(`Fax Sent to Accuroute`);
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
      console.log(message);
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