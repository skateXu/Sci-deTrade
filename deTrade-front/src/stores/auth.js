import { defineStore } from 'pinia';

export const useAuthStore = defineStore('auth', {
  state: () => ({
    isLoggedIn: localStorage.getItem('isLoggedIn') === 'true',
    publicKey: localStorage.getItem('publicKey') || '',
    privateKey: localStorage.getItem('privateKey') || '',
  }),
  actions: {
    login(publicKey, privateKey) {
      // 保存公钥和私钥到本地存储
      this.publicKey = publicKey;
      this.privateKey = privateKey;
      this.isLoggedIn = true;

      localStorage.setItem('publicKey', publicKey);
      localStorage.setItem('privateKey', privateKey);
      localStorage.setItem('isLoggedIn', true);
    },
    logout() {
      // 清空公钥和私钥，并设置登录状态为 false
      this.publicKey = '';
      this.privateKey = '';
      this.isLoggedIn = false;

      localStorage.removeItem('publicKey');
      localStorage.removeItem('privateKey');
      localStorage.setItem('isLoggedIn', false);
    },
  },
});
