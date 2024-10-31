
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
      class="page-header min-height-300"
      :style="`background-image: url(${image})`"
      loading="lazy"
    >
      <span class="mask bg-gradient-dark opacity-8"></span>
    </div>
  </Header>

  <div class="card card-body blur shadow-blur mx-3 mx-md-6 mt-n4">
    <div class="container py-5">
      <div class="row gx-5">
        <div class="col-lg-5">
          <div class="card h-100 transparent-card">
            <div class="card-header p-3 pt-2">
              <div class="icon icon-lg icon-shape bg-gradient-info shadow-info text-center border-radius-xl mt-n4 position-absolute">
                <i class="material-icons opacity-10">account_balance_wallet</i>
              </div>
              <div class="text-end pt-1">
                <p class="text-sm mb-0 text-capitalize">余额</p>
                <h4 class="mb-0">{{ accountInfo.balance }}</h4>
              </div>
            </div>
            <div class="card-body p-3">
              <h6 class="mb-0 ">公钥</h6>
              <p class="mb-0">{{ publicKey }}</p>
              <hr class="dark horizontal">
              <h6 class="mb-0 ">其他信息</h6>
              <p class="mb-0">{{ accountInfo.otherInfo }}</p>
            </div>
          </div>
        </div>
        <div class="col-lg-7">
          <div class="card mb-5 transparent-card">
            <div class="card-header p-3 pt-2">
              <div class="icon icon-lg icon-shape bg-gradient-success shadow-success text-center border-radius-xl mt-n4 position-absolute">
                <i class="material-icons opacity-10">add_circle</i>
              </div>
              <div class="text-end pt-1">
                <h4 class="mb-0">充值</h4>
              </div>
            </div>
            <div class="card-body p-3">
              <div class="input-group input-group-outline mb-3">
                <input v-model="depositAmount" type="number" class="form-control" placeholder="输入金额" required>
              </div>
              <button @click="handleDeposit" class="btn bg-gradient-success w-100 mb-0">充值</button>
            </div>
          </div>
          <div class="card transparent-card">
            <div class="card-header p-3 pt-2">
              <div class="icon icon-lg icon-shape bg-gradient-warning shadow-warning text-center border-radius-xl mt-n4 position-absolute">
                <i class="material-icons opacity-10">remove_circle</i>
              </div>
              <div class="text-end pt-1">
                <h4 class="mb-0">提现</h4>
              </div>
            </div>
            <div class="card-body p-3">
              <div class="input-group input-group-outline mb-3">
                <input v-model="withdrawAmount" type="number" class="form-control" placeholder="输入金额" required>
              </div>
              <button @click="handleWithdraw" class="btn bg-gradient-warning w-100 mb-0">提现</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>



<script setup>
import { ref, onMounted } from 'vue';
import { useAuthStore } from '../../stores/auth';
import { useRouter } from 'vue-router';
import NavbarDefault from "../../components/NavbarDefault.vue";
import Header from "../../examples/Header.vue";
import axios from "@/api/axios";

//images
import image from "@/assets/img/city-profile.jpg";
import bgContact from "@/assets/img/examples/blog2.jpg";

const authStore = useAuthStore();
const router = useRouter();

const publicKey = ref('');
const accountInfo = ref({ balance: 0, otherInfo: '' });
const depositAmount = ref(0);
const withdrawAmount = ref(0);

const fetchAccountInfo = async () => {
  try {
    const uID = publicKey.value;
    const response = await axios.get('/getUser', {
      params: { uID },
    });
    accountInfo.value.balance = response.data.result.Value;
  } catch (error) {
    console.error('getUser fail', error);
  }
};

const handleDeposit = async () => {
  try {
    const uID = publicKey.value; 
    const value = depositAmount.value; 
    await axios.post('/mint', { uID, value });

    fetchAccountInfo(); 
  } catch (error) {
    console.error('mint fail', error);
    this.errorMessage = 'Failed to deposit';
  }
};


const handleWithdraw = async () => {
  try {
    const uID = publicKey.value;
    const value = withdrawAmount.value; 

    await axios.post('/burn', { uID, value });

    fetchAccountInfo(); 
  } catch (error) {
    console.error('withdraw fail', error);
    this.errorMessage = 'Failed to deposit';
  }
};

onMounted(() => {
  publicKey.value = authStore.publicKey;
  fetchAccountInfo();
});
</script>

<style scoped>
.page-header {
  background-size: cover;
  background-position: center center;
}

.transparent-card {
  border-radius: 0.75rem;
  box-shadow: 0 4px 20px 0 rgba(0, 0, 0, 0.14), 0 7px 10px -5px rgba(0, 0, 0, 0.4);
  backdrop-filter: blur(10px);
  background-color: rgba(255, 255, 255, 0.6) !important;
}

.icon-shape {
  width: 70px;
  height: 70px;
  background-position: center;
  border-radius: 0.75rem;
}

.icon-shape i {
  color: #fff;
  opacity: 0.8;
  top: 19px;
  position: relative;
}

.input-group-outline {
  border: 1px solid #d2d6da;
  border-radius: 0.375rem;
}

.input-group-outline .form-label {
  padding: 0.6rem 0.75rem;
  margin-bottom: 0;
}

.btn {
  text-transform: uppercase;
  letter-spacing: 0.025em;
}

.card-header {
  background-color: transparent;
  padding: 1.5rem;
}

.card-body {
  padding: 1.5rem;
}

/* 增加卡片之间的间距 */
.col-lg-7 .card:first-child {
  margin-bottom: 2rem;
}

/* 增加左右两列之间的间距 */
@media (min-width: 992px) {
  .gx-5 {
    --bs-gutter-x: 10rem;
  }
}
</style>