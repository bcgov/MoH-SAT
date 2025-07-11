import { LightningElement, track } from 'lwc';
import getSessions from '@salesforce/apex/EDRD_cls_OmniSavedSessionController.getSessions';
import getSessionCount from '@salesforce/apex/EDRD_cls_OmniSavedSessionController.getSessionCount';
import launchSession from '@salesforce/apex/EDRD_cls_OmniSavedSessionController.launchSession';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EDRD_lwc_omniScriptSessionViewer extends LightningElement {
    @track sessions = [];
    @track totalRecords;
    @track viewMode = 'MyDrafts'; // Default to My Drafts
    pageSize = 20;
    pageNumber = 1;
    totalPages;
    sortBy = 'CreatedDate';
    sortDirection = 'desc';
    sortedBy = 'CreatedDate';
    sortedDirection = 'desc';

    viewOptions = [
        { label: 'My Drafts', value: 'MyDrafts' },
        { label: 'My Team Drafts', value: 'MyTeamDrafts' }
    ];

    columns = [
        { label: 'Sl No.', fieldName: 'slno', sortable: true },
        { label: 'Draft Name', fieldName: 'Draft_Name__c', type: 'text', sortable: true },
        { label: 'Status Category', fieldName: 'StatusCategory', type: 'text', sortable: true },
        {
            label: 'Created Date',
            fieldName: 'CreatedDate',
            type: 'date',
            typeAttributes: {
                day: '2-digit', month: 'short', year: 'numeric',
                hour: '2-digit', minute: '2-digit', hour12: true
            },
            sortable: true
        },
        { label: 'Created By', fieldName: 'CreatedByName', type: 'text', sortable: true },
        { label: 'Owner', fieldName: 'OwnerName', type: 'text', sortable: true },
        {
            label: 'Last Modified Date',
            fieldName: 'LastModifiedDate',
            type: 'date',
            typeAttributes: {
                day: '2-digit', month: 'short', year: 'numeric',
                hour: '2-digit', minute: '2-digit', hour12: true
            },
            sortable: true
        },
        { label: 'Last Modified By', fieldName: 'LastModifiedByName', type: 'text', sortable: true },
        {
            label: 'Resume',
            fieldName: 'action',
            type: 'button',
            typeAttributes: {
                label: 'Launch',
                name: 'launch',
                title: 'Launch',
                variant: 'brand'
            }
        }
    ];

    connectedCallback() {
        this.loadSessions();
    }

    loadSessions() {
        getSessionCount({ viewMode: this.viewMode })
            .then(count => {
                this.totalRecords = count;
                this.totalPages = Math.ceil(count / this.pageSize);
            });

        getSessions({
            pageSize: this.pageSize,
            pageNumber: this.pageNumber,
            sortBy: this.sortBy,
            sortDirection: this.sortDirection,
            viewMode: this.viewMode
        })
            .then(data => {
                this.sessions = data.map((row, index) => ({
                    ...row,
                    slno: (this.pageNumber - 1) * this.pageSize + index + 1,
                    CreatedByName: row.CreatedBy?.Name,
                    OwnerName: row.Owner?.FirstName + ' ' + row.Owner?.LastName,
                    LastModifiedByName: row.LastModifiedBy?.Name
                }));
            })
            .catch(error => {
                this.sessions = [];
                this.showToast('Error', 'Error loading sessions', 'error');
                console.error(error);
            });
    }

    handleSort(event) {
    const fieldName = event.detail.fieldName;
    const sortDirection = event.detail.sortDirection;
    this.sortedBy = fieldName;
    this.sortedDirection = sortDirection;

    let sortedData = [...this.sessions];
    sortedData.sort((a, b) => {
        let aValue = a[fieldName] || '';
        let bValue = b[fieldName] || '';

        if (aValue < bValue) return sortDirection === 'asc' ? -1 : 1;
        if (aValue > bValue) return sortDirection === 'asc' ? 1 : -1;
        return 0;
    });

    this.sessions = sortedData;
}

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'launch') {
            this.handleLaunch(row.Id);
        }
    }

    handleLaunch(recordId) {
        launchSession({ recordId })
            .then(resumeUrl => {
                if (resumeUrl) {
                    window.open(resumeUrl, '_blank');
                } else {
                    this.showToast('Error', 'Resume URL not found.', 'error');
                }
            })
            .catch(error => {
                this.showToast('Error', 'Unable to launch session.', 'error');
                console.error(error);
            });
    }

    handlePrevious() {
        if (this.pageNumber > 1) {
            this.pageNumber--;
            this.loadSessions();
        }
    }

    handleNext() {
        if (this.pageNumber < this.totalPages) {
            this.pageNumber++;
            this.loadSessions();
        }
    }

    handleViewChange(event) {
        this.viewMode = event.detail.value;
        this.pageNumber = 1;
        this.loadSessions();
    }

    get disablePrevious() {
        return this.pageNumber <= 1;
    }

    get disableNext() {
        return this.pageNumber >= this.totalPages;
    }

    get pageIndicator() {
        return `Page ${this.pageNumber} of ${this.totalPages}`;
    }

    get dataToDisplay() {
        return this.sessions;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}