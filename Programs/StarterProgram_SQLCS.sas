/*********************************/
/* SAS SQL Case Study Preview    */
/* SAS Innovate 2025             */
/* Carleigh Jo Crabtree          */
/* Starter Program               */
/*********************************/

/***************/
/* Access Data */
/***************/

/*******************************************************************************************************/
/* The following libname is in the autoexec program to create the CS library with the claimsRaw table. */
/*                                                                                                     */
/* libname cs "/home/student/SQLCaseStudy";                                                            */ 
/*******************************************************************************************************/

/****************/
/* Explore Data */
/****************/

/*****************************************************************************************************************/
/* 1. View all columns and the first 10 observations in each table.                                              */
/*    - On the SELECT clause, add a special character to view all columns.                                       */
/*    - On the PROC SQL statement, add an option to process all rows, but limit the number of rows output to 10. */
/*****************************************************************************************************************/

proc sql;
title "cs.claimsraw";
select 
	from cs.claimsraw;
title;
quit;

/************************************************************************************************************/
/* 2. Explore the current values in Claim_Site, Disposition and Claim_Type in cs.claimsraw.                 */
/* 	  - On the PROC SQL statement, add an option to display row numbers as the first column in the results. */
/*    - On each SELECT clause, add a keyword to select unique values within the specified column.           */
/*                                                                                                          */
/*    Q: What changes may need to be made to these values?                                                  */
/************************************************************************************************************/

proc sql ;
title "Values in Claim_Site";
select  claim_site
	from cs.claimsraw
	order by claim_site;

title "Values in Disposition";
select  disposition
	from cs.claimsraw
	order by disposition;

title "Values in Claim_Type";
select  claim_type
	from cs.claimsraw
	order by claim_type;
title;
quit;

/*************************************************************************************/
/* 3. Explore the years included in Date_Received and Incident_Date in cs.claimsraw. */
/* 	  Valid years are 2013-2017.                                                     */
/*    - On the first SELECT clause, create a column named Date_Received_Year.        */
/*      Use the PUT function to put the Date_Received column in the year4. format.   */
/*    - On the second SELECT clause, create a column named Incident_Date_Year.       */
/*      Use the PUT function to put the Incident_Date column in the year4. format.   */
/*                                                                                   */
/*    Q: Are any dates outside of the valid years 2013-2017?                         */
/*************************************************************************************/

proc sql number;
title "Years of Claims";
/*              put(): returns a value using a specified format */
select distinct 
	from cs.claimsraw
	order by Date_Received_Year;

title "Years of Incidents";
select distinct 
	from cs.claimsraw
	order by Incident_Date_Year;
title;
quit;

/*****************************************************************************************/
/* 4. Explore the rows where Incident_Date occurred after Date_Received in cs.claimsraw. */
/* 	  Date_Received should occur after Incident_Date.                                    */
/*    - On the first SELECT clause, use a function to count the total number of rows.    */
/*                                                                                       */
/*    Q: How many invalid incidents were found?                                          */
/*****************************************************************************************/

proc sql;
title "Number of claims where Incident_Date occurred after Date_Received";
select 
	from cs.claimsraw
	where Incident_Date> Date_Received;
	
title "Invalid Dates";
select Claim_Number, Date_Received, Incident_Date
	from cs.claimsraw
	where Incident_Date> Date_Received;
title;
quit;

/****************/
/* Prepare Data */
/****************/

/**********************************************************************************************/
/* 5. Create a new table claims_noDup from cs.claimsraw that removes entirely duplicate rows. */
/*    - Add a statement to create a table named claims_noDup.                                 */
/*                                                                                            */
/*    Q: Compare the total number of observations in cs.claimsraw and claims_noDup.           */
/*       How many rows were removed?                                                          */
/**********************************************************************************************/

proc sql;

select distinct *
	from cs.claimsraw;
quit;

proc contents data=cs.claimsraw;
run;

