import { LightningElement, wire, api } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

import FLD_PROVIDER_TYPE from '@salesforce/schema/Contact.Provider_Type__c';
import OBJ_ACCOUNT from '@salesforce/schema/Account';
import OBJ_CONTACT from '@salesforce/schema/Contact';

import findProvider from '@salesforce/apex/OdrLookup.findProvider';

export default class ProviderLookup extends LightningElement {
    @api
    title;

    @api
    iconName = 'utility:search';

    provider = {};
    odrProvider = {};
    hasOdrProvider;

    @wire(getObjectInfo, { objectApiName: OBJ_ACCOUNT })
    accountObjInfo;

    @wire(getObjectInfo, { objectApiName: OBJ_CONTACT })
    contactObjInfo;

    @wire(getPicklistValues, { fieldApiName: FLD_PROVIDER_TYPE, recordTypeId: '012000000000000AAA' })
    providerTypeFldInfo;

    get ready() {
        return this.contactObjInfo && this.contactObjInfo.data && 
            this.providerTypeFldInfo && this.providerTypeFldInfo.data;
    }

    get providerTypeOptions() {
        return this.providerTypeFldInfo.data.values;
    }

    get providerTypeLabel() {
        return this.contactObjInfo.data.fields['Provider_Type__c'].label;
    }
    
    get providerIdLabel() {
        return this.contactObjInfo.data.fields['Provider_Identifier__c'].label;
    }

    get providerRecordTypeId() {
        return Object.values(this.accountObjInfo.data.recordTypeInfos).find(rti => rti.name=='Provider').recordTypeId;
    }

    handleFormChange(event) {
        this.provider[event.currentTarget.dataset.field] = event.target.value;

        this.template.querySelector('.btn-lookup').disabled 
            = !(this.provider.Provider_Type__pc 
            && this.provider.Provider_Identifier__pc);
    }

    async handleLookup() {
        this.template.querySelector('.btn-lookup').disabled = true;
        
        this.odrProvider = {};

        this.provider = {
            RecordTypeId: this.providerRecordTypeId,
            Provider_Identifier__pc: this.provider.Provider_Identifier__pc,
            Provider_Type__pc: this.provider.Provider_Type__pc
        };

        this.odrProvider = await findProvider({
            providerId: this.provider.Provider_Identifier__pc,
            providerType: this.provider.Provider_Type__pc,
        });
        
        this.hasOdrProvider = this.odrProvider && this.odrProvider.hasOwnProperty('status');

        this.provider = {
            FirstName: this.odrProvider.firstName,
            LastName: this.odrProvider.lastName,
            PersonBirthdate: this.parseDate(this.odrProvider.dateofBirth),
            verified: this.odrProvider.status == 'P',
            ...this.provider
        }
        
        this.publishChange(this.provider);
                
        this.template.querySelector('.btn-lookup').disabled = false;
    }

    publishChange(record) {
        this.dispatchEvent(new CustomEvent('change', { detail: record }));
    }

    parseDate(odrDateStr) {
        if (!odrDateStr) return null;
        var mdy = odrDateStr.split('/');
        return mdy[2] + '-' + mdy[0] + '-' + mdy[1];
    }

    get statusCss() {
        return this.odrProvider.status == 'P' 
            ? 'slds-text-color_success' 
            : 'slds-text-color_error';
    }

    get noRecord() {
        return this.odrProvider && this.odrProvider.verified === false;
    }
}