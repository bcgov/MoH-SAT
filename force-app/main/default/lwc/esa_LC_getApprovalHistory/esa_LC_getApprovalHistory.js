import { LightningElement, api } from 'lwc';
import fetchSAApprovalHistory from '@salesforce/apex/ODRIntegration.fetchSAApprovalHistory';
import fetchIntegrationLogs from '@salesforce/apex/ODRIntegration.fetchIntegrationLogs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ESA_label_rationalText from '@salesforce/label/c.ESA_label_rationalText';

const columns = [
    { label: 'Description', fieldName: 'description', type: 'text', wrapText: true, initialWidth: 120, hideDefaultActions: true },
    { label: 'RDP or DIN/PIN', fieldName: 'dinrdp', type: 'text', wrapText: true, hideDefaultActions: true },
    { label: 'Auth Type', fieldName: 'specAuthType', type: 'text', wrapText: true, hideDefaultActions: true },
    { label: 'Effective Date', fieldName: 'effectiveDate', wrapText: true, typeAttributes:{ month: "2-digit", day: "2-digit" }, hideDefaultActions: true },
    { label: 'Termination Date', fieldName: 'terminationDate', wrapText: true, typeAttributes:{ month: "2-digit", day: "2-digit" }, hideDefaultActions: true },
    { label: 'Excluded Plans', fieldName: 'excludedPlans', type: 'text', wrapText: true, hideDefaultActions: true },
  ];

export default class Esa_LC_getApprovalHistory extends LightningElement {
  @api phn
  @api rationalText
  @api RDPCode
  @api effectiveDateOpt
  @api terminationDateOpt
  columns = columns;
  data = [];
  patientIdentifier;
  loaded = false;
  hasResults = false;
  completeAndNoResults = false;
  totalRecords = 0;
  error = {};
  isError = false;
  
  rationalTextLabel = ESA_label_rationalText;
  saApprovalRequestFormatData = [];

  connectedCallback() {
    this.fetchItem();
  }

  async fetchItem() {
    let data = await fetchSAApprovalHistory({recordId: this.phn});
   
    if (data && data.error == null) {
    let keys = this.generateKeys(data.saRecords);
    let logs = await fetchIntegrationLogs({phn: this.phn, keys: keys});
      const records = data.saRecords;
      this.totalRecords = data.totalRecords;
       
      if (this.totalRecords > 0) {
        handleSuccess(records, logs);
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

  convertDINPIN(type, value) {
    if (type == 'R') {
      return value.substr(0,4) + '-' + value.substr(4);
    } else {
      return value;
    }
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

  handleSuccess(records, logs){
    this.completeAndNoResults = false;
        this.hasResults = true;
        let dataArray = [];
        let index = 0;
        let todaysDate = new Date();
        let terminationDateMax;

        records.forEach(record => {
          // Needed because SAApprovalHistoryResponse is a different format than SAApprovalRequest.
          let saRecord = {saRecord: {
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
          let terminationDate = new Date(record.terminationDate);
          if (records.length == 1){
          this.rationalText = this.rationalTextLabel.replace("EFFECTIVEDATE", record.effectiveDate).replace("TERMINATIONDATE", record.terminationDate); 
          if (todaysDate < terminationDate){
            this.terminationDateOpt = terminationDate;
            this.effectiveDateOpt = new Date(record.effectiveDate);
          }      
          } else if(item['dinrdp'].replace("-","") == this.RDPCode.replace("-","")){
            if (todaysDate <= terminationDate){
                if(!terminationDateMax){
                    this.rationalText = this.rationalTextLabel.replace("EFFECTIVEDATE", record.effectiveDate).replace("TERMINATIONDATE", record.terminationDate);   
                    terminationDateMax = terminationDate; 
                    this.terminationDateOpt = terminationDateMax;
                    this.effectiveDateOpt = new Date(record.effectiveDate);
                } else if(terminationDateMax <= terminationDate){
                    this.rationalText = this.rationalTextLabel.replace("EFFECTIVEDATE", record.effectiveDate).replace("TERMINATIONDATE", record.terminationDate);
                    this.terminationDateOpt = record.terminationDate;
                    this.effectiveDateOpt = new Date(record.effectiveDate);       
                }
            }
          }
        });
        this.data = dataArray;  
  }

  generateSingleKey(record){
    return this.patientIdentifier + (record.specialItem.din || "null") + (record.specialItem.rdp || "null") + record.specAuthType + record.effectiveDate.replace(/-/g,"");
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

  generateKeys(saRecords){
    let keys = [];
    saRecords.forEach(record => {
      let key = this.generateSingleKey(record);
      keys.push(key);
    })
    return keys;
  }
}