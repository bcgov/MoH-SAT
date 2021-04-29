import { LightningElement, wire, api } from 'lwc';
import queryCases from '@salesforce/apex/PatientRelatedCases.query';

export default class PatientRelatedCases extends LightningElement {
    @api recordId;
    @api hideRequestDetails;
    
    @wire(queryCases, { caseId : '$recordId' })
    cases;

    get hasCases() {
        return this.cases;
    }
}