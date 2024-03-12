import { LightningElement } from 'lwc';
import  omniscriptSaveForLaterAcknowledge from 'vlocity_cmt/omniscriptSaveForLaterAcknowledge';
import {OmniscriptBaseMixin} from 'vlocity_cmt/omniscriptBaseMixin';
import tmpl from './sampleSaveForLater.html';

export default class SampleSaveForLater extends OmniscriptBaseMixin(omniscriptSaveForLaterAcknowledge) {

    render() {
        console.log('testrender');
        return tmpl;
    }
    handleClick(){

        window.history.go(0);
    }


}