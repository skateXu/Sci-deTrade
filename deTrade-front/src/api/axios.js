// src/axios.js
import axios from 'axios';

const instance = axios.create({
  baseURL: 'http://localhost:3001',
  timeout: 10000, // 请求超时时间
  // headers: {
  //   'Content-Type': 'application/json',
  // }
});

// 请求拦截器
instance.interceptors.request.use(
  config => {
    // 发送请求之前
    return config;
  },
  error => {
    // 请求错误
    return Promise.reject(error);
  }
);

// 响应拦截器
instance.interceptors.response.use(
  response => {
    // 响应数据
    return response;
  },
  error => {
    // 响应错误
    return Promise.reject(error);
  }
);

export default instance;
