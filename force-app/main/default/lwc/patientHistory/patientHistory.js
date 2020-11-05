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

  @wire(fetchData, { page: '0', count: '100'}) mapObjectToData({error,data}) {
    console.log("error:", error);
    console.log("data:", data);

    if (data) {
      // console.log("medHistory:", data.medHistory);
      // console.log("medRecords:", data.medHistory.medRecords);
      const records = data.medHistory.medRecords;
      if (records.length) {
        let dataArray = [];
        records.forEach(record => {
          let item = {};
          item['rxNumber'] = record.rxNumber;
          item['rxStatus'] = record.rxStatus;
          item['genericName'] = record.genericName;
          item['dispensingPharmacyName'] = record.dispensingPharmacy.name;
          item['dateDispensed'] = record.dateDispensed;
          item['dinpin'] = record.dinpin;
          item['quantity'] = record.quantity;
          item['refills'] = record.refills;
          dataArray.push(item);
        });
        this.data = dataArray;
        this.loaded = true;
      }
    }
  };
}