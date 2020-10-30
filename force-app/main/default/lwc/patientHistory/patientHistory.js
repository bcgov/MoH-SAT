import { LightningElement, wire } from 'lwc';
import fetchData from '@salesforce/apex/ODRIntegration.fetchData';

const columns = [
  { label: 'RX Number', fieldName: 'rxNumber', initialWidth: 120 },
  { label: 'RX Status', fieldName: 'rxStatus', initialWidth: 110 },
  { label: 'Name', fieldName: 'genericName' },
  { label: 'Date Dispensed', fieldName: 'dateDispensed', type: 'date', initialWidth: 140 }
];

export default class PatientHistory extends LightningElement {
  columns = columns;
  data = [];

  @wire(fetchData, { page: '0', count: '100'}) mapObjectToData(payload) {
    if (payload.data) {
      this.data = JSON.parse(payload.data)
    }
  };
}