import { LightningElement, api } from 'lwc';
import TIMEZONE from '@salesforce/i18n/timeZone';


export default class RequestDetailValue extends LightningElement {
    @api record;
    timezone = TIMEZONE;

    get isString() {
        return this.record.String_Value__c != null;
    }

    get isDatetime() {
        return this.record.Datetime_Value__c != null;
    }

    get isDecimal() {
        return this.record.Decimal_Value__c != null;
    }

    get isDate() {
        return this.record.Date_Value__c != null;
    }

    get isBoolean() {
        return !this.isString && 
            !this.isDatetime && 
            !this.isDate &&
            !this.isDecimal && 
            this.record.Boolean_Value__c !== undefined;
    }
}