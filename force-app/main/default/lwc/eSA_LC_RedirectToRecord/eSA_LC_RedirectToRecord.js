import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { FlowNavigationFinishEvent } from 'lightning/flowSupport';

export default class ESA_LC_RedirectToRecord extends NavigationMixin(
    LightningElement
)  {
    @api recordId;
    @api availableActions = [];
    @api  objectType;

    connectedCallback(){
       console.log('recordid'+this.recordId);
       
    this[NavigationMixin.GenerateUrl]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.recordId,
                apiName: this.objectType,
                actionName: "edit"
        },
       
    }).then(url => { window.open(url) });
        

        if (this.availableActions.find((action) => action === 'FINISH')) {
            this.dispatchEvent(new FlowNavigationFinishEvent());
        } 
    }
    }
