package main

import (
	"context"
	"database/sql"
	"fmt"
	"github.com/GuiaBolso/darwin"
	_ "github.com/lib/pq"
	"log"
	// "os"
	api "squash/api/v1"
	_ "testing"
	"time"
)

var (
	migrations = []darwin.Migration{
		{
			Version:     1,
			Description: "Initialize tables",
			Script: `CREATE TABLE squash_link (
				id 				SERIAL PRIMARY KEY,
				original_url 	varchar(255) NOT NULL,
				squash_id 		varchar(10) NOT NULL,
				UNIQUE(original_url)
			);`,
		},
	}
)

func main() {
	fmt.Println("Running version 1.1")

	// dbUser := os.Getenv("DB_USER")
	// dbPassowrd := os.Getenv("DB_USER")
	// dbHost := os.Getenv("DB_HOST")
	// connStr := fmt.Sprintf("user=%s password=%s host=%s port=5432 sslmode=disable", dbUser, dbPassowrd, dbHost)
	// "postgres://username:password@localhost:5432/database_name"
	connStr := fmt.Sprintf("postgres://postgres:postgres@postgres:5432/postgres?sslmode=disable")
	time.Sleep(2 * time.Second)

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	err = db.Ping()
	if err != nil {
		panic(err)
	}
	fmt.Println("Connection made")

	driver := darwin.NewGenericDriver(db, darwin.PostgresDialect{})
	d := darwin.New(driver, migrations, nil)
	err = d.Migrate()

	if err != nil {
		log.Println(err)
	}

	ctx := context.Background()
	ctx = context.WithValue(ctx, "hostname", "http://localhost:8080")
	ctx = context.WithValue(ctx, "dbConnStr", connStr)
	db.Close()

	api.Start(ctx)
}
