import { LightningElement ,api,wire } from 'lwc';
import getGeneralStamp from '@salesforce/apex/ESA_cls_CaseSuperStampHelper.getGeneralStamp';
import getSuperStamp from '@salesforce/apex/ESA_cls_CaseSuperStampHelper.getSuperStamp';
import { updateRecord ,getRecord} from 'lightning/uiRecordApi';
import GeneralStamp_FIELD from "@salesforce/schema/Case.ESA_General_Stamps__c";
import SuperStamp_FIELD from "@salesforce/schema/Case.ESA_Super_Stamp__c";
import ID_FIELD from "@salesforce/schema/Case.Id";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const columns1 = [
    { label: 'Stamps', fieldName: 'ESA_Stamp_Text__c', type :'text', sortable : true , wrapText: true ,
     cellAttributes: {
        class: 'height : 100px'
    },  }
    
];
const columns2 = [
    { label: 'Stamps', fieldName: 'ESA_Super_Stamp__c', type :'text', sortable : true , wrapText: true ,
     cellAttributes: {
        class: 'height : 120px'
    },  }
    
];

export default class Esa_LC_SuperStamps extends LightningElement {
   @api recordId;
   @api isSuperStamp= false;
   isGeneralStamps = true;
   records = [];
   columns ;
   record = {};
   pageSize = 10;
   totalRecords;
   pageNumber = 1;
   recordsToDisplay;
   totalPages;
   selectedText ='';
   recordInput ;
   generalStampText ='';
   superStampText='';
   selectedRows =[];
     connectedCallback() {
        this.isGeneralStamps = !this.isSuperStamp;
        if(this.isGeneralStamps){
            this.columns = columns1;
        getGeneralStamp()
        .then((result) => {
            if (result != null) {
                this.records = result;
                this.totalRecords = result.length; // update total records count  
                this.paginationHelper(); // call helper menthod to update pagination logic 
            }
        })
        .catch((error) => {
            console.log('error while fetch data--> ' + JSON.stringify(error));
        });

    }
    else{
        this.columns = columns2;
        getSuperStamp({caseId : this.recordId})
        .then((result) => {
            if (result != null) {
                this.records = result;
                this.totalRecords = result.length; // update total records count               
                this.paginationHelper(); // call helper menthod to update pagination logic 
            }
        })
        .catch((error) => {
            console.log('error while fetch data--> ' + JSON.stringify(error));
        });

    }     
    }

    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }

    // JS function to handel pagination logic 
    paginationHelper() {
        this.recordsToDisplay = [];
        // calculate total pages
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        // set records to display on current page 
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.recordsToDisplay.push(this.records[i]);
        }
        this.template.querySelector('[data-id="stamps"]').selectedRows = this.selectedRows;
    }

    handleRowSelection(event){
        let updatedItemsSet = new Set();
        // List of selected items we maintain.
        let selectedItemsSet = new Set(this.selectedRows);
        // List of items currently loaded for the current view.
        let loadedItemsSet = new Set();

        this.recordsToDisplay.map((ele) => {
            loadedItemsSet.add(ele.Id);
        });

        if (event.detail.selectedRows) {
            event.detail.selectedRows.map((ele) => {
                updatedItemsSet.add(ele.Id);
            });

            // Add any new items to the selectedRows list
            updatedItemsSet.forEach((id) => {
                if (!selectedItemsSet.has(id)) {
                    selectedItemsSet.add(id);
                }
            });
        }

        loadedItemsSet.forEach((id) => {
            if (selectedItemsSet.has(id) && !updatedItemsSet.has(id)) {
                // Remove any items that were unselected.
                selectedItemsSet.delete(id);
            }
        });

        this.selectedRows = [...selectedItemsSet];        
  }

    processUpdate(){
        updateRecord(this.recordInput)
        .then(() => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: "Case updated",
              variant: "success",
            }),
          );
         
        })
        .catch((error) => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error while adding to case record",
              message: error.body.message,
              variant: "error",
            }),
          );
        });
    }

    save(){
    const fields = {};
    let selected = this.selectedRows;
    let selectedRows = this.records.filter(function (el) {
            return selected.includes(el.Id);
             });
       this.selectedText = this.isGeneralStamps ? this.generalStampText : this.superStampText;
        for(let i=0; i< selectedRows.length; i++){
         this.selectedText = this.isGeneralStamps ? this.selectedText +'\n'+ selectedRows[i].ESA_Stamp_Text__c : this.selectedText +'\n'+ selectedRows[i].ESA_Super_Stamp__c ;          
        }

      fields[ID_FIELD.fieldApiName] = this.recordId;
    if(this.isGeneralStamps)
      fields[GeneralStamp_FIELD.fieldApiName] =  this.selectedText;
    else
    fields[SuperStamp_FIELD.fieldApiName] =  this.selectedText;
       this.recordInput = { fields };
       this.processUpdate();
    }

    @wire(getRecord,{ recordId: "$recordId", fields: [GeneralStamp_FIELD,SuperStamp_FIELD] })
    getCaseDetails({data,error}){
        if(data){
            this.generalStampText = data.fields.ESA_General_Stamps__c.value? data.fields.ESA_General_Stamps__c.value :'';
            this.superStampText = data.fields.ESA_Super_Stamp__c.value  ? data.fields.ESA_Super_Stamp__c.value  :'';
        }
        else if(error){
            console.log('error while retrieving the record'+error.body.message);
        }
    
    }
}