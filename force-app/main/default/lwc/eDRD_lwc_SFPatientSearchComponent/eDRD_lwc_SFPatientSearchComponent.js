import { LightningElement, track, api, wire } from 'lwc';
import { FlowNavigationBackEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import searchPatients from '@salesforce/apex/EDRDAccountLookupController.searchPatients';
import searchPatients_SOSL from '@salesforce/apex/EDRDAccountLookupController.searchPatients_SOSL';
import validatePatients from '@salesforce/apex/EDRDAccountLookupController.validatePatientIdentifier';
import EDRD_label_lwc_SFPSC_sN_Error from '@salesforce/label/c.EDRD_label_lwc_SFPSC_sN_Error';
import EDRD_label_lwc_SFPSC_sN_Success from '@salesforce/label/c.EDRD_label_lwc_SFPSC_sN_Success';
import EDRD_label_lwc_SFPSC_sN_deceased from '@salesforce/label/c.EDRD_label_lwc_SFPSC_sN_deceased';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import GENDER_FIELD from '@salesforce/schema/Account.PersonGender';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class eDRD_lwc_SFPatientSearchComponent extends LightningElement {
    // Input fields
    patientIdentifier = '';
    firstName = '';
    lastName = '';
    birthDate = '';
    gender = '';
    isDisabledSearchBy3Param = true;
    isDisabledSearchByPHN = true;

    @api patientFirstName;
    @api patientLastName;
    @api patientGender;
    @api patientIdentifier;
    @api patientSFId;
    @api patientBirthdate;
    @api patientDeceased;
    @api isCreatePatientManuallyChecked;
    @api availableActions = [];

    @track isPHNAvaiable = false;
    @track isNextDisable = true;
    @track patient_IdentifierManual;
    @track isDisableValidatePHN = true;
    @track patientIdentifierSearch;

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    accountObjectInfo;

    // Fetch picklist values
    @wire(getPicklistValues, { 
        recordTypeId: '012000000000000AAA', 
        fieldApiName: GENDER_FIELD 
    })
    genderOptions;

    // Results
    @track patients = [];
    showNoResultsMessage = false;

    // Create Patient Manually Checkbox
    isCreatePatientManuallyChecked = false;

    // Columns for datatable
    columns = [
        { label: 'First Name', fieldName: 'FirstName' },
        { label: 'Last Name', fieldName: 'LastName' },
        { label: 'Birthdate', fieldName: 'PersonBirthdate', type: 'date-local' },
        { label: 'Gender', fieldName: 'PersonGender' },
        { label: 'Deceased', fieldName: 'Patient_is_Deceased__pc', type: 'boolean' },
        { label: 'Patient Identifier', fieldName: 'Patient_Identifier__pc' }
    ];

    // Validate button visibility
    validatebuttonVisibility() {
        if (this.firstName && this.lastName && this.birthDate) {
            this.isDisabledSearchBy3Param = false;
        } else {
            this.isDisabledSearchBy3Param = true;
        }
    }

    // Handle input changes
    handlePatientIdentifierChange(event) {
        this.patientIdentifier = event.target.value;
        this.patientIdentifierSearch = event.target.value;

        this.isDisabledSearchByPHN = !this.patientIdentifier;
    }

    handleFirstNameChange(event) {
        this.firstName = event.target.value;
        this.validatebuttonVisibility();
    }

    handleLastNameChange(event) {
        this.lastName = event.target.value;
        this.validatebuttonVisibility();
    }

    handleDOBChange(event) {
        this.birthDate = event.target.value;
        this.validatebuttonVisibility();
    }

    // Handle "Create Patient Manually" checkbox change
    handleCreatePatientManuallyChange(event) {
        this.isCreatePatientManuallyChecked = event.target.checked;
        this.clearManualFields(); // Clear manual fields when toggling
    }

    // Clear manual fields when toggling the checkbox
    clearManualFields() {
        if (!this.isCreatePatientManuallyChecked) {
            this.firstName = '';
            this.lastName = '';
            this.birthDate = '';
            this.gender = '';
            this.patientIdentifier = '';
        }
    }

    // Search by Patient Identifier
    async handleSearchByIdentifier() {
        this.patients = [];
        this.showNoResultsMessage = false;

        try {
            const searchCriteria = {
                patientIdentifier: this.patientIdentifierSearch,
                firstName: null,
                lastName: null,
                birthDate: null
            };

            const results = await searchPatients({ searchCriteria });
            this.processSearchResults(results);
        } catch (error) {
            console.error('Error fetching patients:', error);
        }
    }

    // Search by First Name, Last Name, and Birthdate
    async handleSearchByNameAndBirthdate() {
        this.patients = [];
        this.showNoResultsMessage = false;

        try {
            const searchCriteria = {
                patientIdentifier: null,
                firstName: this.firstName,
                lastName: this.lastName,
                birthDate: this.birthDate
            };

            //const results = await searchPatients({ searchCriteria });
            const results = await searchPatients_SOSL({ searchCriteria });
            this.processSearchResults(results);
        } catch (error) {
            console.error('Error fetching patients:', error);
        }
    }

    // Create Patient Manually
    async handleValidatePatient() {
        if (!this.isCreatePatientManuallyChecked) return;

        try {
            const isPHNAvaiable = await validatePatients({ patientIdentifier: this.patient_IdentifierManual });
            this.isPHNAvaiable = isPHNAvaiable;
            this.isNextDisable = isPHNAvaiable;

            if (isPHNAvaiable) {
                this.showNotification(
                    'Error',
                    EDRD_label_lwc_SFPSC_sN_Error,
                    'error'
                );
            } else {
                this.showNotification(
                    'Success',
                    EDRD_label_lwc_SFPSC_sN_Success,
                    'success'
                );
            }
        } catch (error) {
            console.error('Error validating patient:', error);
        }
    }

    // Process search results
    processSearchResults(results) {
        if (results && results.length > 0) {
            this.patients = results;
            this.showNoResultsMessage = false;
        } else {
            this.patients = [];
            this.showNoResultsMessage = true;
        }
    }

    handleRowSelection(event) {
        const selectedRecord = event.detail.selectedRows;

        if (selectedRecord && selectedRecord.length > 0) {
            this.patientSFId = selectedRecord[0].Id;
            this.patientFirstName = selectedRecord[0].FirstName;
            this.patientLastName = selectedRecord[0].LastName;
            this.patientGender = selectedRecord[0].PersonGender;
            this.patientDeceased = selectedRecord[0].Patient_is_Deceased__pc;
            this.patientIdentifier = selectedRecord[0].Patient_Identifier__pc;
            this.isCreatePatientManuallyChecked = false;
            this.isNextDisable = false;
        } else {
            this.patientSFId = null;
            this.patientFirstName = null;
            this.patientLastName = null;
            this.patientGender = null;
            this.patientIdentifier = null;
            this.patientDeceased = false;
        }
        if(this.patientDeceased){
            this.isNextDisable = true;
            this.showNotification(
                    'Error',
                    EDRD_label_lwc_SFPSC_sN_deceased,
                    'error'
                );
        }
    }

    handleManualInputChange(event) {
        const field = event.target.dataset.id;

        if (field === 'manualFirstName') {
            this.patientFirstName = event.target.value;
        } else if (field === 'manualLastName') {
            this.patientLastName = event.target.value;
        } else if (field === 'manualGender') {
            this.patientGender = event.target.value;
        } else if (field === 'manualBirthDate') {
            this.patientBirthdate = event.target.value;
        } else if (field === 'manualPatientIdentifier') {
            this.patientIdentifier = event.target.value;
            this.patient_IdentifierManual = event.target.value;
            this.isNextDisable = true;

            this.isDisableValidatePHN = !this.patient_IdentifierManual;
            return;
        }

        this.isNextDisable = !(
            this.patientFirstName &&
            this.patientLastName &&
            this.patientBirthdate &&
            (!this.patient_IdentifierManual || !this.isPHNAvaiable)
        );
    }

    shouldDispatchAction(action) {
        return this.availableActions.includes(action);
    }

    dispatchFlowEvent(eventType) {
        const flowEvent = new eventType();
        this.dispatchEvent(flowEvent);
    }

    handleNext() {
        if (this.shouldDispatchAction('NEXT')) {
            this.dispatchFlowEvent(FlowNavigationNextEvent);
        }
    }

    handleBack() {
        if (this.shouldDispatchAction('BACK')) {
            this.dispatchFlowEvent(FlowNavigationBackEvent);
        }
    }

    showNotification(titleText, messageText, variantText) {
        const evt = new ShowToastEvent({
            title: titleText,
            message: messageText,
            variant: variantText,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    label = {
        EDRD_label_lwc_SFPSC_sN_deceased,
        EDRD_label_lwc_SFPSC_sN_Error,
        EDRD_label_lwc_SFPSC_sN_Success
    };

    connectedCallback() {
        this.isCreatePatientManuallyChecked = false; 
    }

    disconnectedCallback() {
        this.patientFirstName = '';
        this.patientLastName = '';
        this.patientGender = '';
        this.patientBirthdate = null;
        this.patientIdentifier = '';
        this.patient_IdentifierManual = '';
        this.isCreatePatientManuallyChecked = false;
    }
}