CREATE TABLE booking_table(
   Booking_id       VARCHAR(3) NOT NULL 
  ,Booking_date     date NOT NULL
  ,User_id          VARCHAR(2) NOT NULL
  ,Line_of_business VARCHAR(6) NOT NULL
);
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b1','2022-03-23','u1','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b2','2022-03-27','u2','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b3','2022-03-28','u1','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b4','2022-03-31','u4','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b5','2022-04-02','u1','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b6','2022-04-02','u2','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b7','2022-04-06','u5','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b8','2022-04-06','u6','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b9','2022-04-06','u2','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b10','2022-04-10','u1','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b11','2022-04-12','u4','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b12','2022-04-16','u1','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b13','2022-04-19','u2','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b14','2022-04-20','u5','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b15','2022-04-22','u6','Flight');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b16','2022-04-26','u4','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b17','2022-04-28','u2','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b18','2022-04-30','u1','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b19','2022-05-04','u4','Hotel');
INSERT INTO booking_table(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b20','2022-05-06','u1','Flight');
;
CREATE TABLE user_table(
   User_id VARCHAR(3) NOT NULL
  ,Segment VARCHAR(2) NOT NULL
);
INSERT INTO user_table(User_id,Segment) VALUES ('u1','s1');
INSERT INTO user_table(User_id,Segment) VALUES ('u2','s1');
INSERT INTO user_table(User_id,Segment) VALUES ('u3','s1');
INSERT INTO user_table(User_id,Segment) VALUES ('u4','s2');
INSERT INTO user_table(User_id,Segment) VALUES ('u5','s2');
INSERT INTO user_table(User_id,Segment) VALUES ('u6','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u7','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u8','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u9','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u10','s3');


select*from booking_table;
select*from user_table;

-- write a query to give the segment, user_count and user_count who booked flight in apr2022
select u.segment, count(distinct u.user_id) as user_count,
count(distinct case when b.Line_of_business='Flight' 
and b.Booking_date between '2022-04-01' and '2022-04-30' then b.User_id end)
as user_booked_flight_apr2022
from user_table u left join booking_table b
on b.User_id = u.User_id
group by u.Segment;

--write a query to identify users whose first booking was a hotel booking
with cte as 
(
select User_id, booking_date, Line_of_business,
rank() Over(partition by user_id order by Booking_date asc) rank_
from booking_table
)
select * from cte
where rank_=1 and Line_of_business='Hotel';

-----------Alternate--------------
select distinct user_id from (
select * ,
first_value(Line_of_business) Over(partition by user_id order by Booking_date asc) first_booking
from booking_table) A
where first_booking='Hotel';

--write a query to calculate the days between first and last booking of each user
select user_id, datediff(day,first_date,last_date) days_diff from (
select distinct user_id,
first_value(Booking_date) over(partition by user_id order by Booking_date) first_date,
first_value(Booking_date) over(partition by user_id order by Booking_date desc) last_date
from booking_table) A;

------------Alternate--------------
select user_id, datediff(day, min(booking_date), max(booking_date)) days_diff
from booking_table
group by user_id;

-- write a query to count the number of flight and hotel bookings in each of the user segments for the year 2022
select u.segment, 
sum(case when b.Line_of_business='Flight' then 1 else 0 end) as flight_count,
sum(case when b.Line_of_business='Hotel' then 1 else 0 end) as hotel_count
from booking_table b
inner join user_table u
on b.user_id = u.user_id
where datepart(year, booking_date) = 2022
group by u.segment;


