import { LightningElement, wire, api } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

import FLD_PROVIDER_TYPE from '@salesforce/schema/Contact.Provider_Type__c';
import FLD_PROVIDER_OVERRIDE_REASON from '@salesforce/schema/Case.Prescriber_Override_Reason__c';
import OBJ_ACCOUNT from '@salesforce/schema/Account';
import OBJ_CONTACT from '@salesforce/schema/Contact';
import OBJ_CASE from '@salesforce/schema/Case';

import findProvider from '@salesforce/apex/OdrLookup.findProvider';
export default class ProviderLookup extends LightningElement {
    @api
    title;

    @api
    iconName = 'utility:search';

    @api
    hideOverride = false;

    form = {
        overrideReason: 'None'
    };

    @wire(getObjectInfo, { objectApiName: OBJ_ACCOUNT })
    accountObjInfo;

    @wire(getObjectInfo, { objectApiName: OBJ_CONTACT })
    contactObjInfo;
    
    @wire(getObjectInfo, { objectApiName: OBJ_CASE })
    caseObjInfo;

    @wire(getPicklistValues, { fieldApiName: FLD_PROVIDER_TYPE, recordTypeId: '012000000000000AAA' })
    providerTypeFldInfo;

    @wire(getPicklistValues, { fieldApiName: FLD_PROVIDER_OVERRIDE_REASON, recordTypeId: '012000000000000AAA' })
    providerOverrideReasonFldInfo;

    get ready() {
        return this.contactObjInfo && this.contactObjInfo.data && 
            this.caseObjInfo && this.caseObjInfo.data &&
            this.providerTypeFldInfo && this.providerTypeFldInfo.data &&
            this.providerOverrideReasonFldInfo && this.providerOverrideReasonFldInfo.data;
    }

    get providerTypeOptions() {
        return this.providerTypeFldInfo.data.values;
    }

    get providerOverrideReasonOptions() {
        return this.providerOverrideReasonFldInfo.data.values;
    }

    get providerTypeLabel() {
        return this.contactObjInfo.data.fields['Provider_Type__c'].label;
    }
    
    get providerIdLabel() {
        return this.contactObjInfo.data.fields['Provider_Identifier__c'].label;
    }
    
    get providerOverrideReasonLabel() {
        return this.caseObjInfo.data.fields['Prescriber_Override_Reason__c'].label;
    }

    get providerId() {
        return this.template.querySelector('.providerIdentifier').value;
    }

    get providerIdType() {
        return this.template.querySelector('.providerIdType').value;
    }

    get providerRecordTypeId() {
        return Object.values(this.accountObjInfo.data.recordTypeInfos).find(rti => rti.name=='Provider').recordTypeId;
    }

    handleFormChange(event) {
        if (event.currentTarget.dataset.field == 'overrideReason') {
            this.form[event.currentTarget.dataset.field] = event.target.value.replace(/\s/g,'');
            this.publishChange(this.form);
        }

        this.template.querySelector('.btn-lookup').disabled 
            = !(this.providerId && this.providerIdType);
    }

    async handleLookup() {
        this.template.querySelector('.btn-lookup').disabled = true;
        
        let odrProvider = await findProvider({
            providerId: this.providerId,
            providerType: this.providerIdType,
        });
        
        this.resetForm();
        
        this.form = {
            firstName: odrProvider.firstName,
            lastName: odrProvider.lastName,
            personBirthdate: this.parseDate(odrProvider.dateofBirth),
            status: odrProvider.status,
            verified: odrProvider.status == 'P',
            statusHumanReadable: odrProvider.status == 'P' ? 'Practicing' : 'Non-Practicing',
            ...this.form
        }

        this.publishChange(this.form);
                
        this.template.querySelector('.btn-lookup').disabled = false;
    }

    publishChange(form) {
        let result = {
            overrideReason: form.overrideReason,
            verified: form.verified,
            sobject : {
                RecordTypeId: this.providerRecordTypeId,
                Provider_Identifier__pc: form.providerIdentifier,
                Provider_Type__pc: this.form.providerIdType,
                FirstName: form.firstName,
                LastName: form.lastName,
                PersonBirthdate: form.personBirthdate,
            }
        }
        this.dispatchEvent(new CustomEvent('result', { detail: result }));
    }

    resetForm() {
        this.form = {
            providerIdentifier: this.providerId,
            providerIdType: this.providerIdType,
            overrideReason: 'None'
        }
    }

    parseDate(odrDateStr) {
        if (!odrDateStr) return null;
        var mdy = odrDateStr.split('/');
        return mdy[2] + '-' + mdy[0] + '-' + mdy[1];
    }

    get statusCss() {
        return this.form.status == 'P' 
            ? 'slds-text-color_success' 
            : 'slds-text-color_error';
    }

    get noRecord() {
        return this.form && this.form.verified === false;
    }
}