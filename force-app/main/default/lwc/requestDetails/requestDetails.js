import { LightningElement, wire, api } from 'lwc';
import getRequestDetails from '@salesforce/apex/RequestDetails.getRequestDetails';

export default class RequestDetails extends LightningElement {
    @api recordId;

    @api
    hideQidToggle = false;
    
    @wire(getRequestDetails, { caseId: '$recordId'})
    records;
    
    showIds = false;

    get hasRecords() {
        return this.records && this.records.data && this.records.data.length > 0;
    }

    toggleIds() {
        this.showIds = !this.showIds;
    }
}