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

    @api
    validate() {
        const prescriberValid = this.prescriber && this.prescriber.verified;
        const patientValid = this.patient;
        const submitterValid = this.submitter === undefined || (this.submitter && this.submitter.verified);
        
        const valid = {
            isValid: false,
            errorMessage: []
        };

        if (!prescriberValid) {
            valid.isValid = false;
            valid.errorMessage.push('Prescriber is empty or not practicing.');
        } 
        if (!patientValid) {
            valid.isValid = false;
            valid.errorMessage.push('Patient is empty or invalid.');
        } 
        if (!submitterValid) {
            valid.isValid = false;
            valid.errorMessage.push('Submitter is not practicing.');
        } 

        if (prescriberValid && patientValid && submitterValid) {
            valid.isValid = true;
            valid.errorMessage = undefined;
        }
        
        if (valid.isValid == false) {
            valid.errorMessage = valid.errorMessage.join('\n');
        }

        return valid;
    }

}