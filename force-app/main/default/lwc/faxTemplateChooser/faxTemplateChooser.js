import { LightningElement, api, track } from 'lwc';
import getTemplates from '@salesforce/apex/FolderUtility.getTemplates';
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

  handleChange(event) {
    this.value = event.detail.value;
    this.templateName = this.options.filter(item => item.value == event.detail.value)[0].label;
    this.isDisabled = false;
  }

  generatePDF(event) {
    window.open('/apex/PDFGenerator?id=' + this.recordId + '&templateId=' + this.value)
  }
}