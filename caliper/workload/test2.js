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
            throw error;
        }
    }

    async submitTransaction() {
        const maxRetries = 5;  // 增加到5次重试
        let attempt = 0;
        
        while (attempt < maxRetries) {
            const uniqueId = uuidv4();
            const user_cu_id = "user"+`${this.workerIndex}_${uniqueId}`;
            console.log(`-----------> Worker ${this.workerIndex}: create user${this.workerIndex}_${uniqueId} (attempt ${attempt + 1}/${maxRetries})`);
            
            const request = {
                contractId: this.roundArguments.contractId,
                contractFunction: 'CreateUser',
                invokerIdentity: 'Admin@org1.example.com',
                contractArguments: [user_cu_id, '0'],
                readOnly: false
            };

            try {
                await this.sutAdapter.sendRequests(request);
                console.log(`Worker ${this.workerIndex}: Transaction successful for ${user_cu_id}`);
                return;  // 成功时直接返回
            } catch (error) {
                console.error(`Worker ${this.workerIndex}: Transaction failed for ${user_cu_id}:`, error);
                
                if (error.toString().includes('status code: 11') && attempt < maxRetries - 1) {
                    attempt++;
                    // 使用指数退避策略计算延迟时间
                    const baseDelay = 1000; // 基础延迟1秒
                    const maxDelay = 5000;  // 最大延迟5秒
                    const exponentialDelay = Math.min(baseDelay * Math.pow(2, attempt), maxDelay);
                    // 添加随机抖动，避免多个事务同时重试
                    const jitter = Math.random() * 1000;
                    const delay = exponentialDelay + jitter;
                    
                    console.log(`Worker ${this.workerIndex}: Retry ${attempt}/${maxRetries} after ${delay}ms...`);
                    await new Promise(resolve => setTimeout(resolve, delay));
                    continue;
                }
                
                throw error;  // 如果不是 MVCC 错误或已达到最大重试次数，则抛出错误
            }
        }
    }
}

function createWorkloadModule() {
    return new MyWorkload();
}
 
module.exports.createWorkloadModule = createWorkloadModule;