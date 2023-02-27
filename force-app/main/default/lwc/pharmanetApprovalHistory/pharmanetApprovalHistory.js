import { LightningElement, api } from 'lwc';
import fetchSAApprovalHistoryByCase from '@salesforce/apex/ODRIntegration.fetchSAApprovalHistoryByCase';
import fetchIntegrationLogs from '@salesforce/apex/ODRIntegration.fetchIntegrationLogs';
import getPatientIdentifier from '@salesforce/apex/ODRIntegration.getPatientIdentifier';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
  { label: 'Description', fieldName: 'description', type: 'text', wrapText: true, initialWidth: 120, hideDefaultActions: true },
  { label: 'RDP or DIN/PIN', fieldName: 'dinrdp', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Auth Type', fieldName: 'specAuthType', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Effective Date', fieldName: 'effectiveDate', wrapText: true, typeAttributes:{ month: "2-digit", day: "2-digit" }, hideDefaultActions: true },
  { label: 'Termination Date', fieldName: 'terminationDate', wrapText: true, typeAttributes:{ month: "2-digit", day: "2-digit" }, hideDefaultActions: true },
  { label: 'Pract ID', fieldName: 'practId', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Pract ID Ref', fieldName: 'practIdRef', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'DaysSupply', fieldName: 'maxDaysSupply', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Excluded Plans', fieldName: 'excludedPlans', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Pharmacy', fieldName: 'pharmacyID', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'DEC', fieldName: 'decCode', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'CreatedBy', fieldName: 'createdBy', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Log', fieldName: 'integrationLog', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Terminate', type: 'button', typeAttributes: { label: 'Terminate', name: 'terminate'}}
];

export default class PharmanetApprovalHistory extends LightningElement {
  @api recordId;
  columns = columns;
  data = [];
  patientIdentifier;
  loaded = false;
  hasResults = false;
  completeAndNoResults = false;
  totalRecords = 0;
  error = {};
  isError = false;

  openModal = false;
  selectedSARecord;
  saApprovalRequestFormatData = [];

  connectedCallback() {
    this.fetchItems();
  }

  get hasPermissions(){
    return hasSAApprovalUpdate;
  }

  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    switch (actionName) {
      case 'terminate':
        console.log(JSON.stringify(row));
        this.openUpdateModal(row.index);
        break;
      default:
    }
  }

  openUpdateModal(index){
    this.saApprovalRequestFormatData.forEach((record) => { 
      if(record.index == index){
        this.selectedSARecord = record;
      }
    });
    this.openModal = true;
  }

  closeUpdateModal(){
    this.fetchItems();
    this.openModal = false;
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

  generateSingleKey(record){
    return this.patientIdentifier + (record.specialItem.din || "null") + (record.specialItem.rdp || "null") + record.specAuthType + record.effectiveDate.replace(/-/g,"");
  }

  generateKeys(saRecords){
    let keys = [];
    saRecords.forEach(record => {
      let key = this.generateSingleKey(record);
      keys.push(key);
    })
    return keys;
  }

  getLatestLog(key, logs){
    if (logs[key] === undefined) return;
    let log = logs[key];
    let logMessage = '';

    if (log.Code__c == 200 || log.Code__c == 201){
      logMessage = log.Type__c == 'SA Approval Update Request' ? 'Updated on ' : 'Terminated on ';
    } else {
      logMessage = log.Type__c == 'SA Approval Update Request' ? 'Failed update ' : 'Failed termination ';  
    }
    logMessage += log.Timestamp__c.slice(0,10);

    return logMessage;
  }

  async fetchItems() {
    let data = await fetchSAApprovalHistoryByCase({recordId: this.recordId});
    this.patientIdentifier = await getPatientIdentifier({recordId: this.recordId});
    let keys = this.generateKeys(data.saRecords);
    let logs = await fetchIntegrationLogs({phn: this.patientIdentifier, keys: keys});
    if (data && data.error == null) {
      const records = data.saRecords;
      this.totalRecords = data.totalRecords;

      if (this.totalRecords > 0) {
        this.completeAndNoResults = false;
        this.hasResults = true;
        let dataArray = [];
        let index = 0;

        records.forEach(record => {
          // Needed because SAApprovalHistoryResponse is a different format than SAApprovalRequest.
          let saRecord = {saRecord: {
            phn: this.patientIdentifier,
            saRequester: record.saRequester,
            specialItem: record.specialItem,
            specAuthType: record.specAuthType,
            justificationCodes: record.justificationCodes,
            excludedPlans: record.excludedPlans,
            effectiveDate: record.effectiveDate,
            terminationDate: record.terminationDate,
            maxDaysSupply: record.maxDaysSupply,
            maxPricePct: record.maxPricePct
          }};

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
          item['integrationLog'] = this.getLatestLog(this.generateSingleKey(record), logs);
          item['index'] = index;
          saRecord.index = index++;
          dataArray.push(item);
          this.saApprovalRequestFormatData.push(saRecord);        
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