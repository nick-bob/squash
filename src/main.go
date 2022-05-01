package main

import (
	_ "ariga.io/atlas/sql/schema"
	_ "ariga.io/atlas/sql/sqlite"
	_ "database/sql"
	"fmt"
	_ "log"
	"os"
	api "squash/api/v1"
	_ "testing"
)

func main() {
	fmt.Println("Running version 1.1")
	fmt.Println(os.Getenv("DB_USER"))
	api.Start("http://localhost:8080")
}
