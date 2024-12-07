# DeTrade-大数据交易平台概要设计文档

## 摘要

针对目前中心化数据交易平台所面临的**数据检索结果不透明、缺乏可信仲裁机制、个人隐私信息易泄露**等问题，本项目创新性地引入了区块链和智能合约技术，分别设计了**身份管理模块、数据检索模块、数据交付模块**，实现了**点对点、可审计可验证**的全流程数据交易。

此外，由于区块链的引入带来了新的隐私风险和性能瓶颈，我们分别对各个模块进行了优化设计。在身份管理模块中，我们基于DID实现匿名和抗链接的身份管理方案。在数据检索模块中，我们设计实现了平衡效率与安全需求的分级信息检索方式。在数据交易模块中，我们通过设计渐进式数据交易方案，以及数据集脱敏验证方案实现了隐私保护下的数据质量评估和安全可信的数据交易流程。最后，针对区块链性能优化部分，我们从底层区块链角度提出优化设计，通过构建多子链并行的网络架构方案，提高了区块链性能水平。

基于以上模块设计和优化方案，我们实现了数据的安全交易和可信仲裁，提供了面向**隐私保护**和**数据质量评估**的区块链大数据交易示范平台。

## 第一章 平台概述

### 1.1 背景介绍

#### 1.1.1 数据交易市场

**数字经济已经成为国民经济的重要引擎，数据的交易流通有助于赋能实体经济，释放数据价值**。随着信息技术的发展，我国数字化转型不断深入，自党的十八大以来，党中央高度重视发展数字经济，并将其上升至国家战略。据中国信息通讯研究院发布的《中国数字经济发展研究报告》[1]显示，我国数字经济总体规模从2005年的2.62万亿元增长至2023年的53.9万亿元，数字经济总体规模占GDP比重也由2005年的14.2%提升至2023年的42.8%。可以看出，数字经济正在与实体经济进行深度融合，而数据作为数字经济下新型的生产要素，是数字化、网络化、智能化的基础[2]，已经逐渐演变为国家基础性战略资源，并日益对全球的生产、流通、分配、消费活动以及经济运行机制、社会生活方式等产生重要影响。在不同实体间，数据的交易流通能够有效进行资源整合，赋能实体经济，释放数据价值。


**大数据时代下，数据资源的价值逐步得到重视，数据交易需求也在不断增加**。大数据是以容量大、类型多、存取速度快、应用价值高为主要特征的数据集合，全球范围内，运用大数据推动经济发展、完善社会治理、提升政府服务和监管能力正成为趋势。人工智能等技术的出现也使得数据资源的价值得到进一步体现。目前，我国互联网、移动互联网用户规模居全球第一，拥有丰富的数据资源和应用市场优势，在数据交易市场上占有较大规模。2023全球数商大会上发布的《2023年中国数据交易市场研究分析报告》[3]指出，2022年，中国数据交易市场规模达876.8亿元(人民币)，在全球的占比为13.4%，在亚洲的占比为66.5%。我国的数据交易行业在近年进入了快速增长的发展阶段，并预计在未来仍能保持较高速的增长。

**规范大数据交易市场，建立健全数据资源交易机制势在必行**。在数据交易过程中，由于数据作为交易商品具有易复制性、难以追溯等特征，容易面临交易过程不规范、难以仲裁、隐私泄露等风险。2015年《促进大数据发展行动纲要》[4]明确指出要“引导培育大数据交易市场，开展面向应用的数据交易市场试点，探索开展大数据衍生产品交易，鼓励产业链各环节市场主体进行数据交换和交易，促进数据资源流通，建立健全数据资源交易机制和定价机制，规范交易行为。”基于此，结合有效技术手段设计和规范数据交易机制，实现数据流转全流程的公正可信，是当前数据交易行业亟待解决的挑战。


