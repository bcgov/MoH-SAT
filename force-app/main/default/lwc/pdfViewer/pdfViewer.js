import { LightningElement, api, wire } from 'lwc';
import getPdf from '@salesforce/apex/PdfViewer.getPdf';

export default class PdfViewer extends LightningElement {
    @api recordId;

    @api heightInRem;
    
    fileId;

    isEmpty = false;

    async connectedCallback() {
        const fileResult = await getPdf({recordId: this.recordId});
        this.fileId = fileResult?.documentId;
        this.isEmpty = this.fileId == null;
    }
    
    get pdfHeight() {
        return `height: ${this.heightInRem}rem`;
    }

    get url() {
        return `/sfc/servlet.shepherd/document/download/${this.fileId}`;
    }
}