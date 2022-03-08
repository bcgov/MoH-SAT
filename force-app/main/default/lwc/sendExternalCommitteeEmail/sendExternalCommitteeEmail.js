import { LightningElement, api } from "lwc";

export default class SendExternalCommitteeEmail extends LightningElement {
    @api invoke() {
        console.log("To send external committee email");
    }
    // isExecuting = false;

    // @api async invoke() {
    //     if (this.isExecuting) {
    //         return;
    //     }

    //     this.isExecuting = true;
    //     await this.sleep(2000);
    //     this.isExecuting = false;
    // }

    // sleep(ms) {
    //     return new Promise((resolve) => setTimeout(resolve, ms));
    // }
}