> [1].《中国数字经济发展研究报告》http://www.caict.ac.cn/kxyj/qwfb/bps/202408/P020240830315324580655.pdf
> [2].中共中央 国务院. 关于构建数据基础制度更
> 好发挥数据要素作用的意见[Z]. 2022.
> The CPC Central Committee and the State
> Council. Opinions on the construction of
> data fundamental institutions for better
> promoting the data factor value[Z]. 2022.
>
> [3]. https://www.chinanews.com.cn/cj/2023/11-26/10118324.shtml
>
> [4].  https://www.gov.cn/zhengce/content/2015-09/05/content_10137.htm



#### 1.1.2 中心化数据交易模式

中心化数据交易模式一般基于传统的数据交易中心完成交易，由第三方平台提供信任保障，管理数据的上传、存储、交易等行为。数据售卖方和购买方需要分别通过平台进行数据的上传和下载，并且支付给平台额外的手续费用。

<img src="assets/center-trade.png" alt="sys" style="zoom:50%;" />

这种中心化的交易模式由于统一进行了资源整合管理，更够更好的对接市场需求，提供方便快捷的用户接口，并且支持高吞吐量和大规模并发的数据交易场景。然而，其不可避免地面临着以下的痛点问题：

**身份管理和隐私泄露问题**：用户的身份和权限完全受到交易中心控制，容易面临单点故障问题，丢失身份或者篡改权限。同时，中心化的数据交易平台可以获取用户检索和下载数据的所有信息，进而可以推测用户的个人偏好，甚至是身份隐私内容。

**纠纷仲裁问题**：数据商品相较于普通商品而言具有特殊性：一方面数据购买者可以抵赖已经收到的数据，或者恶意声称数据不符合期望，从而拒绝支付费用；另一方面，数据购买者确实需要获得数据后才能检查其是否符合期望质量，此时数据购买者已经获得了数据的副本，即使发现数据质量不符合期望，也可能因为数据售卖者的拒绝而无法和普通商品一样进行正常的售后退回流程。所以数据商品按照传统商品的售卖和售后流程进行处理将不再合适。而面对可能的纠纷，中心化数据交易模式仅仅依靠平台的公信力对纠纷进行仲裁，缺少可信的审计和仲裁机制。

**数据检索问题**：由于数据检索由交易中心完成，容易隐藏、篡改、伪造检索结果，数据购买者无法确认数据检索结果的可靠性。例如，数据交易平台可能会根据不同数据提供者所提交的“广告费”进行检索结果的优先排序，数据购买者可能无法快速检索到实际需要的数据，而是下载了优先推荐的数据，并发现数据质量与预期不符合，而由于数据商品的特殊性，其在售出后难以退款，这将导致错误检索并购买的数据致使用户损失的利益难以追回。与此同时，数据售卖者可能会恶意提交不符合实际内容的标题或者检索关键字，和数据交易平台恶意共谋以谋取更多利益，从而使得这些虚假数据条目不被审计，或者数目众多难以审计，数据购买者的利益受到侵犯。

**数据权属问题**：由于在中心化的数据交易模式中，数据必然会泄露给交易中心，数据的售卖者和购买者无法进行完整的点对点交易。并且由于数据的非排他性，交易中心可以隐藏数据的售出记录，或者篡改数据集的售卖限制范围，而数据售卖者将不会察觉平台的恶意行为。

#### 1.1.3 去中心化数据交易模式

面对以上痛点，本平台考虑引入区块链，利用区块链去中心化、不可篡改等特性，并结合智能合约的逻辑透明、自动执行特点，构建去中心化的数据交易平台。

<p align="center">
<img src="assets/de-trade.png" alt="sys" style="zoom:50%;" />
</p>

具体而言，我们分别设计了以下模块：

**身份管理模块**：自我主权的去中心化身份DID可以使用户掌握自己的身份信息，从而保护用户个人的隐私。我们在平台上实现了基于DID的身份管理模块，从而避免了用户身份权限受到第三方控制导致的易丢失身份或篡改权限等问题。同时，由于个人信息被保护，用户的个人偏好也不会暴露。

