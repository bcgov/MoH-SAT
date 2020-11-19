import { LightningElement, api, wire } from 'lwc';
import fetchBenefits from '@salesforce/apex/ODRIntegration.fetchBenefits';

const columns = [
  { label: 'Code', initialWidth: 80, fieldName: 'authorityCode', initialWidth: 60, hideDefaultActions: true },
  { label: 'Value', initialWidth: 80, fieldName: 'authorityValue', initialWidth: 60, type: 'text', wrapText: true, hideDefaultActions: true },
  { label: 'Effective Date', fieldName: 'effectiveDate', initialWidth: 110, type: 'date-local', typeAttributes:{ month: "2-digit", day: "2-digit" }, hideDefaultActions: true },
  { label: 'Termination Date', fieldName: 'terminationDate', initialWidth: 125, type: 'date-local', typeAttributes:{ month: "2-digit", day: "2-digit" }, hideDefaultActions: true },
  { label: 'Description', fieldName: 'authorityDesc', type: 'text', wrapText: true, hideDefaultActions: true }
];

export default class PatientPlanInformation extends LightningElement {
  @api recordId;
  columns = columns;
  verified = false;
  loaded = false;
  benefitPlans = [];
  hasBenefits = false;

  @wire(fetchBenefits, { recordId: '$recordId' }) mapObjectToData({error,data}) {
    if (data) {
      console.log("PatientPlanInformation:", data);

      if (data.planEligibility.length > 0) {
        this.benefitPlans = data.planEligibility;
        console.log("benefitPlans:", this.benefitPlans);
      }

      this.hasBenefits = true;
      this.loaded = true;
    }
  }
}