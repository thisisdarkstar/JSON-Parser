# 🐚 JSON Parser in Pure Bash

A minimal JSON parser written in **pure Bash**, with no external dependencies.  
Supports extracting values from JSON files using simple query paths.

---

## ✨ Features

- 🗂️ Parses JSON objects and arrays
- 🔎 Extracts values using dot/bracket notation (e.g., `data.users[0].name`)
- 🌟 Supports wildcards for arrays (e.g., `data.users[*]`)
- 🚫 Returns `null` for non-existent paths
- ⚡ No dependencies except Bash (and [bats](https://github.com/bats-core/bats-core) for testing)

---

## 🚀 Usage

```sh
./json_parser.sh <json-file> '<query>'
```

### 📋 Examples

Given a file `test.json`:
```json
{
  "data": {
    "users": [
      { "name": "Yug", "role": "Admin" },
      { "name": "Nova", "role": "User" },
      { "name": "Bob", "role": "User" }
    ]
  }
}
```

Extract a single value:
```sh
./json_parser.sh test.json 'data.users[0].name'
# Output: "Yug"
```

Extract a value from another user:
```sh
./json_parser.sh test.json 'data.users[2].role'
# Output: "User"
```

Extract all users:
```sh
./json_parser.sh test.json 'data.users[*]'
# Output: [{"name":"Yug","role":"Admin"},{"name":"Nova","role":"User"},{"name":"Bob","role":"User"}]
```

Non-existent path:
```sh
./json_parser.sh test.json 'data.users[5].name'
# Output: null
```

---

## 🧪 Running Tests

This project uses [bats](https://github.com/bats-core/bats-core) for unit testing.

### 1️⃣ Install Bats

If you don’t have Bats installed, you can install it via Homebrew (macOS), Chocolatey (Windows), or from source:

- **macOS:**  
  ```sh
  brew install bats-core
  ```
- **Windows (with Chocolatey):**  
  ```sh
  choco install bats
  ```
- **From source:**  
  See [bats-core installation guide](https://github.com/bats-core/bats-core#installation).

### 2️⃣ Run the Tests

From your project directory, run:

```sh
bats unit_test.sh
```

#### 🟢 Example Output

```
 ✓ Extract simple value: data.users[0].name
 ✓ Extract simple value: data.users[2].role
 ✓ Extract full array: data.users[*]
 ✓ Extract full array without *: data.users
 ✓ Non-existent path returns null
 ✓ Invalid query shows null

6 tests, 0 failures
```

You should see green checkmarks for each passing test and a summary at
---

## ⚠️ Limitations

- Only supports a subset of JSON (no support for all edge cases)
- Does not handle escaped quotes inside strings
- Not suitable for very large or deeply nested JSON

---

## 📄 License

MIT License

---

> 🧑‍💻 Inspired by the challenge of parsing JSON with