**数据检索模块**：基于区块链的数据交易平台会将数据检索信息透明公开的保存在区块链上，所有人都可以自主查询相应的数据信息，从而保证检索结果的可信和不可篡改。数据购买方也可以直接通过检索信息中的相关信息和数据售卖方取得联系并进行数据交易，不需要第三方的中介行为或者额外的手续费用，从而可以实现公开可验证的数据检索。

**交易和仲裁模块**：借助区块链和智能合约规范数据交易流程，并通过将关键步骤上链的方式对数据交易过程进行存证，借助区块链的透明和不可篡改特性，每一笔数据交易都可以在区块链上进行追溯，并通过区块链提供的存证信息进行仲裁，最终实现合约安全交易以及链上可信审计。

然而，去中心化数据交易在解决以上问题的同时，带来了新的**挑战**：

①区块链的公开透明，对数据交易所带来的**隐私风险**：由于链上信息透明公开，在用户身份管理时，可能会暴露链上和链下DID的关联性，进而暴露用户的交易行为。在数据检索过程中，用户的检索行为也是公开的，同样会暴露隐私信息。

② 基于区块链的数据交易平台相较于现有中心化平台的**性能劣势**：由于区块链的分布式特性，其在大规模数据交易场景下不可避免地会遇到性能瓶颈。而目前的中心化数据交易平台可以支持高吞吐量和大规模并发，需要提高当前去中心化数据交易平台的性能以

③ 可信中心的缺失对数据质量评估等功能的影响：由于中心化的数据交易平台由第三方提供信任保障，针对数据交易过程中可能面临的纠纷能够提供有效仲裁。而去中心化数据交易平台由于缺失可信中心，需要设计相应的数据质量评估方案等进行功能补全。

基于此，我们的**设计目标**如下：

① 针对各个模块进行优化设计，解决隐私、性能和功能问题；

② 从底层区块链系统的层面提出优化设计，提高区块链性能水平。



### 1.2 相关工作

#### 1.2.1 区块链技术概述

区块链最初由Nakamoto于2008年提出,其本质上是一个可靠的分布式账本。作为分布式系统，区块链在分布式网络上运行，通过共识机制实现节点间数据的一致性；作为数据账本，它将交易记录保存在通过哈希值链接的按照时间顺序排列的链式区块结构中，并利用非对称加密、哈希等密码算法和默克尔树（Merkle Hash Tree，MHT）等验证结构，实现数据的不可篡改存储和高效验证。区块链能够在不完全可信的环境中实现实体之间的信任关系，具有去中心化、防篡改、公开透明等性质。

根据实体的参与方案，区块链可以分为三类：

- 公有链：无官方组织及管理机构，无中心服务器，参与的节点按照系统规则自由接入网络，节点间基于共识机制开展工作。这种情况下，网络中的所有节点都可以读取和发送交易，参与共识，所有交易透明，参与者使用匿名或者伪匿名。
- 私有链： 建立在某个组织内部，系统的运作规则根据组织要求设定，修改甚至是读取权限仅限于少数节点，同时仍保留着区块链的真实性和部分去中心化特征，其主要作用是借助区块链的链式结构保障数据存储的可靠性，防止个人做出恶意删除等行为。
- 联盟链：权限控制介于公有链和私有链之间，由若干机构联合发起，共同管理区块链，具有更高的自主权和控制权。其典型应用包括Hyperlegder Fabric等。

此外， 随着区块链基础设施的发展，“智能合约”的概念被提出以面向更加复杂和灵活的场景。简单来说，智能合约是一组可以自动触发并忠实执行的计算机程序代码和相关数据，它将区块链技术的应用范围从基于货币交易的简单应用，延伸到了图灵完备的通用计算领域，从而允许设计更加复杂的计算逻辑以满足用户的需求。

#### 1.2.2 DID技术概述

去中心化身份DID架构是W3C于2019年8月首次提出的一种分布式数字身份管理架构。在该架构中，身份是完全去中心化的，DID可以用来表示人、组织、数据模型等实体的身份信息。

