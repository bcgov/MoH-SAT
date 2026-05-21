import { LightningElement, api, wire } from 'lwc';
import validateDrugStep from '@salesforce/apex/RxHistoryPatientDrugValidator.validateDrugStep';

export default class SAT_lwc_RxHistoryPatientDrugValidator extends LightningElement {

    @api recordId;
    data = [];
    error;

    
    columns = [
        {
            label: 'Medication Group',
            fieldName: 'categoryName',
            type: 'text',
            wrapText: true
        },
        {
            label: 'Dispensed',
            fieldName: 'foundText',  
            type: 'text',
            cellAttributes: { alignment: 'center' }
        },
        {
            label: 'Qty',
            fieldName: 'totalQuantity',
            type: 'number',
            cellAttributes: { alignment: 'center' }
        },
        {
            label: 'Compliance',
            fieldName: 'thresholdText',
            type: 'text',
            cellAttributes: { alignment: 'center' }
        },
        {
            label: 'Days Supply',
            fieldName: 'totalDaysSupply',
            type: 'number',
            cellAttributes: { alignment: 'center' }
        }
    ];

    get hasData() {
        return this.data && this.data.length > 0;
    }

    @wire(validateDrugStep, { caseId: '$recordId' })
    wiredData({ error, data }) {
        if (data) {
            this.data = data.map((row, index) => ({
                ...row,
                din: row.din || index.toString(),

               
                foundText: row.found ? 'true' : 'false',
                thresholdText: row.threshold ? 'true' : 'false'
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data = [];
        }
    }
}