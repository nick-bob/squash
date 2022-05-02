package v1

import (
	"context"
	"database/sql"
	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq"
	"math/rand"
	"net/http"
	"strings"
	"time"
)

var letters = []rune("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
var squashLength = 9

type SquashLink struct {
	id           int
	original_url string
	squash_id    string
}

func Start(ctx context.Context) {
	connStr := ctx.Value("dbConnStr").(string)
	hostname := ctx.Value("hostname").(string)

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	rand.Seed(time.Now().UnixNano())

	r := gin.Default()

	r.POST("/newurl", func(c *gin.Context) {
		squashId := randSeq(squashLength)

		link := SquashLink{
			squash_id:    squashId,
			original_url: strings.ToLower(c.PostForm("url")),
		}
		_, err = db.Exec("insert into squash_link (original_url, squash_id) values ($1, $2)", link.original_url, link.squash_id)
		if err != nil {
			panic(err)
		}

		c.JSON(http.StatusOK, gin.H{
			"url":       link.original_url,
			"sLink":     strings.Join([]string{hostname, squashId}, "/"),
			"squash_id": link.squash_id,
		})
	})

	r.GET("/:squashLink", func(c *gin.Context) {
		squashId := c.Param("squashLink")
		var link SquashLink
		err := db.QueryRow("select * from squash_link where squash_id = $1", squashId).Scan(&link.id, &link.original_url, &link.squash_id)
		if err != nil {
			panic(err)
		}
		c.JSON(http.StatusOK, gin.H{
			"url": link.original_url,
		})
	})

	r.Run(":8080")
}

func randSeq(n int) string {
	b := make([]rune, n)
	for i := range b {
		b[i] = letters[rand.Intn(len(letters))]
	}
	return string(b)
}
