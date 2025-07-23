/**
* @description Trigger to handle events on Lead Object
*
*
* @author      Mitali Nahar, Traction on Demand
* @date        2020-02-13
*/

trigger traa_LeadTrigger on Lead (after delete, after insert, after undelete,after update, before delete, before insert, before update) {
    hed.TDTM_Global_API.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete, Trigger.new, Trigger.old, Schema.SObjectType.Lead);
}