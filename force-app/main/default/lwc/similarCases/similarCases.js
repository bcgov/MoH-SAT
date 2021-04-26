import { LightningElement, wire, api } from 'lwc';
import findCases from '@salesforce/apex/SimilarCases.find';
export default class SimilarCases extends LightningElement {
    @api recordId;
    
    @wire(findCases, { caseId : '$recordId' })
    cases;

    get hasCases() {
        return this.cases;
    }
}