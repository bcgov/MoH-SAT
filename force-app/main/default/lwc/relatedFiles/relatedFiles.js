import { LightningElement, wire, api } from 'lwc';
import getRelatedFiles from '@salesforce/apex/RelatedFiles.getRelatedFiles';
import { NavigationMixin } from 'lightning/navigation';

export default class RelatedFiles extends NavigationMixin(LightningElement) {
    @api recordId;

    @api
    hideQidToggle = false;

    @wire(getRelatedFiles, { caseId: '$recordId'})
    records;

    showIds = false;

    get hasRecords() {
      return this.records && this.records.data && this.records.data.length > 0;
    }

    handleDownload(event) {
      this[NavigationMixin.Navigate]({
        type: 'standard__webPage',
        attributes: {
          url: event.target.value
        },
        state: {
          recordIds: event.target.value,
          selectedRecordId: event.target.value
        }
      });
    }

    toggleIds() {
        this.showIds = !this.showIds;
    }
}