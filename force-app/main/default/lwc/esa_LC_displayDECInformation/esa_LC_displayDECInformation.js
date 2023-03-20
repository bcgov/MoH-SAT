import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ACCOUNT_NAME from '@salesforce/schema/Case.DEC__r.Name';
import ACCOUNT_DEC from '@salesforce/schema/Case.DEC__r.DEC__c';

const fields = [ACCOUNT_NAME,ACCOUNT_DEC];

export default class Esa_LC_displayDECInformation extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields })
    caseObjRecord;

    get accountName() {
        return getFieldValue(this.caseObjRecord.data, ACCOUNT_NAME);
    }

    get accountDEC() {
        return getFieldValue(this.caseObjRecord.data, ACCOUNT_DEC);
    }     
}