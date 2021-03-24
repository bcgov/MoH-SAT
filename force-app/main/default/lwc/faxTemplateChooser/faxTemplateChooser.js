import { LightningElement, api, track } from 'lwc';
import getTemplates from '@salesforce/apex/FolderUtility.getTemplates';
import sendFax from '@salesforce/apex/InterfaxIntegration.sendFax';
import getFaxOutboundStatus from '@salesforce/apex/InterfaxIntegration.getFaxOutboundStatus';
import updateCaseFaxSent from '@salesforce/apex/InterfaxIntegration.updateCaseFaxSent';
import getProviderFaxNumber from '@salesforce/apex/InterfaxIntegration.getProviderFaxNumber';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FaxTemplateChooser extends LightningElement {
  @api recordId;
  isDisabled = true;
  data = null;
  value = '';
  faxNumber = '';
  options = [ ];

  @track error;
  async connectedCallback() {
    getTemplates({recordId: this.recordId})
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

  handleChange(event) {
    this.value = event.detail.value;
    this.isDisabled = false;
  }

  generatePDF(event) {
    window.open('/apex/PDFGenerator?id=' + this.recordId + '&templateId=' + this.value)
  }

  async sendFax() {
    console.log("SENDING FAX", this.recordId, this.value, this.faxNumber);
    // let faxNumber = "00999999900000000";
    let faxId = await sendFax({
      recordId: this.recordId,
      faxNumber: this.faxNumber,
      templateId: this.value,
      integrationName: '7a'
    });

    console.log("faxId:", faxId);
    let self = this;
    setTimeout(function () { self.checkFaxStatus(faxId, self.recordId, self) }, 5000);
  }

  async checkFaxStatus(faxId, recordId, self) {
    console.log("Checking fax status");
    let faxStatus = await getFaxOutboundStatus({
      recordId: recordId,
      faxId: String(faxId),
      integrationName: '7b'
    });
    console.log("faxStatus:", faxStatus);
    if (faxStatus.status == 0) {
      this.dispatchEvent(new ShowToastEvent({
        title: 'Fax',
        message: 'Fax sent to: ' + faxId,
        mode: "dismissable",
        variant: "success"
      }));
      updateCaseFaxSent({caseId: recordId});
    } else {
      setTimeout(function () { self.checkFaxStatus(faxId, recordId, self) }, 5000);
    }
  }
}