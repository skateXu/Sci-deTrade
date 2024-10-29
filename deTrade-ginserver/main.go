package main

import (
    "deTrade-ginserver/router"
    "deTrade-ginserver/settings"
    

    "github.com/spf13/viper"
    "fmt"
)

func main() {
    //viper加载配置，设置端口，项目名称
    if err := settings.Init(); err != nil {
		fmt.Printf("init settings failed,err:%v\n", err)
	}
    // 注册路由
	r := router.SetupRouter()
 
    // 从 Viper 中获取配置的端口号
    r.Run(fmt.Sprintf(":%d", viper.GetInt("app.port"))) 

}