/******************************************************************************************************************/
/* 6. Create a new table claims_cleaned from claims_noDup.                                                        */
/*    Fix the 65 date issues where Incident_Date occurs after Date_Received by replacing the year 2017 with 2018. */
/*    - Complete the CREATE TABLE statement to create a new table named claims_cleaned.                           */
/*    - Complete the case expression. When Incident_Date is greater than Date_Received, shift the date            */
/*      to the next year.                                                                                         */
/******************************************************************************************************************/

proc sql;
create table  as
select Claim_Number, Incident_Date, 
	case 
		when  then 
/* 			intnx(): shifts date to the next interval */
			intnx("year",Date_Received, 1, "same")
		else Date_Received
	end as Date_Received format=date9.
	
	from claims_noDup;
quit;

/***********************************************************************************************************************/
/* 7. Clean the Claim_Type column.                                                                                     */
/*    Replace missing values with the value Unknown.                                                                   */
/*    If a claim is separated into two types by a slash, Claim_Type is the first type.                                 */
/*    Ex. Personal Injury/Personal Property Loss is considered Personal Injury.                                        */
/*    - Complete the second case expression. When Claim_Type is a null value, update the value to Unknown.             */
/*    - Complete the SCAN function in the second case expression. Define what should be used to determine a substring. */
/***********************************************************************************************************************/

proc sql;
create table claims_cleaned as
select Claim_Number, Incident_Date, 
	case 
		when Incident_Date> Date_Received then
/*  		intnx(): shifts date to the next interval */
			intnx("year",Date_Received, 1, "same")
		else Date_Received
	end as Date_Received format=date9.,
	
	case 
		when  then 
/*   		 scan(): returns the nth word from a string */
		else scan(Claim_Type, 1,  )
	end as Claim_Type
	
	from claims_noDup;
	
select distinct Claim_Type
	from claims_cleaned;
quit;

/****************************************************************************************************/
/* 8. Clean Claim_Site and Disposition.                                                             */
/*    In both columns, replace missing values with the value Unknown.                               */
/*    Modify the invalid values in Disposition.                                                     */
/*    - Complete the COALESCE function to replace null values in Claim_Site with the value Unknown. */
/*    - Complete the third case expression.                                                         */
/*      When Disposition is Closed: Canceled, update the value to Closed:Canceled.                  */
/*      When Disposition is losed: Contractor Claim, update the value to Closed:Contractor Claim.   */
/****************************************************************************************************/

proc sql;
create table claims_cleaned as
select Claim_Number, Incident_Date, 
	case 
		when Incident_Date> Date_Received then
/*		    intnx(): shifts date to the next interval */
			intnx("year",Date_Received, 1, "same")
		else Date_Received
	end as Date_Received format=date9.,
	
	case 
		when Claim_Type is null then "Unknown"
/*		     scan(): returns the nth word from a string */
		else scan(Claim_Type, 1, "/")
	end as Claim_Type,
	
/* 	coalesce(): returns the first non-missing value */
	coalesce(Claim_Site, ) as Claim_Site,
	
	case
		when Disposition is null then "Unknown"
		when Disposition="Closed: Canceled" then 
		when Disposition= "losed: Contractor Claim" then 
		else Disposition
	end as Disposition
	
	from claims_noDup;
	
select distinct Claim_Site
	from claims_cleaned;
select distinct Disposition
	from claims_cleaned;
quit;

/*************************************************************************************************************/
/* 9. Include rows where Incident_Date is between 2013 and 2017.                                             */
/*    In Airport_Code, replace missing values with the value Unknown.                                        */
/*    Order the report by Airport_Code and Incident_Date.                                                    */
/*    - Complete the second COALESCE function to replace null values in Airport_Code with the value Unknown. */
/*    - Complete the WHERE clause to filter the report for Incident_Date years between 2013 and 2017.        */
/*    - Complete the ORDER BY clause to sort the report by Airport_Code and Incident_Date.                   */
/*************************************************************************************************************/

proc sql;
create table claims_cleaned as
select Claim_Number, Incident_Date, 
	case 
		when Incident_Date> Date_Received then
