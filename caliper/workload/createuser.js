'use strict';
 
const { WorkloadModuleBase } = require('@hyperledger/caliper-core');
const { v4: uuidv4 } = require('uuid');
 
class CreateuserWorkload extends WorkloadModuleBase {
    constructor() {
        super();
    }

    async initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext) {
        await super.initializeWorkloadModule(workerIndex, totalWorkers, roundIndex, roundArguments, sutAdapter, sutContext);
        console.log("-----------> 初始化");
        const initLedgerRequest  = {
            contractId: this.roundArguments.contractId,
            contractFunction: 'InitLedger',
            invokerIdentity: 'Admin@org3.example.com',
            contractArguments: [],
            readOnly: false
        };
        try {
            await this.sutAdapter.sendRequests(initLedgerRequest);
        } catch (error) {
            console.error("初始化出错:", error);
        }
        

       


        // //createdataset
        // for (let i=0; i<this.roundArguments.dataNum; i++) {
        //     const temp_cd_id = Math.floor(Math.random()*this.roundArguments.userNum);
        //     const user_cd_id = "user"+`${this.workerIndex}_${temp_cd_id}`
        //     console.log(`-----------> Worker ${this.workerIndex}: createdataset by user${this.workerIndex}_${temp_cd_id}  dataset ${i+1}`);
        //     const tags = ["1", "2", "3"];
        //     const tagsJson = JSON.stringify(tags);
        //     const createDatasetRequest = {
        //         contractId: this.roundArguments.contractId,
        //         contractFunction: 'CreateDataset',
        //         invokerIdentity: 'Admin@org1.example.com',
        //         contractArguments: ['title', 'description', 'hash', 'ipfsAddress', '1', user_cd_id, '1', tagsJson],
        //         readOnly: false
        //     };
    
        //     try {
        //         await this.sutAdapter.sendRequests(createDatasetRequest);
        //     } catch (error) {
        //         console.error('createdataset出错:', error);
        //     }
        // }   

      
        // //createorder
        // for (let i=0; i<this.roundArguments.orderNum; i++) {
        //     const temp_co_id = Math.floor(Math.random()*this.roundArguments.userNum);
        //     const user_co_id = "user"+`${this.workerIndex}_${temp_co_id}`
        //     //dataset计数方式
        //     const temp_co_id2 = Math.floor(Math.random()*this.roundArguments.dataNum)+1;
        //     const data_co_id = "dataset"+`${temp_co_id2}`

        //     console.log(`-----------> Worker ${this.workerIndex}: createorder;user: user${this.workerIndex}_${temp_co_id};data: dataset${temp_co_id2}`);

        //     const createOrderRequest = {
        //         contractId: this.roundArguments.contractId,
        //         contractFunction: 'CreateOrder',
        //         invokerIdentity: 'Admin@org1.example.com',
        //         contractArguments: [user_co_id, data_co_id, 'hash'],
        //         readOnly: false
        //     };
        //     try {
        //         await this.sutAdapter.sendRequests(createOrderRequest);
        //     } catch (error) {
        //         console.error("createorder出错:", error);
        //     }
        // }   
        // //HandleOrder 已经交付的订单会失效，不可重复执行，仅测试一次
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
        //createuser
        console.log("-----------> createuser");
        const uniqueId = uuidv4();
        // const temp_cu_id = Math.floor(Math.random()*this.roundArguments.userNumMax);
        const user_cu_id = "user"+`${this.workerIndex}_${uniqueId}`
        console.log(`-----------> Worker ${this.workerIndex}: create  user${this.workerIndex}_${uniqueId} `);
        const request = {
            contractId: this.roundArguments.contractId,
            contractFunction: 'CreateUser',
            invokerIdentity: 'Admin@org3.example.com',
            contractArguments: [user_cu_id, '0'],
            readOnly: false
        };
        const maxRetries  = 10;
        let attempt = 0;
        while (attempt < maxRetries) {
            try {
                // 提交事务
                await this.sutAdapter.sendRequests(request);
                console.log(`Worker ${this.workerIndex}: Transaction successful for ${user_cu_id}`);
                break;  // 如果成功提交，退出循环
            } catch (error) {
                if ((error.message && error.message.includes('MVCC_READ_CONFLICT')) || error.statusCode === 11) {
                    attempt++;
                    if (attempt < maxRetries) {
                        console.log(`事务提交失败，状态码 11 或 MVCC 冲突，重试第 ${attempt} 次`);
                    }
                } else {
                    console.log("其他错误：", error);
                    throw error;  // 其他错误直接抛出
                }
            }
        }
        if (attempt >= maxRetries) {
            console.error(`Worker ${this.workerIndex}: 最大重试次数已达，提交失败`);
        }

    }

    }
    
function createWorkloadModule() {
    return new CreateuserWorkload();
}
 
module.exports.createWorkloadModule = createWorkloadModule;