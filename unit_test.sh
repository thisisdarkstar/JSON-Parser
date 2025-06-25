#!/usr/bin/env bats

load 'bats-support/load'
load 'bats-assert/load'

setup() {
  cat > test.json <<EOF
{
  "data": {
    "users": [
      { "name": "Yug", "role": "Admin" },
      { "name": "Nova", "role": "User" },
      { "name": "Bob", "role": "User" }
    ]
  }
}
EOF
}

teardown() {
  rm -f test.json
}

@test "Extract simple value: data.users[0].name" {
  run ./json_parser.sh test.json 'data.users[0].name'
  assert_output "\"Yug\""
}

@test "Extract simple value: data.users[2].role" {
  run ./json_parser.sh test.json 'data.users[2].role'
  assert_output "\"User\""
}

@test "Extract full array: data.users[*]" {
  run ./json_parser.sh test.json 'data.users[*]'
  assert_output --partial '"name":"Yug","role":"Admin"'
  assert_output --partial '"name":"Nova","role":"User"'
  assert_output --partial '"name":"Bob","role":"User"'
}

@test "Extract full array without *: data.users" {
  run ./json_parser.sh test.json 'data.users'
  assert_output --partial '"name":"Yug","role":"Admin"'
  assert_output --partial '"name":"Nova","role":"User"'
  assert_output --partial '"name":"Bob","role":"User"'
}

@test "Non-existent path returns null" {
  run ./json_parser.sh test.json 'data.users[5].name'
  assert_output "null"
}

@test "Invalid query shows null" {
  run ./json_parser.sh test.json 'invalid.path'
  assert_output "null"
}