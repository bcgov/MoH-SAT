import { LightningElement, api } from 'lwc';
import fetchPrescriptionHistory from '@salesforce/apex/ODRIntegration.fetchPrescriptionHistory';
import getProductHealthCategories from '@salesforce/apex/ProductHealthCategory.getProductHealthCategories';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
  { label: 'DINPIN', fieldName: 'dinpin', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Name', fieldName: 'genericName', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Reported By', fieldName: 'reportedBy', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Date Reported', fieldName: 'dateReported', type: 'date-local', typeAttributes:{ month: "2-digit", day: "2-digit" }, hideDefaultActions: true },
  { label: 'Text', fieldName: 'text', type: 'text', wrapText: true, initialWidth: 120, hideDefaultActions: true },
  { label: 'Pract Id', fieldName: 'practitionerId', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Date Entered', fieldName: 'dateEntered', type: 'date-local', typeAttributes:{ month: "2-digit", day: "2-digit" }, hideDefaultActions: true }
];

export default class AdverseReactionHistory extends LightningElement {
  @api recordId;
  columns = columns;
  data = [];
  loaded = false;
  hasResults = false;
  completeAndNoResults = false;

  // TODO: Populate via din list picker.
  dinList = [];
  error = {};
  isError = false;

  connectedCallback() {
    this.fetchItems();
  }

  async fetchItems() {
    let data = await fetchPrescriptionHistory({recordId: this.recordId, page: '1', count: '1', dinList: null})
    if (data && data.error == null) {
      console.log("adverseHistory:", data);
      const records = data.adverseReactions;

      if (records.length > 0) {
        this.completeAndNoResults = false;
        this.hasResults = true;
        let dataArray = [];
        records.forEach(record => {
          let item = {};

          item['dinpin'] = record.dinpin;
          item['drugStrength'] = record.drugStrength;
          item['genericName'] = record.genericName;
          item['doseForm'] = record.doseForm;
          item['dateReported'] = record.dateReported;

          if (record.comment) {
            item['dateEntered'] = record.comment.dateEntered;
            item['practitionerName'] = record.comment.practitionerName;
            item['text'] = record.comment.text;
            item['practitionerRefId'] = record.comment.practitionerRefId;
            item['practitionerId'] = record.comment.practitionerId;
          }

          item['reportedBy'] = record.reportedBy;
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