/*
Problem Statement: Julia conducted a  days of learning SQL contest. 
The start date of the contest was March 01, 2016 and the end date was March 15, 2016.

Write a query to print total number of unique hackers who made at least submission each day (starting on the first day of 
the contest), and find the hacker_id and name of the hacker who made maximum number of submissions each day. If more than one 
such hacker has a maximum number of submissions, print the lowest hacker_id. The query should print this information for 
each day of the contest, sorted by the date.
*/


set @startdate = (select min(submission_date) from submissions);

select A.dt, A.cnt, B.id, B.name
from
(select distinct 
    s.submission_date as dt, count(distinct s.hacker_id) as cnt
from 
    submissions s
where
    s.hacker_id in ( /*List of the unique hacker_ids who submits every day starting from first day to current date*/
                    select s1.hacker_id from submissions s1 
                    where s1.submission_date between  @startdate and s.submission_date
                    group by s1.hacker_id
                    having count(distinct s1.submission_date) = (datediff(s.submission_date, @startdate)+1)
                 ) 
group by submission_date) as A, /* Gets total number of unique hackers who made at least submission each day */

(select distinct
    s.submission_date as dt, s.hacker_id as id, h.name as name
from 
    submissions s
        inner join
    hackers h on h.hacker_id = s.hacker_id
where
    s.hacker_id = (select  hacker_id as id /*Get the hacker id who provided the maximum submissions by the date*/
                from submissions s1
                where s1.submission_date = s.submission_date
                group by  hacker_id
                order by count(submission_id) desc, 1 asc limit 1
                )) as B /*Gets the hacker_id and name of the hacker who made maximum number of submissions each day*/
where A.dt = B.dt