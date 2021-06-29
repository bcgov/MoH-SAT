import { LightningElement } from 'lwc';
import fetchSAApprovalHistory from '@salesforce/apex/ODRIntegration.fetchSAApprovalHistory';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
  { label: 'Description', fieldName: 'description', type: 'text', wrapText: true, initialWidth: 120, hideDefaultActions: true },
  { label: 'RDP or DIN/PIN', fieldName: 'dinrdp', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Effective Date', fieldName: 'effectiveDate', wrapText: true, type: 'date-local', typeAttributes:{ month: "2-digit", day: "2-digit" }, hideDefaultActions: true },
  { label: 'Termination Date', fieldName: 'terminationDate', wrapText: true, type: 'date-local', typeAttributes:{ month: "2-digit", day: "2-digit" }, hideDefaultActions: true },
  { label: 'Auth Type', fieldName: 'specAuthType', type: 'text', wrapText: true, hideDefaultActions: true }
];

export default class SaHistoryLookup extends LightningElement {
  patientIdentifier ='';
  dinRdpFilter = '';
  descriptionFilter = '';
  columns = columns;
  data = [];
  loaded = false;
  
  hasResults = false;
  completeAndNoResults = false;
  totalRecords = 0;
  error = {};
  isError = false;

  get patientId() {
    return this.template.querySelector('.patientIdentifier').value;
  }

  handleFormChange(event) {
    this.patientIdentifier = event.target.value;
    this.template.querySelector('.btn-lookup').disabled = false;
  }

  async handleLookup() {
    this.completeAndNoResults = false;
    this.isError = false;
    this.data = [];
    this.fetchItems();
  }

  convertSAType(type) {
    let convertedValue = '';
    switch (type) {
      case 'L':
        convertedValue = 'LCA';
        break;
      case 'B':
        convertedValue = 'Non-Benefit';
        break;
      case 'R':
        convertedValue = 'RDP';
        break;
    }
    return convertedValue;
  }

  convertDINPIN(type, value) {
    if (type == 'R') {
      return value.substr(0,4) + '-' + value.substr(4);
    } else {
      return value;
    }
  }

  handleDinRdpFilterChange(event) {
    this.dinRdpFilter = event.target.value;
    this.fetchItems();
  }

  handleDescriptionFilterChange(event) {
    this.descriptionFilter = event.target.value;
    this.fetchItems();
  }

  async fetchItems() {
    if (this.patientIdentifier == null || this.patientIdentifier.length < 1) return;

    let data = await fetchSAApprovalHistory({phn: this.patientIdentifier})
    if (data && data.error == null) {
      const records = data.saRecords;
      this.totalRecords = data.totalRecords;

      if (this.totalRecords > 0) {
        this.completeAndNoResults = false;
        this.hasResults = true;
        let dataArray = [];
        
        records.forEach(record => {
          // Is there a filter applied?
          if (this.dinRdpFilter.length == 0
              || record.specialItem.din?.indexOf(this.dinRdpFilter.trim()) > -1
              || record.specialItem.rdp?.replace(/-/g,"")?.indexOf(this.dinRdpFilter.trim()) > -1
            ) {
            let item = {};

            // Is there a description filter applied?
            const descr = record.specialItem.itemDescription?.toLowerCase() || '';
            if (this.descriptionFilter.length == 0 || descr.indexOf(this.descriptionFilter.toLowerCase()) > -1) {

              item['description'] = record.specialItem.itemDescription;
              item['dinrdp'] = this.convertDINPIN(record.specAuthType, record.specialItem.din || record.specialItem.rdp);
              item['specAuthType'] = this.convertSAType(record.specAuthType);
              item['effectiveDate'] = record.effectiveDate;
              item['terminationDate'] = record.terminationDate;
              dataArray.push(item);
            }
          }
        });
        this.data = dataArray;
      } else {
        this.hasResults = false;
        this.completeAndNoResults = true;
      }
      this.loaded = true;
    } else {
      this.isError = true;
      this.loaded = true;
      this.error = data.error.errorMessage;
      const event = new ShowToastEvent({
        title: 'Pharmanet Error',
        message: data.error.errorMessage
      });
      this.dispatchEvent(event);
    }
  }
}