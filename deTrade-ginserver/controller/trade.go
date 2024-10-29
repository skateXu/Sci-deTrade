package controller

//网页交互对应功能函数，调用pkg中的方法与区块链交互

import (
	"fmt"

	"github.com/gin-gonic/gin"
)

// get dataset
// func getDataset(c *gin.Context) {
// 	result, err := pkg.getDataset(contract, c.PostForm("traceability_code"))
// 	if err != nil {
// 		c.JSON(200, gin.H{
// 			"message": "查询失败：" + err.Error(),
// 		})
// 		return
// 	}
// 	c.JSON(200, gin.H{
// 		"code":    200,
// 		"message": "query success",
// 		"data":    res,
// 	})

// }