import { LightningElement, wire, track } from 'lwc';
import getAccounts from '@salesforce/apex/EDRD_myPatientsController.getPatientList';
import { NavigationMixin } from 'lightning/navigation';
const columns = [
    {        
            label: 'Patient Name',
            fieldName: 'Name',
            type: 'button',
            sortable: true,
            typeAttributes:{
                 label: { fieldName: 'Name' },
                 disabled: false,
                 variant: 'base',
                 value: 'Name'
                }            
    }, {
        label: 'Patient Identifier',
        fieldName: 'Patient_Identifier__c',
        type: 'text'
    },
    {
        label: 'Birthdate',
        fieldName: 'Birthdate',
        type: 'Date'
    }
];
export default class edrdMyPatients extends NavigationMixin(LightningElement) {
    data = [];
    columns = columns;
    @track searchString;
    @track initialRecords;
    @wire(getAccounts)
    wiredAccounts({
        error,
        data
    }) {
        if (data) {
            this.data = JSON.parse(JSON.stringify(data));
            this.initialRecords = this.data;
        } else if (error) {
            this.error = 'error';
        }
    }
    handleRowAction(event) {
        if(event.detail.row.Id){
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                recordId: event.detail.row.Id,
                objectApiName: 'Contact',
                actionName: 'view'
                }
            });
        }
     }
     handleSearch(event) {
        const searchKey = event.target.value.toLowerCase(); 
        if (searchKey) {
            this.data = this.initialRecords;
            if (this.data) {
                let searchRecords = []; 
                for (let record of this.data) {
                    let valuesArray = Object.values(record); 
                    for (let val of valuesArray) {
                        let strVal = String(val); 
                        if (strVal) { 
                            if (strVal.toLowerCase().includes(searchKey)) {
                                searchRecords.push(record);
                                break;
                            }
                        }
                    }
                } 
                this.data = searchRecords;
            }
        } else {
            this.data = this.initialRecords;
        }
     }
}