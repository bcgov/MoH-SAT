import { LightningElement, track, api, wire } from 'lwc';
import { FlowNavigationBackEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import searchPatients from '@salesforce/apex/EDRDAccountLookupController.searchPatients';
import validatePatients from '@salesforce/apex/EDRDAccountLookupController.validatePatientIdentifier';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import GENDER_FIELD from '@salesforce/schema/Account.PersonGender';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EDRD_lwc_SFPatientSearchComponent extends LightningElement {
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
        { label: 'Birthdate', fieldName: 'PersonBirthdate', type: 'date' },
        { label: 'Gender', fieldName: 'PersonGender' },
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

            const results = await searchPatients({ searchCriteria });
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
            this.isNextDisable = !isPHNAvaiable;

            if (isPHNAvaiable) {
                this.showNotification(
                    'Error',
                    'This PHN is already present in the Pharma Org. Please search using the patient identifier and then select the appropriate patient.',
                    'error'
                );
            } else {
                this.showNotification(
                    'Success',
                    'This PHN can be used to create a new patient.',
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
            this.patientIdentifier = selectedRecord[0].Patient_Identifier__pc;
            this.isCreatePatientManuallyChecked = false;
            this.isNextDisable = false;
        } else {
            this.patientSFId = null;
            this.patientFirstName = null;
            this.patientLastName = null;
            this.patientGender = null;
            this.patientIdentifier = null;
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

            this.isDisableValidatePHN = !this.patient_IdentifierManual;
        }

        this.isNextDisable = !(
            this.patientFirstName &&
            this.patientLastName &&
            this.patientGender &&
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
}