# 🦈 Shark Tank India Data Analysis Project

## 📁 Overview

This project analyzes an impure dataset of **Shark Tank India** to extract business insights that can help marketing teams, venture capitalists, and investors make informed decisions. The data is cleaned using `pandas` in Python, and each business problem is solved with relevant logic and analysis.

---

## 🧹 Data Cleaning Steps (Performed Using pandas)

1. **Loading the data** from CSV using `pd.read_csv()`
2. **Removing unnecessary columns** like URLs or irrelevant text columns
3. **Standardizing column names** (e.g., `Startup Name` → `startup_name`)
4. **Handling missing values** via imputation or logical assumptions (e.g., 'Not Mentioned')
5. **Converting data types** like revenue and deal amount into numeric values
6. **Stripping whitespaces** and **removing duplicates**
7. **Filtering out invalid rows** or corrupted records

---

## 📊 Business Problems and Solutions

### 1. 📌 Highest Funding Domain-wise (Season 4 Promotion)

**Objective:** Attract new startups by showcasing the industries that received the highest funding in **each domain (industry)**.

**Solution:** Group by `industry` and sum up `total_deal_amount_in_lakhs` for each. Filter by `Season_Number = 4`.

---

### 2. 👩‍🦰 Female to Male Pitcher Ratio > 70%

**Objective:** Identify industries with a high ratio of female pitchers to attract women entrepreneurs.

**Solution:** Compute ratio = female_pitchers / total_pitchers. Filter domains with ratio > 0.7.

---

### 3. 📈 Pitch Volume and Conversion Analysis

**Objective:** For each season, report:
- Total pitches
- Pitches receiving offers
- Pitches converted (Accepted Offers)
- % of converted
- % of entertained (received offers)

**Solution:** Use `groupby` on `Season_Number` and count with conditional logic.

---

### 4. 💸 Highest Avg. Monthly Sales by Season + Top 5 Industries

**Objective:** Determine:
- Season with highest average monthly sales
- Top 5 industries during that season based on average monthly sales

**Solution:** 
- Clean and convert `monthly_sales` column
- Group by `Season_Number` → average
- Filter top 5 industries in the highest season

---

### 5. 📊 Industries with Consistent Funding Growth

**Objective:**
- Identify industries appearing in all 3 seasons
- Check if funds raised increased in every season
- Analyze pitch counts, received offers, accepted offers per season

**Solution:** Use `groupby` + pivot logic + filtering industries with increasing trend.

---

### 6. 💰 Investment Return Period Calculator (System for Sharks)

**Objective:** Based on startup name, calculate years to recover investment using:
**Note:** If revenue is "Not Mentioned", return "Cannot be Calculated"

**Solution:** Build a function or stored procedure with input `Startup_Name`.

---

### 7. 🧑‍💼 Most Generous Shark (Avg. Investment Per Deal)

**Objective:** Find which shark invests the most per deal (on average).

**Solution:** 
- Parse `investors` field (handle multiple sharks per deal)
- Divide deal equally and compute average per shark

---

### 8. 🛠 Stored Procedure: Shark's Sector Investment Summary

**Objective:**
- Input: `Season Number`, `Shark Name`
- Output: Total invested by shark per industry
- Also: % contribution per industry relative to shark’s total investment

**Solution:** Create a SQL stored procedure using parameters.

---

### 9. 🌐 Most Diversified Shark

**Objective:** Find which shark invested across **most different industries**.

**Solution:**
- Count distinct industries per shark
- Rank by diversity
- Optional: Use entropy as a diversity measure

---

## 🔧 Tools and Technologies

- **Python** (pandas, numpy)
- **MySQL/PostgreSQL** (for stored procedures)
- **Jupyter Notebook** for EDA and reporting
  
---

---

## 📬 Contact

**Uttam Kumar Mahato**  
📧 uttammahato379@gmail.com  

---

