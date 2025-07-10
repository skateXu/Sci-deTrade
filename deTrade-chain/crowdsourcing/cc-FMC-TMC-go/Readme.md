

## 项目概述

包含资金管理合约（FMC）和任务管理合约（TMC）

## 项目结构

```shell
cc-FMC-TMC-go/
├── fmc.go              # 资金管理合约
├── tmc.go              # 任务管理合约
├── fmc_test.go         # FMC 测试文件
├── tmc_test.go         # TMC 测试文件
├── go.mod              # Go 模块文件
└── README.md           # 本文档
```

## 核心数据结构

### FMC 相关结构体

```go
// 资金账户结构
type FundAccount struct {
    Owner           string  `json:"owner"`           // 账户所有者
    FreeBalance     uint64  `json:"freeBalance"`     // 自由资金余额 FB
    LockedBalance   uint64  `json:"lockedBalance"`   // 锁定资金余额 LB
    TotalDeposit    uint64  `json:"totalDeposit"`    // 总存款
    CreatedAt       int64   `json:"createdAt"`       // 创建时间
    UpdatedAt       int64   `json:"updatedAt"`       // 更新时间
}

// 支付记录结构
type PaymentRecord struct {
    PaymentID       string  `json:"paymentId"`       // 支付ID
    FromAccount     string  `json:"fromAccount"`     // 付款账户
    ToAccount       string  `json:"toAccount"`       // 收款账户
    Amount          uint64  `json:"amount"`          // 支付金额
    PaymentType     string  `json:"paymentType"`     // 支付类型（validator/worker）
    TaskID          string  `json:"taskId"`          // 关联任务ID
    Timestamp       int64   `json:"timestamp"`       // 支付时间
    Status          string  `json:"status"`          // 支付状态
}

// 任务激活记录
type TaskActivation struct {
    TaskID          string  `json:"taskId"`          // 任务ID
    RequesterID     string  `json:"requesterId"`     // 请求者ID
    BudgetAmount    uint64  `json:"budgetAmount"`    // 预算金额 B
    ActivatedAt     int64   `json:"activatedAt"`     // 激活时间
    Status          string  `json:"status"`          // 激活状态
}
```

### TMC 相关结构体

```go
// 任务配置结构
type TaskConfig struct {
    TaskID              string            `json:"taskId"`              // 任务ID
    RequesterID         string            `json:"requesterId"`         // 请求者ID
    DataConstraints     map[string]string `json:"dataConstraints"`     // 数据约束参数 D
    RequiredDataCount   int               `json:"requiredDataCount"`   // 每周期所需数据量 n
    CyclicBudget        uint64            `json:"cyclicBudget"`        // 周期性预算 B
    PublicKey           string            `json:"publicKey"`           // 加密公钥 pk
    ValidatorReward     uint64            `json:"validatorReward"`     // 验证者奖励
    WorkerReward        uint64            `json:"workerReward"`        // 收集者奖励
    CreatedAt           int64             `json:"createdAt"`           // 创建时间
    Status              string            `json:"status"`              // 任务状态
}

// 数据提交记录
type DataSubmission struct {
    SubmissionID        string   `json:"submissionId"`        // 提交ID
    TaskID              string   `json:"taskId"`              // 任务ID
    CipherTextHashes    []string `json:"cipherTextHashes"`    // 密文摘要列表 h_Ci
    StorageIndexes      []string `json:"storageIndexes"`      // 存储索引列表 I_Ci
    ValidatorAddress    string   `json:"validatorAddress"`    // 验证者地址
    WorkerAddresses     []string `json:"workerAddresses"`     // 收集者地址列表
    AggregateProof      string   `json:"aggregateProof"`      // 聚合证明 π_agg
    SubmittedAt         int64    `json:"submittedAt"`         // 提交时间
    VerificationStatus  string   `json:"verificationStatus"`  // 验证状态
    DataCount           int      `json:"dataCount"`           // 数据数量
}

// 任务周期管理
type TaskCycle struct {
    CycleID             string   `json:"cycleId"`             // 周期ID
    TaskID              string   `json:"taskId"`              // 任务ID
    CycleNumber         int      `json:"cycleNumber"`         // 周期编号
    StartTime           int64    `json:"startTime"`           // 开始时间
    EndTime             int64    `json:"endTime"`             // 结束时间
    RequiredDataCount   int      `json:"requiredDataCount"`   // 需要数据量
    SubmittedDataCount  int      `json:"submittedDataCount"`  // 已提交数据量
    Status              string   `json:"status"`              // 周期状态
    CompletedAt         int64    `json:"completedAt"`         // 完成时间
}

// 验证结果
type VerificationResult struct {
    SubmissionID        string   `json:"submissionId"`        // 提交ID
    TaskID              string   `json:"taskId"`              // 任务ID
    IsValid             bool     `json:"isValid"`             // 验证结果
    ValidDataCount      int      `json:"validDataCount"`      // 有效数据数量
    TotalReward         uint64   `json:"totalReward"`         // 总奖励
    ValidatorReward     uint64   `json:"validatorReward"`     // 验证者奖励
    WorkerRewards       []uint64 `json:"workerRewards"`       // 收集者奖励列表
    VerifiedAt          int64    `json:"verifiedAt"`          // 验证时间
    ErrorMessage        string   `json:"errorMessage"`        // 错误信息
}
```

