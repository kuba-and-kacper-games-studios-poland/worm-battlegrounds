# MatchRewards

Pays players when a match ends: coins by kind, size and place, XP, statistics, then the Results screen. Public
deathmatch and team matches pay by place; a solo match pays only a win, by the bot's difficulty; a party match (friends
only) pays as a public deathmatch of its size, or `PARTY_NO_BOTS_SHARE` of that without bots; custom and tutorial
matches pay no coins, and custom lobbies give no XP. Against farming, the last two places are paid only after `ANTI_FARM_ROUNDS` rounds or a knockout
by another player. The Double Coins pass doubles coins. Leavers get nothing. XP comes line by line: `XP_PER_MATCH` for
playing, `XP_WIN` for a win (first place, or the winning team) and `XP_PER_KNOCKOUT` for each snail knocked out (the
owner's pick, 2026-11-17). The lines are queued for the lobby's XP replay (`I.Progression.SetReplay`), added to any
still waiting (a rematch on the same server), and sent with the results.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/MatchRewards` |
| Runs on | Server · Match map |
| Uses | `I.Match`, `I.Currency`, `I.Progression`, `I.Statistic`, `I.G_Marketplace`, `I.Player`, `I.BN` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Tracking knockouts by other players, paying out, the results remote |
| `ServerSettings.lua` | `MatchRewards_Settings`, under a server name so clients never get the payouts |
| `_meta/_types.lua` | `MatchRewards_Earned` |

## Network

### Server

**Send: RemoteEvents**

- `Match_Results @ (placements: { Match_Placement }, stats: { [string]: Match_Stats }, earned: MatchRewards_Earned)`:
  to each player once the match ends, after their profile is saved

It listens to `Match_ParticipantOut`, `Match_PhaseChanged` and `Match_Ended`.

## Data

Writes the `MatchesPlayed`, `Wins`, `Knockouts` and `DamageDealt` statistics, and coins and XP through their modules.
`MatchRewards_Earned`: `Coins` (`{ [participantId]: string }`), `Xp`, `Level`, `LevelUp`, and `XpLines`
(`{ Progression_XpLine }`), `XpBefore` and `XpAfter` (`Progression_Progress`) for the Results screen's level bar.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `DEATHMATCH_COINS` | 2: 50, 15 · 4: 100, 50, 25, 15 · 6: 125 … 15 · 8: 150 … 15 | Public deathmatch coins by size, then place |
| `TEAM_COINS` | 2 teams: 100, 15 · 3: 100, 50, 15 · 4: 100, 60, 30, 15 | Public team coins by number of teams, then place |
| `TEAM_2V2_WIN` | `75` | A won 2v2 pays this instead |
| `SOLO_COINS` | Easy 20, Medium 35, Hard 60 | A solo win |
| `PARTY_NO_BOTS_SHARE` | `0.5` | The share of a deathmatch's coins a party match without bots pays |
| `ANTI_FARM_ROUNDS` | `2` | Rounds the last two places must play to be paid |
| `DOUBLE_COINS_PASS` | `"DoubleCoins"` | The pass that doubles coins |
| `XP_PER_MATCH`, `XP_KINDS` | `100`; Public, Solo, Party (not Custom) | XP for playing a match of those kinds; a custom lobby gives none |
| `XP_WIN`, `XP_PER_KNOCKOUT` | `50`, `10` | XP on top for a win and for each knockout |
| `XP_LABELS` | "Match played", "Victory", "1 knockout" (and the several forms) | The XP lines' text in the replay and Results |
