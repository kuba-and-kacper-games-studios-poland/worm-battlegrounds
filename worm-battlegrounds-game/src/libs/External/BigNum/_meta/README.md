# BigNum

Arbitrary-size integers for currencies and stats: `I.BN.new("1e+30")` objects with arithmetic and comparison operators, precise power, multiply, divide and percentage, and abbreviation and separator formatting. Vendored, by Frederico Macedo Pessoa and Marco Serpa Molinaro.

| | |
| --- | --- |
| Folder | `src/libs/External/BigNum` |
| Exposes | `I.BN` |
| Runs on | Both sides |

## Files

| File | What it controls |
| --- | --- |
| `init.lua` | The class and its operators |
| `Scripts/Arithmetic.lua` | Add, subtract, multiply, divide, power |
| `Scripts/Comparison.lua` | Comparisons |
| `Scripts/Precise.lua` | Fixed-precision operations |
| `Scripts/Convert.lua` | Abbreviations and separators |
| `Scripts/Metatable.lua` | Operators |
| `Scripts/Helpers.lua` | Internals |
| `_meta/_types.lua` | `BigNum_Instance`, `BigNum_Value` |

## API

### Create

Objects support `+ - * / ^ % == < <=` and `tostring`. Saved values and attributes are BigNum strings (`tostring(bn)`).

| Function | Returns | What it does |
| --- | --- | --- |
| `I.BN.new(value: BigNum_Value?)` | `BigNum_Instance` | Creates a BigNum from a number, an integer / decimal / scientific string, or another BigNum (copied). Fractions are truncated toward zero. No value creates zero. |
| `I.BN.IsBigNum(value: any)` | `boolean` | Returns whether the value is a BigNum instance. |
| `I.BN.ToBigNum(value: BigNum_Value?)` | `BigNum_Instance` | Returns the value itself when it is a BigNum, otherwise a new BigNum built from it. |

### Compare

| Function | Returns | What it does |
| --- | --- | --- |
| `I.BN.Compare(bnum1: BigNum_Instance, bnum2: BigNum_Instance)` | `number` | Compares two BigNums: 1 when `bnum1` is greater, 2 when it is smaller, 0 when equal. |
| `I.BN.CompareAbs(bnum1: BigNum_Instance, bnum2: BigNum_Instance)` | `number` | Compares the absolute values of two BigNums: 1 when \|bnum1\| is greater, 2 when smaller, 0 when equal. |
| `I.BN.Eq(bnum1: BigNum_Instance, bnum2: BigNum_Instance)` | `boolean` | Returns whether two BigNums are equal. |
| `I.BN.Lt(bnum1: BigNum_Instance, bnum2: BigNum_Instance)` | `boolean` | Returns whether `bnum1` is smaller than `bnum2`. |
| `I.BN.Le(bnum1: BigNum_Instance, bnum2: BigNum_Instance)` | `boolean` | Returns whether `bnum1` is smaller than or equal to `bnum2`. |

### Arithmetic

| Function | Returns | What it does |
| --- | --- | --- |
| `I.BN.Add(bnum1: BigNum_Instance, bnum2: BigNum_Instance, bnum3: BigNum_Instance)` |  | Stores `bnum1 + bnum2` in `bnum3`. The output may be one of the inputs. |
| `I.BN.Sub(bnum1: BigNum_Instance, bnum2: BigNum_Instance, bnum3: BigNum_Instance)` |  | Stores `bnum1 - bnum2` in `bnum3`. The output may be one of the inputs. |
| `I.BN.Mul(bnum1: BigNum_Instance, bnum2: BigNum_Instance, bnum3: BigNum_Instance)` |  | Stores `bnum1 * bnum2` in `bnum3`. The output may be one of the inputs. |
| `I.BN.Div(bnum1: BigNum_Instance, bnum2: BigNum_Instance, bnum3: BigNum_Instance, bnum4: BigNum_Instance)` |  | Stores `bnum1 / bnum2` truncated toward zero in `bnum3`, and the remainder (with the sign of `bnum1`) in `bnum4`. The outputs must be new BigNums, not the inputs. |
| `I.BN.Pow(base: BigNum_Instance, exponent: BigNum_Instance)` | `BigNum_Instance` | Returns `base ^ exponent` for a non-negative integer exponent, using exponentiation by squaring. |

### Precise

| Function | Returns | What it does |
| --- | --- | --- |
| `I.BN.Power(base: BigNum_Value, exponent: number)` | `BigNum_Instance` | Returns `base ^ exponent` for a whole exponent (negative exponents count as 0). The base is rounded to a whole number. |
| `I.BN.MultiplyWithPrecision(a: BigNum_Value, b: BigNum_Value, precision: number?)` | `BigNum_Instance` | Returns `a * b` as a whole BigNum (truncated). Each input is rounded to `precision` decimals (0–9, default 0) first. |
| `I.BN.DivideWithPrecision(a: BigNum_Value, b: BigNum_Value, precision: number?)` | `BigNum_Instance` | Returns `a / b` as a whole BigNum (truncated toward zero). Each input is rounded to `precision` decimals (0–9, default 0) first. |
| `I.BN.PowerWithPrecision(base: BigNum_Value, exponent: number, precision: number?)` | `BigNum_Instance` | Returns `base ^ exponent` as a whole BigNum (truncated), supporting decimal bases and exponents. The exponent is rounded to 2 decimals and may be negative. `precision` (0–9, default 6) is the number of decimals the base is rounded to and used while taking roots. |
| `I.BN.Percentage(a: BigNum_Value, b: BigNum_Value, precision: number?)` | `number` | Returns `a / b` as a regular number rounded to `precision` decimals (0–9, default 2), for example 2 / 3 -> 0.67. The division runs on BigNums scaled by 10^precision, so huge values keep their ratio. Returns 0 when `b` is 0. |

### Format

| Function | Returns | What it does |
| --- | --- | --- |
| `I.BN.AbbreviationConvert(num: BigNum_Value, decimalCount: number?, returnSeparated: boolean?)` | `string, string?` | Abbreviates a whole number (`1234567` -> `1.23m` with 2 decimals). Decimals are truncated and keep trailing zeros. With `returnSeparated`, returns the number part and the suffix separately. |
| `I.BN.AbbreviationConvertFormatted(num: BigNum_Value, decimalCount: number?)` | `string` | Abbreviates a whole number and trims trailing decimal zeros (`1.20k` -> `1.2k`, `1.00k` -> `1k`). |
| `I.BN.ConvertFromAbbreviation(num: string)` | `string?` | Expands an abbreviated number (`1.5k` -> `1500`) into a whole number string, truncating extra decimals. Plain integers are returned canonically. Returns nil for anything else. |
| `I.BN.FormatWithSeparator(num: number \| string, separator: string?)` | `string` | Inserts `separator` (`,` by default) between every three integer digits, keeping the sign and any decimals. |
| `I.BN.DynamicFormat(num: number \| string, length: number?, separator: string?)` | `string` | Formats a number with separators, or abbreviates it (2 decimals, trimmed) once it has `length` or more integer digits. Values that are not numbers are returned through `tostring`. |

## Usage

```lua
local total = I.BN.new(current) + I.BN.new(amount)
label.Text = I.BN.AbbreviationConvertFormatted(total)
```

## Types

In `_meta/_types.lua`: `BigNum_Instance`, `BigNum_Value`, `BigNum_Constants`.
