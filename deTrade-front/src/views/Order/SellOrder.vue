<script setup>
import { onMounted, ref } from "vue";
import { useRoute } from 'vue-router';
import axios from "@/api/axios";
import NavbarDefault from "../../components/NavbarDefault.vue";
import CryptoJS from 'crypto-js';

// image
import image from "@/assets/img/city-profile.jpg";
// image
import bgContact from "@/assets/img/examples/blog2.jpg";

// tooltip
import setTooltip from "@/assets/js/tooltip";
import { useAuthStore } from "@/stores/auth"; // 引入 store

const store = useAuthStore();
const route = useRoute();

// 定义订单信息和输入框数据
const order = ref({
  Buyer: '',
  DatasetID: '',
  EndTime: '',
  OrderID: '',
  PayHash: ''
});
const encryptionKey = ref('');
const paymentKey = ref('');
const n = ref('');

// 获取订单信息
const fetchOrder = async () => {
  try {
    const response = await axios.get('/getorder',{params: { id: route.params.id },});
    order.value = response.data.order;
  } catch (error) {
    console.error("Error fetching order:", error);
  }
};

// 提交加密密钥
const submitEncryptionKey = async () => {
  try {
    // 调用后端接口，传递加密密钥口令
    const response = await axios.post('/handleOrder', {

      encryptionKey: encryptionKey.value
    });
    // 将返回的支付密钥填入输入框
    paymentKey.value = response.data.paymentKey;
    alert("支付密钥已生成！");
  } catch (error) {
    console.error("Error submitting encryption key:", error);
    alert("提交加密密钥失败。");
  }
};

// 结束订单
const endOrder = async () => {
  try {
    // 调用后端接口，结束交易
    await axios.post('/handleOrder', {
      orderID: route.params.id,
      n:n.value,
      payword: paymentKey.value
    });
    alert("订单已结束！");
  } catch (error) {
    console.error("Error ending order:", error);
    alert("结束订单失败。");
  }
};

const truncateText = (text, length) => {
  if (text.length > length) {
    return text.substring(0, length) + "...";
  }
  return text;
};

onMounted(() => {
  fetchOrder();
});
</script>


<template>
  <div class="container position-sticky z-index-sticky top-0">
    <div class="row">
      <div class="col-12">
        <NavbarDefault :sticky="true" />
      </div>
    </div>
  </div>

  <Header>
    <div
      class="page-header min-height-200"
      :style="`background-image: url(${image})`"
      loading="lazy"
    >
      <span class="mask bg-gradient-dark opacity-8"></span>
    </div>
  </Header>

  <div class="card card-body blur shadow-blur mx-3 mx-md-6 mt-n4">
    <section class="py-lg-6">
      <div class="container">
        <div class="row">
          <div class="col">
            <div class="card box-shadow-xl overflow-hidden mb-5">
              <div class="row">
                <div
                  class="col-lg-5 position-relative bg-cover px-0"
                  :style="{ backgroundImage: `url(${bgContact})` }"
                  loading="lazy"
                >
                  <div
                    class="z-index-2 text-center d-flex h-100 w-100 d-flex m-auto justify-content-center"
                  >
                    <div class="mask bg-gradient-dark opacity-8"></div>
                    <div
                      class="p-5 ps-sm-8 position-relative text-start my-auto z-index-2"
                    >
                      <h3 class="text-white">订单信息</h3>
                      <p class="text-white opacity-8 mb-4">
                        <span class="text-sm opacity-8">买家: {{ truncateText(order.Buyer, 20) }}</span><br>
                        <span class="text-sm opacity-8">数据集ID: {{ order.DatasetID }}</span><br>
                        <span class="text-sm opacity-8">订单ID: {{ order.OrderID }}</span><br>
                        <span class="text-sm opacity-8">结束时间: {{ order.EndTime }}</span><br>
                        <span class="text-sm opacity-8">支付哈希: {{ truncateText(order.PayHash, 20) }}</span>
                      </p>
                    </div>
                  </div>
                </div>
                <div class="col-lg-7">
                  <form class="p-3" id="order-form" method="post">
                    <div class="card-header px-4 py-sm-5 py-3">
                      <h2>处理订单</h2>
                      <p class="lead">输入加密密钥口令和支付密钥</p>
                    </div>
                    <div class="card-body pt-1">
                      <div class="row">
                        <div class="col-md-12 pe-2 mb-3">
                          <div class="input-group input-group-static mb-4">
                            <label>加密密钥口令</label>
                            <input
                              type="text"
                              class="form-control"
                              placeholder="输入加密密钥口令"
                              v-model="encryptionKey"
                            />
                          </div>
                        </div>
                        <div class="col-md-12 pe-2 mb-3">
                          <div class="input-group input-group-static mb-4">
                            <label>支付密钥</label>
                            <input
                              type="text"
                              class="form-control"
                              placeholder="支付密钥"
                              v-model="paymentKey"
                              readonly
                            />
                          </div>
                        </div>
                      </div>
                      <div class="row">
                        <div class="col-md-12 text-end ms-auto">
                          <button
                            type="button"
                            class="btn btn-success mb-0 mx-2"
                            @click="submitEncryptionKey"
                          >
                            提交加密密钥
                          </button>
                          <button
                            type="button"
                            class="btn btn-danger mb-0 mx-2"
                            @click="endOrder"
                          >
                            结束订单
                          </button>
                        </div>
                      </div>
                    </div>
                  </form>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>