<p align="center">
<img src="assets/DIDsys.png" alt="sys" style="zoom:45%;" />
</p>


如图所示，参与DID技术的实体主要包括DID持有人（DID subject）、DID控制者（DID controller）和可验证的数据注册中心（Verifiable Data Registry）。其中，DID持有者是指拥有DID身份的实体，DID控制者是拥有DID标识符控制权的实体，而可验证的注册中心指的是提供DID标识符的生成、注册和颁发等服务的组织机构，负责管理和验证DID标识符的唯一和真实性。

实体所控制的身份信息主要有DID标识符、DID文档和DID URL。DID标识符也是统一资源标识符的一种，是由一组字符串组成的唯一标识符。DID文档通常是一个JSON文档，用于描述DID的元数据和验证信息等。DID URL是基于DID标识符的统一资源定位器，用于解析或者反引用到具体的DID文档。

面对不同的场景需求中，实现方也会使用不同的DID方法（DID method）。DID方法指的是实现DID技术的具体方法和协议，定义了DID创建，解析，删除和修改的方式等。DID方法的自主定义模式也极大增加了DID的可扩展性，能够面对具体的需求和应用场景，设计实现更加灵活、安全、高效的身份管理方案。

DID架构在实际应用中，通常会与VC技术结合使用。VC技术是一种通过加密安全和机器可验证方式表达凭证数据的机制，其核心在于可验证性，可以通过区块链、数字签名等技术手段，确保证书的真实性和可靠性。

<p align="center">
<img src="assets/VC.png" alt="sys" style="zoom:50%;" />
</p>


如图所示，在VC技术中，通常涉及三类不同的实体，分别是发行者（Issuer）、使用者（Holder）和验证者（Verifier）。其中发行者是指颁发VC的实体，类似于传统PKI体系中的CA，例如企业、政府等。使用者是使用VC的实体，而验证者是验证VC的真实性和有效性的实体，通常是需要对VC进行验证的第三方服务提供商等。

通过对使用者签发VC可以证明其拥有某些属性。而使用者可以将多个VC进行组合或者处理，构成VP（Verifiable Presentation）进行进一步的验证。VP被验证方验证后可以确认持有者的身份和能力，并授予相关数据和服务，这一过程可以由持有者控制个人信息的披露范围。

DID架构的最大优势是将身份信息和属性信息进行分离，从而提供了极大的灵活性，同时用户能够绝对自主的掌握自己的身份，将身份标识和任何中央机构或第三方机构解耦，实现自主身份控制，其选择性披露机制也提供了一定的隐私保护能力。目前的很多区块链相关的主流社区和机构都实现了DID的部署应用，并提出了相关的DID方法，例如微软的ccf，比特币的btcr等。

#### 1.2.3 基于区块链的数据交易





### 1.3 设计目标

#### 1.3.1 大规模交易下的性能提升

在当前大规模数据交易的需求场景下，传统区块链由于其吞吐量受限的特点，在数据交易过程中的性能可能会受到限制。基于此，平台的设计目标之一是研究在大规模交易下的区块链性能提升，具体而言，本项目通过设计主侧链并行的网络架构，利用kubernetes工具进行集群搭建，大幅提高了网络的吞吐量。

#### 1.3.2 隐私保护下的数据质量评估和可信仲裁

针对数据交易过程中，数据商品难以进行质量评估以及售后退款，从而可能出现的纠纷问题，本项目分别设计了隐私保护下的数据质量评估方案以及数据集脱敏方案。在数据质量评估方案中，通过将数据集切分成多个子集，逐个进行交易实现渐进式的数据评估，并通过两阶段密钥交换协议保证交易原子性，基于状态通道降低多子集交易的链上开销。在数据脱敏方案中，通过零知识证明验证脱敏数据集和原始数据集之间的对应关系。

#### 1.3.3 用户身份隐私保护及查询行为保护

针对中心化数据交易平台面临的用户身份隐私易泄露的问题，本项目的设计目标

