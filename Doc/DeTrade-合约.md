以下是您的智能合约API接口文档的Markdown版本，并已翻译为中文：

# Chaincode API Documentation
## 智能合约API

### 1. 初始化账本

- **InitLedger**(ctx contractapi.TransactionContextInterface) error
  - **描述**：使用默认数据集、订单列表和合约用户初始化账本。此函数只能由管理员调用。
  - **参数**：
    - ctx: 事务上下文接口。
  - **返回值**：
    - error: 如果初始化失败，则返回错误。


### 2. 创建数据集

- **CreateDataset**(ctx contractapi.TransactionContextInterface, description string, hash string, ipfsAddress string, n_subset int, owner string, price int, tags []string) error
  - **描述**：创建一个新的数据集，并更新数据集列表和用户的数据集记录。
  - **参数**：
    - ctx: 事务上下文接口。
    - description: 数据集的描述。
    - hash: 用于验证数据集的哈希值。
    - ipfsAddress: 数据集的IPFS地址。
    - n_subset: 数据集中的子集数量。
    - owner: 数据集所有者的ID。
    - price: 数据集的价格。
    - tags: 与数据集关联的标签。
  - **返回值**：
    - error: 如果创建失败，则返回错误。


### 3. 创建订单

- **CreateOrder**(ctx contractapi.TransactionContextInterface, buyer string, datasetID string, payHash string) error
  - **描述**：创建一个新的订单，将其添加到订单列表，并更新用户订单记录。
  - **参数**：
    - ctx: 事务上下文接口。
    - buyer: 买家的ID。
    - datasetID: 数据集的ID。
    - payHash: 支付哈希值。
  - **返回值**：
    - error: 如果创建失败，则返回错误。


### 4. 创建用户

- **CreateUser**(ctx contractapi.TransactionContextInterface, uID string, value int) error
  - **描述**：创建一个新用户并将其添加到用户列表。
  - **参数**：
    - ctx: 事务上下文接口。
    - uID: 用户ID。
    - value: 初始值（例如，余额）。
  - **返回值**：
    - error: 如果创建失败，则返回错误。


### 5. 获取数据集

- **GetDataset**(ctx contractapi.TransactionContextInterface, datasetID string) (*Dataset, error)
  - **描述**：检索指定ID的数据集。
  - **参数**：
    - ctx: 事务上下文接口。
    - datasetID: 要检索的数据集的ID。
  - **返回值**：
    - *Dataset: 数据集对象。
    - error: 如果检索失败，则返回错误。


### 6. 获取订单

- **GetOrder**(ctx contractapi.TransactionContextInterface, orderID string) (*Order, error)
  - **描述**：检索指定ID的订单。
  - **参数**：
    - ctx: 事务上下文接口。
    - orderID: 要检索的订单的ID。
  - **返回值**：
    - *Order: 订单对象。
    - error: 如果检索失败，则返回错误。


### 7. 获取用户

- **GetUser**(ctx contractapi.TransactionContextInterface, uID string) (*User, error)
  - **描述**：检索指定ID的用户。
  - **参数**：
    - ctx: 事务上下文接口。
    - uID: 要检索的用户ID。
  - **返回值**：
    - *User: 用户对象。
    - error: 如果检索失败，则返回错误。


### 8. 获取数据集列表

- **GetDatasetList**(ctx contractapi.TransactionContextInterface) (*DatasetList, error)
  - **描述**：检索数据集列表。
  - **参数**：
    - ctx: 事务上下文接口。
  - **返回值**：
    - *DatasetList: 数据集列表对象。
    - error: 如果检索失败，则返回错误。


### 9. 获取订单列表

- **GetOrderList**(ctx contractapi.TransactionContextInterface) (*OrderList, error)
  - **描述**：检索订单列表。
  - **参数**：
    - ctx: 事务上下文接口。
  - **返回值**：
    - *OrderList: 订单列表对象。
    - error: 如果检索失败，则返回错误。


### 10. 处理订单

- **HandleOrder**(ctx contractapi.TransactionContextInterface, orderID string, n int, payword string) error
  - **描述**：处理指定的订单，根据其过期和支付哈希更新用户和合约的状态。
  - **参数**：
    - ctx: 事务上下文接口。
    - orderID: 要处理的订单的ID。
    - n: 要处理的子集数量。
    - payword: 支付确认词。
  - **返回值**：
    - error: 如果订单处理失败，则返回错误。


### 11. 铸造货币

- **Mint**(ctx contractapi.TransactionContextInterface, uID string, value int) error
  - **描述**：向用户的账户中铸造（增加）货币。此函数只能由银行调用。
  - **参数**：
    - ctx: 事务上下文接口。
    - uID: 要铸造货币的用户ID。
    - value: 要铸造的货币数量。
  - **返回值**：
    - error: 如果铸造失败，则返回错误。


### 12. 销毁货币

- **Burn**(ctx contractapi.TransactionContextInterface, uID string, value int) error
  - **描述**：从用户账户中销毁（移除）货币。此函数只能由银行调用。
  - **参数**：
    - ctx: 事务上下文接口。
    - uID: 要销毁货币的用户ID。
    - value: 要销毁的货币数量。
  - **返回值**：
    - error: 如果销毁失败，则返回错误。


## 内部函数
实现包括几个用于加法和减法的安全溢出检查的帮助函数：
- add(b int, q int) (int, error)
- sub(b int, q int) (int, error)
这些函数安全地处理数学运算，确保不会发生溢出。
