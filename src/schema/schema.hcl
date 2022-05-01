schema "public" {
  comment = "Public schema for Squash"
}

table "urls" {
  schema = schema.public
  column "id" {
    type = int
  }
  column "url" {
    type = varchar(255)
  }
  column "squash_url" {
    type = varchar(255)
  }
}