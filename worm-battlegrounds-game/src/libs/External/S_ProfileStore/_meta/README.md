# S_ProfileStore

Player data sessions with session locking (loleris' ProfileStore). The Player module opens every profile through it; other modules reach it through `I.Player.GetProfile` instead of using it directly. Server only: the `S_` prefix hides it from clients.

| | |
| --- | --- |
| Folder | `src/libs/External/S_ProfileStore` |
| Exposes | `I.ProfileStore` |
| Runs on | Server |

## Files

| File | What it controls |
| --- | --- |
| `init.lua` | `New`, constants, the store class |
| `Scripts/profile_store.lua` | Store methods: sessions, messages, reads, removal, versions |
| `Scripts/profile.lua` | A profile |
| `Scripts/save.lua` | Autosave |
| `Scripts/datastore.lua` | DataStore calls |
| `Scripts/mock.lua` | The mock store |
| `Scripts/version_query.lua` | Version queries |
| `Scripts/signal.lua` | Signals |
| `Scripts/runtime.lua` | The update loop |
| `Scripts/helpers.lua` | Helpers |

## API

### I.ProfileStore

`I.ProfileStore.New(storeName, template)` creates a store. Full documentation: the ProfileStore docs by loleris.

| Function | Returns | What it does |
| --- | --- | --- |
| `I.ProfileStore.SetConstant(name, value)` |  | Updates a tunable constant at runtime. Validates the name and enforces a numeric value so callers can't silently break behaviour. |
| `I.ProfileStore.Test()` |  | Exposes internal tables for test assertions. Gated to Studio only so production server code can't accidentally mutate live ProfileStore internals. Returns a fresh table of references each call. |

### Store

| Function | Returns | What it does |
| --- | --- | --- |
| `store.New(store_name, template)` |  | Creates a ProfileStore instance for the given DataStore name. Resolution of DataStoreState (Access / NoAccess / NoInternet) may happen after construction; public methods wait for it internally. |
| `store:StartSessionAsync(profile_key: string, params)` |  | Loads a profile and takes session ownership. Handles session stealing, force-load conflicts, and shutdown / cancel. |
| `store:MessageAsync(profile_key: string, message)` | `boolean` | Queues a global update on the target profile. If the profile is active on this server it's saved immediately; otherwise we publish a MessagingService hint so the owning server saves sooner. |
| `store:GetAsync(profile_key: string, version: string?)` |  | Read-only snapshot of a profile. Returned profiles are in view mode and cannot :Save() - only :SetAsync() (force-overwrite) is valid. |
| `store:RemoveAsync(profile_key: string)` | `boolean` | Deletes profile data permanently. Mock stores delete in-memory; live stores call DataStore:RemoveAsync. |
| `store:VersionQuery(profile_key: string, sort_direction: Enum.SortDirection?, min_date, max_date)` |  | Returns a VersionQuery object that can iterate historic versions. Unsupported against mock stores; returns a query that yields no profiles and warns once in Studio. |

### Profile

| Function | Returns | What it does |
| --- | --- | --- |
| `profile.New(raw_data, key_info, profile_store, key, is_mock, session_token)` |  | Builds a Profile object from a raw DataStore read (loaded_data + key_info). ProfileStore.New's internal call sites handle active / view-mode / mock distinction via arguments. |
| `profile:IsActive()` | `boolean` | True while this server still holds the session lock for the profile. Only valid synchronously - yielding invalidates the guarantee. |
| `profile:Reconcile()` |  | Fills missing fields on Profile.Data from the ProfileStore template. Safe to call repeatedly; existing values are preserved. |
| `profile:EndSession()` |  | Releases the session; subsequent :IsActive() returns false. Runs the save on a new thread so callers don't yield through a full DataStore round-trip unless they explicitly wait for OnSessionEnd. |
| `profile:AddUserId(user_id: number)` |  | Associates `user_id` with the profile (GDPR compliance). |
| `profile:RemoveUserId(user_id: number)` |  | Removes a `user_id` association (safe - no-op if not present). |
| `profile:SetAsync()` |  | Forcefully saves the profile. Only valid for view-mode profiles (returned by :GetAsync / :VersionQuery); live sessions must use :Save so session-lock invariants are respected. |
| `profile:MessageHandler(fn: (message: any, processed: () -> ()) -> ())` |  | Registers a function that handles incoming global updates (messages). Handlers are invoked in registration order; the first to call the "processed" callback locks the message so no later handlers see it. |
| `profile:Save()` |  | Immediately saves an active profile. Also reschedules the next auto save so we don't double-save shortly after. |
