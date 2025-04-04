import { LightningElement, wire, track } from 'lwc';
import getAccounts from '@salesforce/apex/EDRD_myPatientsController.getPatientList';
import { NavigationMixin } from 'lightning/navigation';

const PAGE_SIZE = 25;

const columns = [
    {
        label: 'Serial Number',
        fieldName: 'serialNumber',
        type: 'number',
        initialWidth: 100,
        sortable: true
    },
    {
        label: 'EDRD Reference Number',
        fieldName: 'EDRD_Ref_No__c',
        type: 'text',
        sortable: true
    },
    {
        label: 'Patient Name',
        fieldName: 'Name',
        type: 'button',
        sortable: true,
        typeAttributes: {
            label: { fieldName: 'Name' },
            disabled: false,
            variant: 'base',
            value: 'Name'
        }
    },
    {
        label: 'Patient Identifier',
        fieldName: 'Patient_Identifier__c',
        type: 'text',
        sortable: true
    },
    {
        label: 'Birthdate',
        fieldName: 'Birthdate',
        type: 'date',
        sortable: true
    }
];

export default class EdMyPatients extends NavigationMixin(LightningElement) {
    @track data = [];
    @track dataToDisplay = [];
    @track currentPage = 1;
    @track totalPages = 0;
    @track initialRecords = [];
    @track error;
    @track sortedBy;
    @track sortedDirection = 'asc';

    columns = columns;

    @wire(getAccounts)
    wiredAccounts({ error, data }) {
        if (data) {
            this.data = JSON.parse(JSON.stringify(data));
            this.initialRecords = [...this.data];
            this.totalPages = Math.ceil(this.data.length / PAGE_SIZE);
            this.updateDataToDisplay();
        } else if (error) {
            this.error = error;
        }
    }

    updateDataToDisplay() {
        const startIdx = (this.currentPage - 1) * PAGE_SIZE;
        const endIdx = startIdx + PAGE_SIZE;

        this.dataToDisplay = this.data.slice(startIdx, endIdx).map((record, index) => ({
            ...record,
            serialNumber: startIdx + index + 1
        }));
    }

    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
            this.updateDataToDisplay();
        }
    }

    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.updateDataToDisplay();
        }
    }

    handleRowAction(event) {
        if (event.detail.row.Id) {
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
            this.data = this.initialRecords.filter(record => {
                return Object.values(record).some(val =>
                    String(val).toLowerCase().includes(searchKey)
                );
            });
            this.totalPages = Math.ceil(this.data.length / PAGE_SIZE);
            this.currentPage = 1;
            this.updateDataToDisplay();
        } else {
            this.data = [...this.initialRecords];
            this.totalPages = Math.ceil(this.data.length / PAGE_SIZE);
            this.currentPage = 1;
            this.updateDataToDisplay();
        }
    }

    handleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        this.sortedBy = sortedBy;
        this.sortedDirection = sortDirection;

        this.data = [...this.data].sort((a, b) => {
            const aValue = a[sortedBy] ? a[sortedBy].toString().toLowerCase() : '';
            const bValue = b[sortedBy] ? b[sortedBy].toString().toLowerCase() : '';

            return sortDirection === 'asc'
                ? aValue.localeCompare(bValue)
                : bValue.localeCompare(aValue);
        });

        this.updateDataToDisplay();
    }

    get disablePrevious() {
        return this.currentPage === 1;
    }

    get disableNext() {
        return this.currentPage === this.totalPages;
    }

    get pageIndicator() {
        return `Page ${this.currentPage} of ${this.totalPages}`;
    }
}