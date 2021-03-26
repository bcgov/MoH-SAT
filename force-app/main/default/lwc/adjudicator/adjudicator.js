import { LightningElement, api } from 'lwc';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import runAdjudicator from '@salesforce/apex/AdjudicatorController.runAdjudicator';

export default class Adjudicator extends LightningElement {

    @api
    recordId;

    async handleAdjudicate() {
        this.busy = true;

        try {
            await runAdjudicator({caseId: this.recordId});
            getRecordNotifyChange([{recordId: this.recordId}]); // delete
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