import { LightningElement, api} from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class OdrLookup extends LightningElement {
    
    @api
    prescriber;

    @api
    submitter;

    @api
    patient;

    @api
    availableActions = [];

    handlePrescriber(event) {
        this.prescriber = event.detail;
    }
    
    handleSubmitter(event) {
        this.submitter = event.detail;
    }

    handlePatient(event) {
        this.patient = event.detail;
    }
    
    handleCancel() {
        console.log('cancel');
    }

    handleNext() {
        debugger;
        if (this.availableActions.find(action => action === 'NEXT')) {
            this.dispatchEvent(new FlowNavigationNextEvent());
        }
    }

}