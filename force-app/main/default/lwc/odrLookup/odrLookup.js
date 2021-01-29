import { LightningElement, api} from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class OdrLookup extends LightningElement {
    
    @api
    prescriber;

    @api
    submitter;

    @api
    patient;

    @api showPatient;
    @api showPrescriber;
    @api showSubmitter;

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
        let validPrescriber = !this.showPrescriber || (this.prescriber && this.prescriber.verified);
        let validPatient =  !this.showPatient || (this.patient && this.patient.verified);
        let validSubmitter = !this.showSubmitter || 
            (this.submitter === undefined || (this.submitter && this.submitter.verified));

        let flowHasNext = this.availableActions.find(action => action === 'NEXT');

        const allowNext = validPrescriber && validPatient && validSubmitter && flowHasNext;

        if (allowNext) {
            this.dispatchEvent(new FlowNavigationNextEvent());
        }
    }

}