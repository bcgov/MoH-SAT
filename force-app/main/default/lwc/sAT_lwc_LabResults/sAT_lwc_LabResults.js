import { LightningElement, track, api } from 'lwc';
import getLabResults from '@salesforce/apex/SAT_LabResultsService.getLabResults';
import getCurrentUser from '@salesforce/apex/SAT_LabResultsService.getCurrentUser';

export default class SAT_lwc_LabResults extends LightningElement {
    @track selectedTestType = 'A1C';
    @track results = [];
    @track loading = false;
    @track error = null;
    @api recordId;
    @track currentUserLastName = '';

    get testTypeOptions() {
        return [
            { label: 'A1C', value: 'A1C' },
            { label: 'CALPROTECTIN', value: 'CALPROTECTIN' },
            { label: 'Hep B', value: 'HEP-B' },
            { label: 'eGFR', value: 'EGFR' }
        ];
    }

    connectedCallback() {
        console.log('Connected callback Record ID:', this.recordId);
        this.loadCurrentUser();
    }

    async loadCurrentUser() {
        try {
            const userLastName = await getCurrentUser();
            this.currentUserLastName = userLastName;
            console.log('Current User Last Name:', this.currentUserLastName);
            
            if (this.recordId) {
                this.fetchResults();
            }
        } catch (e) {
            console.error('Error loading current user:', e);
            this.error = 'Failed to load user information.';
        }
    }

    get hasResults() {
        return Array.isArray(this.results) && this.results.length > 0;
    }

    get noResults() {
        return !this.loading && !this.error && (!this.filteredResults || this.filteredResults.length === 0);
    }

    get errorMessage() {
        if (!this.error) return '';
        if (typeof this.error === 'string') return this.error;
        if (this.error && this.error.body && this.error.body.message) return this.error.body.message;
        return 'An unexpected error occurred while loading lab results.';
    }

    get filteredResults() {
        return this.results;
    }

    async fetchResults() {
        this.loading = true;
        this.error = null;
        this.results = [];

        try {
            if (!this.recordId) {
                throw new Error('Record ID is missing.');
            }

            if (!this.currentUserLastName) {
                throw new Error('User information is not loaded.');
            }

            console.log('Fetching data from Apex...');

            // Get today's date in ISO format
            const today = new Date();
            const asOfDate = today.toISOString().split('T')[0] + 'T00:00:00';

            const params = {
                caseId: this.recordId,
                testType: this.selectedTestType,
                asOfDate: '2008-01-01T00:00:00',//asOfDate,
                requester: this.currentUserLastName
            };

            console.log('Sending params:', JSON.stringify(params));

            const data = await getLabResults(params);
            console.log('Received data:', data);

            if (data && Array.isArray(data) && data.length > 0) {
                this.results = data.map((r, idx) => ({
                    test: r.test,
                    resultDate: r.observationDateTime,
                    resultValue: r.value,
                    units: r.unit,
                    referenceRange: r.referenceRangeTxt,
                    abnormalFlag: r.abnormalFlagCd,
                    coding: r.coding,
                    rowKey: r.test + '-' + idx
                }));
                console.log('Mapped results:', JSON.stringify(this.results));
            } else {
                this.results = [];
                console.log('No results returned from Apex');
            }

        } catch (e) {
            console.error('Error fetching data:', e);
            this.error = e.message || 'Failed to load lab results.';
            this.results = [];
        } finally {
            this.loading = false;
        }
    }

    handleTestTypeChange(event) {
        this.selectedTestType = event.detail.value;
    }

    handleSearch() {
        this.fetchResults();
    }
}