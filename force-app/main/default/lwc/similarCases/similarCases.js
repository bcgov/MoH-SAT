import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import findCases from '@salesforce/apex/SimilarCases.find';

const columns = [
    { label: 'Question', fieldName: 'Question__c', wrapText: true, hideDefaultActions: true },
    { label: 'Response', fieldName: 'String_Value__c', wrapText: true, hideDefaultActions: true }
]
export default class SimilarCases extends NavigationMixin(LightningElement) {
    @api recordId;
    
    @wire(findCases, { caseId : '$recordId' })
    cases;

    get hasCases() {
        return this.cases && this.cases.data && this.cases.data.length > 0;
    }

    requestDetailsCols = columns;

    viewCase(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.currentTarget.dataset.caseId,
                actionName: 'view'
            },
        });
    }
}