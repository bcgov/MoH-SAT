import { LightningElement } from 'lwc';
import fetchSAApprovalHistory from '@salesforce/apex/ODRIntegration.fetchSAApprovalHistory';
import fetchIntegrationLogs from '@salesforce/apex/ODRIntegration.fetchIntegrationLogs';
import findPatient from '@salesforce/apex/EmpiLookup.findPatient';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import hasSAApprovalUpdate from '@salesforce/customPermission/Access_SA_Approval_Update';

const columns = [
  { label: 'Description', fieldName: 'description', type: 'text', wrapText: true, initialWidth: 120, hideDefaultActions: true },
  { label: 'RDP or DIN/PIN', fieldName: 'dinrdp', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Effective Date', fieldName: 'effectiveDate', wrapText: true, type: 'date-local', typeAttributes:{ month: "2-digit", day: "2-digit" }, hideDefaultActions: true },
  { label: 'Termination Date', fieldName: 'terminationDate', wrapText: true, type: 'date-local', typeAttributes:{ month: "2-digit", day: "2-digit" }, hideDefaultActions: true },
  { label: 'Auth Type', fieldName: 'specAuthType', type: 'text', wrapText: true, hideDefaultActions: true },
];

export default class SaHistoryLookup extends LightningElement {
  patientIdentifier ='';
  dinRdpFilter = '';
  descriptionFilter = '';
  columns = columns;
  data = [];
  loaded = false;
  patientName;
  patientDOB;
  
  hasResults = false;
  completeAndNoResults = false;
  totalRecords = 0;
  error = {};
  isError = false;

  openModal = false;
  selectedSARecord;
  saApprovalRequestFormatData = [];

  constructor() {
    super();
    if (hasSAApprovalUpdate) {
      this.columns.push({ label: 'Log', fieldName: 'integrationLog', type: 'text', wrapText: true, hideDefaultActions: true });
      this.columns.push({ label: 'Update', type: 'button', typeAttributes: { label: 'Update', name: 'update'} });
    } 
  }

  get patientId() {
    return this.template.querySelector('.patientIdentifier').value;
  }

  handleFormChange(event) {
    this.patientIdentifier = event.target.value;
    this.template.querySelector('.btn-lookup').disabled = false;
  }

  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    switch (actionName) {
      case 'update':
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

  async handleLookup() {
    this.completeAndNoResults = false;
    this.isError = false;
    this.data = [];
    this.setPatientInformation(null, null);
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

    if (log.Code__c != 200 || log.Code__c != 201){
      logMessage = log.Type__c == 'SA Approval Update Request' ? 'Failed update ' : 'Failed termination ';  
    } else {
      logMessage = log.Type__c == 'SA Approval Update Request' ? 'Updated on ' : 'Terminated on ';
    }
    logMessage += log.Timestamp__c.slice(0,10);

    return logMessage;
  }

  setPatientInformation(patient){
    if (patient == null || patient.names.length == 0) {
      this.patientName = null;
      this.patientDOB = null;
      return;
    }

    let familyName = patient.names[0].familyName;
    let givenNames = patient.names[0].givenNames;
    let patientName = familyName + ',';
    givenNames.forEach(name => {
      patientName += ' ' + name;
    })

    this.patientName = patientName;
    this.patientDOB = patient.dob;
  }

  async fetchItems() {
    if (this.patientIdentifier == null || this.patientIdentifier.length < 1) return;

    let data = await fetchSAApprovalHistory({phn: this.patientIdentifier});
    let patient = await findPatient({phn: this.patientIdentifier});
    
    if (data && data.error == null) {
      const records = data.saRecords;
      this.totalRecords = data.totalRecords;
      let keys = this.generateKeys(data.saRecords);
      let logs = await fetchIntegrationLogs({phn: this.patientIdentifier, keys: keys});
      this.setPatientInformation(patient);

      if (this.totalRecords > 0) {
        this.completeAndNoResults = false;
        this.hasResults = true;
        let dataArray = [];
        let index = 0;
        
        records.forEach(record => {
          // Needed because SAApprovalHistoryResponse is a different format than SAApprovalRequest (pnetSaForm).
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
              item['integrationLog'] = this.getLatestLog(this.generateSingleKey(record), logs);
              item['index'] = index;
              saRecord.index = index++;
              dataArray.push(item);
              this.saApprovalRequestFormatData.push(saRecord);
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