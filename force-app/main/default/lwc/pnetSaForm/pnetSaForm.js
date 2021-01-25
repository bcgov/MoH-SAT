import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PnetSaForm extends LightningElement {
    @api
    caseId;
    
    _record;

    get record() {
        return this._record;
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
            justificationCodes: value.saRecord.justificationCodes,
            excludedPlans: value.saRecord.excludedPlans,
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

    handleFormChange(event) {
        this._record[event.currentTarget.dataset.field] = event.target.value;
    }

    handleSubmit() {
        console.log(this._record);
    }
}