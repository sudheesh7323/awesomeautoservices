public with sharing class MaintenanceTriggerHandler {
    /**
     * Update Part Inventory after insert/create/delete of each Maintenance Part record
     */
    public static void updateInventory(Map<Id, Maintenance_Part__c> maintenacePartOldMap, Map<Id, Maintenance_Part__c> maintenacePartNewMap){
        
        List<Id> partInventoryIdList = new List<Id>();
        Map<Id, Part_Inventory__c> partInventoryMap;
        if (maintenacePartNewMap != null) {
            for(Maintenance_Part__c maintenancePartRec: maintenacePartNewMap.values()){
                partInventoryIdList.add(maintenancePartRec.Part__c);
            }
        }
        else if (maintenacePartOldMap != null) {
            for(Maintenance_Part__c maintenancePartRec: maintenacePartOldMap.values()){
                partInventoryIdList.add(maintenancePartRec.Part__c);
            }
        }
        if (partInventoryIdList.size() > 0) {
            partInventoryMap = new Map<Id, Part_Inventory__c>([SELECT Id, Quantity_In_Stock__c FROM Part_Inventory__c WHERE Id IN : partInventoryIdList]);
        }
        if(partInventoryMap.size() > 0){
            if (maintenacePartNewMap != null) {
                for(Maintenance_Part__c maintenancePartRec: maintenacePartNewMap.values()){
                    if (maintenacePartOldMap != null) {
                        if (maintenacePartOldMap.get(maintenancePartRec.Id).Quantity_Utilized__c > 0) {
                            Decimal quantity = 0;
                            quantity = partInventoryMap.get(maintenancePartRec.Part__c).Quantity_In_Stock__c + maintenacePartOldMap.get(maintenancePartRec.Id).Quantity_Utilized__c;
                            partInventoryMap.get(maintenancePartRec.Part__c).Quantity_In_Stock__c = quantity - maintenancePartRec.Quantity_Utilized__c;
                        }
                    }
                    else {
                        partInventoryMap.get(maintenancePartRec.Part__c).Quantity_In_Stock__c -= maintenancePartRec.Quantity_Utilized__c;
                    }
                }
            }
            else if (maintenacePartOldMap.size() > 0) {
                for(Maintenance_Part__c maintenancePartRec: maintenacePartOldMap.values()){
                    partInventoryMap.get(maintenancePartRec.Part__c).Quantity_In_Stock__c += maintenancePartRec.Quantity_Utilized__c;
                }
            }
            try{
                update partInventoryMap.values();
            } catch(exception e){
                
            }
        }
    }
    /**
     * Check if all the child parts in a Part set is available.
     * If Part Set order is success then manage the inventory of child parts
     */
    public static void fullSetPartOrder(List<Maintenance_Part__c> maintenancePartRecordsList, Map<Id, Maintenance_Part__c> maintenancePartRecordsOldMap){
        Set<Id> inventoryIdSet = new Set<Id>();
        Map<Id, Decimal> parentPartIdQuantityMap = new Map<Id, Decimal>();
        List<Part_Inventory__c> inventoryPartRecordsList = new List<Part_Inventory__c>();
        Map<Id, Maintenance_Part__c> maintenancePartRecordMap = new Map<Id, Maintenance_Part__c>();
        if(maintenancePartRecordsList.size() > 0){
            for (Maintenance_Part__c maintenanceParRec : maintenancePartRecordsList) {
                parentPartIdQuantityMap.put(maintenanceParRec.Part__c,maintenanceParRec.Quantity_Utilized__c);
                maintenancePartRecordMap.put(maintenanceParRec.Id, maintenanceParRec);
            }
        }

        if (parentPartIdQuantityMap.size() > 0) {
            
            inventoryPartRecordsList = [SELECT Id, Name,Quantity_In_Stock__c, Parent_Part__c FROM Part_Inventory__c WHERE Parent_Part__c IN : parentPartIdQuantityMap.keySet()];
        }

        if (inventoryPartRecordsList.size() > 0) {
            for(Maintenance_Part__c maintenanceRec: maintenancePartRecordsList){
                for(Part_Inventory__c partInventoryRec: inventoryPartRecordsList){
                    if (maintenanceRec.Part__c == partInventoryRec.Parent_Part__c) {
                        if (maintenanceRec.Quantity_Utilized__c > partInventoryRec.Quantity_In_Stock__c) {
                            maintenanceRec.addError('Availability of '+partInventoryRec.Name+' is '+partInventoryRec.Quantity_In_Stock__c);
                        }else {
                            if (maintenancePartRecordsOldMap != null) {
                                partInventoryRec.Quantity_In_Stock__c += maintenancePartRecordsOldMap.get(maintenanceRec.Id).Quantity_Utilized__c;
                            }
                            partInventoryRec.Quantity_In_Stock__c -= maintenanceRec.Quantity_Utilized__c;
                        }
                    }
                }
            }
            try {
                update inventoryPartRecordsList;
            } catch (Exception e) {
                
            }
        }

    }
}