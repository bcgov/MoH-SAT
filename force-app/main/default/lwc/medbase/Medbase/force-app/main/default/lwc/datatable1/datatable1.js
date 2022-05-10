import { LightningElement ,api, wire, track} from 'lwc';
import getDrugList from '@salesforce/apex/DrugHelper.getDrugList';
export default class datatable1 extends LightningElement {
    @track columns = [{
            label: 'Drug name',
            fieldName: 'Name',
            type: 'text',
            sortable: true
        },
        {
            label: 'Brand name',
            fieldName: '',
            type: 'text',
            sortable: true
        },
        {
            label: 'RDP code',
            fieldName: 'PharmaNet_RDP_code__c',
            type: 'text',
            sortable: true
        },
        {
            label: 'Strength',
            fieldName: 'Strength__c',
            type: 'text',
            sortable: true
        },
        {
            label: 'Criteria Website',
            fieldName: 'Criteria_Website__c',
            type: 'url',
            sortable: true
        },
        {
            label: 'Tech Sheet',
            fieldName: 'Tech_Sheet__c',
            type: 'turl',
            sortable: true
        }
    ];
 
    @track error;
    @track drugList ;
    @wire(getDrugList)
    wiredDrugs({
        error,
        data
    }) {
        if (data) {
            this.drugList = data;
        } else if (error) {
            this.error = error;
        }
    }
}