结合区块链存证以及渐进式数据交易方案进行可信仲裁，结合DID实现匿名安全交易。

#### 1.3.4 落地用户友好交易平台

本项目借助底层区块链技术和数据交易方案提供了面向**隐私保护**和**数据质量评估**的区块链大数据交易平台。出于用户友好角度考虑，我们搭建了实际的网络平台，并提供了直观便捷的用户页面。



### 1.4 应用前景

据2023年的相关报告[3]指出，金融行业是目前最大的细分业数据交易市场，占比达35%；其次是互联网行业，占比约为24%。目前，我国各地正加强“数据驱动力”，繁荣数据生态。数据交易市场规模稳步扩大，数据交易需求也在日渐增加。




## 第二章 技术原理与设计

### 2.1 系统架构设计

![image-20241108121119290](assets/image-20241108121119290.png)

我们的系统架构如图所示，其中：

- **用户授权和管理模块**：实现用户自主身份管理与授权。为了保护用户身份隐私，我们基于DID设计并实现了匿名和抗链接的身份管理方案。目前是通过DID实现链上的交易身份验证，后续考虑进一步设计DID生成方式，实现可审查的不可链接DID，并通过DID的选择性披露特性进一步保护隐私信息。
- **信息检索模块**：实现平衡效率与安全需求的多种信息检索方式。出于对用户检索数据的验证需求以及查询行为的隐私保护需求，我们设计了多种信息检索方式。通过查询冗余信息以及链下查询的方法实现查询行为的保护。后续考虑通过设计密态数据可验证检索方案，以及基于链上信息和联盟链节点的外包查询方案进一步优化功能。
- **数据交付模块**：为了实现安全可信的数据交易过程，我们分别设计了渐进式数据交易方案，实现数据质量评估，以及数据集脱敏方案，保护数据敏感信息。
- **底层区块链系统**：针对区块链在应对大规模数据交易过程中可能产生的性能瓶颈，设计了多子链并行架构，通过Kerbernetes工具组织节点提升平台性能。



### 2.2 用户授权和管理模块

针对传统中心化身份管理系统中存在的身份隐私易泄露，权限管理不公开等问题，提出了基于DID的用户身份管理系统：

- 用户产生助记词并据此派生DID
- 用户向区块链链上合约注册相应DID
- 链上合约验证用户提交的VC来完成认证



由于链上的DID公开，链下的VC颁发实体可能泄漏链上身份与链下身份的关联性，所以我们设计了可审查的不可链接的DID实现用户链上和链下身份关联性的保护：

- 不可链接性：链上主DID，链下根据主DID派生子DID，链上零知识验证派生关系以及主DID与子DID的VC
- 可审查性：发生恶意行为后揭露主DID，构建陷门实现

> 可审查的不可链接性DID用户向权威机构提交个人身份凭证等，获取根DID根DID不能直接使用，只能通过与所要加入的组织的联盟CA合作生成子DID，根DID此时仅提供合法身份证明和查重
>
> 细粒度管理用户权限，CA负责向系统合约写入用户对部分合约的读权限具体合约的接口权限由合约管理者单独配置



### 2.3 信息检索模块

针对传统平台存在的数据检索不全，检索信息不透明等问题，提出三种检索方式：

| **检索方式** | **说明**                                                     | **适用场景**                                                 |
| ------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 合约检索     | 用户通过合约提供的简单查询接口                               | 检索条件简单的场景                                           |
| 本地检索     | 用户通过合约检索相关数据描述信息，同时检索大量冗余信息，随后本地执行检索获得结果 | 适用与用户**隐私要求较高**，不愿暴露数据偏好，用户主机性能和带宽较强等场景 |
| 外包检索     | 用户向联盟链节点发送检索请求。联盟链节点基于链上信息和其本地维护的数据库给出检索结果和正确性证明 | 用户对隐私要求不高，本地主机性能弱                           |

其中，在外包检索部分，设计了可验证的检索方案：

