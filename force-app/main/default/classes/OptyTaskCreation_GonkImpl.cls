/****************************************************************************************
* Gonkulator Apex Class: OptyTaskCreation_GonkImpl
* Triggered on Opportunity AFTER_INSERT
* Creates two tasks when Opportunity.StageName == 'Value Proposition'
* - Task1: Assign Sales Engineer
* - Task2: Set Discovery Appointment
* Only creates tasks if they do not already exist
****************************************************************************************/
global without sharing class OptyTaskCreation_GonkImpl implements gonkulator.Gonkiface {
    global gonkulator.GonkulatorModel.Gonk vGonk;
    public static gonkulator.GonkulatorModel.Query vOpportunityQuery;
    public static Map<String, Opportunity> vOptyMap = new Map<String, Opportunity>();

    // Init method to initialize the Gonkulator model
    global void init(gonkulator.GonkulatorModel.Gonk incomingGonk) {
        vGonk = incomingGonk;
    }

    // GetData to retrieve Opportunity and related Tasks
    global void getData() {
        if (vOpportunityQuery == null) {
            vOpportunityQuery = new gonkulator.GonkulatorModel.Query();
            vOpportunityQuery.children.add('Tasks');
            vOpportunityQuery.criteriaField = 'Id';
            vGonk.queryMap.put(Opportunity.getSObjectType(), vOpportunityQuery);
            gonkulator.GonkulatorCore.gonkQuery(vGonk);
        }
        for (Opportunity vOpportunity : (List<Opportunity>) vGonk.queryMap.get(Opportunity.getSObjectType()).queryResults) {
            vOptyMap.put(vOpportunity.Id, vOpportunity);
        }
    }

    // Validate method to skip execution if tasks already exist
    global void validate() {
        for (Opportunity vOpportunity : (List<Opportunity>) vGonk.objectList) {
            if (vOptyMap.containsKey(vOpportunity.Id) && vOptyMap.get(vOpportunity.Id).Tasks.size() > 0) {
                vGonk.status = 'Error'; // prevent further processing
            }
        }
    }

    // Execute method to create tasks
    global void execute() {
        for (Opportunity opp : (List<Opportunity>) vGonk.objectList) {
            if (opp.StageName == 'Value Proposition') {
                Task task1 = new Task(
                    Subject = 'Assign Sales Engineer',
                    WhatId = opp.Id,
                    OwnerId = opp.OwnerId,
                    Status = 'Not Started'
                );
                vGonk.objectsToInsert.add(task1);

                Task task2 = new Task(
                    Subject = 'Set Discovery Appointment',
                    WhatId = opp.Id,
                    OwnerId = opp.OwnerId,
                    Status = 'Not Started'
                );
                vGonk.objectsToInsert.add(task2);
            }
        }
    }

    // DML method to insert created tasks
    global void dml() {
        if (!vGonk.objectsToInsert.isEmpty()) {
            insert vGonk.objectsToInsert;
        }
    }
}


