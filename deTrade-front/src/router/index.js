import { createRouter, createWebHistory } from "vue-router";
import { useAuthStore } from '../stores/auth';
import HomeView from "../views/Home/HomeView.vue";
import MarketView from "../views/Market/MarketView.vue";
import LoginView from "../views/Login/LoginView.vue";
import BuyView from "../views/Order/BuyView.vue";
import SellView from "../views/Order/SellView.vue";
import FinanceView from "../views/Finance/FinanceView.vue";
import CreateOrder from "../views/Market/CreateOrder.vue";
import SellOrder from "../views/Order/SellOrder.vue";
import BuyOrder from "../views/Order/BuyOrder.vue";
import DataView from "../views/Data/DataView.vue";

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: "/",
      name: "home",
      component: HomeView,
    },
    {
      path: "/login",
      name: "login",
      component: LoginView,
    },
    {
      path: "/market",
      name: "market",
      component: MarketView,
      meta: { requiresAuth: true },
    },
    {
      path: '/dataset/:id',
      name: 'CreateOrder',
      component: CreateOrder,
      meta: { requiresAuth: true },
    },

    {
      path: '/buyorder/:id',
      name: 'BuyOrder',
      component: BuyOrder,
      meta: { requiresAuth: true },
    },
    {
      path: '/sellorder/:id',
      name: 'SellOrder',
      component: SellOrder,
      meta: { requiresAuth: true },
    },

    {
      path: "/buy",
      name: "buy",
      component: BuyView,
      meta: { requiresAuth: true },
    },
    {
      path: "/sell",
      name: "sell",
      component: SellView,
      meta: { requiresAuth: true },
    },
    {
      path: "/finance",
      name: "finance",
      component: FinanceView,
      meta: { requiresAuth: true },
    },
    {
      path: "/create",
      name: "create",
      component: DataView,
      meta: { requiresAuth: true },
    },
  ],
});

router.beforeEach((to, from, next) => {
  const authStore = useAuthStore();
  const requiresAuth = to.matched.some(record => record.meta.requiresAuth);
  const isLoggedIn = authStore.isLoggedIn;

  if (requiresAuth && !isLoggedIn) {
    next('/login');
  } else {
    next();
  }
});

export default router;
