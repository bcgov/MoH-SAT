import { LightningElement, api } from 'lwc';
export default class OdrLookup extends LightningElement {
    
    prescriberResult;
    submitterResult;
    patientResult;

    prescriberOverrideReason;
    patientOverrideReason;

    @api showPatient;
    @api showPrescriber;
    @api showSubmitter;

    @api
    availableActions = [];

    handlePrescriber(event) {
        this.prescriberResult = event.detail;
    }
    
    handleSubmitter(event) {
        this.submitterResult = event.detail;
    }
    
    handlePatient(event) {
        this.patientResult = event.detail;
    }

    @api
    validate() {
        const allowNext = this.isPrescriberValid() && this.isPatientValid() && this.isSubmitterValid();

        return {
            isValid: allowNext,
            errorMessage: allowNext ? undefined : 'Missing or invalid prescriber, submitter, or patient lookup.'
        }
    }

    @api
    get prescriber() {
        return this.prescriberResult.sobject;
    }
    
    @api
    get submitter() {
        return this.submitterResult?.sobject;
    }

    @api
    get patient() {
        return this.patientResult.sobject;
    }

    isPrescriberValid() {
        return !this.showPrescriber || (this.prescriber && this.prescriberResult.verified) || this.hasOverride(this.prescriberResult.overrideReason);
    }

    isPatientValid() {
        return !this.showPatient || (this.patient && this.patientResult.verified) || this.hasOverride(this.patientResult.overrideReason);
    }

    isSubmitterValid() {
        return !this.showSubmitter || (this.submitter === undefined || (this.submitter && this.submitterResult.verified));
    }

    hasOverride(reason) {
        return reason && reason != 'None';
    }
}