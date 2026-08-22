# NYC Hospital Quality & Emergency Department Operations Analysis

An analysis of hospital quality ratings and emergency department performance across New York City's 45 hospitals, using federal CMS Care Compare data. Built with Python, SQL, and Tableau.

**📊 [View the interactive dashboard on Tableau Public](https://public.tableau.com/app/profile/sheriffa.singh/viz/nyc_hospital_quality/NYCHospitalQualityEROperations)**

---

## Business Problem

A health system's leadership team wants an external read on how NYC hospitals compare on federal quality measures. Star ratings alone tell them who scores poorly, but not *why*, and not where operational intervention would matter most. Leadership needs to know which specific facilities warrant investigation, and whether low ratings reflect isolated failures or a structural pattern across the city.

## Objective

Identify performance differences across NYC hospitals, determine whether those differences track with geography or ownership, and connect quality ratings to a concrete operational metric — emergency department throughput — to produce a prioritized list of facilities for leadership review.

## Dataset

Two public files from the **CMS Provider Data Catalog** (Centers for Medicare & Medicaid Services), July 2026 release:

| File | Contents | Rows |
|---|---|---|
| `Hospital_General_Information.csv` | Every US hospital: overall star rating, ownership, type, services | 5,419 |
| `Timely_and_Effective_Care-Hospital.csv` | Quality measures per hospital, including ED timing measures | 138,084 |

Source: [data.cms.gov/provider-data](https://data.cms.gov/provider-data/topics/hospitals)

Filtered to the 45 hospitals in NYC's five boroughs (counties: New York, Kings, Bronx, Queens, Richmond).

**Key fields used**

- `Hospital overall rating` — CMS 1–5 star summary score
- `Hospital Ownership` — government, non-profit, VA, etc.
- `County/Parish` — mapped to borough names
- `OP_18b` — median minutes a patient spends in the ED before leaving (lower is better)
- `OP_22` — percentage of patients who leave the ED before being seen (lower is better)

## Tools

- **Python (pandas)** — cleaning, filtering, missing-value analysis
- **SQL (SQLite)** — aggregation, grouping, joins, conditional logic
- **Tableau Public** — dashboard
- **Git / GitHub** — version control and documentation

SQLite was chosen because it runs natively on macOS with no server or credentials, which keeps the analysis fully reproducible by anyone who clones this repository.

## Data Cleaning

Documented in [`notebooks/01_data_cleaning.ipynb`](notebooks/01_data_cleaning.ipynb).

1. **Scoped** the national file to the 45 NYC hospitals.
2. **Handled missing ratings correctly.** The rating column stores `"Not Available"` as text for unrated hospitals. These were converted to true missing values, never to zero — an unrated hospital has not failed, it simply is not scored.
3. **Investigated why data was missing** rather than just dropping it. The 10 unrated NYC hospitals are almost entirely psychiatric facilities plus one eye-and-ear specialty hospital. CMS star ratings are built from general acute-care measures these facilities do not report. They are retained in the cleaned file and flagged with `is_rated`, but excluded from rating comparisons.
4. **Standardized structure** — 38 columns reduced to 20, renamed to `snake_case`, with a readable `borough` column added.
5. **Preserved raw data.** All transformations write to `data/cleaned/`; the CMS downloads are untouched.

## Analysis

Queries are in [`sql/`](sql/), ordered as the investigation progressed:

1. [`01_borough_performance.sql`](sql/01_borough_performance.sql) — top performers and rating profile by borough
2. [`02_ownership_analysis.sql`](sql/02_ownership_analysis.sql) — testing ownership as an explanation for the borough gap
3. [`03_er_join_analysis.sql`](sql/03_er_join_analysis.sql) — joining ED measures to ratings, benchmarking NYC against national averages, building the watchlist

Row counts were validated against the source API before analysis to confirm nothing was lost in transfer.

## Key Questions

1. Which NYC hospitals perform best and worst on CMS overall ratings?
2. Does hospital quality vary by borough?
3. Does ownership type explain any borough differences?
4. How do NYC emergency departments compare to national performance?
5. Do low-rated hospitals also show weak ED operations, or are these independent problems?
6. Which facilities should leadership investigate first?

## Dashboard

**[NYC Hospital Quality & ER Operations →](https://public.tableau.com/app/profile/sheriffa.singh/viz/nyc_hospital_quality/NYCHospitalQualityEROperations)**

Three views, each answering one question above:

- **Rating by Borough** — average CMS star rating per borough
- **Rating vs ER Wait** — every hospital plotted by rating against median ED time, colored by borough, exposing which facilities are weak on both
- **Watchlist** — hospitals rated 2 stars or below, with their ED wait times and walkout rates

Workbook file: [`dashboard/nyc_hospital_quality.twb`](dashboard/nyc_hospital_quality.twb)

## Key Findings

**1. Hospital quality varies sharply by borough.**

| Borough | Rated hospitals | Avg. star rating |
|---|---|---|
| Manhattan | 11 | 3.73 |
| Queens | 6 | 2.17 |
| Bronx | 6 | 2.17 |
| Staten Island | 2 | 2.00 |
| Brooklyn | 10 | 1.80 |

Manhattan averages nearly two full stars above Brooklyn. Manhattan's *lowest*-rated hospital scores at or above the *average* hospital in every other borough. All five of the city's 5-star hospitals are in Manhattan except one — NewYork-Presbyterian/Queens.

**2. Ownership is part of the story, but not all of it.**

| Ownership | Hospitals | Avg. rating |
|---|---|---|
| VA | 3 | 3.67 |
| Voluntary non-profit | 23 | 2.65 |
| Government | 9 | 1.89 |

Government-run hospitals average nearly a full star below non-profits. However, the borough gap persists within ownership categories, and government hospitals are not concentrated in a single borough — Manhattan and Brooklyn each have three. Ownership alone does not account for the geographic spread.

**3. NYC emergency departments run substantially slower than the national average.**

| Measure | NYC | National |
|---|---|---|
| Median time in ED (minutes) | 216 | 157 |
| Patients leaving before being seen | 2.5% | 1.7% |

NYC's typical ED visit runs about an hour longer than the national median. Individual hospitals range from 144 to 301 minutes. This is a citywide pattern, not a handful of outliers.

**4. Fourteen hospitals combine low ratings with weak ED performance — and thirteen are outside Manhattan.**

Filtering to hospitals rated 2 stars or below *and* performing worse than the NYC median on ED wait (218 minutes) or walkout rate (≥3%) returns 14 facilities: 5 in Queens, 4 in the Bronx, 4 in Brooklyn, 1 in Manhattan.

The most acute cases:

- **Lincoln Medical & Mental Health Center** (Bronx, 2 stars) — 9% of ED patients leave before being seen, roughly one in eleven, and over five times the national rate.
- **St Barnabas Hospital** (Bronx, 1 star) — a 301-minute median ED stay, the longest in the city, with an 8% walkout rate.

**5. Slow ED times alone do not indicate a failing hospital.**

NewYork-Presbyterian/Queens holds a 5-star rating alongside a 280-minute median ED time — one of the longest in the city. High-volume academic centers can post long ED times while delivering strong outcomes. The meaningful signal is the *combination* of a low rating and poor ED throughput, which is why the watchlist requires both conditions rather than ranking on wait time alone.

## Business Recommendations

1. **Prioritize the 14-hospital watchlist for operational review**, beginning with Lincoln and St Barnabas, where walkout rates indicate patients are leaving without care — a patient-safety concern, not only a satisfaction one.
2. **Treat ED throughput as a citywide capacity issue, not a per-hospital failure.** With NYC running an hour above the national median, hospital-level targets alone are unlikely to close the gap; the analysis points toward system-level factors such as inpatient bed availability and staffing.
3. **Investigate the Brooklyn cluster specifically.** Ten rated hospitals averaging 1.8 stars, with no facility above 4, is the densest concentration of low performance in the city and warrants a borough-level review rather than facility-by-facility remediation.
4. **Do not use star ratings to evaluate psychiatric or specialty facilities.** Ten NYC hospitals are unrated by design. Any scorecard built on CMS overall ratings needs a separate measurement approach for these facilities.
5. **Study NewYork-Presbyterian/Queens as an internal benchmark** — the only non-Manhattan hospital achieving 5 stars, and doing so despite heavy ED demand.

## Limitations

- **Small sample.** 45 hospitals, 35 with ratings. Borough averages built on two or three hospitals (Staten Island) are statistically fragile and should be read as indicative, not conclusive.
- **No case-mix adjustment.** CMS star ratings incorporate risk adjustment, but this analysis does not independently control for patient acuity, socioeconomic factors, or payer mix. Hospitals serving higher-need populations may face structural disadvantages this data cannot separate from performance.
- **Incomplete ED coverage.** Only 31 of 45 hospitals report median ED time and 28 report walkout rates; facilities without emergency departments are absent from those comparisons.
- **Correlation, not causation.** The borough and ownership patterns identified here describe associations. Establishing cause would require data on staffing, funding, and patient demographics that these files do not contain.
- **Point-in-time snapshot.** Reflects the July 2026 CMS release. Trends over time are not assessed.

## Skills Demonstrated

- Data cleaning and missing-value analysis (pandas)
- Investigating *why* data is missing and adjusting analytical scope accordingly
- SQL: `SELECT`, `WHERE`, `GROUP BY`, `ORDER BY`, aggregate functions, `CASE WHEN`, `HAVING`, `JOIN`, `LEFT JOIN`
- Benchmarking a local population against a national baseline
- Multi-criteria filtering to build a prioritized action list
- Dashboard design in Tableau Public
- Translating analysis into business recommendations with stated limitations
- Reproducible project structure and documentation with Git and GitHub

## Repository Structure

```
nyc-healthcare-performance-analysis/
├── README.md
├── data/
│   ├── raw/          CMS source files, unmodified
│   ├── cleaned/      analysis-ready outputs
│   └── nyc_hospitals.db
├── notebooks/        data cleaning notebook
├── sql/              analysis queries
└── dashboard/        Tableau workbook
```

## Reproducing This Analysis

1. Clone the repository.
2. Run `notebooks/01_data_cleaning.ipynb` to regenerate the cleaned dataset from the raw CMS files.
3. Query `data/nyc_hospitals.db` with any SQLite client using the scripts in `sql/`.

---

*Analysis by Sheriffa Singh. Data: CMS Provider Data Catalog, July 2026 release.*
