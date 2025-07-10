# 平台开发相关


## 核心模块


- [x] 基于gnark/circom+snarkjs的zk-SNARK proof生成和验证
- [x] hyperledger fabric 平台上golang 的chaincode 和 app实现链上链下基础交互
- [x] 前端按钮触发调用合约的app接口
- [ ] chaincode验证zk-SNARK proof
- [ ] Hyperledger fabric 链码间相互调用


## 开发规划

一些思考：
+ gnark虽然速度更快，但是其与前端语言js脚本并不适配，如需在前端浏览器中执行zk-snark proof的生成和验证，还需要将特定的golang 代码打包到wasm中去，可能比较复杂。但是gnark支持proof递归证明，

+ circom+snarkjs的开发路线目前更受欢迎，circom所支持的相关library也更多，但是其暂时好像并不支持递归。

目前准备先基于golang来写chaincode、application的zk-snark proof生成和验证，基本流程走通之后，确定需要将那些内容打包到wasm中，这部分涉及到前端所需内容，我目前对前端代码还不够熟悉。

只要解决这一步，剩下的就是基于chaincode和application的增删改查了。这部分基本就是体力活，用claude帮助可以慢慢实现。