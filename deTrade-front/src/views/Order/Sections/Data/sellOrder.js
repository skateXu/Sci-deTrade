/*
=========================================================
* Vue Material Kit 2 - v1.0.0
=========================================================

* Product Page: https://www.creative-tim.com/product/vue-material-kit-pro
* Copyright 2021 Creative Tim (https://www.creative-tim.com)

Coded by www.creative-tim.com

 =========================================================

* The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
*/

const imagesPrefix =
  "https://raw.githubusercontent.com/creativetimofficial/public-assets/master/material-design-system/presentation/sections";

import imgPricing from "@/assets/img/pricing.png";
import imgFeatures from "@/assets/img/features.png";
import imgBlogPosts from "@/assets/img/blog-posts.png";
import imgTestimonials from "@/assets/img/testimonials.png";
import imgTeam from "@/assets/img/team.png";
import imgStat from "@/assets/img/stat.png";

export default [
  {
    heading: "出售订单",
    description:
      "您的所有出售的订单管理",
      items: [
        {
          id: "1",
          image: `${imagesPrefix}/headers.jpg`,
          title: "金融数据",
          subtitle: "10GB",
          route: "SellOrder",
          pro: false
        },
        {
          id: "1",
          image: imgFeatures,
          title: "电力数据",
          subtitle: "14GB",
          route: "SellOrder",
          pro: false
        },
        {
          id: "1",
          image: imgPricing,
          title: "A股融资数据",
          subtitle: "3GB",
          route: "SellOrder",
          pro: false
        },
        {
          id: "1",
          image: `${imagesPrefix}/faq.jpg`,
          title: "tick级美股交易数据",
          subtitle: "100GB",
          route: "SellOrder",
          pro: false
        },
        {
          id: "1",
          image: imgBlogPosts,
          title: "比特币链上交易数据",
          subtitle: "3GB",
          route: "SellOrder",
          pro: false
        },
        {
          id: "1",
          image: imgTestimonials,
          title: "微信公众号活跃数据",
          subtitle: "11GB",
          route: "SellOrder",
          pro: false
        },
        {
          id: "1",
          image: imgTeam,
          title: "磷酸铁锂产能数据",
          subtitle: "2GB",
          route: "SellOrder",
          pro: false
        },
        {
          id: "1",
          image: imgStat,
          title: "糖尿病患者血糖数据",
          subtitle: "7GB",
          route: "SellOrder",
          pro: false
        },
        {
          id: "1",
          image: `${imagesPrefix}/call-to-action.jpg`,
          title: "阿兹海默患者脑部CT数据",
          subtitle: "112GB",
          route: "SellOrder",
          pro: false
        },
      ]
  }
 
 
 
];
