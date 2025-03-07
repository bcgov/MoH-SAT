import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';

import submitSinglePnetSar from '@salesforce/apex/PharmanetPayloadController.submitSinglePnetSar';
import submitSaApprovalUpdate from '@salesforce/apex/PharmanetPayloadController.submitSaApprovalUpdate';
import getDescription from '@salesforce/apex/DescriptionLookup.getDescription';
import UserPreferencesShowFaxToGuestUsers from '@salesforce/schema/User.UserPreferencesShowFaxToGuestUsers';
import FLD_MAX_DAYS_SUPPLY from '@salesforce/schema/Case.Max_Days_Supply__c';
import { getRecord } from "lightning/uiRecordApi";


export default class PnetSaForm extends LightningElement {
    @api
    caseId;

    @track recordId;
    
    _record;
    original_record;

    @api
    formDisabled;

    hasError;

    // Is this form being used to update, terminate, or submit?
    @api
    update = false;
    
    @api
    terminate = false;

    description;
    maxDaysSupply;
    payloadMaxDaysSupply;

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.attributes.recordId;
        }
    }

    @wire(getRecord, { recordId: "$caseId", fields: [FLD_MAX_DAYS_SUPPLY]})
    cases({data, error}){
        if(data) {
          let maxDaysSupply = data.fields.Max_Days_Supply__c.value;
          if(maxDaysSupply){
            this.maxDaysSupply = data.fields.Max_Days_Supply__c.value;
            this._record.maxDaysSupply = this.maxDaysSupply;
          }
          else {
            this.maxDaysSupply = this._record.maxDaysSupply;
            this._record.maxDaysSupply = this.payloadMaxDaysSupply;
          }
        }
        else if (error){
            console.log(error);
        }
    }

    async connectedCallback() {
        let param = this.isRdp == true ? this._record.rdpFormatted : this._record.din;
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
        var revisedData = this.constructRevisedData();
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
            saRevisedData: revisedData
        };
    }

    constructRevisedData(){
        var saRevisedData = {};
        if (this.original_record.specAuthType != this._record.specAuthType) saRevisedData.specAuthType = this._record.specAuthType;
        if (this.original_record.justificationCodes != this._record.justificationCodes) saRevisedData.justificationCodes = this.strToArr(this._record.justificationCodes);
        if (this.original_record.excludedPlans != this._record.excludedPlans) saRevisedData.excludedPlans = this.strToArr(this._record.excludedPlans);
        if (this.original_record.effectiveDate != this._record.effectiveDate) saRevisedData.effectiveDate = this.dateSfdcToOdr(this._record.effectiveDate);
        if (this.original_record.maxDaysSupply != this._record.maxDaysSupply) saRevisedData.maxDaysSupply = this._record.maxDaysSupply; 
        this.payloadMaxDaysSupply = this._record.maxDaysSupply;

        console.log("SA REVISED DATA");
        console.log(saRevisedData);
        return saRevisedData;
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
        this.original_record = {
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

        if (record.saRevisedData == null || Object.keys(record.saRevisedData).length === 0 ){
            this.showError("No changes in update.");
            this.formDisabled = this.terminate; // if terminate, keep form disabled
            success = false;
            return success;
        }
        
        try {
            if(this.caseId){
                await submitSaApprovalUpdate({caseId: this.caseId, saaUpdateRequest: record });
            }else if(this.recordId){
                await submitSaApprovalUpdate({caseId: this.recordId, saaUpdateRequest: record });
            }
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
