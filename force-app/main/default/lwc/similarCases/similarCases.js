import { LightningElement, wire, api } from 'lwc';
import findCases from '@salesforce/apex/SimilarCases.find';

export default class SimilarCases extends LightningElement {
    @api recordId;
    cases;
    
    @wire(findCases, { caseId : '$recordId' })
    loadCases({error, data}) {
        console.log("recordId " + this.recordId);
        console.log("cases: " + data);
        if (data) {
            this.cases = data;
            console.log("this.cases" + this.cases);
        }
    }

}