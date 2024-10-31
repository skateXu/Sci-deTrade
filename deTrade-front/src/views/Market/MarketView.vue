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
      <Dataset v-if="data" :data="data"/>
    </div>
  </template>
  
<script setup>
  import { ref, computed , onMounted, onUnmounted } from 'vue';
  import { useRouter } from 'vue-router';
  import NavbarDefault from "../../components/NavbarDefault.vue";
  import Dataset from "./Sections/Dataset.vue";
  // import data from "./Sections/Data/designBlocksData";
  import vueMkHeader from "@/assets/img/vue-mk-header.jpg";
  import imgStat from "@/assets/img/stat.png";

  // backend
  import axios from "@/api/axios";

  const router = useRouter();
  
  // 模拟数据集

  const body = document.getElementsByTagName("body")[0];
  const data = ref(null)
const fetchData = async () => {
  data.value = [{
    heading: "数据集",
    description:
      "汇集各行业数据",
      items: []
  }];
  try {
    const response = await axios.get('/getDatasets');
    const datasets = response.data.datasets;
    var items = [{
          id: "1",
          image: imgStat,
          title: "金融数据",
          subtitle: "10GB",
          route: "CreateOrder",
          pro: false
        }];
    for (const dataset of datasets) {
      var item = {
          id: dataset.DatasetID,
          image: imgStat,
          title: dataset.Title,
          subtitle: dataset.Description,
          route: "CreateOrder",
          pro: false
        };
        items.push(item);
    }
    data.value[0].items = items;
    console.log(data.value[0].items);
  } catch (error) {
    console.error('getUser fail', error);
  }
};

  onMounted(() => {
    body.classList.add("presentation-page");
    body.classList.add("bg-gray-200");
    fetchData();
  });
  onUnmounted(() => {
    body.classList.remove("presentation-page");
    body.classList.remove("bg-gray-200");
  });

</script>