/*  		intnx(): shifts date to the next interval */
			intnx("year",Date_Received, 1, "same")
		else Date_Received
	end as Date_Received format=date9.,
	
	case 
		when Claim_Type is null then "Unknown"
/*   		 scan(): returns the nth word from a string */
		else scan(Claim_Type, 1, "/")
	end as Claim_Type,
	
/* 	coalesce(): returns the first non-missing value */
	coalesce(Claim_Site, "Unknown") as Claim_Site,
	
	case
		when Disposition is null then "Unknown"
		when Disposition="Closed: Canceled" then "Closed:Canceled"
		when Disposition= "losed: Contractor Claim" then "Closed:Contractor Claim"
		else Disposition
	end as Disposition,
	
/* 	coalesce(): returns the first non-missing value */
	coalesce( , "Unknown") as Airport_Code,
	Airport_Name
	
	from claims_noDup
	
/* 	      year(): returns the year from a SAS date value */
	where year(Incident_Date) between  and 
	order by ;
quit;

/******************************************************************************************************************/
/* 10. Create a view totalClaims from claims_cleaned.                                                             */
/*     Count the number of claims for each combination of Airport_Code, Airport_Name and Year.                    */
/* 	   Create a report from totalClaims ordered by Airport_Code and Year.                                         */
/*     - Complete the CREATE VIEW statement to create a view named totalClaims.                                   */
/*     - After the FROM clause, add a GROUP BY clause to group the values by Airport_Code, Airport_Name and Year. */
/******************************************************************************************************************/

proc sql;
/*     view: stored query, contains no actual data, accesses most current data */
create view  as 
select Airport_Code, 
	   Airport_Name, 
  	   year(Incident_Date) as Year, 
       count(*) as TotalClaims
	from claims_cleaned 
	;
select *
	from totalClaims
	order by Airport_Code, Year;
quit;

/***************************************************************************/
/* Bonus: Generate summary statistics from totalClaims and claims_cleaned. */
/***************************************************************************/

/******************/
/* Report on Data */
/******************/

/**********************************************************************************************/
/* 11. How many total claims were filed?                                                      */
/*     - Complete the SELECT clause. Use the SUM function to generate the sum of totalClaims. */
/**********************************************************************************************/

proc sql;
/* 	   sum(): returns the sum of nonmissing arguments */
select  as SumClaims format=comma6.
	from totalclaims;
quit;

/*************************************************************************************************/
/* 12. What is the average time in days to file a claim?                                         */
/*     - Complete the SELECT clause. Use the AVG function to generate the average number of days */
/*       it takes to file a claim by subtracting Incident_Date from Date_Received.               */
/*************************************************************************************************/

proc sql;
/*     avg(): returns the average of all values in a column */
select  as AvgDays format=4.1
	from claims_cleaned;
quit;

/***********************************************************************************************/
/* 13. How many unknown airport codes are in the results?                                      */
/*     - Complete the SELECT clause. Use the COUNT function to count the total number of rows  */
/*       in the Airport_Code column.                                                           */
/*     - Complete the WHERE clause to filter for the value Unknown in the Airport_Code column. */
/***********************************************************************************************/

proc sql;
/*     count(): counts the number of rows */
select  as UnknownAirports
	from claims_cleaned
	where ;
quit;

/**********************************************************************************/
/* 14. What type of claim type occurs most frequently?                            */
/*     How many claims were that type?                                            */
/*     - Add a GROUP BY clause to group the report by Claim_Type.                 */
/*     - Add an ORDER BY clause to sort the report by Claims in descending order. */
/**********************************************************************************/

proc sql;
select Claim_Type, count(*) as Claims format=comma10.
	from claims_cleaned
/*  summarize groups of data by Claim_Type */
	
/*  sort by Claims in descending order */
	;
quit;

/*************************************************************************************/
/* 15. How many claims include the string Closed?                                    */
/*     - Complete the WHERE clause. Filter for values in Disposition where the value */
/*       contains Closed anywhere in the value.                                      */
/*************************************************************************************/

proc sql;
select Disposition, count(*) as Claims format=comma10.
	from claims_cleaned
