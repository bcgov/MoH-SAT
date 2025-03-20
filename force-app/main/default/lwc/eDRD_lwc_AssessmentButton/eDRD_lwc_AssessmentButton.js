import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getAssessmentResponseSummary from '@salesforce/apex/EDRD_cls_AssessmentResponseService.getAssessmentResponseSummary';

export default class EDRD_lwc_AssessmentButton extends LightningElement {
    @track recordId;
    @track outputJSON;
    @track isButtonDisabled = false; 

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.attributes.recordId;
            
        }
    }

    handleButtonClick() {
        this.isButtonDisabled = true; 
        getAssessmentResponseSummary({ assessmentId: this.recordId })
            .then((response) => {
                let responseObj = JSON.parse(response);
                let headingList = responseObj['headingList'];
                this.outputJSON = responseObj['Response'];
                const jsonParser = this.template.querySelector('c-json-parser');

                if (jsonParser) {
                    jsonParser.processJson(this.outputJSON, headingList, this.recordId);
                } else {
                    console.error('JsonParser component not found!');
                }
            })
            .catch((error) => {
                console.error('Error fetching assessment response:', (error));
                this.isButtonDisabled = false; 
            });
    }
}