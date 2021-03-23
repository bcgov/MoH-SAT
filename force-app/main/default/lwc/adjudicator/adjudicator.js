import { LightningElement, api } from 'lwc';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import runAdjudicator from '@salesforce/apex/AdjudicatorController.runAdjudicator';

export default class Adjudicator extends LightningElement {

    @api
    recordId;

    async handleAdjudicate() {
        try {
            await runAdjudicator({caseId: this.recordId});
            getRecordNotifyChange([{recordId: this.recordId}]); // delete
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    showToast(title, message, variant) {
        console.log(message); // delete
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            mode: "sticky",
            variant: variant
        }));
    }

}