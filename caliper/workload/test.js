'use strict';
 
const { WorkloadModuleBase } = require('@hyperledger/caliper-core');
const { v4: uuidv4 } = require('uuid');
 
class MyWorkload extends WorkloadModuleBase {
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
        const HandleorderId = Math.floor(Math.random()*this.roundArguments.orderNum+1);
        console.log(`-----------> Worker ${this.workerIndex}: HandleOrder:order${HandleorderId}`);
        const handleOrderRequest = {
            contractId: this.roundArguments.contractId,
            contractFunction: 'HandleOrder',
            invokerIdentity: 'Admin@org1.example.com',
            contractArguments: [`order${HandleorderId}`, '1', 'hash'],
            readOnly: false
        };
        try {
            await this.sutAdapter.sendRequests(handleOrderRequest);
        } catch (error) {
            console.error("HandleOrder出错:", error);
        }


    }

    async submitTransaction() {
        //createuser
        const uniqueId = uuidv4();
        // const temp_cu_id = Math.floor(Math.random()*this.roundArguments.userNumMax);
        const user_cu_id = "user"+`${this.workerIndex}_${uniqueId}`
        console.log(`-----------> Worker ${this.workerIndex}: create  user${this.workerIndex}_${uniqueId} `);
        const request = {
            contractId: this.roundArguments.contractId,
            contractFunction: 'CreateUser',
            invokerIdentity: 'Admin@org1.example.com',
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

        //CreateDataset （不需要id）
        // const temp_cd_id = Math.floor(Math.random()*this.roundArguments.userNum);
        // const user_cd_id = "user"+`${this.workerIndex}_${temp_cd_id}`
        // console.log(`-----------> Worker ${this.workerIndex}: createdataset by user${this.workerIndex}_${temp_cd_id} `);
    
        // const tags = ["1", "2", "3"];
        // const tagsJson = JSON.stringify(tags);
        // const createDatasetRequest = {
        //     contractId: this.roundArguments.contractId,
        //     contractFunction: 'CreateDataset',
        //     invokerIdentity: 'Admin@org1.example.com',
        //     contractArguments: ['title', 'description', 'hash', 'ipfsAddress', '1', user_cd_id, '1', tagsJson],
        //     readOnly: false
        // };

        // try {
        //     await this.sutAdapter.sendRequests(createDatasetRequest);
        // } catch (error) {
        //     if (error.message.includes('MVCC_READ_CONFLICT') && attempt < maxRetries - 1) {
        //         attempt++;
        //         console.log(`冲突发生，重试第 ${attempt} 次`);
        //     } else {
        //         throw error;  // 其他错误直接抛出
        //     }
        // }
 
         //CreateOrder （不需要id）  
        //  const temp_co_id = Math.floor(Math.random()*this.roundArguments.userNum);
        //  const user_co_id = "user"+`${this.workerIndex}_${temp_co_id}`
        //  //dataset计数方式
        //  const temp_co_id2 = Math.floor(Math.random()*this.roundArguments.dataNum)+1;
        //  const data_co_id = "dataset"+`${temp_co_id2}`

        //  console.log(`-----------> Worker ${this.workerIndex}: createorder;user: user${this.workerIndex}_${temp_co_id};data: dataset${temp_co_id2}`);

         
        //  const createOrderRequest = {
        //      contractId: this.roundArguments.contractId,
        //      contractFunction: 'CreateOrder',
        //      invokerIdentity: 'Admin@org1.example.com',
        //      contractArguments: [user_co_id, data_co_id, 'hash'],
        //      readOnly: false
        //  };
        //  try {
        //      await this.sutAdapter.sendRequests(createOrderRequest);
        //  } catch (error) {
        //      console.error("createorder出错:", error);
        //  }
        
        // //GetUser 0_0
        // const GetuserId = Math.floor(Math.random()*this.roundArguments.userNum);
        // console.log(`-----------> Worker ${this.workerIndex}: GetUser:user${this.workerIndex}_${GetuserId}`);
        // const GetUserRequest = {
        //     contractId: this.roundArguments.contractId,
        //     contractFunction: 'GetUser',
        //     invokerIdentity: 'Admin@org1.example.com',
        //     contractArguments: ["user"+`${this.workerIndex}_${GetuserId}`],
        //     readOnly: true
        // };

        // try {
        //     await this.sutAdapter.sendRequests(GetUserRequest);
        // } catch (error) {
        //     console.error("GetUser出错:", error);
        // }

        //Mint +value
        // const mintId = Math.floor(Math.random()*this.roundArguments.userNum);
        // const value = Math.floor(Math.random()*100);
        // console.log(`-----------> Worker ${this.workerIndex}: Mint:user${this.workerIndex}_${GetuserId};value:${value}`);
        // const mintRequest = {
        //     contractId: this.roundArguments.contractId,
        //     contractFunction: 'Mint',
        //     invokerIdentity: 'Admin@org1.example.com',
        //     contractArguments: ["user"+`${this.workerIndex}_${mintId}`, `${value}`],
        //     readOnly: false
        // };
        // try {
        //     await this.sutAdapter.sendRequests(mintRequest);
        // } catch (error) {
        //     console.error("Mint出错:", error);
        // }

      
        
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
    

    
    // async cleanupWorkloadModule() {
    //     for (let i=0; i<this.roundArguments.assets; i++) {
    //         const assetID = `${this.workerIndex}_${i}`;
    //         console.log(`Worker ${this.workerIndex}: Deleting asset ${assetID}`);
    //         const request = {
    //             contractId: this.roundArguments.contractId,
    //             contractFunction: 'DeleteAsset',
    //             invokerIdentity: 'Admin@org1.example.com',
    //             contractArguments: [assetID],
    //             readOnly: false
    //         };
 
    //         await this.sutAdapter.sendRequests(request);
    //     }
    // }
 
function createWorkloadModule() {
    return new MyWorkload();
}
 
module.exports.createWorkloadModule = createWorkloadModule;