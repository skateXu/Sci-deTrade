# 众包数据收集系统 - Hyperledger Fabric 实现

## 项目概述

基于 Hyperledger Fabric 的去中心化众包数据收集系统，支持零知识证明验证和加密数据存储。

## 系统架构

```
├── chaincode/                 # 智能合约
│   ├── fmc/                  # 资金管理合约
│   ├── tmc/                  # 任务管理合约
│   └── vc/                   # 验证合约
├── app-gateway-go/           # 应用网关
│   ├── crypto/
│   │   ├── gnark/           # 零知识证明
│   │   └── enc/             # 加密模块
│   ├── fabric.go            # Fabric交互
│   └── main.go
└── network/                  # Fabric网络配置
```

## 开发接口规范

### 1. 智能合约接口

#### 1.1 资金管理合约 (FMC)

```go
// chaincode/fmc/fmc.go

type FMC struct {
    contractapi.Contract
}

// 资金状态结构
type FundState struct {
    Owner           string  `json:"owner"`
    FreeBalance     uint64  `json:"freeBalance"`     // FB - 自由资金余额
    LockedBalance   uint64  `json:"lockedBalance"`   // LB - 锁定资金余额
    TotalBalance    uint64  `json:"totalBalance"`
}

// 初始化资金管理合约
func (f *FMC) InitFMC(ctx contractapi.TransactionContextInterface, 
                      owner string, initialFund uint64) error

// 存入资金
func (f *FMC) DepositFund(ctx contractapi.TransactionContextInterface, 
                          amount uint64) error

// 锁定资金用于任务
func (f *FMC) LockFund(ctx contractapi.TransactionContextInterface, 
                       tmcAddress string, amount uint64) error

// 释放锁定资金
func (f *FMC) ReleaseFund(ctx contractapi.TransactionContextInterface, 
                          tmcAddress string, amount uint64) error

// 支付报酬
func (f *FMC) PayReward(ctx contractapi.TransactionContextInterface, 
                        recipient string, amount uint64) error

// 查询余额
func (f *FMC) GetBalance(ctx contractapi.TransactionContextInterface) (*FundState, error)

// 检查并激活任务
func (f *FMC) CheckAndActivateTask(ctx contractapi.TransactionContextInterface, 
                                   tmcAddress string, requiredBudget uint64) (bool, error)
```

#### 1.2 任务管理合约 (TMC)

```go
// chaincode/tmc/tmc.go

type TMC struct {
    contractapi.Contract
}

// 任务参数结构
type TaskParams struct {
    TaskID          string  `json:"taskId"`
    Requester       string  `json:"requester"`
    FMCAddress      string  `json:"fmcAddress"`
    DataConstraints string  `json:"dataConstraints"`    // D - 数据约束参数
    RequiredCount   uint32  `json:"requiredCount"`      // n - 每周期所需数据量
    PeriodBudget    uint64  `json:"periodBudget"`       // B - 周期性预算
    PublicKey       string  `json:"publicKey"`          // pk = s·G
    IsActive        bool    `json:"isActive"`
    CreatedAt       int64   `json:"createdAt"`
}

// 提交记录结构
type SubmissionRecord struct {
    Period          uint32                `json:"period"`
    Submissions     []DataSubmission      `json:"submissions"`
    AggregateProof  string               `json:"aggregateProof"`
    ValidatorAddr   string               `json:"validatorAddr"`
    Status          string               `json:"status"`
    SubmittedAt     int64                `json:"submittedAt"`
}

type DataSubmission struct {
    CipherHash      string  `json:"cipherHash"`      // h_Ci
    StorageIndex    string  `json:"storageIndex"`    // I_Ci
    WorkerAddr      string  `json:"workerAddr"`      // addr_W
    ValidatorAddr   string  `json:"validatorAddr"`   // addr_V
}

// 初始化任务
func (t *TMC) InitTask(ctx contractapi.TransactionContextInterface,
                       taskParams TaskParams) error

// 激活任务
func (t *TMC) ActivateTask(ctx contractapi.TransactionContextInterface,
                           taskID string) error

// 提交聚合证明和数据列表
func (t *TMC) SubmitAggregateProof(ctx contractapi.TransactionContextInterface,
                                   taskID string,
                                   period uint32,
                                   aggregateProof string,
                                   submissions []DataSubmission) error

// 验证并处理提交
func (t *TMC) ValidateAndProcess(ctx contractapi.TransactionContextInterface,
                                 taskID string, period uint32) error

// 查询任务信息
func (t *TMC) GetTask(ctx contractapi.TransactionContextInterface,
                      taskID string) (*TaskParams, error)

// 查询提交记录
func (t *TMC) GetSubmissionRecord(ctx contractapi.TransactionContextInterface,
                                  taskID string, period uint32) (*SubmissionRecord, error)
```

