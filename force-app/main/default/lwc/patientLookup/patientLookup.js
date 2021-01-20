import { LightningElement, wire, api } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

import OBJ_ACCOUNT from '@salesforce/schema/Account';
import OBJ_CONTACT from '@salesforce/schema/Contact';

export default class PatientLookup extends LightningElement {
    @api
    title;

    @api
    iconName = 'utility:search';

    @api
    patient;
    odrPatient = {};

    @wire(getObjectInfo, { objectApiName: OBJ_ACCOUNT })
    accountObjInfo;

    @wire(getObjectInfo, { objectApiName: OBJ_CONTACT })
    contactObjInfo;

    connectedCallback() {
        this.patient = this.patient || {};
    }

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

    handleLookup() {

    }
}