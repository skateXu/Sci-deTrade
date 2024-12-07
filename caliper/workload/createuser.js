'use strict';
 
const { WorkloadModuleBase } = require('@hyperledger/caliper-core');
const { v4: uuidv4 } = require('uuid');
 
class CreateuserWorkload extends WorkloadModuleBase {
    constructor() {
        super();
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

    }

    }
    
function createWorkloadModule() {
    return new CreateuserWorkload();
}
 
module.exports.createWorkloadModule = createWorkloadModule;