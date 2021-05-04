import { LightningElement } from 'lwc';
import fetchSAApprovalHistoryx from '@salesforce/apex/ODRIntegration.fetchSAApprovalHistoryx';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProductHealthCategories from '@salesforce/apex/ProductHealthCategory.getProductHealthCategories';

const columns = [
  { label: 'Description', fieldName: 'description', type: 'text', wrapText: true, initialWidth: 120, hideDefaultActions: true },
  { label: 'RDP or DIN/PIN', fieldName: 'dinrdp', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Effective Date', fieldName: 'effectiveDate', wrapText: true, type: 'date-local', typeAttributes:{ month: "2-digit", day: "2-digit" }, hideDefaultActions: true },
  { label: 'Termination Date', fieldName: 'terminationDate', wrapText: true, type: 'date-local', typeAttributes:{ month: "2-digit", day: "2-digit" }, hideDefaultActions: true },
  { label: 'Auth Type', fieldName: 'specAuthType', type: 'text', wrapText: true, hideDefaultActions: true }
];

export default class SaHistoryLookup extends LightningElement {
  patientIdentifier ='';
  descriptionFilter = '';
  columns = columns;
  data = [];
  loaded = false;
  dinList = [];

  categories = [];
  categoryFilter = "";
  hasResults = false;
  completeAndNoResults = false;
  totalRecords = 0;
  error = {};
  isError = false;

  get patientId() {
    return this.template.querySelector('.patientIdentifier').value;
  }

  connectedCallback() {
    this.phcFilterOptions();
  }

  handleFormChange(event) {
    console.log('event.target.value', event.target.value);

    this.patientIdentifier = event.target.value;

    // re-enable the button
    this.template.querySelector('.btn-lookup').disabled = false;
  }

  async handleLookup() {
    this.completeAndNoResults = false;
    this.isError = false;
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

  handlephcFilterChange(event) {
    this.categoryFilter = event.detail.value;
    let filter = null;
    if (this.categoryFilter == "None") {
      filter = "";
    } else {
      filter = this.categoryFilter;
    }
    this.fetchProductHealthCategories(filter);
  }

  handleDescriptionFilterChange(event) {
    this.descriptionFilter = event.target.value;
    this.fetchItems();
  }

  fetchProductHealthCategories(filter) {
    let list = [];
    if (filter) {
      list = filter.split(',');
    }
    if (list.length > 0) {
      this.dinList = list;
    } else {
      this.dinList = [];
    }
    this.fetchItems();
  }

  phcFilterOptions() {
    return getProductHealthCategories()
    .then(data => {
      this.categories = [ ...this.categories, { label: 'None', value: 'None' } ];
      data.forEach(item => {
        this.categories = [ ...this.categories, { label: item.Name, value: item.DINs__c }];
      });
      return this.categories;
    })
  }

  async fetchItems() {
    let data = await fetchSAApprovalHistoryx({phn: this.patientIdentifier, page: null, count: null, dinList: this.dinList})
    if (data && data.error == null) {
      // console.log("saHistory:", data);
      const records = data.saRecords;
      this.totalRecords = data.totalRecords;

      if (this.totalRecords > 0) {
        this.completeAndNoResults = false;
        this.hasResults = true;
        let dataArray = [];
        records.forEach(record => {
          // Is there a filter applied?
          if (this.dinList.length == 0
              || this.dinList.includes(record.specialItem.din)
              || (record.specialItem.rdp && this.dinList.includes(record.specialItem.rdp.replace(/-/g,"")))
              ) {
            let item = {};

            // Is there a description filter applied?
            const descr = record.specialItem.itemDescription.toLowerCase();
            if (this.descriptionFilter.length == 0 || descr.indexOf(this.descriptionFilter.toLowerCase()) > -1) {
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