## FMC 合约接口

### 资金管理接口

```go
// 初始化资金账户
func (fmc *FMC) InitAccount(ctx contractapi.TransactionContextInterface, 
    owner string, initialDeposit uint64) error

// 存入资金
func (fmc *FMC) Deposit(ctx contractapi.TransactionContextInterface, 
    owner string, amount uint64) error

// 提取资金
func (fmc *FMC) Withdraw(ctx contractapi.TransactionContextInterface, 
    owner string, amount uint64) error

// 锁定资金（用于任务预算）
func (fmc *FMC) LockFunds(ctx contractapi.TransactionContextInterface, 
    owner string, taskID string, amount uint64) error

// 释放锁定资金
func (fmc *FMC) ReleaseFunds(ctx contractapi.TransactionContextInterface, 
    owner string, taskID string, amount uint64) error
```

### 支付接口

```go
// 支付验证者奖励
func (fmc *FMC) PayValidator(ctx contractapi.TransactionContextInterface, 
    payerID string, validatorID string, taskID string, amount uint64) error

// 支付收集者奖励
func (fmc *FMC) PayWorker(ctx contractapi.TransactionContextInterface, 
    payerID string, workerID string, taskID string, amount uint64) error

// 批量支付收集者
func (fmc *FMC) BatchPayWorkers(ctx contractapi.TransactionContextInterface, 
    payerID string, workerIDs []string, taskID string, amounts []uint64) error
```

### 任务激活接口

```go
// 检查并激活任务
func (fmc *FMC) CheckAndActivateTask(ctx contractapi.TransactionContextInterface, 
    requesterID string, taskID string, budgetAmount uint64) error

// 停用任务
func (fmc *FMC) DeactivateTask(ctx contractapi.TransactionContextInterface, 
    requesterID string, taskID string) error
```

### 查询接口

```go
// 查询账户信息
func (fmc *FMC) GetAccount(ctx contractapi.TransactionContextInterface, 
    owner string) (*FundAccount, error)

// 查询支付记录
func (fmc *FMC) GetPaymentRecord(ctx contractapi.TransactionContextInterface, 
    paymentID string) (*PaymentRecord, error)

// 查询任务激活状态
func (fmc *FMC) GetTaskActivation(ctx contractapi.TransactionContextInterface, 
    taskID string) (*TaskActivation, error)

// 查询账户支付历史
func (fmc *FMC) GetPaymentHistory(ctx contractapi.TransactionContextInterface, 
    accountID string, limit int) ([]*PaymentRecord, error)
```

## TMC 合约接口

### 任务管理接口

```go
// 创建任务配置
func (tmc *TMC) CreateTask(ctx contractapi.TransactionContextInterface, 
    taskID string, requesterID string, dataConstraints map[string]string, 
    requiredDataCount int, cyclicBudget uint64, publicKey string, 
    validatorReward uint64, workerReward uint64) error

// 更新任务配置
func (tmc *TMC) UpdateTask(ctx contractapi.TransactionContextInterface, 
    taskID string, requesterID string, updates map[string]interface{}) error

// 暂停任务
func (tmc *TMC) PauseTask(ctx contractapi.TransactionContextInterface, 
    taskID string, requesterID string) error

// 恢复任务
func (tmc *TMC) ResumeTask(ctx contractapi.TransactionContextInterface, 
    taskID string, requesterID string) error
```

### 数据提交验证接口

