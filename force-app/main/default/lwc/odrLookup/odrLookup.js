import { LightningElement, wire, api} from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';

import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import FLD_PROVIDER_TYPE from '@salesforce/schema/Contact.Provider_Type__c';
import OBJ_ACCOUNT from '@salesforce/schema/Account';
import OBJ_CONTACT from '@salesforce/schema/Contact';

import findProvider from '@salesforce/apex/OdrLookup.findProvider';
export default class OdrLookup extends LightningElement {
    
    @wire(getObjectInfo, { objectApiName: OBJ_ACCOUNT })
    accountObjInfo;

    @wire(getObjectInfo, { objectApiName: OBJ_CONTACT })
    contactObjInfo;

    @wire(getPicklistValues, { fieldApiName: FLD_PROVIDER_TYPE, recordTypeId: '012000000000000AAA' })
    providerTypeInfo;

    @api
    provider = {};
    odrProvider = {};

    get ready() {
        return this.contactObjInfo && this.contactObjInfo.data && 
            this.providerTypeInfo && this.providerTypeInfo.data;
    }

    get providerTypeOptions() {
        return this.providerTypeInfo.data.values;
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

    async handleLookupProvider(event) {
        this.template.querySelector('.btn-lookupProvider').disabled = true;
        
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
        
        this.template.querySelector('.btn-lookupProvider').disabled = false;
    }

    parseDate(odrDateStr) {
        var mdy = odrDateStr.split('/');
        return mdy[2] + '-' + mdy[0] + '-' + mdy[1];
    }

    handleUseProvider() {
        this.dispatchEvent(new FlowAttributeChangeEvent('providerRecord', this.provider));
    }


}