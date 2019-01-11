/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name FROM `Facilities` WHERE membercost != 0

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(name) FROM `Facilities` WHERE membercost = 0


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance FROM `Facilities` 
	WHERE membercost < (monthlymaintenance/5)

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT * FROM `Facilities` 
	WHERE (facid = 1 OR facid = 5)


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
	CASE WHEN monthlymaintenance > 100 THEN 'expensive'
	     WHEN monthlymaintenance <= 100 THEN 'cheap'
	END
	FROM Facilities


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname, surname, joindate
FROM Members
ORDER BY joindate DESC


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT (a.memid), a.firstname, a.surname, b.facid, b.memid, c.name, c.facid, concat(a.surname,', ', a.firstname, ' ',c.name) AS final_answer
FROM Members a
JOIN Bookings b ON a.memid = b.memid
JOIN Facilities c ON b.facid = c.facid

WHERE b.facid < 2
ORDER BY a.surname, a.firstname


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name, concat(m.firstname, " ", m.surname) AS member_name, b.slots*f.membercost AS cost FROM Bookings b
JOIN Facilities f ON b.facid = f.facid
JOIN Members m ON b.memid = m.memid
WHERE b.starttime LIKE '2012-09-14%'
AND b.memid > 0
AND b.slots*f.membercost > 30

UNION

SELECT f.name, concat(m.firstname, " ", m.surname) AS member_name, b.slots*f.guestcost AS cost FROM Bookings b
JOIN Facilities f ON b.facid = f.facid
JOIN Members m ON b.memid = m.memid
WHERE b.starttime LIKE '2012-09-14%'
AND b.memid = 0
AND b.slots*f.guestcost > 30

ORDER BY cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT cost, member_name, facility_name FROM 

(SELECT b.memid AS member, concat(m.firstname, ' ', m.surname) AS member_name, (b.slots * f.guestcost) AS cost, f.name AS facility_name FROM Bookings b
JOIN Facilities f ON b.facid = f.facid
JOIN Members m ON b.memid = m.memid
WHERE b.starttime LIKE '2012-09-14%'
AND b.memid = 0
AND b.slots*f.guestcost > 30
     
UNION
     
SELECT b.memid AS member, concat(m.firstname, ' ', m.surname) AS member_name, (b.slots * f.membercost) AS cost, f.name AS facility_name FROM Bookings b
JOIN Facilities f ON b.facid = f.facid
JOIN Members m ON b.memid = m.memid
WHERE b.starttime LIKE '2012-09-14%'
AND b.memid > 0
AND b.slots*f.membercost > 30) subquery

ORDER BY cost DESC


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT s.facid, d.name, SUM(revenue) AS total_revenue

FROM(

SELECT a.bookid, a.memid, a.starttime, a.slots, b.facid, b.guestcost, CONCAT( c.firstname, c.surname ) AS member_name, (
a.slots * b.guestcost
) AS revenue
FROM Bookings a
JOIN Facilities b ON a.facid = b.facid
JOIN Members c ON a.memid = c.memid
WHERE a.memid =0

UNION 

SELECT a.bookid, a.memid, a.starttime, a.slots, b.facid, b.membercost, CONCAT( c.firstname, c.surname ) AS member_name, (
a.slots * b.guestcost
) AS revenue
FROM Bookings a
JOIN Facilities b ON a.facid = b.facid
JOIN Members c ON a.memid = c.memid
WHERE a.memid >0 ) AS s

INNER JOIN Facilities AS d
ON s.facid = d.facid

GROUP BY facid
ORDER BY total_revenue DESC

/* According to this analysis, the total revenue from each facility was over 1000.  No date range was specified in problem 10 */

