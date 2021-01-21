import { LightningElement, api, track } from 'lwc';
import getTemplates from '@salesforce/apex/FolderUtility.getTemplates';

export default class FaxTemplateChooser extends LightningElement {
  @api recordId;
  isDisabled = true;
  data = null;
  value = '';
  options = [ ];

  @track error;
  connectedCallback() {
    getTemplates({recordId: this.recordId})
    .then(data => {
      this.options = data.map(item => {
        return {
          label: item.Name,
          value: item.Id
        }
      });
    })
  }

  handleChange(event) {
    this.value = event.detail.value;
    this.isDisabled = false;
  }

  generatePDF(event) {
    window.open('/apex/PDFGenerator?id=' + this.recordId + '&templateId=' + this.value)
  }
}