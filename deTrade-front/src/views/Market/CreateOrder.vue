<script setup>
import { onMounted,ref } from "vue";
import { useRoute } from 'vue-router';
import axios from "@/api/axios";
import NavbarDefault from "../../components/NavbarDefault.vue";

// image
import image from "@/assets/img/city-profile.jpg";
// image
import bgContact from "@/assets/img/examples/blog2.jpg";

// tooltip
import setTooltip from "@/assets/js/tooltip";
import { useAuthStore } from "@/stores/auth"; // 引入 store
import CryptoJS from 'crypto-js';

const store = useAuthStore();
const route = useRoute();

// 定义数据集信息和输入框数据
const dataset = ref({
  Title: '',
  Description: '',
  Id: '',
  Hash: '',
  IpfsAddress: '',
  N_subset: '',
  Owner: '',
  Price: '',
  Tags: ''
});
const secretKey = ref('');
const paymentProof = ref('');

// 获取数据集信息
const fetchDataset = async () => {
  try {
    const response = await axios.get('/getdataset',{ params: { id: route.params.id } });
    dataset.value = response.data;
  } catch (error) {
    console.error("Error fetching dataset:", error);
  }
};

// 生成支付凭证
const generatePaymentProof = () => {
  let hash = secretKey.value || store.privateKey;
  for (let i = 0; i <= parseInt(dataset.value.N_subset, 10); i++) {
    hash = hash + dataset.value.Id;
    hash = CryptoJS.SHA256(hash).toString(CryptoJS.enc.Hex);
  }
  paymentProof.value = hash;
};

// 购买数据集
const purchaseDataset = async () => {
  try {
    await axios.post('/purchase', {
      datasetId: route.params.id,
      paymentProof: paymentProof.value
    });
    alert("Dataset purchased successfully!");
  } catch (error) {
    console.error("Error purchasing dataset:", error);
    alert("Failed to purchase dataset.");
  }
};

// 下载数据集
const downloadDataset = async () => {
  try {
    const response = await axios.get(`/download/${dataset.value.IpfsAddress}`, {
      responseType: 'blob'
    });
    const url = window.URL.createObjectURL(new Blob([response.data]));
    const link = document.createElement('a');
    link.href = url;
    link.setAttribute('download', `${dataset.value.Title}.zip`); // 设置下载文件名
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  } catch (error) {
    console.error("Error downloading dataset:", error);
    alert("Failed to download dataset.");
  }
};

onMounted(() => {
  // setTooltip(store.bootstrap);
  fetchDataset();
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
                      <h3 class="text-white">{{ dataset.Title }}</h3>
                      <p class="text-white opacity-8 mb-4">
                        {{ dataset.Description }}
                      </p>
                      <div class="d-flex p-2 text-white">
                        <div class="ps-3">
                          <span class="text-sm opacity-8">ID: {{ dataset.Id }}</span>
                        </div>
                      </div>
                      <div class="d-flex p-2 text-white">
                        <div class="ps-3">
                          <span class="text-sm opacity-8">Hash: {{ dataset.Hash }}</span>
                        </div>
                      </div>
                      <div class="d-flex p-2 text-white">
                        <div class="ps-3">
                          <span class="text-sm opacity-8">IpfsAddress: {{ dataset.IpfsAddress }}</span>
                        </div>
                      </div>
                      <div class="d-flex p-2 text-white">
                        <div class="ps-3">
                          <span class="text-sm opacity-8">N_subset: {{ dataset.N_subset }}</span>
                        </div>
                      </div>
                      <div class="d-flex p-2 text-white">
                        <div class="ps-3">
                          <span class="text-sm opacity-8">Owner: {{ dataset.Owner }}</span>
                        </div>
                      </div>
                      <div class="d-flex p-2 text-white">
                        <div class="ps-3">
                          <span class="text-sm opacity-8">Price: {{ dataset.Price }}</span>
                        </div>
                      </div>
                      <div class="d-flex p-2 text-white">
                        <div class="ps-3">
                          <span class="text-sm opacity-8">Tags: {{ dataset.Tags }}</span>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="col-lg-7">
                  <form class="p-3" id="contact-form" method="post">
                    <div class="card-header px-4 py-sm-5 py-3">
                      <h2>创建订单</h2>
                      <p class="lead">输入交易秘密口令，生成支付凭证</p>
                    </div>
                    <div class="card-body pt-1">
                      <div class="row">
                        <div class="col-md-12 pe-2 mb-3">
                          <div class="input-group input-group-static mb-4">
                            <label>秘密口令</label>
                            <input
                              type="text"
                              class="form-control"
                              placeholder="默认使用私钥"
                              v-model="secretKey"
                            />
                          </div>
                        </div>
                        <div class="col-md-12 pe-2 mb-3">
                          <div class="input-group input-group-static mb-4">
                            <label>支付凭据</label>
                            <input
                              type="text"
                              class="form-control"
                              placeholder="可自行生成"
                              v-model="paymentProof"
                            />
                          </div>
                        </div>
                      </div>
                      <div class="row">
                        <div class="col-md-12 text-end ms-auto">
                          <button
                            type="button"
                            class="btn btn-success mb-0 mx-2"
                            @click="generatePaymentProof"
                          >
                            生成支付凭据
                          </button>
                          <button
                            type="button"
                            class="btn btn-success mb-0 mx-2"
                            @click="purchaseDataset"
                          >
                            购买数据集
                          </button>
                          <button
                            type="button"
                            class="btn btn-success mb-0 mx-2"
                            @click="downloadDataset"
                          >
                            下载数据集
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
