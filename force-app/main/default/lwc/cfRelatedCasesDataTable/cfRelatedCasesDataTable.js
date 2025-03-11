import { LightningElement, api } from "lwc";
export default class cfRelatedCasesDataTable extends LightningElement {
    @api recordId;
	@api objectApiName;
	@api theme;
	@api orgNsPrefix;
	@api sessionVars;
	@api searchParam;
	@api obj;
	@api isRecursive;
	@api debug;
	@api isChildCardTrackingEnabled;
	@api trackingObj;
	@api testParams;
	@api size;
	@api records;
	@api cardNode;
	@api parentData;
	@api parentUniquekey;
	@api isInsideParent;
	@api parentRecord;
	@api parentRecords;
	@api parentAttribute;
	@api parentMergefields;
	@api listenOsDataChange;
	@api omniJsonData;
    
    @api omniSupportKey;
	@api omniScriptHeaderDef;
	@api omniResume;
	@api omniSeedJson;
	@api omniJsonDef;
	@api omniCustomState;
	@api omniJsonDataStr;
    
    @api checkValidity() {
      return this.runtimeWrapper?.checkValidity();
    }
    @api reportValidity() {
      return this.runtimeWrapper?.reportValidity();
    }
    
    get runtimeWrapper() {
      return this.template.querySelector('omnistudio-flex-card-standard-runtime-wrapper');
    }
}