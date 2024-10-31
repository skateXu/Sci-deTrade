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
  Hash: '',
  IpfsAddress: '',
  N_subset: '',
  Owner: '',
  Price: '',
  Tags: ''
});

const tagsInput = ref('');
const fileInput = ref(null);

// 处理文件上传
const handleFileUpload = () => {
  dataset.value.file = fileInput.value.files[0];
};

// 上传数据集
const uploadDataset = async () => {
  const formData = new FormData();
  formData.append('file', dataset.value.file);

  try {
    const response = await axios.post('/upload', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    });
    dataset.value.IpfsAddress = response.data.ipfsAddress;
    alert("文件上传成功,IPFS地址已更新");
  } catch (error) {
    console.error("Error uploading dataset:", error);
    alert("文件上传失败。");
  }
};

// 上架数据集
const listDataset = async () => {
  dataset.value.Tags = JSON.stringify(tagsInput.value.split(','));
  dataset.value.Owner = store.publicKey;
  try {
    const { Title, Description, Hash, IpfsAddress, N_subset, Owner, Price, Tags } = dataset.value;
    console.log(Title);        // 'New Title'
    console.log(Description);  // 'New Description'
    console.log(Hash);         // 'New Hash'
    console.log(IpfsAddress);  // 'New IpfsAddress'
    console.log(N_subset);     // 'New N_subset'
    console.log(Owner);        // 'New Owner'
    console.log(Price);        // 'New Price'
    console.log(Tags);         // 'New Tags'
    await axios.post('/createDataset', {
      Title, Description, Hash, IpfsAddress, N_subset, Owner, Price, Tags
    });
    alert("数据集已成功上架！");
  } catch (error) {
    console.error("Error listing dataset:", error);
    alert("数据集上架失败。");
  }
};


onMounted(() => {

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
  
    <div class="card card-body blur shadow-blur mx-3 mx-md-7 mt-n6">
      <section class="py-lg-4">
        <div class="container">
          <div class="row">
            <div class="col">
              <div class="card box-shadow-xl overflow-hidden mb-5">
                <div class="row">
                  <div
                    class="col-lg-3 position-relative bg-cover px-0"
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
                      </div>
                    </div>
                  </div>
                  <div class="col-lg-7">
                    <form class="p-3" id="dataset-form" method="post">
                      <div class="card-header px-4 py-sm-5 py-3">
                        <h2>上架数据集</h2>
                        <p class="lead">填写数据集信息并上传文件</p>
                      </div>
                      <div class="card-body pt-4">
                        <div class="row">
                          <div class="col-md-6 pe-2 mb-4">
                            <div class="input-group input-group-static mb-4">
                              <label>标题</label>
                              <input
                                type="text"
                                class="form-control"
                                placeholder="输入标题"
                                v-model="dataset.Title"
                              />
                            </div>
                          </div>
                          <div class="col-md-6 pe-2 mb-4">
                            <div class="input-group input-group-static mb-4">
                              <label>描述</label>
                              <input
                                type="text"
                                class="form-control"
                                placeholder="输入描述"
                                v-model="dataset.Description"
                              />
                            </div>
                          </div>
  
                          <div class="col-md-6 pe-2 mb-4">
                            <div class="input-group input-group-static mb-4">
                              <label>Hash</label>
                              <input
                                type="text"
                                class="form-control"
                                placeholder="输入Hash"
                                v-model="dataset.Hash"
                              />
                            </div>
                          </div>
                          <div class="col-md-6 pe-2 mb-4">
                            <div class="input-group input-group-static mb-4">
                              <label>IPFS地址</label>
                              <input
                                type="text"
                                class="form-control"
                                placeholder="IPFS地址"
                                v-model="dataset.IpfsAddress"
                              />
                            </div>
                          </div>
                          <div class="col-md-6 pe-2 mb-4">
                            <div class="input-group input-group-static mb-4">
                              <label>N_subset</label>
                              <input
                                type="text"
                                class="form-control"
                                placeholder="输入N_subset"
                                v-model="dataset.N_subset"
                              />
                            </div>
                          </div>
                          <div class="col-md-6 pe-2 mb-4">
                            <div class="input-group input-group-static mb-4">
                              <label>价格</label>
                              <input
                                type="text"
                                class="form-control"
                                placeholder="输入价格"
                                v-model="dataset.Price"
                              />
                            </div>
                          </div>
                          <div class="col-md-6 pe-2 mb-4">
                            <div class="input-group input-group-static mb-4">
                              <label>标签</label>
                              <input
                                type="text"
                                class="form-control"
                                placeholder="输入标签，用逗号分隔"
                                v-model="tagsInput"
                              />
                            </div>
                          </div>
                          <div class="col-md-6 pe-2 mb-4">
                            <div class="input-group input-group-static mb-4">
                              <label>上传文件</label>
                              <div class="custom-file">
                                <input
                                  type="file"
                                  class="custom-file-input"
                                  ref="fileInput"
                                  @change="handleFileUpload"
                                />
                                <label class="custom-file-label" for="customFile"></label>
                              </div>
                            </div>
                          </div>
                        </div>
                        <div class="row">
                          <div class="col-md-12 text-end ms-auto">
                            <button
                              type="button"
                              class="btn btn-success mb-0 mx-2"
                              @click="uploadDataset"
                            >
                              上传数据集
                            </button>
                            <button
                              type="button"
                              class="btn btn-success mb-0 mx-2"
                              @click="listDataset"
                            >
                              上架数据集
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
  