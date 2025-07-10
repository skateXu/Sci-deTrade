
# 数据交易流程

受限于vscode不同主题，显示效果可能不佳，点击[链接](https://www.mermaidchart.com/app/projects/5e8632b4-73f3-401b-80e1-012df7f3d7ec/diagrams/fcd56e10-d50f-4c59-8873-700254ddfb9c/share/invite/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkb2N1bWVudElEIjoiZmNkNTZlMTAtZDUwZi00YzU5LTg4NzMtNzAwMjU0ZGRmYjljIiwiYWNjZXNzIjoiQ29tbWVudCIsImlhdCI6MTc1MjEwOTU5OX0.YmYnWkp6hp1Yrax3-AV2idBE3jrWzaDDvEe-m01ytWM)查看web版

```mermaid

sequenceDiagram

    actor DO as 机构
    participant DC as 数据管理合约
    participant VC as 验证合约
    actor DR as 数据请求者

    
    DO->> DC: 部署数据管理合约，上传数据摘要
    
    rect rgb(112, 138, 88)
    note over DR,DO: 链下交互
    DR<<->>DO: 发送数据请求，包括检索条件F,脱敏规则M,数据单价p等参数
    end


    DR->>VC: 部署验证合约，锁定资金并提交哈希链$$h^n$$ <br> 执行zk-SNARK setup, 上传pk

    DO->>VC: 锁定押金

    
    DO->> DO: 根据检索条件F筛选出所需数据集DS<br> 将脱敏规则作用于D得到MDS <br>将MDS切分成多个子集 <br>为每个子集生成零知识证明 $$\pi$$

    rect rgb(112, 138, 88)
    note over DO,DR: 链下交互
    loop 链下数据交付循环，第$$i$$轮
    DR->>+DO: 支付凭证有效性证明，即$$\pi_{pc_i} = ZKP\{H(h^{n-i-1}) = h^{n-i}\}$$
    DO->>DR: 验证支付凭证有效性证明，若有效，发送数据完整性和有效性证明$$\pi_{MDS_i}$$
    DR->> DO: 验证脱敏数据子集MDSi的完整性和有效性，若有效，对zk-SNARK proof的签名 $$\sigma = Sign(sk,\pi_{MDS_i})$$
    DO->>DR: 验证签名有效性，若有效，发送脱敏数据子集$$MDS_i$$
    DR->>DO: 验证脱敏数据子集内容是否与zk-SNARK proof对应，若一切正常，发送支付凭证$$h^{n-i-1}$$
    end
    end

```