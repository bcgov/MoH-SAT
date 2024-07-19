import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import STATUS_FIELD from "@salesforce/schema/Case.Status";
import EFS_DATE_FIELD from "@salesforce/schema/Case.EDRD_Eligibility_Form_Signed_Date__c";
import RECORD_TYPE_FIELD from "@salesforce/schema/Case.RecordType.DeveloperName";
import isAttachmentPresent from '@salesforce/apex/EDRD_cls_ShowToastMsgController.isAttachmentPresent';
import WARNING_MSG from "@salesforce/label/c.EDRD_label_ShowToastMsgWarning";
import EF_WARNING_MSG from "@salesforce/label/c.EDRD_label_ShowToast_EF_Warning";
import ED_WARNING_MSG from "@salesforce/label/c.EDRD_label_ShowToast_ED_Warning";

const FIELDS = [ STATUS_FIELD, EFS_DATE_FIELD, RECORD_TYPE_FIELD ];
const TRIGGER_STATUSES = ['Received - Awaiting Verification', 'SC Review', 'AC Review', 'MOH Review'];
const TARGET_RECORD_TYPE = 'EDRD';

export default class eDRD_LC_ShowToastMessageOnCase extends LightningElement {
    @api recordId;
    @api relatedRecordId;
    oldValue;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: FIELDS
    })
    getCaseRecord(result) {
        console.log(this.oldValue);

        if (result.data?.fields?.RecordType?.displayValue === TARGET_RECORD_TYPE) {
            if (!this.oldValue) {
                this.oldValue = result?.data?.fields?.Status?.value;
            } else if (result.data.fields.Status.value !== this.oldValue) {
                this.oldValue = result?.data?.fields?.Status?.value;

                if (TRIGGER_STATUSES.includes(this.oldValue)) {
                    this.handleStatusChange(result);
                }
            }
        }
    }

    handleStatusChange(result) {
        const efsDateValue = result?.data?.fields?.EDRD_Eligibility_Form_Signed_Date__c?.value;
        isAttachmentPresent({ caseId: this.recordId })
            .then(isAttachmentPresentResult => {
                if (!isAttachmentPresentResult && !efsDateValue) {
                    this.showToast(); // Warning when both conditions are not met
                } else if (!efsDateValue) {
                    this.showToastEDMsg(); // Warning when EFS date is missing
                } else if (!isAttachmentPresentResult) {
                    this.showToastEFMsg(); // Warning when attachment is missing
                }
            })
            .catch(error => {
                console.error(error);
            });
    }

    showToast() {
        const event = new ShowToastEvent({
            title: 'WARNING:',
            message: WARNING_MSG,
            variant: 'warning',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    showToastEFMsg() {
        const event = new ShowToastEvent({
            title: 'WARNING:',
            message: EF_WARNING_MSG,
            variant: 'warning',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    showToastEDMsg() {
        const event = new ShowToastEvent({
            title: 'WARNING:',
            message: ED_WARNING_MSG,
            variant: 'warning',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}