/* 	like operator: used for pattern matching */
	where 
	group by Disposition;
quit;


/*********************************/
/* SAS SQL Case Study Preview    */
/* SAS Innovate 2025             */
/* Carleigh Jo Crabtree          */
/* Starter Program               */
/*********************************/

/***************/
/* Access Data */
/***************/

/*******************************************************************************************************/
/* The following libname is in the autoexec program to create the CS library with the claimsRaw table. */
/*                                                                                                     */
/* libname cs "/home/student/SQLCaseStudy";                                                            */ 
/*******************************************************************************************************/

/****************/
/* Explore Data */
/****************/

/*****************************************************************************************************************/
/* 1. View all columns and the first 10 observations in each table.                                              */
/*    - On the SELECT clause, add a special character to view all columns.                                       */
/*    - On the PROC SQL statement, add an option to process all rows, but limit the number of rows output to 10. */
/*****************************************************************************************************************/

proc sql;
title "cs.claimsraw";
select 
	from cs.claimsraw;
title;
quit;

/************************************************************************************************************/
/* 2. Explore the current values in Claim_Site, Disposition and Claim_Type in cs.claimsraw.                 */
/* 	  - On the PROC SQL statement, add an option to display row numbers as the first column in the results. */
/*    - On each SELECT clause, add a keyword to select unique values within the specified column.           */
/*                                                                                                          */
/*    Q: What changes may need to be made to these values?                                                  */
/************************************************************************************************************/

proc sql ;
title "Values in Claim_Site";
select  claim_site
	from cs.claimsraw
	order by claim_site;

title "Values in Disposition";
select  disposition
	from cs.claimsraw
	order by disposition;

title "Values in Claim_Type";
select  claim_type
	from cs.claimsraw
	order by claim_type;
title;
quit;

/*************************************************************************************/
/* 3. Explore the years included in Date_Received and Incident_Date in cs.claimsraw. */
/* 	  Valid years are 2013-2017.                                                     */
/*    - On the first SELECT clause, create a column named Date_Received_Year.        */
/*      Use the PUT function to put the Date_Received column in the year4. format.   */
/*    - On the second SELECT clause, create a column named Incident_Date_Year.       */
/*      Use the PUT function to put the Incident_Date column in the year4. format.   */
/*                                                                                   */
/*    Q: Are any dates outside of the valid years 2013-2017?                         */
/*************************************************************************************/

proc sql number;
title "Years of Claims";
/*              put(): returns a value using a specified format */
select distinct 
	from cs.claimsraw
	order by Date_Received_Year;

title "Years of Incidents";
select distinct 
	from cs.claimsraw
	order by Incident_Date_Year;
title;
quit;

/*****************************************************************************************/
/* 4. Explore the rows where Incident_Date occurred after Date_Received in cs.claimsraw. */
/* 	  Date_Received should occur after Incident_Date.                                    */
/*    - On the first SELECT clause, use a function to count the total number of rows.    */
/*                                                                                       */
/*    Q: How many invalid incidents were found?                                          */
/*****************************************************************************************/

proc sql;
title "Number of claims where Incident_Date occurred after Date_Received";
select 
	from cs.claimsraw
	where Incident_Date> Date_Received;
	
title "Invalid Dates";
select Claim_Number, Date_Received, Incident_Date
	from cs.claimsraw
	where Incident_Date> Date_Received;
title;
quit;

/****************/
/* Prepare Data */
/****************/

/**********************************************************************************************/
/* 5. Create a new table claims_noDup from cs.claimsraw that removes entirely duplicate rows. */
/*    - Add a statement to create a table named claims_noDup.                                 */
/*                                                                                            */
/*    Q: Compare the total number of observations in cs.claimsraw and claims_noDup.           */
/*       How many rows were removed?                                                          */
/**********************************************************************************************/

proc sql;

select distinct *
	from cs.claimsraw;
quit;

proc contents data=cs.claimsraw;
run;

