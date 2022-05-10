import { LightningElement, api } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import sendAlert from "@salesforce/apex/ExternalCommitteeAlert.sendAlert";

export default class SendExternalCommitteeEmail extends LightningElement {
    @api recordId;

    @api async invoke() {
        try {
            await sendAlert({externalCommitteeId: this.recordId});
            getRecordNotifyChange([{recordId: this.recordId}]);
            this.showSuccess('Email sent.');
        } catch (error) {
            this.showError(error.body.message);
        }
    }

    showSuccess(message) {
        this.showToast('Success', message, 'success');
    }
    
    showError(message) {
        this.showToast('Error', message, 'error');
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            mode: "sticky",
            variant: variant
        }));
    }
}