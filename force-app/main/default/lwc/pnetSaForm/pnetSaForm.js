import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import postSingleSAApproval from '@salesforce/apex/ODRIntegration.postSingleSAApproval';
export default class PnetSaForm extends LightningElement {
    @api
    caseId;
    
    _record;

    @api
    formDisabled;

    get msOptions () {
        return [{'value':'B','label':'Non-Benefit'},
                {'value':'L','label':'LCA',},
                {'value':'R','label':'RDP'}];
    }

    handleComboItemSelected (event) {
        this._record['specAuthType'] = event.target.value;
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
                    practId: this._record.practId
                },
                specialItem: {
                    din: this._record.din,
                    rdp: this._record.rdp
                }
            }
        };
    }

    @api
    set record(value) {
        this._record = {
            phn: value.saRecord.phn,
            practId: value.saRecord.saRequester.practId,
            practIdRef: value.saRecord.saRequester.practIdRef,
            din: value.saRecord.specialItem.din,
            rdp: value.saRecord.specialItem.rdp,
            specAuthType: value.saRecord.specAuthType,
            justificationCodes: this.arrToStr(value.saRecord.justificationCodes),
            excludedPlans: this.arrToStr(value.saRecord.excludedPlans),
            effectiveDate: this.dateOdrToSfdc(value.saRecord.effectiveDate),
            terminationDate: this.dateOdrToSfdc(value.saRecord.terminationDate),
            maxDaysSupply: value.saRecord.maxDaysSupply,
            maxPricePct: value.saRecord.maxPricePct,
        };
    }

    dateOdrToSfdc(odrDateStr) {
        if (!odrDateStr) return null;
        return odrDateStr.replaceAll('/', '-');
    }

    dateSfdcToOdr(sfdcDateStr) {
        if (!sfdcDateStr) return null;
        return sfdcDateStr.replaceAll('-', '/');
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
        try {
            let saResponse = await postSingleSAApproval({
                caseId: this.caseId,
                pnetSa: this.record
            });

            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Submitted to Pharmanet',
                mode: "dismissable",
                variant: "success"
            }));

            this.disableForm();
            
        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                mode: "dismissable",
                variant: "error"
            }));
        }
    }

    disableForm() {
        this.formDisabled = true;
    }
}
