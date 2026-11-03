# Table

Table helpers: deep copy, sum, length of packed tables, safe concat, deep equality.

| | |
| --- | --- |
| Folder | `src/libs/Internal/Table` |
| Exposes | `I.Table` |
| Runs on | Both sides |

## Files

| File | What it controls |
| --- | --- |
| `init.lua` | Every function |

## API

| Function | Returns | What it does |
| --- | --- | --- |
| `I.Table.DeepCopy(t: { [any]: any })` | `{ [any]: any }` | Deep copies a table without metatables. Cyclic references and shared subtables are preserved in the copy. |
| `I.Table.Sum(t: { [any]: any })` | `number` | Sums every numeric value in the table, including numeric strings. |
| `I.Table.PackedLength(t: { [any]: any })` | `number` | Returns the total key count of the table, including non-array keys. |
| `I.Table.SafeConcat(t: { any }, sep: string?, i: number?, j: number?)` | `string` | Concatenates `t[i]` through `t[j]` with `sep`, converting every value with `tostring`. |
| `I.Table.Equal(t1: { [any]: any }, t2: { [any]: any })` | `boolean` | Performs a shallow comparison of two tables. |