/******************************************************************************************************************/
/* 6. Create a new table claims_cleaned from claims_noDup.                                                        */
/*    Fix the 65 date issues where Incident_Date occurs after Date_Received by replacing the year 2017 with 2018. */
/*    - Complete the case expression. When Incident_Date is greater than Date_Received, shift the date            */
/*      to the next year.                                                                                         */
/******************************************************************************************************************/

proc sql;
create table  as
select Claim_Number, Incident_Date, 
	case 
		when  then 
/* 			intnx(): shifts date to the next interval */
			intnx("year",Date_Received, 1, "same")
		else Date_Received
	end as Date_Received format=date9.
	
	from claims_noDup;
quit;

/***********************************************************************************************************************/
/* 7. Clean the Claim_Type column.                                                                                     */
/*    Replace missing values with the value Unknown.                                                                   */
/*    If a claim is separated into two types by a slash, Claim_Type is the first type.                                 */
/*    Ex. Personal Injury/Personal Property Loss is considered Personal Injury.                                        */
/*    - Complete the second case expression. When Claim_Type is a null value, update the value to Unknown.             */
/*    - Complete the SCAN function in the second case expression. Define what should be used to determine a substring. */
/***********************************************************************************************************************/

proc sql;
create table claims_cleaned as
select Claim_Number, Incident_Date, 
	case 
		when Incident_Date> Date_Received then
/*  		intnx(): shifts date to the next interval */
			intnx("year",Date_Received, 1, "same")
		else Date_Received
	end as Date_Received format=date9.,
	
	case 
		when  then 
/*   		 scan(): returns the nth word from a string */
		else scan(Claim_Type, 1,  )
	end as Claim_Type
	
	from claims_noDup;
	
select distinct Claim_Type
	from claims_cleaned;
quit;

/****************************************************************************************************/
/* 8. Clean Claim_Site and Disposition.                                                             */
/*    In both columns, replace missing values with the value Unknown.                               */
/*    Modify the invalid values in Disposition.                                                     */
/*    - Complete the COALESCE function to replace null values in Claim_Site with the value Unknown. */
/*    - Complete the third case expression.                                                         */
/*      When Disposition is Closed: Canceled, update the value to Closed:Canceled.                  */
/*      When Disposition is losed: Contractor Claim, update the value to Closed:Contractor Claim.   */
/****************************************************************************************************/

proc sql;
create table claims_cleaned as
select Claim_Number, Incident_Date, 
	case 
		when Incident_Date> Date_Received then
/*		    intnx(): shifts date to the next interval */
			intnx("year",Date_Received, 1, "same")
		else Date_Received
	end as Date_Received format=date9.,
	
	case 
		when Claim_Type is null then "Unknown"
/*		     scan(): returns the nth word from a string */
		else scan(Claim_Type, 1, "/")
	end as Claim_Type,
	
/* 	coalesce(): returns the first non-missing value */
	coalesce(Claim_Site, ) as Claim_Site,
	
	case
		when Disposition is null then "Unknown"
		when Disposition="Closed: Canceled" then 
		when Disposition= "losed: Contractor Claim" then 
		else Disposition
	end as Disposition
	
	from claims_noDup;
	
select distinct Claim_Site
	from claims_cleaned;
select distinct Disposition
	from claims_cleaned;
quit;

/*************************************************************************************************************/
/* 9. Include rows where Incident_Date is between 2013 and 2017.                                             */
/*    In Airport_Code, replace missing values with the value Unknown.                                        */
/*    Order the report by Airport_Code and Incident_Date.                                                    */
/*    - Complete the second COALESCE function to replace null values in Airport_Code with the value Unknown. */
/*    - Complete the WHERE clause to filter the report for Incident_Date years between 2013 and 2017.        */
/*    - Complete the ORDER BY clause to sort the report by Airport_Code and Incident_Date.                   */
/*************************************************************************************************************/

proc sql;
create table claims_cleaned as
select Claim_Number, Incident_Date, 
	case 
		when Incident_Date> Date_Received then
/*  		intnx(): shifts date to the next interval */
			intnx("year",Date_Received, 1, "same")
		else Date_Received
	end as Date_Received format=date9.,
	
	case 
		when Claim_Type is null then "Unknown"
