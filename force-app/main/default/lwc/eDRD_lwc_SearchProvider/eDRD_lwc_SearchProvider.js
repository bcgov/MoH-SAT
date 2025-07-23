import { LightningElement, api, track } from 'lwc';
import { FlowNavigationBackEvent, FlowNavigationNextEvent } from "lightning/flowSupport";
import getProviderAccount from '@salesforce/apex/EDRDAccountLookupController.getProviderAccount';

export default class EDRD_lwc_SearchProvider extends LightningElement {
    @api accountPHN = '';
    @api providerPHN;
    @api accountName;
    @api messageResult = false;
    @api showRemoveButton = false;
    @api accountList = [];
    @api Type;
    @api Name;
    @api ProviderAccId;
    @api ProviderIdentifier;
    @api availableActions = [];

    @track disableNextButton = true;
    @track resultLength = 0;

    onProviderPhnChange(event) {
        this.accountPHN = event.currentTarget?.value || '';
    }

    performSearch() {
        this.disableNextButton = false;

        if (!this.accountPHN) {
            this.displayNoResults();
            return;
        }

        getProviderAccount({ providerAct: this.accountPHN })
            .then(result => this.handleSearchResult(result))
            .catch(() => this.displayNoResults());
    }

    handleSearchResult(result) {
        if (result && Array.isArray(result) && result.length > 0) {
            this.accountList = result;
            this.Name = result[0].Name;
            this.ProviderAccId = result[0].Id;
            this.ProviderIdentifier = result[0].Patient_Identifier__pc;
            this.Type = result[0].Provider_Type__pc;
            this.showRemoveButton = true;
            this.messageResult = false;
            this.resultLength = result.length;
        } else {
            this.displayNoResults();
        }
    }

    displayNoResults() {
        this.accountList = undefined;
        this.messageResult = true;
        this.disableNextButton = true;
        this.resultLength = 0;
        this.showRemoveButton = false;
    }

    clearSearch() {
        this.accountList = [];
        this.Name = '';
        this.ProviderAccId = '';
        this.Type = '';
        this.providerPHN = '';
        this.accountPHN = '';
        this.messageResult = false;
        this.resultLength = 0;
        this.showRemoveButton = false;
        this.disableNextButton = true;
    }

    proceedNext() {
        if (!this.resultLength || !this.accountPHN) {
            this.messageResult = true;
            this.accountList = undefined;
        } else if (this.availableActions.includes("NEXT")) {
            this.dispatchEvent(new FlowNavigationNextEvent());
        }
    }

    goBack() {
        if (this.availableActions.includes("BACK")) {
            this.dispatchEvent(new FlowNavigationBackEvent());
        }
    }
}