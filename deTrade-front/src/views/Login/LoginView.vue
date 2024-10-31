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
      class="page-header align-items-start min-vh-100"
      :style="{
        backgroundImage:
          'url(https://images.unsplash.com/photo-1497294815431-9365093b7331?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1950&q=80)'
      }"
      loading="lazy"
    >
      <span class="mask bg-gradient-dark opacity-6"></span>
      <div class="container my-auto">
        <div class="row">
          <div class="col-lg-4 col-md-8 col-12 mx-auto">
            <div class="card z-index-0 fadeIn3 fadeInBottom">
              <div class="card-header p-0 position-relative mt-n4 mx-3 z-index-2">
                <div class="bg-gradient-success shadow-success border-radius-lg py-3 pe-1">
                  <h4 class="text-white font-weight-bolder text-center mt-2 mb-0">
                    登录
                  </h4>
                  <h6 class="text-white font-weight-bolder text-center mt-2 mb-0">
                    请输入您的公私钥或助记词进行登录
                  </h6>
                </div>
              </div>
              <div class="card-body">
                <form @submit.prevent="handleLogin" class="text-start">
                  <div class="input-group input-group-outline my-3">
                    <label for="publicKey" class="form-label"></label>
                    <input
                      id="publicKey"
                      type="text"
                      class="form-control"
                      v-model="publicKey"
                      placeholder="输入您的公钥"
                      required
                    />
                  </div>
                  <div class="input-group input-group-outline mb-3">
                    <label for="privateKey" class="form-label"></label>
                    <input
                      id="privateKey"
                      :type="showPrivateKey ? 'text' : 'password'"
                      class="form-control"
                      v-model="privateKey"
                      placeholder="输入您的私钥"
                      required
                    />
                  </div>
                  <div class="form-check form-switch mb-3">
                    <input
                      class="form-check-input"
                      type="checkbox"
                      id="showPrivateKeySwitch"
                      v-model="showPrivateKey"
                    />
                    <label class="form-check-label" for="showPrivateKeySwitch">显示私钥</label>
                  </div>
                  <div class="input-group input-group-outline mb-3">
                    <label for="mnemonic" class="form-label"></label>
                    <input
                      id="mnemonic"
                      :type="showMnemonic ? 'text' : 'password'"
                      class="form-control"
                      v-model="mnemonic"
                      placeholder="输入助记词以生成公私钥"
                    />
                  </div>
                  <div class="form-check form-switch mb-3">
                    <input
                      class="form-check-input"
                      type="checkbox"
                      id="showMnemonicSwitch"
                      v-model="showMnemonic"
                    />
                    <label class="form-check-label" for="showMnemonicSwitch">显示助记词</label>
                  </div>
    
                  <div class="text-center">
                    <button type="submit" class="btn btn-success btn-lg w-100 my-4 mb-2">登录</button>
                  </div>
                  <button @click="generateKeys" type="button" class="btn btn-secondary mt-3 w-100">生成公私钥</button>
                </form>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </Header>
</template>

<script setup>
import { ref } from 'vue';
import { useAuthStore } from '../../stores/auth';
import { useRouter } from 'vue-router';
import NavbarDefault from "../../components/NavbarDefault.vue";
import Header from "@/examples/Header.vue";

import elliptic from 'elliptic';
import CryptoJS from 'crypto-js';

const authStore = useAuthStore();
const router = useRouter();

const publicKey = ref('');
const privateKey = ref('');
const showPrivateKey = ref(false);
const showMnemonic = ref(false);
const mnemonic = ref('');

const generateKeys = () => {
  const ec = new elliptic.ec('secp256k1');
  let keyPair;

  if (mnemonic.value) {
    // 使用助记词恢复密钥对
    const hash = CryptoJS.SHA256(mnemonic.value).toString();
    keyPair = ec.keyFromPrivate(hash);
  } else {
      // 生成一个随机字符串
    const randomString = CryptoJS.lib.WordArray.random(6).toString();
    mnemonic.value = randomString
    const hash = CryptoJS.SHA256(randomString).toString();
    keyPair = ec.keyFromPrivate(hash);
  }

  publicKey.value = keyPair.getPublic('hex');
  privateKey.value = keyPair.getPrivate('hex');
};

const handleLogin =  () => {
  authStore.login(publicKey.value, privateKey.value);
  router.push({ name: 'home' });
};
</script>

<style scoped>
.page-header {
  background-size: cover;
  background-position: center;
}

.mask {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}

.card {
  border: none;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.card-header {
  border-bottom: none;
}

.card-body {
  padding: 2rem;
}

.input-group-outline {
  position: relative;
}

.input-group-outline .form-control {
  border: 1px solid #ced4da;
  border-radius: 0.25rem;
  padding: 0.375rem 0.75rem;
  transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
}

.input-group-outline .form-control:focus {
  border-color: #80bdff;
  outline: 0;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

.input-group-outline .form-label {
  position: absolute;
  top: 0;
  left: 0;
  padding: 0.375rem 0.75rem;
  pointer-events: none;
  transition: 0.15s ease-in-out;
  color: #6c757d;
}

.input-group-outline .form-control:focus ~ .form-label,
.input-group-outline .form-control:not(:placeholder-shown) ~ .form-label {
  top: -1.25rem;
  left: 0.75rem;
  font-size: 0.75rem;
  color: #007bff;
}

.btn-success {
  background-color: #28a745;
  border-color: #28a745;
}

.btn-success:hover {
  background-color: #218838;
  border-color: #1e7e34;
}

.btn-secondary {
  background-color: #6c757d;
  border-color: #6c757d;
}

.btn-secondary:hover {
  background-color: #5a6268;
  border-color: #545b62;
}
</style>
