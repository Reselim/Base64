# Base64

A pretty fast Luau Base64 encoder

## Installation

### [Wally](https://wally.run/)

Add the following to your `wally.toml` under `[dependencies]`:

```toml
base64 = "reselim/base64@3.0.0"
```

### Manual

[Download the latest release](https://github.com/Reselim/Base64/releases/latest) from the releases page and drag it into Studio.

## Usage

```lua
local Base64 = require(path.to.Base64)

local data = buffer.fromstring("Hello, world!")

local encodedData = Base64.encode(data) -- buffer: "SGVsbG8sIHdvcmxkIQ=="
local decodedData = Base64.decode(encodedData) -- buffer: "Hello, world!"

print(buffer.tostring(decodedData)) -- "Hello, world!"
```

## Benchmarks

Benchmarks ran in Roblox Studio with a payload of **100,000,000** characters running on a **Ryzen 5900X** and **32GB RAM @ 3200MHz**, as of **2024/01/11**

#### Native mode OFF:
- Encode: 3303.27ms (30,273,037/s)
- Decode: 3747.17ms (26,686,826/s)

#### Native mode ON:
- Encode: 461.23ms (216,813,496/s)
- Decode: 596.37ms (167,680,012/s)