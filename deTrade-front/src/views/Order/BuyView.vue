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
      <Order v-if="data" :data="data" />
    </div>

  </template>
  
  <script setup>
  import { ref, computed ,onMounted} from 'vue';
  import { useAuthStore } from '../../stores/auth';
  import { useRouter } from 'vue-router';
  import NavbarDefault from "../../components/NavbarDefault.vue";
  import Order from "./Sections/OrderDetail.vue";
  // import data from "./Sections/Data/buyOrder";
  import vueMkHeader from "@/assets/img/vue-mk-header.jpg";
  import axios from '@/api/axios';
  import imgStat from "@/assets/img/stat.png";

  const router = useRouter();
  const authStore = useAuthStore();

  // 模拟数据集
  const data = ref(null)
const fetchData = async () => {
  data.value = [{
    heading: "管理订单",
    description:
      "您的购买订单",
      items: []
  }];
  try {
    const uID = authStore.publicKey;
    const response = await axios.get('/getBuyOrders', {
      params: { uID },
    });
    const buyOrders = response.data.buyOrders;
    console.log("test:",buyOrders);

    var items = [{
          id: "1",
          image: imgStat,
          title: "金融数据",
          subtitle: "10GB",
          route: "BuyOrder",
          pro: false
        }];

    for (const buyOrder of buyOrders) {
      var item = {
          id: buyOrder.OrderID,
          image: imgStat,
          title: buyOrder.DatasetID,
          subtitle: buyOrder.EndTime,
          route: "BuyOrder",
          pro: false
        };
        items.push(item);
    }
    data.value[0].items = items;
  } catch (error) {
    console.error('getBuyOrders fail', error);
  }
};

  onMounted(() => {
    fetchData();
  });


  </script>
