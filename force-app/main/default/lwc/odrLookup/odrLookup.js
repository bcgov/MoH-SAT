import { LightningElement, api } from 'lwc';
export default class OdrLookup extends LightningElement {
    @api showPatient;
    @api showPrescriber;
    @api showSubmitter;

    prescriberResult;
    submitterResult;
    patientResult;
    @api patient;
    @api prescriber;
    @api submitter;
    @api patientOverrideReason;
    @api prescriberOverrideReason;

    handlePrescriber(event) {
        this.prescriberResult = event.detail;
        this.prescriber = this.prescriberResult?.sobject;
        this.prescriberOverrideReason = this.prescriberResult?.overrideReason;
    }
    
    handleSubmitter(event) {
        this.submitterResult = event.detail;
        this.submitter = this.submitterResult.sobject;
    }
    
    handlePatient(event) {
        this.patientResult = event.detail;
        this.patient = this.patientResult.sobject;
        this.patientOverrideReason = this.patientResult?.overrideReason;
    }

    toggleShowSubmitter(event) {
        this.showSubmitter = event.target.checked;

        if (this.showSubmitter == false) {
            this.submitterResult = null;
            this.submitter = null;
        }
    }

    @api
    validate() {
        const allowNext = this.isPrescriberValid() && this.isPatientValid() && this.isSubmitterValid();

        return {
            isValid: allowNext,
            errorMessage: allowNext ? undefined : 'Missing or invalid prescriber, submitter, or patient lookup.'
        }
    }

    isPrescriberValid() { // Added this.prescriberResult as we are trying to access prescriberResult.overrideReason without checking if the prescriberResult is undefined or not
        return !this.showPrescriber || (this.prescriber && this.prescriberResult.verified) || this.hasOverride(this.prescriberResult) || this.hasOverride(this.prescriberResult.overrideReason);
    }

    isPatientValid() { // Added this.patientResult as we are trying to access patientResult.overrideReason without checking if the patientResult is undefined or not
        return !this.showPatient || (this.patient && this.patientResult.verified) || this.hasOverride(this.patientResult) || this.hasOverride(this.patientResult.overrideReason);
    }

    isSubmitterValid() {
        return !this.showSubmitter || (this.submitter === undefined || (this.submitter && this.submitterResult.verified));
    }

    hasOverride(reason) {
        return reason && reason != 'None';
    }
}