```go
// 提交聚合数据和证明
func (tmc *TMC) SubmitAggregateData(ctx contractapi.TransactionContextInterface, 
    taskID string, cipherTextHashes []string, storageIndexes []string, 
    validatorAddress string, workerAddresses []string, aggregateProof string) error

// 验证聚合证明
func (tmc *TMC) VerifyAggregateProof(ctx contractapi.TransactionContextInterface, 
    submissionID string) (*VerificationResult, error)

// 处理验证结果
func (tmc *TMC) ProcessVerificationResult(ctx contractapi.TransactionContextInterface, 
    submissionID string, isValid bool, validDataCount int) error
```

### 周期管理接口

```go
// 开始新周期
func (tmc *TMC) StartNewCycle(ctx contractapi.TransactionContextInterface, 
    taskID string) error

// 完成当前周期
func (tmc *TMC) CompleteCycle(ctx contractapi.TransactionContextInterface, 
    taskID string, cycleID string) error

// 获取当前周期
func (tmc *TMC) GetCurrentCycle(ctx contractapi.TransactionContextInterface, 
    taskID string) (*TaskCycle, error)
```

### 查询接口

```go
// 查询任务配置
func (tmc *TMC) GetTask(ctx contractapi.TransactionContextInterface, 
    taskID string) (*TaskConfig, error)

// 查询数据提交记录
func (tmc *TMC) GetDataSubmission(ctx contractapi.TransactionContextInterface, 
    submissionID string) (*DataSubmission, error)

// 查询任务周期历史
func (tmc *TMC) GetTaskCycles(ctx contractapi.TransactionContextInterface, 
    taskID string, limit int) ([]*TaskCycle, error)

// 查询验证结果
func (tmc *TMC) GetVerificationResult(ctx contractapi.TransactionContextInterface, 
    submissionID string) (*VerificationResult, error)

// 查询任务统计信息
func (tmc *TMC) GetTaskStatistics(ctx contractapi.TransactionContextInterface, 
    taskID string) (map[string]interface{}, error)
```

## 事件定义

### FMC 事件

```go
// 账户创建事件
type AccountCreatedEvent struct {
    Owner           string `json:"owner"`
    InitialDeposit  uint64 `json:"initialDeposit"`
    Timestamp       int64  `json:"timestamp"`
}

// 资金存入事件
type FundsDepositedEvent struct {
    Owner       string `json:"owner"`
    Amount      uint64 `json:"amount"`
    NewBalance  uint64 `json:"newBalance"`
    Timestamp   int64  `json:"timestamp"`
}

// 支付完成事件
type PaymentCompletedEvent struct {
    PaymentID   string `json:"paymentId"`
    From        string `json:"from"`
    To          string `json:"to"`
    Amount      uint64 `json:"amount"`
    PaymentType string `json:"paymentType"`
    TaskID      string `json:"taskId"`
    Timestamp   int64  `json:"timestamp"`
}

// 任务激活事件
type TaskActivatedEvent struct {
    TaskID      string `json:"taskId"`
    RequesterID string `json:"requesterId"`
    Budget      uint64 `json:"budget"`
    Timestamp   int64  `json:"timestamp"`
}
```

### TMC 事件

```go
// 任务创建事件
type TaskCreatedEvent struct {
    TaskID              string `json:"taskId"`
    RequesterID         string `json:"requesterId"`
    RequiredDataCount   int    `json:"requiredDataCount"`
    CyclicBudget        uint64 `json:"cyclicBudget"`
    Timestamp           int64  `json:"timestamp"`
}

// 数据提交事件
type DataSubmittedEvent struct {
    SubmissionID     string   `json:"submissionId"`
    TaskID           string   `json:"taskId"`
    ValidatorAddress string   `json:"validatorAddress"`
    WorkerCount      int      `json:"workerCount"`
    DataCount        int      `json:"dataCount"`
    Timestamp        int64    `json:"timestamp"`
}

// 验证完成事件
type VerificationCompletedEvent struct {
    SubmissionID    string `json:"submissionId"`
    TaskID          string `json:"taskId"`
    IsValid         bool   `json:"isValid"`
    ValidDataCount  int    `json:"validDataCount"`
    TotalReward     uint64 `json:"totalReward"`
    Timestamp       int64  `json:"timestamp"`
}

// 周期完成事件
type CycleCompletedEvent struct {
    CycleID            string `json:"cycleId"`
    TaskID             string `json:"taskId"`
    CycleNumber        int    `json:"cycleNumber"`
    SubmittedDataCount int    `json:"submittedDataCount"`
    Timestamp          int64  `json:"timestamp"`
}
```