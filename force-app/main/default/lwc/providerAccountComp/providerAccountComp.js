import { LightningElement, api, wire} from 'lwc';
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
    @api required;
    handlekeychange(event) {
            this.accountPHN = event.currentTarget.value; 
           }
    handleSearch() {
            if(!this.accountPHN) {
                this.messageResult=true;
                this.accountList = undefined;
                return;
            }
            getProviderAccount({providerAct : this.accountPHN})
            .then(result => {
                this.accountList = result;
                this.Name = result[0].Name;
                this.ProviderAccId = result[0].Id;
                this.ProviderIdentifier = result[0].Patient_Identifier__pc;
                this.Type = result[0].Provider_Type__pc;
                this.showRemoveButton=true;
                this.messageResult=false;
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
        this.showRemoveButton=false;
        this.messageResult=false;
        }
    }