- 联盟链节点基于链上信息和其本地维护的数据库给出检索结果和正确性证明
- 链上数据与链下缓存的一致性

基于以上设计，实现了提高检索性能的同时保证用户检索的安全性。



### 2.4 交易交付模块

#### 2.4.1无认证数据交易

渐进式交易过程：在去中心化交易场景下，为了保证数据的可用性和不可抵赖性，设计了多子集的数据交付过程，具体交易流程如下：

1. 将数据集切分成多个子集，并且生成对应的密钥进行加密，存储在云中

   $D\xrightarrow{Devide}\{D_1,...,D_n\}$

   $CD_i =Enc (K_i,D_i)$

2. 数据请求者通过智能合约生成子集的交易序列，并在智能合约中存入对应预先支付的资金，对随机数x生成哈希链，上传最后一个哈希值

   $\{H^1(x),...,H^{n+1}(x)\}$

3. 通过链下通道逐子集交付数据，在链上提交最终状态，并关闭通道。数据请求者每确认一个子集数据Di，向数据拥有者提供一个payword：

   $p_i =H^{n+1-i}(x)$

4. 通道关闭

   - 拥有payword：合约验证后发送对应奖励
   - 未拥有payword ：将请求者的确认签名$\sigma _i$ 以及$k_i^2$上传并验证tag

5. 验证与仲裁

   - 首先验证数据请求者的签名是否正确
     $Verify(pk_{requester},\sigma _{s_i},H(k^1_{S_i})) == 1$
   - 计算tag，并与链上保存的tag进行对比，后续需要更新tag
     $t= H(k^1_{S_i}))\oplus H(k^2_{S_i}))$



#### 2.4.2认证数据交易

保护原始数据集隐私同时保证数据可用性

- 认证方提供脱敏数据集与原始数据集认证信息

- 零知识证明脱敏数据集与原始数据集的对应关系



### 2.5 底层区块链系统

网络架构设计如下：

<p align="center">
<img src="assets/network.png" alt="sys" style="zoom:80%;" />
</p>





## 第三章 系统搭建与实现

### 3.1 智能合约设计

本部分将简要介绍智能合约实现模块以及接口：

#### 3.1.1 数据结构

Dataset 数据集信息结构

```go
type Dataset struct {
    DatasetID   string   `json:"DatasetID"`   // 数据集唯一标识
    Title       string   `json:"Title"`       // 数据集标题
    Describtion string   `json:"Description"` // 数据集描述
    Hash        string   `json:"Hash"`        // 数据集哈希值
    IpfsAddress string   `json:"IpfsAddress"` // IPFS存储地址
    N_subset    int      `json:"N_subset"`    // 子集数量
    Owner       string   `json:"Owner"`       // 所有者ID
    Price       int      `json:"Price"`       // 价格
    Tags        []string `json:"Tags"`        // 标签列表
}

```

Order 订单信息结构

```go
type Order struct {
    OrderID   string    `json:"OrderID"`   // 订单唯一标识
    Buyer     string    `json:"Buyer"`     // 买方ID
    DatasetID string    `json:"DatasetID"` // 数据集ID
    PayHash   string    `json:"PayHash"`   // 支付哈希
    EndTime   time.Time `json:"EndTime"`   // 订单截止时间
}
```

User 用户信息结构

```go
type User struct {
    UID          string   `json:"UID"`          // 用户唯一标识，存储用户公钥信息
    Value        int      `json:"Value"`        // 账户余额
    Nonce        int      `json:"Nonce"`        // 交易计数器
    DatasetIDs   []string `json:"DatasetIDs"`   // 拥有的数据集ID列表
    BuyOrderIDs  []string `json:"BuyOrderIDs"`  // 购买订单ID列表
    SellOrderIDs []string `json:"SellOrderIDs"` // 销售订单ID列表
}
```

DatasetList 数据集列表结构

```go
type DatasetList struct {
    DLID       string   `json:"DLID"`       // 列表唯一标识
    DatasetIDs []string `json:"DatasetIDs"` // 数据集ID列表
    Next       int      `json:"Next"`       // 下一个数据集索引
}
```

