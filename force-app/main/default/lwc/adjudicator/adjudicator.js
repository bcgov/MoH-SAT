import { LightningElement, api } from 'lwc';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import runAdjudicator from '@salesforce/apex/AdjudicatorController.runAdjudicator';

export default class Adjudicator extends LightningElement {

    @api
    recordId;

    async handleAdjudicate() {
        this.adjudicate(false);
    }
    
    async handleAdjudicateWithAssignment() {
        this.adjudicate(true);
    }

    async adjudicate(assignOwner) {
        this.busy = true;
        try {
            await runAdjudicator({caseId: this.recordId, assignOwner: assignOwner});
            getRecordNotifyChange([{recordId: this.recordId}]);
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
        }
        this.busy = false;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            mode: "sticky",
            variant: variant
        }));
    }

    set busy(value) {
        if (value) {
            this.template.querySelector('.icon-container').classList.add('spin');
        } else {
            this.template.querySelector('.icon-container').classList.remove('spin');
        }
    }
}