'use strict';
 
const { WorkloadModuleBase } = require('@hyperledger/caliper-core');
const { v4: uuidv4 } = require('uuid');
 
class QueryWorkload extends WorkloadModuleBase {
    constructor() {
        super();
    }
    
    async submitTransaction() {
        console.log("-----------> 查询测试");
        // GetDataset(1-dataNum)
        const GetdatasetId = Math.floor(Math.random()*this.roundArguments.dataNum)+1;
        console.log(`-----------> Worker ${this.workerIndex}: GetDataset:data${GetdatasetId}`);
        const getDatasetRequest = {
            contractId: this.roundArguments.contractId,
            contractFunction: 'GetDataset',
            invokerIdentity: 'Admin@org1.example.com',
            contractArguments:  [`dataset${GetdatasetId}`],
            readOnly: true
        };
        try {
            await this.sutAdapter.sendRequests(getDatasetRequest);
        } catch (error) {
            console.error('GetDataset出错:', error);
        }

      

        //GetOrder(1-orderNum)
        const GetorderId =  Math.floor(Math.random()*this.roundArguments.orderNum)+1;
        console.log(`-----------> Worker ${this.workerIndex}: GetOrder:order${GetorderId}`);
        const getOrderRequest = {
            contractId: this.roundArguments.contractId,
            contractFunction: 'GetOrder',
            invokerIdentity: 'Admin@org1.example.com',
            contractArguments:  [`order${GetorderId}`],
            readOnly: true
        };
        try {
            await this.sutAdapter.sendRequests(getOrderRequest);
        } catch (error) {
            console.error("GetOrder出错:", error);
        }


    }


    }
    
function createWorkloadModule() {
    return new QueryWorkload();
}
 
module.exports.createWorkloadModule = createWorkloadModule;