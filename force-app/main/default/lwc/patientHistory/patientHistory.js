import { LightningElement, wire } from 'lwc';
import fetchData from '@salesforce/apex/ODRIntegration.fetchData';

const columns = [
  { label: 'RX Number', fieldName: 'rxNumber', initialWidth: 120 },
  { label: 'RX Status', fieldName: 'rxStatus', initialWidth: 110 },
  { label: 'Name', fieldName: 'genericName', type: 'text', wrapText: true },
  { label: 'Quantity', fieldName: 'quantity', initialWidth: 80 },
  { label: 'Refills', fieldName: 'refills', initialWidth: 80 },
  { label: 'Date Dispensed', fieldName: 'dateDispensed', type: 'date-local', typeAttributes:{ month: "2-digit", day: "2-digit" }, initialWidth: 140 },
  { label: 'Dispenser', fieldName: 'dispensingPharmacyName', type: 'text', wrapText: true },
  { label: 'DIN', fieldName: 'dinpin' },
];

export default class PatientHistory extends LightningElement {
  columns = columns;
  data = [];
  loaded = false;

  @wire(fetchData, { page: '0', count: '100'}) mapObjectToData(payload) {
    if (payload.data) {
      let dataArray = [];
      const dataObj = JSON.parse(payload.data);
      dataObj.forEach(element => {
        let item = {};
        item['rxNumber'] = element.rxNumber;
        item['rxStatus'] = element.rxStatus;
        item['genericName'] = element.genericName;
        item['dispensingPharmacyName'] = element.dispensingPharmacy.name;
        item['dateDispensed'] = element.dateDispensed;
        item['dinpin'] = element.dinpin;
        item['quantity'] = element.quantity;
        item['refills'] = element.refills;
        dataArray.push(item);
      });
      this.data = dataArray;
      this.loaded = true;
    }
  };
}