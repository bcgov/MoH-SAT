import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import EDRD_label_SaveForLaterAcknowledge from '@salesforce/label/c.EDRD_label_SaveForLaterAcknowledge';
import EDRD_label_SaveForLaterAcknowledge_HelpText from '@salesforce/label/c.EDRD_label_SaveForLaterAcknowledge_HelpText';
import  omniscriptSaveForLaterAcknowledge from 'omnistudio/omniscriptSaveForLaterAcknowledge';
import {OmniscriptBaseMixin} from 'omnistudio/omniscriptBaseMixin';
import tmpl from './eDRD_lwc_customSaveforlater.html';

export default class eDRD_lwc_customSaveforlater extends OmniscriptBaseMixin(omniscriptSaveForLaterAcknowledge) {

    render() {
        return tmpl;
    }

    handleRefresh(event) {
     this[NavigationMixin.Navigate]({
      type: 'comm__namedPage',
      attributes: {
          name: 'Home'
        }
      });
    }

    label = {
        EDRD_label_SaveForLaterAcknowledge,
        EDRD_label_SaveForLaterAcknowledge_HelpText
    };
}