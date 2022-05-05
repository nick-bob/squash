package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/GuiaBolso/darwin"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ssm"
	_ "github.com/lib/pq"

	_ "os"
	api "squash/api/v1"
	_ "testing"
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

func connectDbByEnv() (*sql.DB, string) {
	dbUser := os.Getenv("DB_USER")
	dbPassowrd := os.Getenv("DB_USER")
	dbHost := os.Getenv("DB_HOST")
	sslMode := os.Getenv("DB_SSL_MODE")
	connStr := fmt.Sprintf("user=%s password=%s host=%s port=5432 sslmode=%s", dbUser, dbPassowrd, dbHost, sslMode)
	time.Sleep(5 * time.Second)

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		panic(err)
	}

	err = db.Ping()
	if err != nil {
		panic(err)
	}
	fmt.Println("Connection made")
	return db, connStr
}

func connectDbBySSM(svc *ssm.SSM) (*sql.DB, string) {
	dbHost := fetchSSMParam(svc, "SQUASH_DB_HOST")
	dbPassword := fetchSSMParam(svc, "SQUASH_DB_PASSWORD")
	dbUser := fetchSSMParam(svc, "SQUASH_DB_USER")
	sslMode := "disable"
	connStr := fmt.Sprintf("user=%s password=%s host=%s port=5432 sslmode=%s", dbUser, dbPassword, dbHost, sslMode)

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		panic(err)
	}

	err = db.Ping()
	if err != nil {
		panic(err)
	}
	fmt.Println("Connection made")
	return db, connStr
}

func fetchSSMParam(svc *ssm.SSM, key string) string {
	fmt.Sprintln("Retrieving $1 from SSM", key)
	param, err := svc.GetParameter(&ssm.GetParameterInput{
		Name:           aws.String(key),
		WithDecryption: aws.Bool(false),
	})
	if err != nil {
		panic(err)
	}
	return *param.Parameter.Value
}

func migrate(db *sql.DB) {
	driver := darwin.NewGenericDriver(db, darwin.PostgresDialect{})
	d := darwin.New(driver, migrations, nil)
	err := d.Migrate()

	if err != nil {
		log.Println(err)
	}
}

func main() {
	var connStr, hostname string

	_, envVarsEnabled := os.LookupEnv("DB_HOST")
	if envVarsEnabled {
		db, connStr = connectDbByEnv()
		hostname = os.Getenv("HOSTNAME")
	} else {
		sess, err := session.NewSessionWithOptions(session.Options{
			Config:            aws.Config{Region: aws.String("us-east-")},
			SharedConfigState: session.SharedConfigEnable,
		})
		if err != nil {
			panic(err)
		}
		svc := ssm.New(sess, aws.NewConfig().WithRegion("us-east-1"))

		db, connStr = connectDbBySSM(svc)
		hostname = fetchSSMParam(svc, "SQUASH_HOSTNAME")
	}

	migrate(db)

	ctx := context.Background()
	ctx = context.WithValue(ctx, "hostname", hostname)
	ctx = context.WithValue(ctx, "dbConnStr", connStr)

	api.Start(ctx)
}
