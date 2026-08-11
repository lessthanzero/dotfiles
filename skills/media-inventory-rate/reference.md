# Media inventory rate — reference

## Inventory schemas (observed)

All files are YAML **lists** under:

`~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Vault/context/inventory/`

### movies.yaml

```yaml
- title: "Conclave"
  release_year: 2024
  rating: 4.0          # Letterboxd 0–5, half-stars
  liked: true
  watched_date: "2026-08-11"
  tmdb_id: 974576
  status: Completed
  sources:
    - Letterboxd Profile
    - Manual
```

Sparse rows (title + status + sources only) are valid.

### shows.yaml

```yaml
- title: "Fallout: Season 1"
  release_year: 2024
  rating: 4.0
  status: Completed
  sources:
    - Metacritic Profile
```

Prefer `"Show: Season N"` when the user rated a season, not the whole series, unless they said otherwise.

### music.yaml

```yaml
- artist: Burial
  release_type: Album
  title: Untrue
  musicbrainz_artist_id: "..."
  notes: optional
  # When rated (optional — omit on unscored albums):
  rating: 4.5
  liked: true
  watched_date: "2026-08-11"
```

Primary match: `artist` + `title`. Do not require MusicBrainz ids.

### games.yaml

```yaml
- name: Hades
  platform: Nintendo   # or PC / Xbox / etc.
  status: Completed
  rating: 9            # 0–10 integer
  metacritic: 93
  release_year: 2020
  played_year: 2021
  time_days: 40.0
```

Keep **0–10**. Do not convert historical game ratings to Letterboxd 0–5.

## Rating conversion cheat sheet

| User said | Movies/shows/music (0–5) | Games (0–10) |
|-----------|--------------------------|--------------|
| 10/10 | 5.0 | 10 |
| 9/10 | 4.5 | 9 |
| 8/10 | 4.0 | 8 |
| 7/10 | 3.5 | 7 |
| 4/5 | 4.0 | 8 |
| 3/5 | 3.0 | 6 |

## *arr tag conventions

| Tag | Meaning |
|-----|---------|
| `rated-4.0` | Normalised score string (use the inventory value, e.g. `rated-4.0` or `rated-9`) |
| `watched` | User marked completed/watched |

Radarr/Sonarr/Lidarr do **not** store personal numeric ratings. Tags only.

## API touchpoints (existing stack)

- Radarr/Sonarr: `~/Developer/music-library/media-intake` — `lib/arr.py`, `config.yaml`
- Lidarr: Docker `:8686`, API key from container config when needed
- List endpoints only for lookup; tag endpoints for updates
- **Forbidden:** `POST` create movie/series/artist, download client grabs, monitored search

## Vault sync

After editing iCloud inventory:

```bash
~/Developer/dotfiles/scripts/agent/sync-vault.sh
```

Same rules as memorise-vault: no secrets, no force-push.
