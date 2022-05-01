package v1

import (
	"github.com/gin-gonic/gin"
	"math/rand"
	"net/http"
	"strings"
	"time"
)

var letters = []rune("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")

type SquashLink struct {
	sId   string
	sLink string
	url   string
}

func Start(hostname string) {
	rand.Seed(time.Now().UnixNano())
	var links []SquashLink

	r := gin.Default()

	r.POST("/newurl", func(c *gin.Context) {
		squashId := randSeq(9)

		link := SquashLink{
			sId:   squashId,
			sLink: strings.Join([]string{hostname, squashId}, "/"),
			url:   c.PostForm("url"),
		}
		links = append(links, link)

		c.JSON(http.StatusOK, gin.H{
			"url":   link.url,
			"sLink": link.sLink,
			"sId":   link.sId,
		})
	})

	r.GET("/:squashLink", func(c *gin.Context) {
		squashId := c.Param("squashLink")
		found := false

		for i := 0; i < len(links); i++ {
			sLink := links[i]
			if sLink.sId == squashId {
				c.Redirect(http.StatusNotModified, sLink.url)
				found = true
				break
			}
		}
		if !found {
			c.JSON(http.StatusNotFound, gin.H{
				"Error": "Squash not found",
			})
		}
	})

	r.Run(":8080")
}

// shamelessly taken from: https://stackoverflow.com/questions/22892120/how-to-generate-a-random-string-of-a-fixed-length-in-go/22892986#22892986
func randSeq(n int) string {
	b := make([]rune, n)
	for i := range b {
		b[i] = letters[rand.Intn(len(letters))]
	}
	return string(b)
}
