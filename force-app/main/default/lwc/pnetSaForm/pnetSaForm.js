import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import submitSinglePnetSar from '@salesforce/apex/PharmanetPayloadController.submitSinglePnetSar';
import submitSaApprovalUpdate from '@salesforce/apex/PharmanetPayloadController.submitSaApprovalUpdate';
import getDescription from '@salesforce/apex/DescriptionLookup.getDescription';

export default class PnetSaForm extends LightningElement {
    @api
    caseId;
    
    _record;

    @api
    formDisabled;

    hasError;

    // Is this form being used to update, terminate, or submit?
    @api
    update = false;
    
    @api
    terminate = false;

    description;

    async connectedCallback() {
        let param = this.isRdp == true ? this._record.rdp : this._record.din;
        this.description = await getDescription({ code: param });
    }

    get isSubmit(){
        return this.update == this.terminate;
    }

    get msOptions () {
        return [{'value':'B','label':'Non-Benefit'},
                {'value':'L','label':'LCA',},
                {'value':'R','label':'RDP'}];
    }

    handleComboItemSelected (event) {
        this._record['specAuthType'] = event.target.value;
    }

    get updateRecord() {
        return {
            updateType:"U",
            saRecordId:{
                phn: this._record.phn,
                specialItem: {
                    din: this._record.din,
                    rdp: this._record.rdp
                },
                specAuthType: this._record.specAuthType,
                effectiveDate: this.dateSfdcToOdr(this._record.effectiveDate)
            },
            saRevisedData: {
                specialItem: {
                    din: this._record.din,
                    rdp: this._record.rdp
                },
                specAuthType: this._record.specAuthType,
                justificationCodes: this.strToArr(this._record.justificationCodes),
                excludedPlans: this.strToArr(this._record.excludedPlans),
                saRequester: {
                    practIdRef: this._record.practIdRef,
                    practId: this._record.practId,
                    decCode: this._record.decCode
                },
                effectiveDate: this.dateSfdcToOdr(this._record.effectiveDate),
                terminationDate: this.dateSfdcToOdr(this._record.terminationDate),
                maxDaysSupply: this._record.maxDaysSupply,
                maxPricePct: this._record.maxPricePct,
            }
        };
    }

    get terminateRecord(){
        return {
            updateType:"T",
            saRecordId:{
                phn: this._record.phn,
                specialItem: {
                    din: this._record.din,
                    rdp: this._record.rdp
                },
                specAuthType: this._record.specAuthType,
                effectiveDate: this.dateSfdcToOdr(this._record.effectiveDate)
            },
            saRevisedData: {
                terminationDate: this.dateSfdcToOdr(this._record.terminationDate)
            }
        };
    }

    get record() {
        return {
            saRecord: {
                phn: this._record.phn,
                specAuthType: this._record.specAuthType,
                justificationCodes: this.strToArr(this._record.justificationCodes),
                excludedPlans: this.strToArr(this._record.excludedPlans),
                effectiveDate: this.dateSfdcToOdr(this._record.effectiveDate),
                terminationDate: this.dateSfdcToOdr(this._record.terminationDate),
                maxDaysSupply: this._record.maxDaysSupply,
                maxPricePct: this._record.maxPricePct,
                saRequester: {
                    practIdRef: this._record.practIdRef,
                    practId: this._record.practId,
                    decCode: this._record.decCode
                },
                specialItem: {
                    din: this._record.din,
                    rdp: this._record.rdp
                }
            }
        };
    }

    // SAApprovalRequest
    @api
    set record(value) {
        this._record = {
            phn: value.saRecord.phn,
            practId: value.saRecord.saRequester.practId,
            practIdRef: value.saRecord.saRequester.practIdRef,
            decCode: value.saRecord.saRequester.decCode,
            din: value.saRecord.specialItem.din,
            rdpFormatted: this.formatRdp(value.saRecord.specialItem.rdp),
            rdp: value.saRecord.specialItem.rdp,
            specAuthType: value.saRecord.specAuthType,
            justificationCodes: this.arrToStr(value.saRecord.justificationCodes),
            excludedPlans: this.arrToStr(value.saRecord.excludedPlans),
            effectiveDate: this.dateOdrToSfdc(value.saRecord.effectiveDate),
            terminationDate: this.setTerminationDate(value.saRecord.terminationDate),
            maxDaysSupply: value.saRecord.maxDaysSupply,
            maxPricePct: value.saRecord.maxPricePct,
        };
    }

    get isDin() {
        return this._record.din && this._record.din.length > 0;
    }

    get isRdp() {
        return this._record.rdp && this._record.rdp.length > 0
    }

    setTerminationDate(odrDateStr){
        // if terminate, set termination date to today
        let today = new Date().toISOString().slice(0, 10);
        return this.terminate ? this.dateOdrToSfdc(today) : this.dateOdrToSfdc(odrDateStr);
    }

    dateOdrToSfdc(odrDateStr) {
        if (!odrDateStr) return null;
        return odrDateStr.replaceAll('/', '-');
    }

    dateSfdcToOdr(sfdcDateStr) {
        if (!sfdcDateStr) return null;
        return sfdcDateStr.replaceAll('-', '/');
    }

    formatRdp(rdp) {
        if (!rdp) return null;
        return rdp.substring(0,4)+'-'+rdp.substring(4);
    }

    arrToStr(arr) {
        return arr ? arr.join(',') : '';
    }

    strToArr(strValue) {
        return strValue.split(',').map(item => item.trim());
    }

    handleFormChange(event) {
        this._record[event.currentTarget.dataset.field] = event.target.value;
    }

    @api
    async submit() {
        let subject = this._record.rdp || this._record.din;
        let success = true;
        
        this.formDisabled = true;
        
        try {
            await submitSinglePnetSar({caseId: this.caseId, pnetSa: this.record });
            this.showSuccess(`[${subject}] Submitted to Pharmanet.`);
        } catch (error) {
            this.showError(error.body.message);
            this.formDisabled = false;
            success = false;
        }

        return success;
    }

    @api
    async updateSAARecord() {
        let subject = this._record.rdp || this._record.din;
        let success = true;
        let record = this.update ? this.updateRecord : this.terminateRecord;
        
        this.formDisabled = true;
        
        try {
            await submitSaApprovalUpdate({caseId: this.caseId, saaUpdateRequest: record });
            this.showSuccess(`[${subject}] Submitted to Pharmanet.`);
        } catch (error) {
            this.showError(error.body.message);
            this.formDisabled = this.terminate; // if terminate, keep form disabled
            success = false;
        }

        return success;
    }

    showSuccess(message) {
        this.hasError = false;
        this.template.querySelector('.slds-box').classList.remove('submit-error');
        this.template.querySelector('.slds-box').classList.add('submit-success');
        this.showToast('Success', message, 'success');
    }
    
    showError(message) {
        console.log(message);
        this.hasError = true;
        this.template.querySelector('.slds-box').classList.add('submit-error');
        this.template.querySelector('.slds-box').classList.remove('submit-success');
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
