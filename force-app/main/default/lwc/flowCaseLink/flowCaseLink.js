import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { FlowNavigationFinishEvent } from 'lightning/flowSupport';

import PATIENT_NAME from '@salesforce/schema/Case.Contact.Name';

export default class FlowCaseLink extends NavigationMixin(LightningElement) {
    @api recordId;
    @api availableActions = [];
    patientName = PATIENT_NAME;
    
    openCase(event) {
        event.preventDefault();
        event.stopPropagation();

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                apiName: 'Case',
                actionName: 'view'
            },
        });

        if (this.availableActions.find((action) => action === 'FINISH')) {
            this.dispatchEvent(new FlowNavigationFinishEvent());
        }
    }

}