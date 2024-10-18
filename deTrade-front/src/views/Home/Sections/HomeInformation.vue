<script setup>
import RotatingCard from "../../../examples/cards/rotatingCards/RotatingCard.vue";
import RotatingCardFront from "../../../examples/cards/rotatingCards/RotatingCardFront.vue";
import RotatingCardBack from "../../../examples/cards/rotatingCards/RotatingCardBack.vue";
import DefaultInfoCard from "../../../examples/cards/infoCards/DefaultInfoCard.vue";
</script>

<template>
  <section class="my-5 py-5">
    <div class="container">
      <div class="row align-items-center">
        <div class="col-lg-4 ms-auto me-auto p-lg-4 mt-lg-0 mt-4">
          <RotatingCard>
            <RotatingCardFront
              image="https://images.unsplash.com/photo-1569683795645-b62e50fbf103?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=987&q=80"
              icon="touch_app"
              title="体验数据交易"
              description="我们提供安全、透明的交易环境，确保您数据的隐私和价值。"
            />
            <RotatingCardBack
              image="https://images.unsplash.com/photo-1498889444388-e67ea62c464b?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1365&q=80"
              title="了解更多"
              description="加入我们，体验无缝的数据交易流程，助力您的业务发展。"
              :action="[
                {
                  route: '/login',
                  label: '立即交易',
                },
              ]"
            />
          </RotatingCard>
        </div>
        <div class="col-lg-6 ms-auto">
          <div class="row justify-content-start">
            <DefaultInfoCard
              icon="content_copy"
              title="去中心化"
              description="无可信第三方，确保自主数据交易"
            />
            <DefaultInfoCard
              icon="privacy_tip"
              title="数据隐私"
              description="数据加密存储，保护您的数据安全"
            />
          </div>
          <div class="row justify-content-start mt-5">
            <DefaultInfoCard
              class="mt-3"
              icon="currency_exchange"
              title="交易安全"
              description="保证交易原子性，避免交易纠纷"
            />
            <DefaultInfoCard
              class="mt-3"
              icon="verified"
              title="数据质量"
              description="独特交易模式，验证数据有效性"
            />
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

