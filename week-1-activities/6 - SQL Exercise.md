# Hands-On Exercises
---
## I. Analyze Netflix Data:
---
### 1. Find the top 5 content types (Movie/TV Show) by number of releases each year.

<img width="947" height="544" alt="Image" src="https://github.com/user-attachments/assets/ee0079c9-52f9-4fdb-85a8-7871c40488be" />

---

### 2. Calculate the total number of releases per country and list the top 10 countries with the most content.

<img width="1041" height="732" alt="Image" src="https://github.com/user-attachments/assets/80bc9fe3-ca7d-4d69-871d-eb4c91928216" />

---
## II. Write 3 complex SQL queries demonstrating join concepts on the single netflix_titles table:
---

### 1. **Self-join (conceptual):** Find pairs of movies/TV shows that share at least one common director or cast member.

- Script:

<img width="968" height="1005" alt="Image" src="https://github.com/user-attachments/assets/8c257f05-35ae-4634-b6d6-b1431fb6f9a4" />

- Sample output of 15 rows:

<img width="1238" height="637" alt="Image" src="https://github.com/user-attachments/assets/afce7bcf-4b6f-4e32-9448-235b5a1c677a" />

- Full output with 33k rows:  [.CSV File](https://github.com/user-attachments/files/24891392/_CTE_para_i_normalize_yung_cast_column_WITH_actors_normalized_AS_202601280130.csv)

---

### 2. **Subquery/CTE for "Inner Join" concept:** Identify titles where the country is among the top 3 countries for content releases.

- Script: 

<img width="977" height="759" alt="Image" src="https://github.com/user-attachments/assets/24719095-86c4-4926-8f80-59fc8a99aaac" />

- Sample output of 15 rows:

<img width="1226" height="609" alt="Image" src="https://github.com/user-attachments/assets/0ec3d211-6def-4e90-abd5-62c0d43ccb85" />

- Full output with 33k rows: [.CSV File](https://github.com/user-attachments/files/24897817/_CTE_para_makuha_yung_top_3_countries_with_ranking_WITH_top_coun_202601280913.csv)

---

### 3. **NOT EXISTS for "Left Join" concept:** Find movies/TV shows that are not associated with any of the top 5 most frequent genres (use a subquery to define top genres).

- Script: 

<img width="967" height="788" alt="Image" src="https://github.com/user-attachments/assets/117624e7-8e8a-43f2-bb06-d4f458e59c14" />

- Sample output of 15 rows: 

<img width="1634" height="638" alt="Image" src="https://github.com/user-attachments/assets/973c3c85-0ea3-400c-9827-06f051eb7e36" />

- Full output with 1.7k rows: [.CSV File](https://github.com/user-attachments/files/24897944/202601280932.csv)

---
## **III. Window Function Exercise:**
---

### 1. For each release_year and type (Movie/TV Show), assign a rank to each title based on its duration (or a proxy like num_seasons for TV shows, if available/simulated).

- Script: 

<img width="1358" height="544" alt="Image" src="https://github.com/user-attachments/assets/3ca68b07-e5fa-4782-91fb-63b83b546410" />

- Sample output of 15 rows: 

<img width="1240" height="599" alt="Image" src="https://github.com/user-attachments/assets/3b0cbf89-480c-41b2-b09e-6ef191f28793" />

- Full output with 3.9k rows: [.CSV File](https://github.com/user-attachments/files/24898017/202601280938.csv)

---

### 2. Find the previous release year's content count for each country using LAG() by country and ordered by year.

- Script:

<img width="939" height="826" alt="Image" src="https://github.com/user-attachments/assets/cde4c603-6d85-48bb-892c-d0276097b370" />

- Sample output of 15 rows: 

<img width="1270" height="606" alt="Image" src="https://github.com/user-attachments/assets/1042d78c-ea27-4842-9a46-24511e1acd05" />

- Full output with 534 rows: [.CSV File](https://github.com/user-attachments/files/24898084/202601280947.csv)

---

submitted by: @kristhiacayle 
submitted to: @jgvillanuevastratpoint 
submission date: 01/28/2026
