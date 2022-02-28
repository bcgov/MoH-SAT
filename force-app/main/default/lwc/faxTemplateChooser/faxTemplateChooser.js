import { LightningElement, api, track } from 'lwc';
import getTemplates from '@salesforce/apex/FolderUtility.getTemplates';
import sendFax from '@salesforce/apex/FaxService.sendFax';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FaxTemplateChooser extends LightningElement {
  @api recordId;
  isDisabled = true;
  data = null;
  value = '';
  templateName = '';
  faxNumber = '';
  options = [ ];

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
        this.showSuccess(`Submitted.`);
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