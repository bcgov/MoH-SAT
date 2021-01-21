import { LightningElement, wire, api } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

import OBJ_ACCOUNT from '@salesforce/schema/Account';
import OBJ_CONTACT from '@salesforce/schema/Contact';

export default class PatientLookup extends LightningElement {
    @api
    title;

    @api
    iconName = 'utility:search';

    patient = {};
    odrPatient = {};

    @wire(getObjectInfo, { objectApiName: OBJ_ACCOUNT })
    accountObjInfo;

    @wire(getObjectInfo, { objectApiName: OBJ_CONTACT })
    contactObjInfo;

    get ready() {
        return this.contactObjInfo && this.contactObjInfo.data;
    }

    get patientIdLabel() {
        return this.contactObjInfo.data.fields['Provider_Identifier__c'].label;
    }

    get patientId() {
        return this.template.querySelector('.fld-patientId').value;
    }

    get patientRecordTypeId() {
        return Object.values(this.accountObjInfo.data.recordTypeInfos).find(rti => rti.name=='Patient').recordTypeId;
    }

    handleFormChange(event) {
        this.patient[event.currentTarget.dataset.field] = event.target.value;
        this.sendResult(this.patient);
    }

    handleLookup() {

    }

    sendResult(record) {
        this.dispatchEvent(new CustomEvent('result', { detail: record }));
    }
}