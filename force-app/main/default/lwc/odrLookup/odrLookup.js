import { LightningElement, wire } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import FLD_PROVIDER_TYPE from '@salesforce/schema/Contact.Provider_Type__c';
import OBJ_CONTACT from '@salesforce/schema/Contact';
export default class OdrLookup extends LightningElement {
    
    @wire(getObjectInfo, { objectApiName: OBJ_CONTACT })
    contactObjInfo;

    @wire(getPicklistValues, { fieldApiName: FLD_PROVIDER_TYPE, recordTypeId: '012000000000000AAA' })
    providerTypeInfo;

    get providerTypeOptions() {
        return this.providerTypeInfo.data.values;
    }



}