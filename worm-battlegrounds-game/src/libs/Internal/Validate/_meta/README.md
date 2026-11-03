# Validate

Argument schemas: checks a schema is well formed (`Types`) and that values match it (`Args`). Network and Topic use it for `argTypes`; the schema forms are in `_meta/_types.lua` and the Network README.

| | |
| --- | --- |
| Folder | `src/libs/Internal/Validate` |
| Exposes | `I.Validate` |
| Runs on | Both sides |

## Files

| File | What it controls |
| --- | --- |
| `init.lua` | `Types`, `Args`, `Compile` and `CompiledArgs` |
| `Scripts/Schema.lua` | Reading schema entries |
| `Scripts/Match.lua` | Type matching |
| `Scripts/Constraints.lua` | `Min`, `Max`, `Length` and the other constraints |
| `Scripts/ValidateValue.lua` | One value against one entry |
| `Scripts/BigNum.lua` | BigNum checks |
| `_meta/_types.lua` | Schema shapes |

## API

| Function | Returns | What it does |
| --- | --- | --- |
| `I.Validate.Types(argumentSchema: Validate_ArgumentSchema)` | `boolean, string?` | Checks that an argument schema is a well-formed array of type names or `Validate_SchemaSpec` tables. Unknown fields, wrong field types, and malformed nested `Elements` fail. Values are not checked. |
| `I.Validate.Args(argumentValues: { [any]: any }, argumentSchema: Validate_ArgumentSchema)` | `boolean, string?` | Validates sequential arguments (`table.pack(...)` or a plain array) against an argument schema. `BigNum` slots accept a BigNum instance or an integer string. Errors are prefixed with the 1-based argument index, for example `(2)(Min)`. |
| `I.Validate.Compile(argumentSchema: Validate_ArgumentSchema)` | `{ Validate_SchemaSpec }?` | Turns a schema into its spec list once. `nil` (and a warn) when an entry isn't a schema entry. Network and Topic compile each schema when it is registered. |
| `I.Validate.CompiledArgs(argumentValues: { [any]: any }, specs: { Validate_SchemaSpec })` | `boolean, string?` | `Args` against a spec list from `Compile`, without rebuilding the specs on every call. |

## Usage

```lua
local ok: boolean, err: string? = I.Validate.Args(table.pack(...), { "Player", "string" })
```

## Types

In `_meta/_types.lua`: `Validate_SchemaSpec`, `Validate_SchemaEntry`, `Validate_ArgumentSchema`, `Validate_Internal`.
