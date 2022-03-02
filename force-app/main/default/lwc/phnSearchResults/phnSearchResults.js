import { LightningElement, api } from 'lwc';
import lookup from '@salesforce/apex/PHNCaseLookup.lookup';

const columns = [
  {
    label: 'Case Number', fieldName: 'link', initialWidth: 120, wrapText: true, type: 'url',
    typeAttributes: { label: { fieldName: 'caseNumber' } }, hideDefaultActions: true
  },
  { label: 'Drug', fieldName: 'Drug__c', type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Status', fieldName: 'status', type: 'text', wrapText: true, hideDefaultActions: true },
  {
    label: 'Date/Time Opened', fieldName: 'createdDate', type: 'date', typeAttributes: {
      year: "numeric",
      month: "long",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit"
    }, hideDefaultActions: true
  },
  { label: 'Case Owner Alias', fieldName: 'owner', type: 'text', wrapText: true, hideDefaultActions: true }
];

export default class  extends LightningElement {
  @api phn;
  data = [];
  hasResults = false;
  completeAndNoResults = false;
  columns = columns;

  async connectedCallback() {
    const cases = await lookup({ phn: this.phn });

    if (cases.length > 0) {
      cases.forEach(item => {
        this.data = [...this.data, {
          id: item.Id,
          caseNumber: item.CaseNumber,
          status: item.Status,
          subject: item.Subject,
          link: '/s/case/' + item.Id,
          createdDate: item.CreatedDate,
          owner: item.Owner.Name
        }];
      });
      this.hasResults = true;
    } else {
      this.completeAndNoResults = true;
    }
  }
}