import { LightningElement, api, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import TIMEZONE from '@salesforce/i18n/timeZone';
import OBJ_REQUEST_DETAIL from '@salesforce/schema/Request_Detail__c';
import postToCaseFeed from '@salesforce/apex/RequestDetails.postToCaseFeed'
export default class RequestDetailValue extends LightningElement {
    timezone = TIMEZONE;
    
    @wire(getObjectInfo, { objectApiName: OBJ_REQUEST_DETAIL })
    rdObjInfo;

    recordId;
    type;
    value;
    valueLabel;
    
    mode = 'view';

    @api
    set record(value) {
        this.recordId = value.Id;

        if (value.String_Value__c != null) {
            this.type = 'string';
            this.value = value.String_Value__c;
        } else if (value.Datetime_Value__c != null) {
            this.type = 'datetime';
            this.value = value.Datetime_Value__c;
        } else if (value.Date_Value__c != null) {
            this.type = 'date';
            this.value = value.Date_Value__c;
        } else if (value.Decimal_Value__c != null) {
            this.type = 'decimal';
            this.value = value.Decimal_Value__c;
        } else {
            this.type = 'boolean';
            this.value = value.Boolean_Value__c;
        }

        this.valueLabel = value.Question__c == value.String_Value_Label__c ? null : value.String_Value_Label__c;

        this._record = value;
    }

    get record() {
        return this._record;
    }

    get isString() {
        return this.type == 'string';
    }

    get isDatetime() {
        return this.type == 'datetime';
    }

    get isDecimal() {
        return this.type == 'decimal';
    }

    get isDate() {
        return this.type == 'date';
    }

    get isBoolean() {
        return this.type == 'boolean'
    }

    get editable() {
        return this.rdObjInfo?.data?.updateable;
    }

    get isViewing() {
        return this.mode == 'view';
    }

    get isEditing() {
        return this.editable && this.mode == 'edit';
    }

    get showEdit() {
        return this.editable && this.mode == 'view'
    }

    editHandler() {
        if (!this.editable || this.mode == 'edit') return;

        this.mode = 'edit';
    }

    submitHandler(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    successHandler(event) {
        const newrecord = {
            Id: event.detail.id,
            String_Value__c: event.detail.fields.String_Value__c.value,
            Date_Value__c: event.detail.fields.Date_Value__c.value,
            Datetime_Value__c: event.detail.fields.Datetime_Value__c.value,
            Decimal_Value__c: event.detail.fields.Decimal_Value__c.value,
            Boolean_Value__c: event.detail.fields.Boolean_Value__c.value
        };

        postToCaseFeed({ oldRecord: this._record, newRecord: newrecord })

        this.record = newrecord;

        this.mode = 'view';
    }

    cancelHandler(event) {
        this.mode = 'view';
    }
}