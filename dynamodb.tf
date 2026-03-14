# Create DynamoDB to store book info
resource "aws_dynamodb_table" "book_inventory" {
  name         = "${local.name_prefix}-book-inventory"  # prefixed table name
  billing_mode = "PAY_PER_REQUEST"                      # on-demand
  hash_key     = "ISBN"                                 # primary key
  range_key    = "Genre"                                # sort key

  # primary key attribute
  attribute {
    name = "ISBN"
    type = "S"
  }

  # sort key attribute
  attribute {
    name = "Genre"
    type = "S"
  }
}