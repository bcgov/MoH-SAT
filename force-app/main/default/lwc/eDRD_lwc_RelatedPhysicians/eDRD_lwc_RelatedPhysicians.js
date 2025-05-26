import { LightningElement, wire, track } from 'lwc';
import getRelatedPhysiciansList from '@salesforce/apex/EDRD_myPatientsController.getRelatedPhysiciansList';

const PAGE_SIZE = 15;

const columns = [
    { label: 'Serial Number', fieldName: 'serialNumber', type: 'number', initialWidth: 100, sortable: true },
    { label: 'Name', fieldName: 'Name', type: 'text', sortable: true },
    { label: 'Provider Type', fieldName: 'ProviderType', type: 'text', sortable: true },
    { label: 'Provider Identifier', fieldName: 'ProviderIdentifier', type: 'text', sortable: true },
    { label: 'Role', fieldName: 'Role', type: 'text', sortable: true }
];

export default class EdrdLwcRelatedPhysicians extends LightningElement {
    @track data = [];
    @track dataToDisplay = [];
    @track initialRecords = [];
    @track currentPage = 1;
    @track totalPages = 0;
    @track error;
    @track sortedBy;
    @track sortedDirection = 'asc';

    columns = columns;

    @wire(getRelatedPhysiciansList)
    wiredData({ error, data }) {
        if (data) {
            this.data = JSON.parse(JSON.stringify(data));
            this.initialRecords = [...this.data];
            this.totalPages = Math.ceil(this.data.length / PAGE_SIZE);
            this.updateDataToBeDisplay();
        } else if (error) {
            this.error = error;
        }
    }

    updateDataToBeDisplay() {
        const startId = (this.currentPage - 1) * PAGE_SIZE;
        const endId = startId + PAGE_SIZE;
        this.dataToDisplay = this.data.slice(startId, endId).map((record, index) => ({
            ...record,
            serialNumber: startId + index + 1
        }));
    }

    handleSearch(event) {
        const searchKey = event.target.value.toLowerCase();
        this.data = searchKey ? this.initialRecords.filter(record =>
            Object.values(record).some(val =>
                String(val).toLowerCase().includes(searchKey)
            )
        ) : [...this.initialRecords];

        this.totalPages = Math.ceil(this.data.length / PAGE_SIZE);
        this.currentPage = 1;
        this.updateDataToBeDisplay();
    }

    handleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        this.sortedBy = sortedBy;
        this.sortedDirection = sortDirection;

        this.data = [...this.data].sort((a, b) => {
            const aVal = a[sortedBy]?.toString().toLowerCase() || '';
            const bVal = b[sortedBy]?.toString().toLowerCase() || '';
            return sortDirection === 'asc' ? aVal.localeCompare(bVal) : bVal.localeCompare(aVal);
        });

        this.updateDataToBeDisplay();
    }

    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.updateDataToBeDisplay();
        }
    }

    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.updateDataToBeDisplay();
        }
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