OrderList 订单列表结构

```go
type OrderList struct {
    OLID     string   `json:"OLID"`     // 列表唯一标识
    OrderIDs []string `json:"OrderIDs"` // 订单ID列表
    Next     int      `json:"Next"`     // 下一个订单索引
}
```

UserList 用户列表结构

```go
type UserList struct {
    ULID    string   `json:"ULID"`    // 列表唯一标识
    UserIDs []string `json:"UserIDs"` // 用户ID列表
}
```

#### 3.1.2 函数

**初始化系统**

| 参数                        | 含义                     |
| --------------------------- | ------------------------ |
| TransactionContextInterface | fabric提供的智能合约接口 |

```go
InitLedger(ctx contractapi.TransactionContextInterface) error
```

说明：初始化contract账户用于锁定资金

**数据集管理接口**

| 参数        | 含义                         |
| ----------- | ---------------------------- |
| title       | 数据集标题                   |
| description | 数据集描述                   |
| hash        | 数据集哈希，用于验证完整性   |
| ipfsAddress | 数据集IPFS地址               |
| n_subset    | 数据集切分子集数目           |
| owner       | 数据集拥有者                 |
| price       | 数据集定价                   |
| tags[]      | 数据集加密密钥计算的tags集合 |

- 创建数据集

  ```go
  CreateDataset(ctx contractapi.TransactionContextInterface, title string, description string, hash string, ipfsAddress string, n_subset int, owner string, price int, tags []string) error
  ```

- 获取链上数据集信息

  ```go
  GetDataset(ctx contractapi.TransactionContextInterface, datasetID string) (*Dataset, error)
  ```

- 获取数据集列表

  ```go
  GetDatasetList(ctx contractapi.TransactionContextInterface) (*DatasetList, error)
  ```

**订单处理接口**

| 参数      | 含义         |
| --------- | ------------ |
| buyer     | 数据购买者ID |
| orderID   | 交易ID       |
| datasetID | 交易数据集ID |
| payHash   | 支付凭证     |

- 创建订单

  ```go
  CreateOrder(ctx contractapi.TransactionContextInterface, buyer string, datasetID string, payHash string) error
  ```

- 获取订单信息

  ```go
  GetOrder(ctx contractapi.TransactionContextInterface, orderID string) (*Order, error) 
  ```

- 获取订单列表

  ```go
  GetOrderList(ctx contractapi.TransactionContextInterface) (*OrderList, error)
  ```

- 交付订单

  ```go
  HandleOrder(ctx contractapi.TransactionContextInterface, orderID string, n int, payword string) error
  ```

  说明：

- 在创建订单时，数据购买者会确定子集的交付序列，锁定资金在contract账户中，分别更新数据购买者、售卖者的购买数据集列表、售卖数据集列表。然后上传payHash用于后续的payword验证。

- 在交付订单时，合约会首先检查订单是否过期，然后验证payword，计算应支付的资金n*dataset.Price/dataset.N_subset。分别修改seller、buyer和contract的账户余额。


**用户管理接口**

- 创建用户

  ```go
  CreateUser(ctx contractapi.TransactionContextInterface, uID string, value int) error
  ```

- 获取链上用户信息

  ```go
  GetUser(ctx contractapi.TransactionContextInterface, uID string) (*User, error)
  ```

**代币系统接口**

| 参数  | 含义       |
| ----- | ---------- |
| uID   | 用户UID    |
| value | 余额变化值 |

- 充值：银行等对用户账户余额进行修改，增加余额

  ```go
  Mint(ctx contractapi.TransactionContextInterface, uID string, value int) error
  ```

- 提款：银行等对用户账户余额进行修改，减少余额

  ```go
  Burn(ctx contractapi.TransactionContextInterface, uID string, value int) error
  ```




### 3.2 Fabric区块链

本平台基于Hyperledger Fabric区块链进行搭建。

### 3.3 服务器端设计

