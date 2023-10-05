# Base64

A pretty fast Luau Base64 encoder

## Installation

### [Wally](https://wally.run/)

Add the following to your `wally.toml` under `[dependencies]`:

```toml
base64 = "reselim/base64@2.0.3"
```

### Manual

[Download the latest release](https://github.com/Reselim/Base64/releases/download/latest/Base64.rbxm) from the releases page and drag it into Studio.

## Usage

```lua
local Base64 = require(path.to.Base64)

local data = "Hello, world!"

local encodedData = Base64.encode(data) -- "SGVsbG8sIHdvcmxkIQ=="
local decodedData = Base64.decode(encodedData) -- "Hello, world!"
```

## Benchmarks

Benchmarks ran in Roblox Studio with a payload of **10,000,000** characters running on a **Ryzen 5900X** and **32GB RAM @ 2133MHz**, as of **2023/08/31**

#### Native mode OFF:
- Encode: 524.15ms (19,078,215/s)
- Decode: 356.88ms (28,020,045/s)

#### Native mode ON:
- Encode: 338.07ms (29,579,197/s)
- Decode: 203.61ms (49,111,619/s)