import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getActiveSaRequests from '@salesforce/apex/SimilarCases.getActiveSaRequests';

export default class ActiveSaRequests extends NavigationMixin(LightningElement) {
    @api contactId;
    @api drugId;

    @wire(getActiveSaRequests, { contactId: '$contactId', drugId: '$drugId'})
    cases;

    get hasCases() {
        return this.cases && this.cases.data && this.cases.data.length > 0;
    }

    viewCase(event) {
        event.preventDefault();
        event.stopPropagation();

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.currentTarget.dataset.caseId,
                apiName: 'Case',
                actionName: 'view'
            },
        });
    }
}