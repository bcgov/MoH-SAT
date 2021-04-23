import { LightningElement } from 'lwc';
import fetchSAApprovalHistoryx from '@salesforce/apex/ODRIntegration.fetchSAApprovalHistoryx';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
  { label: 'Description', fieldName: 'description', type: 'text', wrapText: true, initialWidth: 120, hideDefaultActions: true },
  { label: 'RDP or DIN/PIN', fieldName: 'dinrdp', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Auth Type', fieldName: 'specAuthType', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Effective Date', fieldName: 'effectiveDate', wrapText: true, type: 'date-local', typeAttributes:{ month: "2-digit", day: "2-digit" }, hideDefaultActions: true },
  { label: 'Termination Date', fieldName: 'terminationDate', wrapText: true, type: 'date-local', typeAttributes:{ month: "2-digit", day: "2-digit" }, hideDefaultActions: true },
  { label: 'Pract ID', fieldName: 'practId', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Pract ID Ref', fieldName: 'practIdRef', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'DaysSupply', fieldName: 'maxDaysSupply', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Excluded Plans', fieldName: 'excludedPlans', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Pharmacy', fieldName: 'pharmacyID', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'DEC', fieldName: 'decCode', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'CreatedBy', fieldName: 'createdBy', type: 'text', wrapText: true, hideDefaultActions: true }
];

export default class SaHistoryLookup extends LightningElement {
  patientIdentifier ='';
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
    console.log('event.target.value', event.target.value);

    this.patientIdentifier = event.target.value;

    // re-enable the button
    this.template.querySelector('.btn-lookup').disabled = false;
  }

  async handleLookup() {
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

  async fetchItems() {
    let data = await fetchSAApprovalHistoryx({phn: this.patientIdentifier, page: null, count: null, dinList: null})
    if (data && data.error == null) {
      console.log("saHistory:", data);
      const records = data.saRecords;
      this.totalRecords = data.totalRecords;

      if (this.totalRecords > 0) {
        this.completeAndNoResults = false;
        this.hasResults = true;
        let dataArray = [];
        records.forEach(record => {
          let item = {};
          item['description'] = record.specialItem.itemDescription;
          item['dinrdp'] = this.convertDINPIN(record.specAuthType, record.specialItem.din || record.specialItem.rdp);
          item['specAuthType'] = this.convertSAType(record.specAuthType);
          item['effectiveDate'] = record.effectiveDate;
          item['terminationDate'] = record.terminationDate;
          item['practId'] = record.saRequester.practId;
          item['practIdRef'] = record.saRequester.practIdRef;

          item['excludedPlans'] = "";
          record.excludedPlans.forEach(ep => {
            if (item['excludedPlans'] == "") {
              item['excludedPlans'] = ep;
            } else {
              item['excludedPlans'] += ", " + ep
            }
          });
          item['maxDaysSupply'] = record.maxDaysSupply;
          item['pharmacyID'] = record.saRequester.pharmacyID;
          // Not coming in response.
          item['decCode'] = record.saRequester.decCode;
          item['createdBy'] = record.createdBy;
          dataArray.push(item);
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