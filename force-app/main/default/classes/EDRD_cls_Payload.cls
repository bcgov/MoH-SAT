/**********************************************************************************************
* @Author:      Accenture 
* @Date:        07 Jan 2025
* @Description: The purpose of this class is to 
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
                07 Jan -  EDRD-1112         -  Accenture   - To create the payload object.
***********************************************************************************************/
public class EDRD_cls_Payload{
    public cls_inputs[] inputs;
    public class cls_inputs {
        public String assessmentId;
    }
    public static EDRD_cls_Payload parse(String json){
        return (EDRD_cls_Payload) System.JSON.deserialize(json, EDRD_cls_Payload.class);
    }  
}