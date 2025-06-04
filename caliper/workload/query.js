'use strict';
 
const { WorkloadModuleBase } = require('@hyperledger/caliper-core');
const { v4: uuidv4 } = require('uuid');
 
class QueryWorkload extends WorkloadModuleBase {
    constructor() {
        super();
    }
    async initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext) {
        await super.initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext);
        console.log("-----------> 初始化");
        const initLedgerRequest  = {
            contractId: this.roundArguments.contractId,
            contractFunction: 'InitLedger',
            invokerIdentity: 'Admin@org1.example.com',
            contractArguments: [],
            readOnly: false
        };
        try {
            await this.sutAdapter.sendRequests(initLedgerRequest);
        } catch (error) {
            console.error("初始化出错:", error);
        }
        

        //createuser 0_0
        for (let i=0; i<this.roundArguments.userNum; i++) {
            const userID = "user"+`${this.workerIndex}_${i}`;
            console.log(`-----------> Worker ${this.workerIndex}: Creating user ${userID}`);
            const request = {
                contractId: this.roundArguments.contractId,
                contractFunction: 'CreateUser',
                invokerIdentity: 'Admin@org1.example.com',
                contractArguments: [userID, '0'],
                readOnly: false
            };

            try {
                await this.sutAdapter.sendRequests(request);
            } catch (error) {
                console.error("createuser出错:", error);
            }
        }   
    
        //Mint +value
        for (let i=0; i<this.roundArguments.userNum; i++) {
            const mintId = "user"+`${this.workerIndex}_${i}`;
            console.log(`-----------> Worker ${this.workerIndex}: Mint  ${mintId} + 10000`);
            const request = {
                contractId: this.roundArguments.contractId,
                contractFunction: 'Mint',
                invokerIdentity: 'Admin@org1.example.com',
                contractArguments: [mintId, "10000"],
                readOnly: false
            };

            try {
                await this.sutAdapter.sendRequests(request);
            } catch (error) {
                console.error("Mint出错:", error);
            }
        }   

        //createdataset
        for (let i=0; i<this.roundArguments.dataNum; i++) {
            const temp_cd_id = Math.floor(Math.random()*this.roundArguments.userNum);
            const user_cd_id = "user"+`${this.workerIndex}_${temp_cd_id}`
            console.log(`-----------> Worker ${this.workerIndex}: createdataset by user${this.workerIndex}_${temp_cd_id}  dataset ${i+1}`);
            const tags = ["1", "2", "3"];
            const tagsJson = JSON.stringify(tags);
            const createDatasetRequest = {
                contractId: this.roundArguments.contractId,
                contractFunction: 'CreateDataset',
                invokerIdentity: 'Admin@org1.example.com',
                contractArguments: ['title', 'description', 'hash', 'ipfsAddress', '1', user_cd_id, '1', tagsJson],
                readOnly: false
            };
    
            try {
                await this.sutAdapter.sendRequests(createDatasetRequest);
            } catch (error) {
                console.error('createdataset出错:', error);
            }
        }   

      
        //createorder
        for (let i=0; i<this.roundArguments.orderNum; i++) {
            const temp_co_id = Math.floor(Math.random()*this.roundArguments.userNum);
            const user_co_id = "user"+`${this.workerIndex}_${temp_co_id}`
            //dataset计数方式
            const temp_co_id2 = Math.floor(Math.random()*this.roundArguments.dataNum)+1;
            const data_co_id = "dataset"+`${temp_co_id2}`

            console.log(`-----------> Worker ${this.workerIndex}: createorder;user: user${this.workerIndex}_${temp_co_id};data: dataset${temp_co_id2}`);

            const createOrderRequest = {
                contractId: this.roundArguments.contractId,
                contractFunction: 'CreateOrder',
                invokerIdentity: 'Admin@org1.example.com',
                contractArguments: [user_co_id, data_co_id, 'hash'],
                readOnly: false
            };
            try {
                await this.sutAdapter.sendRequests(createOrderRequest);
            } catch (error) {
                console.error("createorder出错:", error);
            }
        }   
        //HandleOrder 已经交付的订单会失效，不可重复执行，仅测试一次
        // const HandleorderId = Math.floor(Math.random()*this.roundArguments.orderNum+1);
        // console.log(`-----------> Worker ${this.workerIndex}: HandleOrder:order${HandleorderId}`);
        // const handleOrderRequest = {
        //     contractId: this.roundArguments.contractId,
        //     contractFunction: 'HandleOrder',
        //     invokerIdentity: 'Admin@org1.example.com',
        //     contractArguments: [`order${HandleorderId}`, '1', 'hash'],
        //     readOnly: false
        // };
        // try {
        //     await this.sutAdapter.sendRequests(handleOrderRequest);
        // } catch (error) {
        //     console.error("HandleOrder出错:", error);
        // }

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