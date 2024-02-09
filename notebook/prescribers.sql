--Prescribers Database

/* For this exericse, you'll be working with a database derived from the [Medicare Part D Prescriber Public Use File](https://www.hhs.gov/guidance/document/medicare-provider-utilization-and-payment-data-part-d-prescriber-0). More information about the data is contained in the Methodology PDF file. See also the included entity-relationship diagram.*/

/*1. 
    a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.*/
	
	SELECT npi, SUM(prescription.total_claim_count)
	FROM prescriber
	INNER JOIN prescription
	USING(npi)
	GROUP BY npi
	ORDER BY SUM(total_claim_count) DESC;
	--answer: npi#1881634483 has the highest total claim count with 99707
	
    
   /* b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.*/
SELECT npi, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, SUM(prescription.total_claim_count)
	FROM prescriber
	INNER JOIN prescription
	USING(npi)
	GROUP BY npi, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
	ORDER BY SUM(total_claim_count) DESC;
	--answer: Bruce Pendley with npi#1881634483 whose specialty is family practice has the most total claims with 99707.


/*2. 
    a. Which specialty had the most total number of claims (totaled over all drugs)?*/
	SELECT specialty_description, COUNT(prescription.total_claim_count) AS total_claims
	FROM prescriber
	INNER JOIN prescription
	USING(npi)
	GROUP BY 1
	ORDER BY COUNT(total_claim_count) DESC;
	-- answer: The specialty Nurse Practitoner has the most total claim count with 164,609 claims.

   /* b. Which specialty had the most total number of claims for opioids?*/
SELECT specialty_description, COUNT(prescription.total_claim_count) AS total_opioid_claims
	FROM prescriber
	INNER JOIN prescription
	USING(npi)
	INNER JOIN drug
	USING(drug_name)
	WHERE opioid_drug_flag = 'Y'
	GROUP BY 1
	ORDER BY COUNT(total_claim_count) DESC;
	--answer: Nurse practitoners has the most opioid claims with 9,551


     /*c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?*/

    /* d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?*/

 /*3. 
    a. Which drug (generic_name) had the highest total drug cost?*/
SELECT generic_name, SUM(p.total_drug_cost) AS total_drug_cost
FROM drug
INNER JOIN prescription AS p
USING (drug_name)
GROUP BY 1
ORDER BY SUM(total_drug_cost) DESC;
--answer: Insulin Glargine, HUM in has the highest total drug cost at $104,264,066.35


    /* b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.** */
SELECT generic_name, SUM(p.total_drug_cost) AS total_drug_cost, SUM(p.total_day_supply) AS total_daily_cost
FROM drug
INNER JOIN prescription AS p
USING (drug_name)
GROUP BY 1
ORDER BY SUM(total_day_supply) DESC;
--answer: Levothyroxine sodium has the highest total daily drug cost at 62,775,253
	

 /*4. 
    a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.*/
	
SELECT drug_name,
 CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	  WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	  ELSE 'neither'
 END AS drug_type
FROM drug
GROUP BY 1,2
ORDER BY drug_type;


     /*b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.*/

SELECT CAST(SUM(total_drug_cost) AS MONEY) AS total_cost,
 CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	  WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	  ELSE 'neither'
 END AS drug_type
FROM drug
INNER JOIN prescription AS p
USING(drug_name)
GROUP BY 2
ORDER BY total_cost;
--answer: More money has been spent on opioids than antibiotics. 


 /*5. 
    a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.*/
SELECT *
FROM cbsa
WHERE cbsaname LIKE '%TN%' 
ORDER BY cbsa


SELECT cbsa, cbsaname
FROM cbsa
WHERE cbsaname LIKE '%TN%' 
GROUP BY cbsa, cbsaname
ORDER BY cbsa;
--answer: there are 10 cbsa in Tennessee

     /*b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.*/
	 
	 SELECT cbsa, cbsaname, SUM(population) AS total_population
FROM cbsa
INNER JOIN population as p
USING(fipscounty)
WHERE cbsaname LIKE '%TN%' 
GROUP BY 1, 2
ORDER BY 3;
--answer: cbsa 34100 has the lowest population with 116,352 and cbsa 34980 has the highest population with 1,830,410

     /*c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.*/

 /*6. 
    a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.*/
	SELECT drug_name, total_claim_count
	FROM prescription
	WHERE total_claim_count > 3000
	

    /* b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.*/
SELECT drug_name, total_claim_count, opioid_drug_flag
	FROM prescription
	INNER JOIN drug
	USING(drug_name)
	WHERE total_claim_count > 3000

     /*c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.*/
SELECT drug_name, total_claim_count, opioid_drug_flag, nppes_provider_last_org_name, nppes_provider_first_name
	FROM prescription
	INNER JOIN drug
	USING(drug_name)
	INNER JOIN prescriber
	USING(npi)
	WHERE total_claim_count > 3000


 /*7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.*/

    /* a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.*/

    /* b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).*/
    
    /* c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.*/