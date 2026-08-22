# Data Dictionary

Fields in `data/cleaned/nyc_hospitals_cleaned.csv` (45 rows, one per NYC hospital) and the `hospitals` table in `data/nyc_hospitals.db`.

| Field | Type | Description | Source column |
|---|---|---|---|
| `facility_id` | text | CMS Certification Number (CCN) — the unique federal hospital identifier. Used as the join key to ED measures. | Facility ID |
| `facility_name` | text | Hospital name as filed with CMS | Facility Name |
| `address`, `city`, `zip_code` | text | Street address | Address, City/Town, ZIP Code |
| `borough` | text | Manhattan, Brooklyn, Bronx, Queens, or Staten Island. Derived from the county field. | County/Parish (mapped) |
| `hospital_type` | text | Acute Care, Psychiatric, Critical Access, etc. | Hospital Type |
| `ownership` | text | Six categories: Voluntary non-profit (Private / Church / Other), Government (State / Local), Veterans Health Administration | Hospital Ownership |
| `emergency_services` | text | Yes / No — whether the facility operates an emergency department | Emergency Services |
| `overall_rating` | number | CMS overall star rating, 1–5. **Blank where CMS does not publish a rating** (originally the text `"Not Available"`). | Hospital overall rating |
| `is_rated` | boolean | True if the hospital has a star rating. False for the 10 psychiatric/specialty facilities CMS does not rate. Use `is_rated = 1` to filter rating comparisons. | derived |
| `mortality_better` / `_no_different` / `_worse` | text | Count of mortality measures where the hospital performs better than, no differently from, or worse than the national rate | Count of MORT Measures … |
| `safety_better` / `_no_different` / `_worse` | text | Same, for patient-safety measures | Count of Safety Measures … |
| `readmission_better` / `_no_different` / `_worse` | text | Same, for readmission measures | Count of READM Measures … |

## Emergency department measures

In `data/cleaned/nyc_hospitals_dashboard.csv` and the `er_measures` table, sourced from `Timely_and_Effective_Care-Hospital.csv`.

| Field | Type | Description |
|---|---|---|
| `er_wait_min` | number | CMS measure **OP_18b** — median minutes patients spend in the ED before leaving, excluding transfers and psychiatric patients. Lower is better. Reported by 31 of 45 NYC hospitals. |
| `pct_walked_out` | number | CMS measure **OP_22** — percentage of ED patients who leave before being seen by a clinician. Lower is better. Reported by 28 of 45. |
| `er_wait_vs_national` | number | `er_wait_min` minus the national average of 156.9 minutes. Positive values are slower than the national average. |

## Notes on interpretation

- **Blank is not zero.** A blank `overall_rating` means CMS does not rate that facility, not that it scored zero. All aggregate calculations exclude blanks rather than treating them as zeros.
- **Star ratings do not apply to every hospital.** They are built from general acute-care measures, so psychiatric and specialty hospitals are systematically unrated. Comparing them on this scale is not valid.
- **The measure counts** (`mortality_*`, `safety_*`, `readmission_*`) are retained as text because CMS uses `"Not Available"` in these columns as well; convert with `pd.to_numeric(..., errors='coerce')` before use.

Source: CMS Provider Data Catalog, July 2026 release — https://data.cms.gov/provider-data/topics/hospitals
