import { LightningElement, api, track } from 'lwc';
import fetchBenefits from '@salesforce/apex/ODRIntegration.fetchBenefits';
import postSAApproval from '@salesforce/apex/ODRIntegration.postSAApproval';

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
  loaded = true;
  benefitPlans = [];
  completeAndNoResults = false;
  error = {};
  isError = false;

  @track error;
  connectedCallback() {
    fetchBenefits({recordId: this.recordId})
    .then(data => {
      if (data && data.error == null) {
        console.log("PatientPlanInformation:", data);

        if (data.planEligibility && data.planEligibility.length > 0) {
          this.completeAndNoResults = false;
          this.hasBenefits = true;
          this.benefitPlans = data.planEligibility;
          console.log("benefitPlans:", this.benefitPlans);
        } else {
          this.completeAndNoResults = true;
        }
        this.loaded = true;
      } else {
        this.isError = true;
        this.loaded = true;
        this.error = data.error.errorMessage;
      }
    });
  }

  handleClick(event) {
    console.log("SA APPROVAL", this.recordId);
    postSAApproval({recordId: this.recordId});
  }
}