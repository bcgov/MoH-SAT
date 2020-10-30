import { LightningElement, api } from 'lwc';
import MOCK_UI from '@salesforce/resourceUrl/mockui';

export default class MockComponent extends LightningElement {
    @api
    title;

    @api 
    fileName;

    get imgSrc() {
        return `${MOCK_UI}/${this.fileName}`;
    }
}