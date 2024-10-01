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
      class="page-header min-vh-50"
      :style="`background-image: url(${vueMkHeader})`"
      loading="lazy"
    >
      <div class="container">
        <div class="row">
          <div class="col-lg-7 text-center mx-auto position-relative">
            <h1
              class="text-white pt-3 mt-n5 me-2"
              :style="{ display: 'inline-block ' }"
            >
              数据交易平台
            </h1>
            <p class="lead text-white px-5 mt-3" :style="{ fontWeight: '500' }">
              借助区块链实现去中心化的可信数据交易。
            </p>
          </div>
        </div>
      </div>
    </div>
  </Header>
  
    <div class="card card-body blur shadow-blur mx-3 mx-md-4 mt-n6">
      <Dataset :data="buyOrder" />
    </div>

  </template>
  
  <script setup>
  import { ref, computed } from 'vue';
  import { useRouter } from 'vue-router';
  import NavbarDefault from "../../components/NavbarDefault.vue";
  import Dataset from "./Sections/OrderDetail.vue";
  import sellOrder from "./Sections/Data/sellOrder";
  import buyOrder from "./Sections/Data/buyOrder";
  import vueMkHeader from "@/assets/img/vue-mk-header.jpg";
  const router = useRouter();
  
  // 模拟数据集
  </script>
