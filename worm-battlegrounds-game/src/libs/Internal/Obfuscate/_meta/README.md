# Obfuscate

Random strings and shuffles; Network uses it to give remotes unreadable names.

| | |
| --- | --- |
| Folder | `src/libs/Internal/Obfuscate` |
| Exposes | `I.Obfuscate` |
| Runs on | Both sides |

## Files

| File | What it controls |
| --- | --- |
| `init.lua` | The charsets and the functions |

## API

| Function | Returns | What it does |
| --- | --- | --- |
| `I.Obfuscate.GetRandomString(length: number?, charset: string?)` | `string` | Returns a random string of `length` characters picked from a named charset (`Default` when omitted). |
| `I.Obfuscate.Shuffle(input: string)` | `string` | Returns `input` with its characters in a random order. |