### 3.4 前端UI设计


## 第四章 平台展示与实验测试

### 4.1 DeTrade功能实现展示

#### 4.1.1 平台主要页面概览

首页：

<p align="center">
<img src="assets/display-Home.png" alt="sys" style="zoom:80%;" />
</p>

用户登录：

<p align="center">
<img src="assets/display-register.png" alt="sys" style="zoom:80%;" />
</p>


数据集查询：

<p align="center">
<img src="assets/display-query.png" alt="sys" style="zoom:80%;" />
</p>

上传数据：

<p align="center">
<img src="assets/display-upload.png" alt="sys" style="zoom:80%;" />
</p>


cash 系统：

<p align="center">
<img src="assets/display-cash.png" alt="sys" style="zoom:80%;" />
</p>

订单管理：

<p align="center">
<img src="assets/display-order.png" alt="sys" style="zoom:80%;" />
</p>

密钥交付：

<p align="center">
<img src="assets/display-key.png" alt="sys" style="zoom:80%;" />
</p>

资金结算：

<p align="center">
<img src="assets/display-pay.png" alt="sys" style="zoom:80%;" />
</p>


#### 4.1.2 数据检索

#### 4.1.3 用户身份管理

#### 4.1.1 数据交易流程

### 4.2 性能测试

#### 4.2.1 实验环境

操作系统：Ubuntu22.04

CPU：13th Gen Intel(R) Core(TM) i5-13400

内存：16G

区块链平台：Fabric

区块链SDK：Node.js

Web框架：express

前端框架：Vue3

主要编程语言：Go

#### 4.2.2测试环境搭建

创建文件夹并进入：

```
 mkdir caliper-workspace
 cd caliper-workspace/
 mkdir networks benchmarks workload
```

下载测试工具：

```
npm init -y
npm install --only=prod @hyperledger/caliper-cli@0.5.0
npx caliper --help
```

绑定fabric-sdk

```
caliper bind --caliper-bind-sut fabric:2.4
```

根据网络环境准备网络配置文件： (networks/fabric-network.yaml)

```yaml
name: Caliper test
version: "2.0.0"

caliper:
  blockchain: fabric

channels:
  # channelName of mychannel matches the name of the channel created by test network
  - channelName: mychannel
    # the chaincodeIDs of all the fabric chaincodes in caliper-benchmarks
    contracts:
    - id: datatrading

organizations:
  - mspid: Org1MSP
    # Identities come from cryptogen created material for test-network
    identities:
      certificates:
      - name: 'User1'
        clientPrivateKey:
          path: '../deTrade-chain/test-network/organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/keystore'
        clientSignedCert:
          path: '../deTrade-chain/test-network/organizations/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp/signcerts/cert.pem'
    connectionProfile:
      path: '../deTrade-chain/test-network/organizations/peerOrganizations/org1.example.com/connection-org1.yaml'
      discover: true
```

测试设置：

```yaml
test:
    name: datatrading-contract-benchmark
    description: test benchmark
    workers:
      type: local
      number: 1
    rounds:
      - label: test
        description: test
        txDuration: 10  # 每轮测试持续 10 秒
        rateControl: 
          type: fixed-rate # 负载控制类型为固定负载
          opts:
            tps : 10 # 每秒 2 个事务（即负载为 2 TPS）
        workload:
          module: workload/test.js
          arguments:
            userNum: 2
            userNumMax: 100
            orderNum: 5
            dataNum: 5
            contractId: datatrading
monitors:
  resource:
  - module: docker
    options: 
      interval: 5 # 每 5 秒收集一次资源数据
      containers:
      - all
```

#### 4.2.3测试

这里针对合约进行压力测试。

```
npx caliper launch manager --caliper-workspace ./ --caliper-networkconfig networks/networkConfig.yaml --caliper-benchconfig benchmarks/myAssetBenchmark.yaml --caliper-flow-only-test --caliper-fabric-gateway-enabled --caliper-fabric-gateway-discovery
```



## 第五章 总结