/**********************************************************************************************
* @Author:      Deepak 
* @Date:        29 Jun 2025
* @Description: The purpose of this Queable class is to insert the Group Member in future context.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
***********************************************************************************************/
public without sharing class EDRD_cls_groupMemberQueable implements Queueable {
    public List<GroupMember> gMToInsert;
    
/**
* @author: Deepak
* @date: 29 Jun 2025
* @description: The purpose of this Constructor method is to return list of Group Member records.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/
    public EDRD_cls_groupMemberQueable(List<GroupMember> gMToInsert){
        this.gMToInsert = gMToInsert;
    }
    
/**
* @author: Deepak
* @date: 29 Jun 2025
* @description: The purpose of this method is to insert Group Member records.
* @Modification Log: [Date] - [Change Reference] - [Changed By] - [Description]
*/
    public void execute(QueueableContext context) {
        insert gMToInsert;
    }
}