/**
 * @description: Trigger to handle events on Application Object
 *
 * @author Pranshu Sharma, Traction on Demand
 * @date   2021-05-05
 */

trigger traa_ApplicationTrigger on hed__Application__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    hed.TDTM_Global_API.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete, Trigger.new, Trigger.old, Schema.SObjectType.hed__Application__c);
}