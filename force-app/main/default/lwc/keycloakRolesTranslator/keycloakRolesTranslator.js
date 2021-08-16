import { LightningElement } from 'lwc';

import translateUserRoles from '@salesforce/apex/KeycloakRolesTranslator.translateUserRoles';


export default class KeycloakRolesTranslator extends LightningElement {

    async connectedCallback() {
        try {
            await translateUserRoles();
        } catch (error) {}
    }

}