#### 1.3 验证合约 (VC)

```go
// chaincode/vc/vc.go

type VC struct {
    contractapi.Contract
}

// 验证密钥结构
type VerificationKey struct {
    TaskID    string `json:"taskId"`
    VK        string `json:"vk"`        // 验证密钥
    SetupAt   int64  `json:"setupAt"`
}

// 数据提交结构
type DataSubmission struct {
    SubmissionID    string `json:"submissionId"`
    TaskID          string `json:"taskId"`
    WorkerAddr      string `json:"workerAddr"`
    CipherHash      string `json:"cipherHash"`     // h_Ci
    StorageIndex    string `json:"storageIndex"`   // I_Ci
    Proof           string `json:"proof"`          // π_i
    IsVerified      bool   `json:"isVerified"`
    SubmittedAt     int64  `json:"submittedAt"`
}

// 设置验证密钥
func (v *VC) SetupVerificationKey(ctx contractapi.TransactionContextInterface,
                                  taskID string, vk string) error

// 提交数据和证明
func (v *VC) SubmitData(ctx contractapi.TransactionContextInterface,
                        submission DataSubmission) error

// 验证零知识证明
func (v *VC) VerifyProof(ctx contractapi.TransactionContextInterface,
                         submissionID string) (bool, error)

// 批量验证
func (v *VC) BatchVerify(ctx contractapi.TransactionContextInterface,
                         taskID string, submissionIDs []string) ([]bool, error)

// 查询提交数据
func (v *VC) GetSubmission(ctx contractapi.TransactionContextInterface,
                           submissionID string) (*DataSubmission, error)

// 获取任务的所有有效提交
func (v *VC) GetValidSubmissions(ctx contractapi.TransactionContextInterface,
                                 taskID string) ([]DataSubmission, error)
```

### 2. 应用网关接口

#### 2.1 零知识证明模块

```go
// app-gateway-go/crypto/gnark/circuits.go

package gnark

import (
    "github.com/consensys/gnark/frontend"
    "github.com/consensys/gnark/std/hash/sha256"
)

// 数据约束验证电路
type DataConstraintCircuit struct {
    // 公开输入
    DataHash        frontend.Variable `gnark:",public"`   // H(d_i)
    ConstraintHash  frontend.Variable `gnark:",public"`   // H(D)
    
    // 私有输入
    Data           frontend.Variable `gnark:",secret"`    // d_i
    Constraint     frontend.Variable `gnark:",secret"`    // D
}

// 定义约束
func (circuit *DataConstraintCircuit) Define(api frontend.API) error

// 范围证明电路
type RangeProofCircuit struct {
    // 公开输入
    Min, Max    frontend.Variable `gnark:",public"`
    
    // 私有输入
    Value       frontend.Variable `gnark:",secret"`
}

func (circuit *RangeProofCircuit) Define(api frontend.API) error

// 聚合验证电路
type AggregateCircuit struct {
    // 公开输入
    AggregateHash   frontend.Variable `gnark:",public"`
    Count          frontend.Variable `gnark:",public"`
    
    // 私有输入
    DataHashes     []frontend.Variable `gnark:",secret"`
}

func (circuit *AggregateCircuit) Define(api frontend.API) error

// 电路接口
type CircuitInterface interface {
    GenerateProof(data interface{}) ([]byte, error)
    VerifyProof(proof []byte, publicInputs []interface{}) (bool, error)
    Setup() error
    GetVerifyingKey() ([]byte, error)
}
```

