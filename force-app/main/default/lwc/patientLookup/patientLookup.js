import { LightningElement, wire, api } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import findPatient from '@salesforce/apex/EmpiLookup.findPatient';

import OBJ_ACCOUNT from '@salesforce/schema/Account';
import OBJ_CONTACT from '@salesforce/schema/Contact';
import FirstName from '@salesforce/schema/Account.FirstName';

export default class PatientLookup extends LightningElement {
    @api
    title;

    @api
    iconName = 'utility:search';

    completeAndNoResults = false;
    hasData = false;
    odrPatient = {};
    message = '';
    messageExists = false;

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
        this.messageExists = false;
        this.completeAndNoResults = false;
        this.template.querySelector('.btn-lookup').disabled = true;

        this.odrPatient = {
            RecordTypeId: this.patientRecordTypeId,
            Patient_Identifier__pc: this.odrPatient.Patient_Identifier__pc
        };

        this.patientProvider = await findPatient({
            phn: this.odrPatient.Patient_Identifier__pc,
        });

        this.message = this.patientProvider.notes;

        if (this.message.startsWith('BCHCIM.GD.2.0018') == true)
        {
            // No Data!
            this.hasData = false;
            this.completeAndNoResults = true;
        } else {
            this.completeAndNoResults = false;
            this.hasData = true;

            if (this.message.startsWith('BCHCIM.GD.0.0013')) {
              this.message = '';
            } else {
              this.messageExists = true;
              // Cleanup UI
              try {
                this.message = this.message.split('Warning: ')[1];
              } catch (e) {
                console.log('Error splitting', e);
              }
            }

            // Pack in the names.
            let FirstName = "";
            let LastName = "";
            await this.patientProvider.names.forEach(async element => {
              if (element.type == 'L') {
                FirstName = element.givenName;
                LastName = element.familyName;
              }
            });
            // Detect masked
            this.odrPatient = {
                FirstName: FirstName, // Always pick their L name
                LastName: LastName, // Always pick their L name
                Names: this.patientProvider.names,
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