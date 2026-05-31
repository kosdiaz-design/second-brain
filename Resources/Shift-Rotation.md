# Shift Rotation Schedule

**Role:** Police Lieutenant, Tampa PD
**Shift Hours:** 1700–0500 (Night Shift)
**Cycle Length:** 14 days (repeating)
**Anchor Date (IMMUTABLE — source of truth):** D1 = Sunday, May 17, 2026

> **Single Source of Truth.** This file is the canonical reference for shift rotation. The *anchor date* and the *14-day pattern* below never change — any date's status is computed as `(days since anchor) mod 14`. The "Current Cycle Reference" table is a derived snapshot and is advanced each cycle; if it ever looks stale, trust the anchor.

---

## 14-Day Cycle

| Day | Type | Best Training Window |
|-----|------|----------------------|
| D1  | 🟢 Off  | 1100–1500 |
| D2  | 🔴 Work | Pre-shift: 1100–1400 |
| D3  | 🔴 Work | Pre-shift: 1100–1400 |
| D4  | 🟢 Off  | 1100–1500 |
| D5  | 🟢 Off  | 1100–1500 |
| D6  | 🔴 Work | Pre-shift: 1100–1400 |
| D7  | 🔴 Work | Pre-shift: 1100–1400 |
| D8  | 🔴 Work | Pre-shift: 1100–1400 |
| D9  | 🔴 Work | Pre-shift: 1100–1400 |
| D10 | 🟢 Off  | 1100–1500 |
| D11 | 🟢 Off  | 1100–1500 |
| D12 | 🔴 Work | Pre-shift: 1100–1400 |
| D13 | 🟢 Off  | 1100–1500 |
| D14 | 🟢 Off  | 1100–1500 |

**Off days per cycle:** 7 (D1, D4, D5, D10, D11, D13, D14)
**Work days per cycle:** 7 (D2, D3, D6, D7, D8, D9, D12)

---

## Current Cycle Reference

| Day | Date | Type |
|-----|------|------|
| D1  | Sun May 31 | 🟢 Off |
| D2  | Mon Jun 1  | 🔴 Work |
| D3  | Tue Jun 2  | 🔴 Work |
| D4  | Wed Jun 3  | 🟢 Off |
| D5  | Thu Jun 4  | 🟢 Off |
| D6  | Fri Jun 5  | 🔴 Work |
| D7  | Sat Jun 6  | 🔴 Work |
| D8  | Sun Jun 7  | 🔴 Work |
| D9  | Mon Jun 8  | 🔴 Work |
| D10 | Tue Jun 9  | 🟢 Off |
| D11 | Wed Jun 10 | 🟢 Off |
| D12 | Thu Jun 11 | 🔴 Work |
| D13 | Fri Jun 12 | 🟢 Off |
| D14 | Sat Jun 13 | 🟢 Off |

**Next cycle starts:** Sunday, June 14, 2026 (repeats D1 pattern)

---

## Training Notes

- **"Morning" for Eric** = 1300–1500 (night shift sleep schedule)
- **Sabbath (Sunday)** = No training, no nudges — rest day regardless of rotation
- **Optimal training days:** Off days with no Sunday conflict
- **Zone 2 target:** 150–200 min/week at 100–115 bpm
- **Strength:** 2x/week via FitBod
- **Sciatica triggers to avoid:** planks, hip hinges, barbell squats

---

## Maintenance Protocol

- **Authority:** This file is the single source of truth for all rotation references.
- **Advancing:** When the active cycle ends (every 14 days), the *Current Cycle Reference* table rolls forward to the next D1 start date. The anchor and pattern are not touched.
- **Verification:** Any date can be checked against the anchor — `(date − May 17, 2026) mod 14` → day index → pattern.
- **Last advanced:** 2026-05-30 → cycle starting Sun May 31, 2026.

> *"Let all things be done decently and in order."* — 1 Corinthians 14:40

---

## Tags
`#schedule` `#shift` `#training-windows` `#ISF`