```go
// app-gateway-go/crypto/gnark/generate.go

package gnark

import (
    "github.com/consensys/gnark-crypto/ecc"
    "github.com/consensys/gnark/backend/groth16"
    "github.com/consensys/gnark/frontend/cs/r1cs"
)

// 证明生成器
type ProofGenerator struct {
    circuit     frontend.Circuit
    pk          groth16.ProvingKey
    vk          groth16.VerifyingKey
    constraint  *r1cs.ConstraintSystem
}

// 初始化证明生成器
func NewProofGenerator(circuitType string) (*ProofGenerator, error)

// 执行可信设置
func (pg *ProofGenerator) Setup() error

// 生成证明
func (pg *ProofGenerator) GenerateProof(witness interface{}) (*ProofResult, error)

// 验证证明
func (pg *ProofGenerator) VerifyProof(proof *ProofResult) (bool, error)

// 获取验证密钥
func (pg *ProofGenerator) GetVerifyingKey() ([]byte, error)

// 证明结果结构
type ProofResult struct {
    Proof       []byte    `json:"proof"`
    PublicWitness []byte  `json:"publicWitness"`
    CircuitType string    `json:"circuitType"`
}

// 数据约束证明生成
func GenerateDataConstraintProof(data []byte, constraints []byte) (*ProofResult, error)

// 范围证明生成
func GenerateRangeProof(value, min, max int64) (*ProofResult, error)

// 聚合证明生成
func GenerateAggregateProof(dataHashes [][]byte) (*ProofResult, error)

// 批量验证
func BatchVerifyProofs(proofs []*ProofResult, vk []byte) ([]bool, error)
```

#### 2.2 加密模块

```go
// app-gateway-go/crypto/enc/enc.go

package enc

import (
    "crypto/elliptic"
    "crypto/rand"
    "math/big"
)

// ECDH密钥交换结构
type ECDHKeyPair struct {
    PrivateKey *big.Int
    PublicKey  *ECPoint
}

type ECPoint struct {
    X, Y *big.Int
}

// 加密参数
type EncryptionParams struct {
    TaskPublicKey   *ECPoint  `json:"taskPublicKey"`    // pk = s·G
    WorkerAddress   string    `json:"workerAddress"`    // addr_W
    TMCAddress      string    `json:"tmcAddress"`       // addr_TMC
}

// 加密结果
type EncryptionResult struct {
    Ciphertext      []byte    `json:"ciphertext"`       // C_i
    CipherHash      []byte    `json:"cipherHash"`       // h_Ci
    SharedSecret    *ECPoint  `json:"sharedSecret"`     // ssk
    EphemeralPubKey *ECPoint  `json:"ephemeralPubKey"`  // sk = r·G
}

// 生成临时密钥对
func GenerateEphemeralKeyPair() (*ECDHKeyPair, error)

// ECDH密钥交换
func ECDHKeyExchange(privateKey *big.Int, publicKey *ECPoint) (*ECPoint, error)

// 派生对称密钥
func DeriveSymmetricKey(sharedSecret *ECPoint, workerAddr, tmcAddr string) ([]byte, error)

// 加密数据
func EncryptData(data []byte, params *EncryptionParams) (*EncryptionResult, error)

// 解密数据 (仅供任务发布者使用)
func DecryptData(ciphertext []byte, taskPrivateKey *big.Int, 
                 ephemeralPubKey *ECPoint, workerAddr, tmcAddr string) ([]byte, error)

// 验证密文哈希
func VerifyCipherHash(ciphertext []byte, expectedHash []byte) bool

// 哈希函数
func HashData(data []byte) []byte

// 椭圆曲线点运算
func ScalarMult(k *big.Int, point *ECPoint) *ECPoint
func PointAdd(p1, p2 *ECPoint) *ECPoint

// 序列化/反序列化
func SerializePoint(point *ECPoint) []byte
func DeserializePoint(data []byte) (*ECPoint, error)
```

#### 2.3 Fabric交互模块

```go
// app-gateway-go/fabric.go

package main

import (
    "github.com/hyperledger/fabric-sdk-go/pkg/gateway"
    "github.com/hyperledger/fabric-sdk-go/pkg/core/config"
)

// Fabric客户端
type FabricClient struct {
    gateway     *gateway.Gateway
    network     *gateway.Network
    fmcContract *gateway.Contract
    tmcContract *gateway.Contract
    vcContract  *gateway.Contract
}

// 初始化Fabric连接
func NewFabricClient(configPath, walletPath, userID string) (*FabricClient, error)

// 关闭连接
func (fc *FabricClient) Close() error

// === FMC合约交互 ===

// 部署资金管理合约
func (fc *FabricClient) DeployFMC(owner string, initialFund uint64) error

// 存入资金
func (fc *FabricClient) DepositFund(amount uint64) error

// 查询余额
func (fc *FabricClient) GetBalance() (*FundState, error)

// 支付报酬
func (fc *FabricClient) PayReward(recipient string, amount uint64) error

// === TMC合约交互 ===

// 部署任务管理合约
func (fc *FabricClient) DeployTMC(taskParams TaskParams) error

```