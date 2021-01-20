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

    @api
    provider;
    odrProvider = {};

    @wire(getObjectInfo, { objectApiName: OBJ_ACCOUNT })
    accountObjInfo;

    @wire(getObjectInfo, { objectApiName: OBJ_CONTACT })
    contactObjInfo;

    @wire(getPicklistValues, { fieldApiName: FLD_PROVIDER_TYPE, recordTypeId: '012000000000000AAA' })
    providerTypeFldInfo;

    connectedCallback() {
        this.provider = this.provider || {};
    }
    
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

    get providerId() {
        return this.template.querySelector('.fld-providerId').value;
    }

    get providerType() {
        return this.template.querySelector('.fld-providerType').value;
    }

    get providerRecordTypeId() {
        return Object.values(this.accountObjInfo.data.recordTypeInfos).find(rti => rti.name=='Provider').recordTypeId;
    }

    handleFormChange(event) {
        this.provider[event.currentTarget.dataset.field] = event.target.value;
        
        // if (event.currentTarget.dataset.field == 'Provider_Identifier__pc')
        
        console.log(this.provider);
    }

    handleCommit(event) {
        this.handleLookup();
    }

    async handleLookup() {
        this.template.querySelector('.btn-lookup').disabled = true;
        
        this.odrProvider = await findProvider({
            providerId: this.providerId,
            providerType: this.providerType,
        });
        
        this.provider = {
            FirstName: this.odrProvider.firstName,
            LastName: this.odrProvider.lastName,
            PersonBirthdate: this.parseDate(this.odrProvider.dateofBirth),
            Provider_Identifier__pc: this.providerId,
            Provider_Type__pc: this.providerType,
            RecordTypeId: this.providerRecordTypeId
        }
        
        this.hasOdrProvider = this.odrProvider && this.odrProvider.hasOwnProperty('firstName');
        
        this.template.querySelector('.btn-lookup').disabled = false;
    }

    parseDate(odrDateStr) {
        var mdy = odrDateStr.split('/');
        return mdy[2] + '-' + mdy[0] + '-' + mdy[1];
    }
}