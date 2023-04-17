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

        records.forEach(rec => {
          // Needed because SAApprovalHistoryResponse is a different format than SAApprovalRequest.
          let saRecord = {saRecord: {
            saRequester: rec.saRequester,
            specialItem: rec.specialItem,
            specAuthType: rec.specAuthType,
            justificationCodes: rec.justificationCodes,
            excludedPlans: rec.excludedPlans,
            effectiveDate: rec.effectiveDate,
            terminationDate: rec.terminationDate,
            maxDaysSupply: rec.maxDaysSupply,
            maxPricePct: rec.maxPricePct
          }};

          let item = {};
          item['description'] = rec.specialItem.itemDescription;
          item['dinrdp'] = this.convertDINPIN(rec.specAuthType, rec.specialItem.din || rec.specialItem.rdp);
          item['specAuthType'] = this.convertSAType(rec.specAuthType);
          item['effectiveDate'] = rec.effectiveDate;
          item['terminationDate'] = rec.terminationDate;
          item['practId'] = rec.saRequester.practId;
          item['practIdRef'] = rec.saRequester.practIdRef;
          item['excludedPlans'] = "";
          rec.excludedPlans.forEach(ep => {
            if (item['excludedPlans'] == "") {
              item['excludedPlans'] = ep;
            } else {
              item['excludedPlans'] += ", " + ep
            }
          });
          item['maxDaysSupply'] = rec.maxDaysSupply;
          item['pharmacyID'] = rec.saRequester.pharmacyID;
          // Not coming in response.
          item['decCode'] = rec.saRequester.decCode;
          item['createdBy'] = rec.createdBy;
          item['integrationLog'] = this.getLatestLog(this.generateSingleKey(rec), logs);
          item['index'] = index;
          saRecord.index = index++;
          dataArray.push(item);
          this.saApprovalRequestFormatData.push(saRecord); 
          let terminationDate = new Date(rec.terminationDate);
          if (records.length == 1){
          this.rationalText = this.rationalTextLabel.replace("EFFECTIVEDATE", rec.effectiveDate).replace("TERMINATIONDATE", rec.terminationDate); 
          if (todaysDate < terminationDate){
            populateDates(terminationDate, rec.effectiveDate);
          }      
          } else if(item['dinrdp'].replace("-","") == this.RDPCode.replace("-","")){
            if (todaysDate <= terminationDate){
                if(!terminationDateMax){
                    this.rationalText = this.rationalTextLabel.replace("EFFECTIVEDATE", rec.effectiveDate).replace("TERMINATIONDATE", rec.terminationDate);   
                    terminationDateMax = terminationDate;
                    populateDates(terminationDateMax, record.effectiveDate);
                } else if(terminationDateMax <= terminationDate){
                    this.rationalText = this.rationalTextLabel.replace("EFFECTIVEDATE", rec.effectiveDate).replace("TERMINATIONDATE", rec.terminationDate);
                    populateDates(rec.terminationDate, rec.effectiveDate);
                }
            }
          }
        });
        this.data = dataArray;  
  }

  populateDates(terminationDate, effectiveDate){
    this.terminationDateOpt = terminationDate;
    this.effectiveDateOpt = new Date(effectiveDate);
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