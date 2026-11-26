# MatchRewards

Pays players when a match ends: diamonds by kind, size and place (coins until 2026-11-25), XP, statistics, then the Results screen. Public
deathmatch and team matches pay by place; a solo match pays only a win, by the bot's difficulty; a party match (friends
only) pays as a public deathmatch of its size, or `PARTY_NO_BOTS_SHARE` of that without bots; custom and tutorial
matches pay no diamonds, and custom lobbies give no XP. Against farming, the last two places are paid only after `ANTI_FARM_ROUNDS` rounds or a knockout
by another player. The Double Diamonds pass doubles diamonds. Leavers get nothing. XP comes line by line: `XP_PER_MATCH` for
playing, `XP_WIN` for a win (first place, or the winning team) and `XP_PER_KNOCKOUT` for each snail knocked out (the
owner's pick, 2026-11-17). The lines are queued for the lobby's XP replay (`I.Progression.SetReplay`), added to any
still waiting (a rematch on the same server), and sent with the results. The diamonds a player was paid go into the same
replay (`I.Progression.AddReplayDiamonds`, added to any still waiting), so the lobby plays them flying into the
diamonds slot first (2026-11-24); a match that gave diamonds but no XP queues only the diamonds.

**A team that's out is paid at once** (2026-11-24, for MatchHud's knockout screen): when a team's last snail goes out
(not by leaving), its place is final, so its players are paid then, by `I.Match.GetPlacements` and `GetStats`, and
sent `MatchRewards_Earned`. Local matches and the last two teams wait for the end. At the end those players aren't
paid again, but their Results show what they earned.

| | |
| --- | --- |
| Folder | `src/modules/Main_Game/MatchRewards` |
| Runs on | Server · Match map |
| Uses | `I.Match`, `I.Currency`, `I.Progression`, `I.Statistic`, `I.G_Marketplace`, `I.Player`, `I.BN` |

## Files

| File | What it controls |
| --- | --- |
| `Server.lua` | Tracking knockouts by other players, paying a team that's out early, paying out, the results remote |
| `ServerSettings.lua` | `MatchRewards_Settings`, under a server name so clients never get the payouts |
| `_meta/_types.lua` | `MatchRewards_Earned` |

## Network

### Server

**Send: RemoteEvents**

- `Match_Results @ (placements: { Match_Placement }, stats: { [string]: Match_Stats }, earned: MatchRewards_Earned)`:
  to each player once the match ends, after their profile is saved
- `MatchRewards_Earned @ (place: number, lastPlace: number, earned: MatchRewards_Earned, stats: Match_Stats?)`:
  to each player of a team paid early, as its last snail goes out

It listens to `Match_ParticipantOut`, `Match_PhaseChanged` and `Match_Ended`.

## Data

Writes the `MatchesPlayed`, `Wins`, `Knockouts` and `DamageDealt` statistics, and diamonds and XP through their modules.
`MatchRewards_Earned`: `Diamonds` (`{ [participantId]: string }`), `Xp`, `Level`, `LevelUp`, and `XpLines`
(`{ Progression_XpLine }`), `XpBefore` and `XpAfter` (`Progression_Progress`) for the Results screen's level bar.

## Settings

| Key | Default | What |
| --- | --- | --- |
| `DEATHMATCH_DIAMONDS` | 2: 25, 8 · 4: 50, 25, 13, 8 · 6: 63 … 8 · 8: 75 … 8 | Public deathmatch diamonds by size, then place (the old coin rewards halved, rounded up) |
| `TEAM_DIAMONDS` | 2 teams: 50, 8 · 3: 50, 25, 8 · 4: 50, 30, 15, 8 | Public team diamonds by number of teams, then place |
| `TEAM_2V2_WIN` | `38` | A won 2v2 pays this instead |
| `SOLO_DIAMONDS` | Easy 20, Medium 30, Hard 40 | A solo win |
| `PARTY_NO_BOTS_SHARE` | `0.5` | The share of a deathmatch's diamonds a party match without bots pays |
| `ANTI_FARM_ROUNDS` | `2` | Rounds the last two places must play to be paid |
| `DOUBLE_DIAMONDS_PASS` | `"DoubleCoins"` | The pass that doubles diamonds; its Marketplace key keeps the old name, since gifted passes are saved by it |
| `XP_PER_MATCH`, `XP_KINDS` | `100`; Public, Solo, Party (not Custom) | XP for playing a match of those kinds; a custom lobby gives none |
| `XP_WIN`, `XP_PER_KNOCKOUT` | `50`, `10` | XP on top for a win and for each knockout |
| `XP_LABELS` | "Match played", "Victory", "1 knockout" (and the several forms) | The XP lines' text in the replay and Results |
