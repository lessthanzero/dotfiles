---
name: media-inventory-rate
description: >-
  Record ratings for movies, TV shows, albums, or games into Obsidian inventory
  YAML (normalise scale, dedupe), optionally tag matching Radarr/Sonarr/Lidarr
  entries already in the library without adding titles or files, then sync the
  vault. Use when the user says rate movie, rate show, rate album, rate game,
  record rating, inventory rate, or gives a score for a title to keep in inventory.
---

# Media Inventory Rate

Upsert a watched/played rating into the Obsidian media inventory, normalise the
score to that file’s scale, dedupe, optionally tag an existing \*arr entry, sync
the vault.

**Requires Agent mode** — writes inventory YAML and runs git sync.

## Hard rules

- **Never** `POST` new movies/series/artists/albums to Radarr/Sonarr/Lidarr.
- **Never** trigger downloads, searches, or monitored grabs.
- If the title is **not already** in the relevant \*arr app, skip \*arr and only update YAML.
- If \*arr is down or SkyHook times out, still finish YAML + vault sync; report the skip.
- Edit **iCloud** inventory first; never write only to `vault-mirror`.
- Do not invent TMDB / MusicBrainz IDs.

## Paths

| Role | Path |
|------|------|
| Vault root | `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Vault` |
| Movies | `context/inventory/movies.yaml` |
| TV | `context/inventory/shows.yaml` |
| Albums | `context/inventory/music.yaml` |
| Games | `context/inventory/games.yaml` |
| Sync | `~/Developer/dotfiles/scripts/agent/sync-vault.sh` |
| \*arr config | `~/Developer/music-library/media-intake/config.yaml` |
| Schema notes | [`reference.md`](reference.md) |

## Workflow

```
- [ ] 1. Detect media type (movie / show / album / game); ask if ambiguous
- [ ] 2. Parse rating + optional watched/played date; normalise to target scale
- [ ] 3. Load inventory YAML; find existing entry (id → title+year); dedupe merges
- [ ] 4. Upsert entry (preserve unknown fields; append Manual to sources if new)
- [ ] 5. Best-effort *arr tag if already present (no add)
- [ ] 6. Run sync-vault.sh; report path, normalised score, *arr action, commit hash
```

## Detect type

| Type | File | Match keys |
|------|------|------------|
| Movie | `movies.yaml` | `title` + `release_year` / `tmdb_id` |
| TV | `shows.yaml` | `title` (often `"Show: Season N"`) + year |
| Album | `music.yaml` | `artist` + `title` (+ MusicBrainz ids if known) |
| Game | `games.yaml` | `name` + `platform` when given |

Ask only when the same title could be multiple types or the year is wrong.

## Normalise rating

Accept `8/10`, `4/5`, `4.0`, `★★★★`, `4 stars`. Map into the **target file’s** scale:

| Inventory | Scale | Example |
|-----------|-------|---------|
| movies, shows | Letterboxd **0–5** half-stars | `8/10` → `4.0` |
| games | **0–10** integers | `8/10` → `8` |
| music | **0–5** half-stars (optional fields) | `9/10` → `4.5` |

Formulas:

- To 0–5: `score_out = round(score_in / scale_in * 5 * 2) / 2`
- To 0–10: `score_out = round(score_in / scale_in * 10)`

Defaults when watching/playing is implied:

- `liked: true` if normalised ≥ `4.0` (0–5) or ≥ `8` (0–10); else `false` unless user said otherwise
- `watched_date` (movies/shows/music) or honour `played_year` (games): user date, else today `YYYY-MM-DD`
- `status: Completed`

Music entries historically lack rating fields — **add** optional `rating`, `liked`, `watched_date` only when the user rates that album; leave unscored albums unchanged.

## Dedupe / upsert

1. Prefer match on `tmdb_id` / MusicBrainz ids.
2. Else case-fold title/`name` + year (and `artist` / `platform` when relevant).
3. If multiple rows match the same identity: merge into one (keep richest non-empty fields), remove extras.
4. Update rating/dates in place; preserve other keys.
5. `sources`: keep existing; append `Manual` for new or newly rated Manual entries.

Keep YAML list order alphabetical by primary title/`name`/`artist` when inserting a **new** row (match neighbouring style). Do not reorder the whole file unless required for a clean insert.

## *arr feedback (tags only)

\*arr has **no** first-class user rating. Tags are the only feedback. Do **not** claim a numeric rating was stored in \*arr.

When `media-intake` config and APIs are reachable:

| App | Find | If found |
|-----|------|----------|
| Radarr | Movie list by `tmdbId` or title+year | Ensure tags include `rated-<score>` (e.g. `rated-4.0`) and `watched` when completed; **do not** POST `/movie` |
| Sonarr | Series list by title | Same tags; **do not** add series |
| Lidarr | Artist/album if clearly matchable | Same; **do not** add artist/album |

Leave `monitored` unchanged unless the user explicitly said they do not want downloads — then set `monitored: false` on the **existing** record only.

Create missing tag labels via the app’s tag API if needed, then attach tag ids to the record.

## Persist vault

```bash
~/Developer/dotfiles/scripts/agent/sync-vault.sh
```

Report: inventory path, normalised rating, whether \*arr was tagged or skipped, commit hash.

### Mac vs Fedora

- **Mac:** full YAML write + sync
- **Fedora:** cannot write iCloud; document the intended YAML diff and ask the user to run on Mac

## Examples

**Movie (Letterboxd scale):** “Conclave 8/10, watched today” → `movies.yaml` `rating: 4.0`, `watched_date` today, `liked: true`; Radarr tag only if already present.

**Movie unscored:** “The Return watched today, no score” → entry with `watched_date`, no `rating` field forced.

**Show:** “Fallout Season 1 4/5” → `shows.yaml` `rating: 4.0`.

**Album:** “Burial Untrue 9/10” → find/create `music.yaml` row for artist+title; set `rating: 4.5`.

**Game:** “Hades 9/10 on Switch” → `games.yaml` `rating: 9` (0–10 scale).

## Do not

- Add files to NAS or staging as part of this skill
- Monitor new \*arr items or run RSS/search
- Overwrite games onto 0–5 (keep 0–10)
- Touch `books.yaml` / `devices.yaml` in v1

## Runtimes

| Runtime | Invoke |
|---------|--------|
| Cursor | Say "rate movie" / "record rating" / etc. |
| Antigravity | Same trigger phrases |
| Codex | Reference media-inventory-rate skill |
| Claude Code | `/media-inventory-rate` or trigger phrase; `/reload-skills` after deploy |
