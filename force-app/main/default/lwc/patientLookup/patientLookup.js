import { LightningElement, wire, api } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import findPatient from '@salesforce/apex/EmpiLookup.findPatient';

import OBJ_ACCOUNT from '@salesforce/schema/Account';
import OBJ_CONTACT from '@salesforce/schema/Contact';

export default class PatientLookup extends LightningElement {
    @api
    title;

    @api
    iconName = 'utility:search';

    completeAndNoResults = false;
    hasData = false;
    odrPatient = {};

    @wire(getObjectInfo, { objectApiName: OBJ_ACCOUNT })
    accountObjInfo;

    @wire(getObjectInfo, { objectApiName: OBJ_CONTACT })
    contactObjInfo;

    get ready() {
        return this.contactObjInfo && this.contactObjInfo.data;
    }

    get patientIdLabel() {
        return this.contactObjInfo.data.fields['Patient_Identifier__c'].label;
    }

    get patientId() {
        return this.template.querySelector('.fld-patientId').value;
    }

    get patientRecordTypeId() {
        return Object.values(this.accountObjInfo.data.recordTypeInfos).find(rti => rti.name=='Patient').recordTypeId;
    }

    handleFormChange(event) {
        this.odrPatient[event.currentTarget.dataset.field] = event.target.value;

        this.template.querySelector('.btn-lookup').disabled
            = !this.odrPatient.Patient_Identifier__pc;
    }

    async handleLookup() {
        this.template.querySelector('.btn-lookup').disabled = true;

        this.odrPatient = {
            RecordTypeId: this.patientRecordTypeId,
            Patient_Identifier__pc: this.odrPatient.Patient_Identifier__pc
        };

        this.patientProvider = await findPatient({
            phn: this.odrPatient.Patient_Identifier__pc,
        });

        if (this.patientProvider.gender == undefined,
            this.patientProvider.dob == undefined,
            this.patientProvider.familyName == undefined,
            this.patientProvider.givenName == undefined)
        {
            // No Data!
            this.hasData = false;
            this.completeAndNoResults = true;
        } else {
            this.completeAndNoResults = false;
            this.hasData = true;

            this.odrPatient = {
                FirstName: this.patientProvider.givenName,
                LastName: this.patientProvider.familyName,
                Gender: this.patientProvider.gender,
                Deceased: this.patientProvider.deceased,
                PersonBirthdate: new Date(this.patientProvider.dob),
                verified: true,
                ...this.odrPatient
            }
        }

        this.publishChange(this.odrPatient);

        this.template.querySelector('.btn-lookup').disabled = false;
    }

    publishChange(record) {
        this.dispatchEvent(new CustomEvent('change', { detail: record }));
    }

    get noRecord() {
        return this.patientProvider && this.patientProvider.verified === undefined;
    }
}