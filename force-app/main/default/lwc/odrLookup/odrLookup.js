import { LightningElement, api } from 'lwc';
export default class OdrLookup extends LightningElement {
    @api showPatient;
    @api showPrescriber;
    @api showSubmitter;

    prescriberResult;
    submitterResult;
    patientResult;
    providerIdentifier;
    @api patient;
    @api prescriber;
    @api submitter;
    @api patientOverrideReason;
    @api prescriberOverrideReason;

    handlePrescriber(event) {
        this.prescriberResult = event.detail;
        this.prescriber = this.prescriberResult?.sobject;
        this.prescriberOverrideReason = this.prescriberResult?.overrideReason;
        this.providerIdentifier = this.prescriberResult?.sobject?.Provider_Identifier__pc;
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
        let prescriberOverriderReason;
        if(this.prescriberResult!=undefined && (this.prescriberResult.overrideReason != 'None')){
            prescriberOverriderReason = this.prescriberResult.overrideReason;
        }else{
            prescriberOverriderReason = undefined;
        }
        return !this.showPrescriber || (this.prescriber && this.prescriberResult?.verified) || prescriberOverriderReason;
    }

    isPatientValid() { // Added   this.patientResult as we are trying to access patientResult.overrideReason without checking if the patientResult is undefined or not
        let patientOverriderReason;
        if(this.patientResult!=undefined && (this.patientResult.overrideReason != 'None')){
            patientOverriderReason = this.patientResult.overrideReason;
        }else{
            patientOverriderReason = undefined;
        }
        return !this.showPatient || (this.patient && this.patientResult?.verified) || patientOverriderReason;
    }

    isSubmitterValid() {
        return !this.showSubmitter || (this.submitter === undefined || (this.submitter && this.submitterResult.verified));
    }

    hasOverride(reason) {
        return reason && reason != 'None';
    }
}