package v1

import "github.com/gin-gonic/gin"
import "net/http"

func Run() {
	r := gin.Default()
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "pong",
		})
	})
	r.GET("/test", func(c *gin.Context) {
		c.Redirect(http.StatusNotModified, "https://reddit.com/")
	})
	r.StaticFile("/favicon.ico", "./assets/favicon.ico")
	r.Run() // listen and serve on 0.0.0.0:8080
}
