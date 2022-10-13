public with sharing class ActionResult {

    private Boolean validationSuccessful;

    public ActionResult setValidationResult(Boolean validationSuccessful){
        this.validationSuccessful = validationSuccessful;
        return this;
    }

    public Boolean getValidationResult(){
        return this.validationSuccessful;
    }
}
