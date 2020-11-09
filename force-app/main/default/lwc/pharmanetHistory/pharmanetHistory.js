import { LightningElement, wire } from 'lwc';
import fetchData from '@salesforce/apex/ODRIntegration.fetchData';

const columns = [
  { label: 'RX Number', fieldName: 'rxNumber', initialWidth: 120 },
  { label: 'RX Status', fieldName: 'rxStatus', initialWidth: 110 },
  { label: 'Name', fieldName: 'genericName', type: 'text', wrapText: true },
  { label: 'Quantity', fieldName: 'quantity', initialWidth: 80 },
  { label: 'Refills', fieldName: 'refills', initialWidth: 80 },
  { label: 'Date Dispensed', fieldName: 'dateDispensed', type: 'date-local', typeAttributes:{ month: "2-digit", day: "2-digit" }, initialWidth: 140 },
  { label: 'Dispenser', fieldName: 'dispensingPharmacyName', type: 'text', wrapText: true },
  { label: 'DIN', fieldName: 'dinpin' },
];

export default class PharmanetHistory extends LightningElement {
  columns = columns;
  data = [];
  loaded = false;
  count = '25';
  isFirstPage = true;
  isLastPage = false;
  totalRecordCount = 111;
  pageNumber = 1;
  totalPageCount = 11;

  handleNextPage(event) {
    console.log('handle previous page', event);
    console.log(this.pageNumber, this.totalPageCount);
    if (this.pageNumber < this.totalPageCount) {
      this.pageNumber = this.pageNumber + 1;
    }
    this.handlePageChange();
  }
  handlePrevPage(event) {
    console.log('handle next page', event);
    console.log(this.pageNumber, this.totalPageCount);
    if (this.pageNumber > 1) {
      this.pageNumber = this.pageNumber - 1;
    }
    this.handlePageChange();
  }
  handlePageChange() {
    // Call the service and update stuff.
    this.updatePageButtons();
  }

  updatePageButtons() {
    console.log('PageNumber:', this.pageNumber, 'total', this.totalPageCount);
    if (this.pageNumber === 1) {
      this.isFirstPage = true;
    } else {
      this.isFirstPage = false;
    }
    if (this.pageNumber >= this.totalPageCount) {
      this.isLastPage = true;
    } else {
      this.isLastPage = false;
    }
  }

  // Count Options
  get countOptions() {
    return [
        { label: '25', value: '25' },
        { label: '50', value: '50' },
        { label: '75', value: '75' },
        { label: '100', value: '100' },
    ];
  }
  // Count change handler
  handleCountChange(event) {
    this.count = event.detail.value;
  }

  @wire(fetchData, { page: '1', count: '$count'}) mapObjectToData({error,data}) {
    console.log("error:", error);
    console.log("data:", data);

    if (data) {
      // console.log("medHistory:", data.medHistory);
      // console.log("medRecords:", data.medHistory.medRecords);
      const records = data.medHistory.medRecords;
      if (records.length) {
        let dataArray = [];
        records.forEach(record => {
          let item = {};
          item['rxNumber'] = record.rxNumber;
          item['rxStatus'] = record.rxStatus;
          item['genericName'] = record.genericName;
          item['dispensingPharmacyName'] = record.dispensingPharmacy.name;
          item['dateDispensed'] = record.dateDispensed;
          item['dinpin'] = record.dinpin;
          item['quantity'] = record.quantity;
          item['refills'] = record.refills;
          dataArray.push(item);
        });
        this.data = dataArray;
        this.loaded = true;
      }
    }
  };
}