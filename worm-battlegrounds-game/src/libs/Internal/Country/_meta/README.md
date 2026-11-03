# Country

Country data (name, ISO codes, calling code, flag emoji) looked up by any of its keys.

| | |
| --- | --- |
| Folder | `src/libs/Internal/Country` |
| Exposes | `I.Country` |
| Runs on | Both sides |

## Files

| File | What it controls |
| --- | --- |
| `init.lua` | The lookups |
| `Data/Countries.lua` | Every country |
| `_meta/_types.lua` | `Country_CountryData` |

## API

| Function | Returns | What it does |
| --- | --- | --- |
| `I.Country.GetByName(countryName: string)` | `Country_CountryData?` | Returns the country with this name (case-insensitive). |
| `I.Country.GetByAlpha2(alpha2: string)` | `Country_CountryData?` | Returns the country with this ISO 3166-1 alpha-2 code (case-insensitive). |
| `I.Country.GetByAlpha3(alpha3: string)` | `Country_CountryData?` | Returns the country with this ISO 3166-1 alpha-3 code (case-insensitive). |
| `I.Country.GetByCountryCode(countryCode: string \| number)` | `Country_CountryData?` | Returns the country with this ISO 3166-1 numeric code. Numbers and short strings are zero-padded (4 -> "004"). |
| `I.Country.GetByEmoji(flagEmoji: string)` | `Country_CountryData?` | Returns the country with this flag emoji. |

## Usage

```lua
local country = I.Country.GetByAlpha2("PL") --- @type Country_CountryData?
```

## Types

In `_meta/_types.lua`: `Country_CountryData`.