/*   		 scan(): returns the nth word from a string */
		else scan(Claim_Type, 1, "/")
	end as Claim_Type,
	
/* 	coalesce(): returns the first non-missing value */
	coalesce(Claim_Site, "Unknown") as Claim_Site,
	
	case
		when Disposition is null then "Unknown"
		when Disposition="Closed: Canceled" then "Closed:Canceled"
		when Disposition= "losed: Contractor Claim" then "Closed:Contractor Claim"
		else Disposition
	end as Disposition,
	
/* 	coalesce(): returns the first non-missing value */
	coalesce( , "Unknown") as Airport_Code,
	Airport_Name
	
	from claims_noDup
	
/* 	      year(): returns the year from a SAS date value */
	where year(Incident_Date) between  and 
	order by ;
quit;

/******************************************************************************************************************/
/* 10. Create a view totalClaims from claims_cleaned.                                                             */
/*     Count the number of claims for each combination of Airport_Code, Airport_Name and Year.                    */
/* 	   Create a report from totalClaims ordered by Airport_Code and Year.                                         */
/*     - Complete the CREATE VIEW statement to create a view named totalClaims.                                   */
/*     - After the FROM clause, add a GROUP BY clause to group the values by Airport_Code, Airport_Name and Year. */
/******************************************************************************************************************/

proc sql;
/*     view: stored query, contains no actual data, accesses most current data */
create view  as 
select Airport_Code, 
	   Airport_Name, 
  	   year(Incident_Date) as Year, 
       count(*) as TotalClaims
	from claims_cleaned 
	;
select *
	from totalClaims
	order by Airport_Code, Year;
quit;

/***************************************************************************/
/* Bonus: Generate summary statistics from totalClaims and claims_cleaned. */
/***************************************************************************/

/******************/
/* Report on Data */
/******************/

/**********************************************************************************************/
/* 11. How many total claims were filed?                                                      */
/*     - Complete the SELECT clause. Use the SUM function to generate the sum of totalClaims. */
/**********************************************************************************************/

proc sql;
/* 	   sum(): returns the sum of nonmissing arguments */
select  as SumClaims format=comma6.
	from totalclaims;
quit;

/*************************************************************************************************/
/* 12. What is the average time in days to file a claim?                                         */
/*     - Complete the SELECT clause. Use the AVG function to generate the average number of days */
/*       it takes to file a claim by subtracting Incident_Date from Date_Received.               */
/*************************************************************************************************/

proc sql;
/*     avg(): returns the average of all values in a column */
select  as AvgDays format=4.1
	from claims_cleaned;
quit;

/***********************************************************************************************/
/* 13. How many unknown airport codes are in the results?                                      */
/*     - Complete the SELECT clause. Use the COUNT function to count the total number of rows  */
/*       in the Airport_Code column.                                                           */
/*     - Complete the WHERE clause to filter for the value Unknown in the Airport_Code column. */
/***********************************************************************************************/

proc sql;
/*     count(): counts the number of rows */
select  as UnknownAirports
	from claims_cleaned
	where ;
quit;

/**********************************************************************************/
/* 14. What type of claim type occurs most frequently?                            */
/*     How many claims were that type?                                            */
/*     - Add a GROUP BY clause to group the report by Claim_Type.                 */
/*     - Add an ORDER BY clause to sort the report by Claims in descending order. */
/**********************************************************************************/

proc sql;
select Claim_Type, count(*) as Claims format=comma10.
	from claims_cleaned
/*  summarize groups of data by Claim_Type */
	
/*  sort by Claims in descending order */
	;
quit;

/*************************************************************************************/
/* 15. How many claims include the string Closed?                                    */
/*     - Complete the WHERE clause. Filter for values in Disposition where the value */
/*       contains Closed anywhere in the value.                                      */
/*************************************************************************************/

proc sql;
select Disposition, count(*) as Claims format=comma10.
	from claims_cleaned
/* 	like operator: used for pattern matching */
	where 
	group by Disposition;
quit;


