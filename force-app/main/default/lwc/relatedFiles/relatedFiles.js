import { LightningElement, wire, api } from 'lwc';
import getRelatedFiles from '@salesforce/apex/RelatedFiles.getRelatedFiles';
import { refreshApex } from '@salesforce/apex'
import { NavigationMixin } from 'lightning/navigation';

const columns = [
  { label: 'Name', fieldName: 'Title', type: 'text', hideDefaultActions: true, },
  { label: "Date", fieldName: "createdDate", type: "date", fixedWidth: 165, hideDefaultActions: true, typeAttributes: { year: "numeric", month: "short", day: "2-digit", hour: "2-digit", minute: "2-digit" }},
  { label: 'View', type: 'button', fixedWidth: 80, hideDefaultActions: true, typeAttributes: { label: 'View', name: 'view_file', title: 'View'}}
];
export default class RelatedFiles extends NavigationMixin(LightningElement) {
    @api recordId;

    @api hideQidToggle = false;

    @wire(getRelatedFiles, { caseId: '$recordId'})
    records;

    showIds = false;

    columns = columns;

    get hasRecords() {
      return this.records && this.records.data && this.records.data.length > 0;
    }

    handleRowAction(event) {
      const action = event.detail.action;
      const row = event.detail.row;

      switch (action.name) {
        case 'view_file':
          this.handleDownload(row.URL);
          break;
      }
    }

    handleDownload(url) {
      this[NavigationMixin.Navigate]({
        type: 'standard__webPage',
        attributes: {
          url: url
        },
        state: {
          recordIds: url,
          selectedRecordId: url
        }
      });
    }

    handleUploadFinished(event) {
      refreshApex(this.records);
    }

    toggleIds() {
        this.showIds = !this.showIds;
    }
}