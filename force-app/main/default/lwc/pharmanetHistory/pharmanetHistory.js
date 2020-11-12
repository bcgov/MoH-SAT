import { LightningElement, wire, api } from 'lwc';
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
  { label: 'Adverse Reactions', fieldName: 'adverseReactions' }
];

export default class PharmanetHistory extends LightningElement {
  @api recordId;
  columns = columns;
  data = [];
  loaded = false;
  count = '10';
  hasResults = false;
  completeAndNoResults = false;
  isFirstPage = true;
  isLastPage = false;
  totalRecords = 0;
  pageNumber = 1;
  totalPages = 0;

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
    // Call the service and update stuff.
    this.updatePageButtons();
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
  }

  @wire(fetchData, { caseId: '$recordId', page: '$pageNumber', count: '$count'}) mapObjectToData({error,data}) {
    console.log("error:", error);
    console.log("data:", data);

    if (data) {
      console.log("medHistory:", data.medHistory);
      const records = data.medHistory && data.medHistory.medRecords;
      this.totalRecords = data.medHistory && data.medHistory.totalRecords;
      this.totalPages = data.medHistory && data.medHistory.totalPages;

      if (this.totalRecords > 0) {
        this.completeAndNoResults = false;
        this.hasResults = true;
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
          item['adverseReactions'] = data.adverseReactions.length;
          dataArray.push(item);
        });
        this.data = dataArray;
      } else {
        this.hasResults = false;
        this.completeAndNoResults = true;
        this.pageNumber = 1;
      }
      this.loaded = true;
      this.updatePageButtons();
    }
  };
}