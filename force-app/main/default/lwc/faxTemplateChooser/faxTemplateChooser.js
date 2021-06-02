import { LightningElement, api, track } from 'lwc';
import getTemplates from '@salesforce/apex/FolderUtility.getTemplates';
import sendFax from '@salesforce/apex/InterfaxIntegration.sendFax';
import getFaxOutboundStatus from '@salesforce/apex/InterfaxIntegration.getFaxOutboundStatus';
import updateCaseFaxSent from '@salesforce/apex/InterfaxIntegration.updateCaseFaxSent';
import getProviderFaxNumber from '@salesforce/apex/InterfaxIntegration.getProviderFaxNumber';
import storeFaxLogIntegration from '@salesforce/apex/InterfaxIntegration.storeFaxLogIntegration';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import faxDisabled from '@salesforce/customPermission/Disable_Fax';

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
    this.faxNumber = await getProviderFaxNumber({recordId: this.recordId});
  }

  get isFaxDisabled() {
    return this.isDisabled || faxDisabled;
  }

  handleChange(event) {
    this.value = event.detail.value;
    this.templateName = this.options.filter(item => item.value == event.detail.value)[0].label;
    this.isDisabled = false;
  }

  generatePDF(event) {
    window.open('/apex/PDFGenerator?id=' + this.recordId + '&templateId=' + this.value)
  }

  async sendFax() {
    this.isDisabled = true;
    // Check if fax number exists
    if (this.faxNumber != '' && this.faxNumber != null) {
      console.log("SENDING FAX", this.recordId, this.value, this.faxNumber);
      // let faxNumber = "00999999900000000";
      let faxId = await sendFax({
        recordId: this.recordId,
        faxNumber: this.faxNumber,
        templateId: this.value,
        integrationName: '7a'
      });

      console.log("faxId:", faxId);
      if (faxId.includes('ERROR')) {
        this.dispatchEvent(new ShowToastEvent({
          title: 'Fax',
          message: 'Error sending fax:' + faxId,
          mode: "dismissable",
          variant: "error"
        }));
        this.isDisabled = false;
      } else {
        this.dispatchEvent(new ShowToastEvent({
          title: 'Fax',
          message: 'Fax is successfully submitted in the queue' + '(faxid: ' + faxId + '): https//secure.interfax.net/',
          mode: "dismissable",
          variant: "success"
        }));
        let self = this;
        setTimeout(function () { self.checkFaxStatus(faxId, self.recordId, self, this.faxNumber) }, 5000);
      }
    } else {
      this.isDisabled = false;
      this.dispatchEvent(new ShowToastEvent({
        title: 'Fax',
        message: 'Please provide provider\'s fax #',
        mode: "dismissable",
        variant: "error"
      }));
    }
  }

  async checkFaxStatus(faxId, recordId, self, faxNumber) {
    console.log("Checking fax status");
    let faxStatus = await getFaxOutboundStatus({
      recordId: recordId,
      faxId: String(faxId),
      integrationName: '7b'
    });
    console.log("faxStatus:", faxStatus);
    if (faxStatus.status == 0) {
      self.isDisabled = false;
      this.dispatchEvent(new ShowToastEvent({
        title: 'Fax',
        message: 'Fax sent to: ' + faxNumber,
        mode: "dismissable",
        variant: "success"
      }));
      updateCaseFaxSent({caseId: recordId});
      storeFaxLogIntegration({caseId: recordId, template: this.templateName});
    } else {
      setTimeout(function () { self.checkFaxStatus(faxId, recordId, self, faxNumber) }, 5000);
    }
  }
}