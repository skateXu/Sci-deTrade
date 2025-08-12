<script setup>
import { ref, computed } from "vue";
import ExampleCard from "../../../components/ExampleCard.vue";
import axios from "../../../api/axios.js";

//订单管理下面的界面，数据来自BuyOrder或者SellOrder传入
const props = defineProps({
  data: {
    type: Array,
    required: true,
    heading: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
    items: {
      type: Array,
      required: true,
      image: {
        type: String,
        required: true,
      },
      title: {
        type: String,
        required: true,
      },
      subtitle: {
        type: String,
        required: true,
      },
    },
  },
  col1: {
    type: String,
    default: "col-lg-3",
  },
  col2: {
    type: String,
    default: "col-lg-9",
  },
});

// 搜索相关的响应式数据
const searchQuery = ref("");
const filteredItems = computed(() => {
  if (!searchQuery.value) {
    return props.data.map(item => item.items).flat(); // 如果没有搜索，返回所有项目
  }

  const query = searchQuery.value.toLowerCase();
  return props.data.map(item => item.items).flat().filter(item => {
    return (
      item.title.toLowerCase().includes(query) ||  
      item.subtitle.toLowerCase().includes(query)
    );
  });
});

// 点击“传输”按钮时，把输入内容发送到后端
const send_to_back = async () => {
  try {
    const payload = { testData: searchQuery.value };
    const { data } = await axios.post("/testData", payload);
    console.log("[前端] 已发送测试数据:", payload);
    console.log("[前端] 后端响应:", data);
    alert("已发送到后端: " + JSON.stringify(payload));
  } catch (error) {
    console.error("发送测试数据失败:", error);
    alert("发送失败: " + (error?.message || "未知错误"));
  }
};

</script>

<script>
export default {
  inheritAttrs: false,
};
</script>

<template>
  <section class="my-5 py-5">
    <div class="container">
      <div class="row justify-content-center text-center my-sm-5">
        <div class="col-lg-6">
          <h2 class="text-dark mb-0">测试界面标题</h2>
          <p class="lead">
            测试界面标题注解
          </p>
          <!-- 搜索框 -->
          <div class="input-group mb-3">
            <input
              v-model="searchQuery"
              type="text"
              class="form-control border-secondary"  
              placeholder="传输数据给后端"
            />
            <button
              @click="send_to_back"  
              class="btn btn-success"  
            >
              传输
            </button>
          </div>
        </div>
      </div>
    </div>
    <div class="container mt-sm-5 mt-3">
      <div
        v-for="({ heading, description, items }, index) in data"
        :class="`row ${index !== 0 ? 'pt-lg-6' : ''}`"
        :key="heading"
      >
        <div :class="`${col1}`">
          <div
            class="position-sticky pb-lg-5 pb-3 mt-lg-0 mt-5 ps-2"
            style="top: 100px"
          >
            <h3>{{ heading }}</h3> <!--这个heading就来自Buy或者Sell Order传入的数据，为“购买订单”或者--“管理订单”-->
            <h6 class="text-secondary font-weight-normal pe-3">
              {{ description }}
            </h6>
          </div>
        </div>
        <div :class="`${col2}`">
          <div :class="`row ${index !== 0 ? 'mt-3' : ''}`">
            <div
              class="col-md-4 mt-md-0"
              v-for="{ image, title, subtitle, route, id, pro } in filteredItems"
              :key="title"
            >
              <ExampleCard
                class="min-height-160 shadow-lg mt-4"
                :image="image"
                :title="title"
                :subtitle="subtitle"
                :route="route"
                :id = "id"
                :pro="pro"
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>
