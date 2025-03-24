import { LightningElement, api, track } from 'lwc';
import {
FlowNavigationBackEvent,
FlowNavigationNextEvent
} from "lightning/flowSupport";
import getProviderAccount from '@salesforce/apex/EDRDAccountLookupController.getProviderAccount';
export default class ProviderAccountComp extends LightningElement {
@api accountPHN = '';
@api providerPHN;
@api accountName;
@api messageResult=false;
@api showsearchedvalues=false;
@api showRemoveButton=false;
@api accountList = [];
@api Type;
@api Name;
@api ProviderAccId;
@api ProviderIdentifier;
@api availableActions = [];

@track disableNextButton = true;

handlekeychange(event) {
    if (event.currentTarget) {
        this.accountPHN = event.currentTarget.value;
    }
        }
handleSearch() {
        this.disableNextButton = false;
        if(!this.accountPHN) {
            this.messageResult=true;
            this.accountList = undefined;
            return;
        }
        getProviderAccount({providerAct : this.accountPHN})
        .then(result => {
            if (result && Array.isArray(result) && result.length > 0){
            this.accountList = result;
            this.Name = result[0].Name;
            this.ProviderAccId = result[0].Id;
            this.ProviderIdentifier = result[0].Patient_Identifier__pc;
            this.Type = result[0].Provider_Type__pc;
            this.showRemoveButton=true;
            this.messageResult=false;
            this.resultLength=result.length;
            }else {
            this.accountList = undefined;
            this.messageResult = true;
             this.disableNextButton = true;
            }
            
        })
        .catch(error => {
            this.accountList = undefined;
            this.messageResult = true;
            if(error) {
                if (Array.isArray(error.body)) {
                    this.errorMsg = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    this.errorMsg = error.body.message;
                }
            }
        }) 
    }
handleRemoveResults(){
    this.accountList = [];
    this.Name = '';
    this.ProviderAccId = '';
    this.Type = '';
    this.providerPHN = '';
    this.accountPHN ='';
    this.showRemoveButton=false;
    this.messageResult=false;
    this.resultLength=0;
    this.showRemoveButton = false;
}
handleNext(){
    if (this.resultLength === 0 || this.resultLength === undefined ||!this.accountPHN) {
      this.messageResult = true;
      this.accountList = undefined;
    }else if (this.availableActions.find((action) => action === "NEXT")){
           const navigateNextEvent = new FlowNavigationNextEvent();
           this.dispatchEvent(navigateNextEvent);
           }
    }
    handleBack(){
        if (this.availableActions.find((action) => action === "BACK")){
            const navigateBackEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateBackEvent);
            }
    }
}