import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class SaCaseList extends NavigationMixin(LightningElement) {

    @api cases;
    @api hideCaseViewButton = false;
    @api hidePatient = false;
    @api hideOwner = false;
    @api hideDrug = false;
    @api hideRequestDetails = false;
    @api hideQidToggle = false;
    

    get hasCases() {
        return this.cases && this.cases.length > 0;
    }

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