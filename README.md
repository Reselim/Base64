# Base64

A pretty fast Luau Base64 encoder

## Installation

### [Wally](https://wally.run/)

Add the following to your `wally.toml` under `[dependencies]`:

```toml
base64 = "reselim/base64@2.0.3"
```

### Manual

[Download the latest release](https://github.com/Reselim/Base64/releases/latest) from the releases page and drag it into Studio.

## Usage

```lua
local Base64 = require(path.to.Base64)

local data = "Hello, world!"

local encodedData = Base64.encode(data) -- "SGVsbG8sIHdvcmxkIQ=="
local decodedData = Base64.decode(encodedData) -- "Hello, world!"
```

## Benchmarks

Benchmarks ran in Roblox Studio with a payload of **10,000,000** characters running on a **Ryzen 5900X** and **32GB RAM @ 3200MHz**, as of **2023/11/03**

#### Native mode OFF:
- Encode: 569.976ms (17,544,586/s)
- Decode: 333.244ms (30,008,033/s)

#### Native mode ON:
- Encode: 365.399ms (27,367,321/s)
- Decode: 166.880ms (59,923,405/s)