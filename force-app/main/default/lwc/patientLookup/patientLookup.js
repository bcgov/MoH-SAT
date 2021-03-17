import { LightningElement, wire, api } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import findPatient from '@salesforce/apex/EmpiLookup.findPatient';

import FLD_PATIENT_OVERRIDE_REASON from '@salesforce/schema/Case.Patient_Override_Reason__c';

import OBJ_ACCOUNT from '@salesforce/schema/Account';
import OBJ_CONTACT from '@salesforce/schema/Contact';
import OBJ_CASE from '@salesforce/schema/Case';

export default class PatientLookup extends LightningElement {
    @api
    title;

    @api
    iconName = 'utility:search';

    completeAndNoResults = false;
    hasData = false;
    
    form = {
        overrideReason: 'None'
    };

    message = '';
    messageExists = false;

    @wire(getObjectInfo, { objectApiName: OBJ_ACCOUNT })
    accountObjInfo;

    @wire(getObjectInfo, { objectApiName: OBJ_CONTACT })
    contactObjInfo;

    @wire(getObjectInfo, { objectApiName: OBJ_CASE })
    caseObjInfo;

    @wire(getPicklistValues, { fieldApiName: FLD_PATIENT_OVERRIDE_REASON, recordTypeId: '012000000000000AAA' })
    patientOverrideReasonFldInfo;

    get ready() {
        return this.contactObjInfo && this.contactObjInfo.data &&
            this.caseObjInfo && this.caseObjInfo.data &&
            this.patientOverrideReasonFldInfo && this.patientOverrideReasonFldInfo.data;
    }

    get patientIdLabel() {
        return this.contactObjInfo.data.fields['Patient_Identifier__c'].label;
    }

    get patientOverrideReasonLabel() {
        return this.caseObjInfo.data.fields['Patient_Override_Reason__c'].label;
    }

    get patientOverrideReasonOptions() {
        return this.patientOverrideReasonFldInfo.data.values;
    }

    get patientId() {
        return this.template.querySelector('.patientIdentifier').value;
    }

    get patientRecordTypeId() {
        return Object.values(this.accountObjInfo.data.recordTypeInfos).find(rti => rti.name=='Patient').recordTypeId;
    }

    handleFormChange(event) {
        if (event.currentTarget.dataset.field == 'overrideReason') {
            this.form[event.currentTarget.dataset.field] = event.target.value.replace(/\s/g,'');
            this.publishChange(this.form);
        }
        
        this.template.querySelector('.btn-lookup').disabled = !this.patientId
    }

    async handleLookup() {
        this.messageExists = false;
        this.completeAndNoResults = false;
        this.template.querySelector('.btn-lookup').disabled = true;

        this.patientProvider = await findPatient({
            phn: this.patientId
        });

        this.resetForm();

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
            } else if (this.message.startsWith('BCHCIM.GD.2.0006')) {
              // Invalid message
              this.message = 'Invalid PHN';
              this.messageExists = true;
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
            this.patientProvider.names.forEach(element => {
              if (element.type == 'L') {
                LastName = element.familyName;

                // Now pluck the given names
                await element.givenNames.forEach(async given => {
                  FirstName += given + ", ";
                });
              }
            });
            // Detect masked
            this.form = {
                FirstName: FirstName, // Always pick their L name
                LastName: LastName, // Always pick their L name
                Names: this.patientProvider.names,
                Gender: this.patientProvider.gender,
                Deceased: this.patientProvider.deceased == true ? 'Yes' : 'No',
                PersonBirthdate: this.patientProvider.dob,
                verified: true,
                ...this.form
            }
        }

        this.publishChange(this.form);

        this.template.querySelector('.btn-lookup').disabled = false;
    }

    resetForm() {
        this.form = {
            patientIdentifier: this.patientId,
            overrideReason: 'None'
        }
    }

    publishChange(form) {
        let result = {
            overrideReason: form.overrideReason,
            verified: form.verified,
            sobject : {
                RecordTypeId: this.patientRecordTypeId,
                Patient_Identifier__pc: form.patientIdentifier,
                FirstName: form.FirstName,
                LastName: form.LastName,
                Patient_is_Deceased__c: form.Deceased,
                PersonBirthdate: form.PersonBirthdate            
            }
        }
        this.dispatchEvent(new CustomEvent('result', { detail: result }));
    }

    get noRecord() {
        return this.patientProvider && this.patientProvider.verified === undefined;
    }
}