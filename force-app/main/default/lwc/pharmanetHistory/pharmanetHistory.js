import { LightningElement, api } from 'lwc';
import fetchPrescriptionHistory from '@salesforce/apex/ODRIntegration.fetchPrescriptionHistory';
import fetchPrescriptionHistoryWithSearchKey from '@salesforce/apex/ODRIntegration.fetchPrescriptionHistoryWithSearchKey';
import getProductHealthCategories from '@salesforce/apex/ProductHealthCategory.getProductHealthCategories';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
  { label: 'Date Dispensed', fieldName: 'dateDispensed', initialWidth: 120, typeAttributes:{ month: "2-digit", day: "2-digit" }, hideDefaultActions: true, sortable: "true" },
  { label: 'Name', fieldName: 'genericName', type: 'text', initialWidth: 120, wrapText: true, hideDefaultActions: true, sortable: "true" },
  { label: 'Strength', fieldName: 'drugStrength', type: 'text', initialWidth: 120, wrapText: true, hideDefaultActions: true },
  { label: 'Direction', fieldName: 'directions', type: 'text',initialWidth: 120,  wrapText: true, hideDefaultActions: true },
  { label: 'Quantity', fieldName: 'quantity', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Days Supply', fieldName: 'daysSupply', hideDefaultActions: true },
  { label: 'Days Last Filled', fieldName: 'daysSince', hideDefaultActions: true },
  { label: 'Status', fieldName: 'rxStatus', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Prescriber', fieldName: 'prescriberName', type: 'text', wrapText: true, initialWidth: 120, hideDefaultActions: true, sortable: "true" },
  { label: 'SA Applied', fieldName: 'saTypeApplied', wrapText: true, hideDefaultActions: true },
  { label: 'Plan Code', fieldName: 'planCode', wrapText: true, hideDefaultActions: true },
  { label: 'Claimed amount', fieldName: 'claimAmount', wrapText: true, hideDefaultActions: true },
  { label: 'Accepted amount', fieldName: 'acceptedAmount', wrapText: true, hideDefaultActions: true },
  { label: 'DINPIN', fieldName: 'dinpin', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Pharmacy', fieldName: 'dispensingPharmacyName', type: 'text', wrapText: true, initialWidth: 120, hideDefaultActions: true },
  { label: 'RxNo', fieldName: 'rxNumber', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Refills', fieldName: 'refills', type: 'text', wrapText: true, hideDefaultActions: true },
];

export default class PharmanetHistory extends LightningElement {
  @api recordId;
  columns = columns;
  data = [];
  categories = [];
  categoryFilter = "";
  loaded = false;
  count = '10';
  hasResults = false;
  completeAndNoResults = false;
  isFirstPage = true;
  isLastPage = false;
  totalRecords = 0;
  pageNumber = 1;
  totalPages = 0;
  sortBy;
  sortDirection;
  initialRecords;
  searchKey;
  searchRecordCount;
  totalRecordsCount;
  searchData =[];
  loadingData = true;
  disableSearch = true;

  // TODO: Populate via din list picker.
  dinList = [];
  error = {};
  isError = false;

  handleNextPage(event) {
    console.log('handle previous page', event);
    console.log(this.pageNumber, this.totalPages);
    if (this.pageNumber < this.totalPages) {
      this.pageNumber = this.pageNumber + 1;
    }
    this.handlePageChange();
  }
  handlePrevPage(event) {
    console.log('handle next page', event);
    console.log(this.pageNumber, this.totalPages);
    if (this.pageNumber > 1) {
      this.pageNumber = this.pageNumber - 1;
    }
    this.handlePageChange();
  }
  handlePageChange() {
    if(!this.searchKey){
      // Call the service and update stuff.
      this.fetchItems();
    }else{
      this.getDataForPage();
    }
  }

  updatePageButtons() {
    console.log('PageNumber:', this.pageNumber, 'total', this.totalPages);
    if (this.pageNumber === 1) {
      this.isFirstPage = true;
    } else {
      this.isFirstPage = false;
    }
    if (this.pageNumber >= this.totalPages) {
      this.isLastPage = true;
    } else {
      this.isLastPage = false;
    }
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
    //this.fetchItems();
  }

  // Count Options
  get countOptions() {
    return [
        { label: '10', value: '10' },
        { label: '50', value: '50' },
        { label: '75', value: '75' },
        { label: '100', value: '100' },
    ];
  }
  // Count change handler
  handleCountChange(event) {
    this.count = event.detail.value;
    if(!this.searchKey){
      this.fetchItems();
    }else{
      this.pageNumber = 1;
      this.totalPages = Math.ceil(this.searchData.length/this.count);
      this.getDataForPage();
    }
    
  }

  connectedCallback() {
    this.phcFilterOptions();
    this.fetchItems();
  }

  fetchItems() {
    this.loadingData = true;
    this.disableSearch = true;
    this.hasResults = false;
    fetchPrescriptionHistory({recordId: this.recordId, page: this.pageNumber, count: this.count, dinList: this.dinList})
    .then(data => {
      if (data && data.error == null) {
        const records = data.medHistory && data.medHistory.medRecords;
        this.totalRecords = data.medHistory && data.medHistory.totalRecords;
        this.searchRecordCount = this.totalRecords;
        this.totalRecordsCount = data.medHistory && data.medHistory.totalRecords;
        this.totalPages = data.medHistory && data.medHistory.totalPages;
        if (this.totalRecords > 0) {
          this.completeAndNoResults = false;
          this.hasResults = true;
          this.loadingData = false;
          this.disableSearch = false;
          let dataArray = [];
          let i = 0;
          records.forEach(record => {
            let item = {};

            item['key'] = i++;
            item['rxNumber'] = record.rxNumber;
            item['quantity'] = record.quantity;
            item['refills'] = record.refills;
            item['dateDispensed'] = record.dateDispensed;
            item['dinpin'] = record.dinpin;
            item['genericName'] = record.genericName;
            item['drugStrength'] = record.drugStrength;
            item['directions'] = record.directions;
            item['daysSupply'] = record.daysSupply;
            item['daysSince'] = record.daysSinceLastFill;

            if (record.dispensingPharmacy) {
              item['dispensingPharmacyName'] = record.dispensingPharmacy.pharmacyId
                + ", " + record.dispensingPharmacy.name
                + ", T:" + record.dispensingPharmacy.phoneNumber
                + ", F:" + record.dispensingPharmacy.faxNumber;
            }

            if (record.claimHistory) {
            item['saTypeApplied'] = record.claimHistory.saTypeApplied;
            item['acceptedAmount'] = record.claimHistory.acceptedAmount;
            item['claimAmount'] = record.claimHistory.claimAmount;
            item['planCode'] = record.claimHistory.planCode;
            }

            if (record.prescriberInfo) {
            item['prescriberName'] = record.prescriberInfo.name + ", "
            + ", " + record.prescriberInfo.licenseNo
            + ", T:" + record.prescriberInfo.phoneNumber
            + ", F:" + record.prescriberInfo.faxNumber;
            }

            item['rxStatus'] = record.rxStatus;
            dataArray.push(item);
          });
          this.data = dataArray;
          this.data.sort((a, b) => {
            let c = Date.parse(new Date(a.datedispensed));
            let d = Date.parse(new Date(b.datedispensed));
            return d-c;
            });
        } else {
          this.handlePharmanetSuccess();
        }
        this.loaded = true;
        this.updatePageButtons();
      } else {
          this.handlePharmanetError(data);
      }
    });
  }

  doSorting(event) {
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.sortData(this.sortBy, this.sortDirection);
  }

  sortData(fieldname, direction) {
    let parseDataObj = JSON.parse(JSON.stringify(this.data));
    let keyValue = (a) => {
        return a[fieldname];
    };
    let isReverse = direction === 'asc' ? 1: -1;
    parseDataObj.sort((a, b) => {
        a = keyValue(a) ? keyValue(a) : ''; 
        b = keyValue(b) ? keyValue(b) : '';
        return isReverse * ((a > b) - (b > a));
    });
    this.data = parseDataObj;
  } 

  handleSearch (event){
    this.searchKey = event.target.value;
    this.disableSearch = false;
    if(this.searchKey && this.searchKey.length >0 && this.searchKey.length < 3){
      this.disableSearch = true;
    }
    if(!this.searchKey && !this.disableSearch){
      this.fetchItems();
    }
  }
  
  handleGetPharmanetHistory(){
    this.pageNumber = 1;
    this.loadingData = true;
    this.disableSearch = true;
    this.hasResults = false;
    //this.totalPages = 1;
    fetchPrescriptionHistoryWithSearchKey({recordId: this.recordId, page: this.pageNumber, totalCount: this.totalRecords, dinList: this.dinList, searchKey: this.searchKey, displayCount: this.totalRecordsCount})
    .then(data => { 
      if (data && data.error == null) {
      const records = data.medHistory && data.medHistory.medRecords;
      this.totalRecords = data.medHistory && data.medHistory.totalRecords;
      //this.totalPages = data.medHistory && data.medHistory.totalPages; 
      this.totalPages = Math.ceil(records.length/this.count);

      this.searchRecordCount = records.length;
      if (this.totalRecords > 0) {
        this.completeAndNoResults = false;
        this.hasResults = true;
        this.loadingData = false;
        this.disableSearch = false;
        let dataArray = [];
        let i = 0;
        records.forEach(rec => {
        let item = {};
    
        item['key'] = i++;
        item['rxNumber'] = rec.rxNumber;
        item['quantity'] = rec.quantity;
        item['refills'] = rec.refills;
        item['dateDispensed'] = rec.dateDispensed;
        item['dinpin'] = rec.dinpin;
        item['genericName'] = rec.genericName;
        item['drugStrength'] = rec.drugStrength;
        item['directions'] = rec.directions;
        item['daysSupply'] = rec.daysSupply;
        item['daysSince'] = rec.daysSinceLastFill;
    
        if (rec.dispensingPharmacy) {
          item['dispensingPharmacyName'] = rec.dispensingPharmacy.pharmacyId
          + ", " + rec.dispensingPharmacy.name
          + ", T:" + rec.dispensingPharmacy.phoneNumber
          + ", F:" + rec.dispensingPharmacy.faxNumber;
        }
    
        if (rec.claimHistory) {
        item['saTypeApplied'] = rec.claimHistory.saTypeApplied;
        item['acceptedAmount'] = rec.claimHistory.acceptedAmount;
        item['claimAmount'] = rec.claimHistory.claimAmount;
        item['planCode'] = rec.claimHistory.planCode;
        }
    
        if (rec.prescriberInfo) {
        item['prescriberName'] = rec.prescriberInfo.name + ", "
        + ", " + rec.prescriberInfo.licenseNo
        + ", T:" + rec.prescriberInfo.phoneNumber
        + ", F:" + rec.prescriberInfo.faxNumber;
        }
    
        item['rxStatus'] = rec.rxStatus;
        dataArray.push(item);
        });
        this.data = dataArray;
        
        this.data.sort((x, y) => {
        let a = Date.parse(new Date(x.datedispensed));
        let b = Date.parse(new Date(y.datedispensed));
        return b-a;
        });
        this.searchData = this.data;
        this.getDataForPage();
      } else {
        this.handlePharmanetSuccess();
      }
      this.loaded = true;
      this.updatePageButtons();
      } else {
        this.handlePharmanetError(data);
      }
    });
    } 

  getDataForPage(){
    const startIndex = (this.pageNumber - 1) * this.count;
    //const endIndex = startIndex + this.count;
    let tempData = [...this.searchData];
    this.data = tempData.splice(startIndex, this.count);
    this.updatePageButtons();

  }

  handlePharmanetSuccess(){
    this.hasResults = false;
    this.loadingData = false;
    this.disableSearch = false;
    this.completeAndNoResults = true;
    this.pageNumber = 1;
  }

  handlePharmanetError(data){
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
