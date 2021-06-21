import { LightningElement, wire } from 'lwc';
import { getListUi } from 'lightning/uiListApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex'
import loadFaxableCases from '@salesforce/apex/AutofaxController.loadFaxableCases';

import USER_ID from '@salesforce/user/Id';
import OBJ_CASE from '@salesforce/schema/Case';
import FLD_ID from '@salesforce/schema/Case.Id';
import FLD_CLOSEDDATE from '@salesforce/schema/Case.ClosedDate';
import FLD_FAXED_BY from '@salesforce/schema/Case.Faxed_by__c';
import FLD_FAX_DATE from '@salesforce/schema/Case.Fax_Notification_Date__c';

export default class AutofaxList extends LightningElement {
    records;
    error;
    templates;

    @wire(getListUi, { 
        objectApiName: OBJ_CASE, 
        listViewApiName: 'To_Be_Faxed_Queue',
        sortBy: FLD_CLOSEDDATE,
        pageSize: 2000,
        fields: [FLD_ID]
    })
    async loadListView(value) {
        this.listView = value;
        const { error, data } = value;
        if (data) {
            this.records = await loadFaxableCases({
                ids : data.records.records.map(r=>r.id) 
            });
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.records = undefined;
        }
    }

    pdfHandler(event) {
        let caseId = event.currentTarget.dataset.caseId;
        let templateId = event.currentTarget.dataset.templateId;
        
        this.template.querySelector('iframe').src = `/apex/PDFGenerator?id=${caseId}&templateId=${templateId}`;
    }

    async markFaxedHandler(event) {
        const fields = {};
        fields[FLD_ID.fieldApiName] = event.currentTarget.dataset.caseId;
        fields[FLD_FAXED_BY.fieldApiName] = USER_ID;
        fields[FLD_FAX_DATE.fieldApiName] = new Date().toISOString();
        await updateRecord( {fields} );
        await refreshApex(this.listView);
    }
}