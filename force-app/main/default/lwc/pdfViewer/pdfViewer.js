import { LightningElement, api, wire } from 'lwc';
import getPdf from '@salesforce/apex/PdfViewer.getPdf';

export default class PdfViewer extends LightningElement {
    @api recordId;

    @api heightInRem;
    
    fileId;

    async connectedCallback() {
        const fileResult = await getPdf({recordId: this.recordId});
        this.fileId = fileResult.documentId;
    }
    
    get pdfHeight() {
        return `height: ${this.heightInRem}rem`;
    }

    get url() {
        return `/sfc/servlet.shepherd/document/download/${this.fileId}`;
    }
}