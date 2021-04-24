trigger MaintenancePartTigger on Maintenance_Part__c (before insert, before update,after insert, after update, after delete) {

    if(trigger.isBefore && trigger.isInsert){
        MaintenanceTriggerHandler.fullSetPartOrder(trigger.new, null);
    }else if(trigger.isBefore && trigger.isUpdate){
        MaintenanceTriggerHandler.fullSetPartOrder(trigger.new, trigger.oldMap);
    }else if (trigger.isInsert  && trigger.isAfter) {
        MaintenanceTriggerHandler.updateInventory(null, trigger.newMap);
    }else if (trigger.isUpdate && trigger.isAfter) {
        MaintenanceTriggerHandler.updateInventory(trigger.oldMap, trigger.newMap);
    }else if (trigger.isDelete && trigger.isAfter) {
        MaintenanceTriggerHandler.updateInventory(trigger.oldMap, null);
    }

}