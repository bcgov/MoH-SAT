import { LightningElement, api, track, wire } from 'lwc';
import { FlowNavigationBackEvent, FlowNavigationNextEvent } from "lightning/flowSupport";
import getAccount from '@salesforce/apex/EDRDAccountLookupController.getAccount';
import FLD_PATIENT_OVERRIDE_REASON from '@salesforce/schema/Case.EDRD_Patient_Override_Reason__c';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import OBJ_CASE from '@salesforce/schema/Case';

export default class CustomObjectForm extends LightningElement {
    @api accountPHN = '';
    @api patientPHN;
    @api accountName;
    @api messageResult = false;
    @api showsearchedvalues = false;
    @api showRemoveButton = false;
    @api accountList = [];
    @api Birthdate;
    @api PHNDOB;
    @api PatientDOB;
    @api Name;
    @api FirstName;
    @api LastName;
    @api PatientFullNameDisplay;
    @api AccountId;
    @api street;
    @api city;
    @api Country;
    @api state;
    @api Zipcode;
    @api PostalCode;
    @api verified;
    @api overRideReason;
    @api Gender;
    @api Deceased;
    @api availableActions = [];

    @track isPHNFound;
    @track isShowNoPHNFound = false;
    @track pHNDetails = {};
    @track sFPHNDetails;
    @track isNextDisable = true;
    @track isReasonValidated = false;
    @track pHNForSearch;

    form = {
        overrideReason: 'None'
    };

    @wire(getObjectInfo, { objectApiName: OBJ_CASE })
    caseObjInfo;

    @wire(getPicklistValues, { fieldApiName: FLD_PATIENT_OVERRIDE_REASON, recordTypeId: '012000000000000AAA' })
    patientOverrideReasonFldInfo;

    get ready() {
        return (
            this.caseObjInfo &&
            this.caseObjInfo.data &&
            this.patientOverrideReasonFldInfo &&
            this.patientOverrideReasonFldInfo.data
        );
    }

    get patientOverrideReasonOptions() {
        return this.patientOverrideReasonFldInfo?.data?.values || [];
    }

    get patientOverrideReasonLabel() {
        return this.caseObjInfo?.data?.fields?.EDRD_Patient_Override_Reason__c?.label || 'Unknown';
    }

    handleFormChange(event) {
        const field = event.currentTarget.dataset.field;
        let value = event.target.value;
        this.isNextDisable = true;

        if (field && value != 'None') {
            this.form[field] = event.target.value?.trim();
            this.overRideReason = event.target.value;
            this.isNextDisable = false;
            this.isShowNoPHNFound = false;
            this.isReasonValidated = true;
        } else if (!this.accountPHN) {
            this.isShowNoPHNFound = false;
        } else if (value == 'None') {
            this.overRideReason = event.target.value;
        }
    }

    handlekeychange(event) {
        this.pHNForSearch = event.currentTarget.value || '';
    }

    handleSearch() {
        this.isNextDisable = true;
        this.showRemoveButton = true;

        if (!this.pHNForSearch) {
            this.isShowNoPHNFound = true;
            this.accountList = undefined;
            return;
        }

        getAccount({ actPHN: this.pHNForSearch })
            .then((result) => {
                try {
                    const keyVsValue = JSON.parse(result);
                    this.isPHNFound = keyVsValue["ISPHNFOUND"] === 'YES';
                    this.pHNDetails = JSON.parse(keyVsValue["PHNDETAILS"]);
                    this.isShowNoPHNFound = false;

                    if (!this.isPHNFound) {
                        this.isShowNoPHNFound = true;
                    } else {
                        let FirstName = "";
                        let LastName = "";
                        this.pHNDetails.names.forEach(element => {
                            this.accountPHN = this.pHNForSearch;
                            if (element.type === 'L') {
                                LastName = element.familyName;

                                // Extract given names
                                element.givenNames.forEach(given => {
                                    FirstName += given + ", ";
                                });
                            }
                        });

                        this.PatientFullNameDisplay = (FirstName + LastName).replace(/,/g, '');
                        this.FirstName = FirstName.replace(/,/g, '');
                        this.LastName = LastName;
                        this.Name = this.PatientFullNameDisplay;
                        this.Gender = this.pHNDetails.gender == 'M' ? 'Male' : this.pHNDetails.gender == 'F' ? 'Female' : 'Other' ;
                        this.Deceased = this.pHNDetails.deceased == true ? 'Yes' : 'No';
                        this.Birthdate = this.pHNDetails.dob;
                        this.PatientDOB = this.pHNDetails.dob;
                        this.patientPHN = this.pHNDetails.phn;
                        this.verified = true;
                        this.isNextDisable = false;
                        this.isShowNoPHNFound = !this.Name;
                    }
                } catch (error) {
                    console.error('Error parsing result:', error);
                     this.isShowNoPHNFound = true;
                }
            })
            .catch((error) => {
                console.error('Error fetching account:', error);
                this.accountList = undefined;
                this.isShowNoPHNFound = true;
                this.errorMsg =
                    Array.isArray(error.body)
                        ? error.body.map((err) => err.message).join(', ')
                        : error.body?.message || 'Unknown error';
            });
    }

    handleRemoveResults() {
        this.accountList = [];
        this.Birthdate = '';
        this.Name = '';
        this.AccountId = '';
        this.Deceased = '';
        this.PatientDOB = null;
        this.Gender = '';
        this.accountPHN = '';
        this.patientPHN = '';
        this.isNextDisable = true;
        this.isShowNoPHNFound = false;
        this.showRemoveButton = false;
    }

    handleNext() {
        if (this.shouldShowErrorMessage()) {
            this.handleNoSearchResult();
        } else if (this.shouldDispatchAction('NEXT')) {
            this.dispatchFlowEvent(FlowNavigationNextEvent);
        }
    }

    handleBack() {
        if (this.shouldDispatchAction('BACK')) {
            this.dispatchFlowEvent(FlowNavigationBackEvent);
        }
    }

    shouldShowErrorMessage() {
        return (!this.accountPHN || !this.isPHNFound) && !this.isReasonValidated;
    }

    handleNoSearchResult() {
        this.isShowNoPHNFound = true;
    }

    shouldDispatchAction(action) {
        return this.availableActions.includes(action);
    }

    dispatchFlowEvent(eventType) {
        const flowEvent = new eventType();
        this.dispatchEvent(flowEvent);
    }

    connectedCallback() {
        this.pHNForSearch = this.accountPHN;  
        this.overRideReason = 'None';  
    }

    disconnectedCallback() {
        this.PatientFullNameDisplay = '';
        this.FirstName = '';
        this.LastName = '';
        this.Name = '';
        this.Gender = '';
        this.Deceased = '';
        this.Birthdate = '';
        this.PatientDOB = null;
        this.patientPHN = '';
        this.verified = '';
        this.isNextDisable = '';
        this.isShowNoPHNFound = '';  
        this.overRideReason = 'None';  
    }
}