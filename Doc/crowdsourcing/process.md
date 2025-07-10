# 众包流程

受限于vscode不同主题，显示效果可能不佳，点击[链接](https://www.mermaidchart.com/app/projects/5e8632b4-73f3-401b-80e1-012df7f3d7ec/diagrams/5dac0322-a367-49c2-a0bd-18e6eab0861f/share/invite/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkb2N1bWVudElEIjoiNWRhYzAzMjItYTM2Ny00OWMyLWEwYmQtMThlNmVhYjA4NjFmIiwiYWNjZXNzIjoiQ29tbWVudCIsImlhdCI6MTc1MjEwOTU3NX0.9EKv4STkcCgQvSp4g3PlLuu8tgZ0176ufeJNgokUkDM)查看web版

以下为mermaid 源码：
```mermaid

sequenceDiagram

    %% 启用编号
    autonumber

    %% 参与者别名
    actor R as 机构 Requester
    participant FMC as 资金管理合约 FMC
    participant TMC as 任务管理合约 TMC
    actor V as 子链验证者 Validator
    participant VC as 验证合约 VC

    actor W as 收集者 Worker
    participant IPFS as 子链分布式存储系统 IPFS

    rect rgb(152, 161, 188)
    note over R,TMC: 主链交互

    %% FMC资金管理合约
    R ->>FMC: 部署资金管理合约到主链，转入资金
    note over R,FMC: 转入资金作为FMC的自由资金余额FB

    %% TMC 任务管理合约
    R ->>TMC: 部署任务管理合约，规定任务参数
    note over R,TMC: 包括数据约束参数D、每个周期所需数据量n,周期性预算资金B 加密参数pk，$$pk = s \cdot G$$
    alt $$FB \gt B$$
    FMC->>TMC: FMC自由余额大于周期性预算,激活任务 <br>从FB中转移预算B到锁定资金余额LB
    end
    note over FMC, TMC: 一个FMC可管理多个TMC。<br>由FMC根据FB数额自动决定是否激活任务。
    end

    rect rgb(112, 138, 88)
    note over V,IPFS: 子链交互
    note over V,VC: 执行zk-SNARK setup得到pk,vk。<br> 基于vk实现验证合约中的零知识证明验证模块
    V ->>VC: 部署验证合约到子链


    loop 收集者执行任务
    W->> IPFS: 提交数据密文$$C_i$$
    activate IPFS
    IPFS ->> W: 返回密文存储索引: $$I_{C_i}$$
    deactivate IPFS
    note over IPFS,V: 加密过程: $$r\gets \{0,1\}^{\lambda}, sk = r \cdot G, ssk = r \cdot pk = r \cdot s \cdot G, k \gets \mathcal{H}(ssk,addr_{W},addr_{TMC}),\ \ C_i = Enc(k,d_i)$$ 

    W->>VC: 提交数据密文摘要、密文存储索引和对应零知识证明$$h_{C_i},I_{C_i},\pi_i$$
    note over W,VC: $$\pi_i = ZKP\bigg\{H(d_i)=h_{d_i}, d_i \models D\bigg\}$$
    end
    end

    rect rgb(152, 161, 188)
    note over FMC,W: 主链交互
    V->>TMC: 提交聚合proof和列表,列表包含：<br>密文数据摘要、密文索引列表、子链验证者主链地址和收集者主链地址
    note over V,TMC: $$\pi_{agg},\{h_{C_i}, I_{C_i}, addr_{V}, addr_{W} \}_{i=1}^{n}$$
    activate TMC
    TMC->>FMC: 验证通过，提交账单
    deactivate TMC
    activate FMC
    FMC->>V: 支付报酬
    FMC->>W: 支付报酬
    deactivate FMC
    end

```
