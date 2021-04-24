@isTest
public with sharing class MaintenanceTriggerHandlerTest {
    public MaintenanceTriggerHandlerTest() {

    }

    @TestSetup
    static void createTestData(){

        Vehicle__c vehicleI20 = new Vehicle__c();
        vehicleI20.Name = 'KL 12 K 1402';
        vehicleI20.Make__c = 'Hyundai';
        insert vehicleI20;

        Maintenance_Request__c maintenanceRequestDoorLockChange = new Maintenance_Request__c();
        maintenanceRequestDoorLockChange.Name = 'Change door lock';
        maintenanceRequestDoorLockChange.Vehicle__c = vehicleI20.Id;
        insert maintenanceRequestDoorLockChange;

        Maintenance_Request__c maintenanceRequestDoorChange = new Maintenance_Request__c();
        maintenanceRequestDoorChange.Name = 'Change door';
        maintenanceRequestDoorChange.Vehicle__c = vehicleI20.Id;
        insert maintenanceRequestDoorChange;

        Part_Inventory__c partDataDoor = new Part_Inventory__c();
        partDataDoor.Name = 'Door';
        partDataDoor.Minimum_quantity_reminder__c = true;
        partDataDoor.Quantity_In_Stock__c = 2;
        insert partDataDoor;

        Part_Inventory__c partDataDoorLock = new Part_Inventory__c();
        partDataDoorLock.Name = 'Door_Lock';
        partDataDoorLock.Minimum_quantity_reminder__c = true;
        partDataDoorLock.Quantity_In_Stock__c = 4;
        partDataDoorLock.Parent_Part__c = partDataDoor.Id;
        insert partDataDoorLock;

    }

   @isTest
    public static void updateInventoryTest() {
        
        Part_Inventory__c partDataDoorLock = [SELECT Id, Name FROM Part_Inventory__c WHERE Name = 'Door_Lock'];
        Maintenance_Request__c maintenanceRequestDoorLockChange = [SELECT Id, Name FROM Maintenance_Request__c WHERE Name = 'Change door lock'];
        
        Maintenance_Part__c maintenancePartDoorLock = new Maintenance_Part__c();
        maintenancePartDoorLock.Name = 'Door Lock';
        maintenancePartDoorLock.Maintenance_Request__c = maintenanceRequestDoorLockChange.Id;
        maintenancePartDoorLock.Part__c = partDataDoorLock.Id;
        maintenancePartDoorLock.Quantity_Utilized__c = 1;
        insert maintenancePartDoorLock;
        
        Maintenance_Part__c maintenancePartObj = [SELECT Id, Quantity_Utilized__c FROM Maintenance_Part__c WHERE Name =: 'Door Lock'];
        
        
        maintenancePartObj.Quantity_Utilized__c = 2;
        update maintenancePartObj;
    }

    @isTest
    public static void fullSetPartOrderTest(){

        Part_Inventory__c partInventoryDoor = [SELECT Id, Name FROM Part_Inventory__c WHERE Name =: 'Door'];
        Maintenance_Request__c maintenanceRequestDoor = [SELECT Id, Name FROM Maintenance_Request__c WHERE Name = 'Change door'];

        Maintenance_Part__c maintenancePartDoor = new Maintenance_Part__c();
        maintenancePartDoor.Name = 'Change Right From door';
        maintenancePartDoor.Maintenance_Request__c = maintenanceRequestDoor.Id;
        maintenancePartDoor.Part__c = partInventoryDoor.Id;
        maintenancePartDoor.Quantity_Utilized__c = 2;
        insert maintenancePartDoor;
        
        delete maintenancePartDoor;

    }

}