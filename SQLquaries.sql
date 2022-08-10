-- CIS761 Project 
-- Employee compalints and accident database of City of Chicago
-- Members : Krish Weragalaarachchi , Douglas Baker

-- SQL queries
-----------------------------------------------------------------------------------------------------
-- 1.accident count by department for year 2020

select d.department_name, t2.accident_count 
from department d 
join (select e.department_code as d_code, sum(t1.count1) as accident_count 
        from employees e join 
                        (select i.employee_id as e_id, count(i.accident_id) as count1 
                        from involved_in i  
                        where extract(year from i.accident_date) = 2020 
                        group by i.employee_id) as t1 
        on e.employee_id = t1.e_id 
        group by e.department_code) t2 
on d.department_code = t2.d_code 
order by t2.accident_count desc; 

----------------------------------------------------------------------------------------------------------
-- 2.complaint count by department for year 2020

select d.department_name, t2.complaint_count 
from department d
join (select e.department_code as d_code, sum(t1.count1) as complaint_count 
        from employees e join
                        (select i.employee_id as e_id, count(i.complaint_id) as count1 
                        from receivedtest i 
                        where extract(year from i.c_date) = 2020
                        group by e_id) as t1
        on e.employee_id = t1.e_id
        group by e.department_code) as t2
on d.department_code = t2.d_code
order by t2.complaint_count desc;

-----------------------------------------------------------------------------------------------------------
-- 3.list of complaint description of compliants from each departmnet in 2020 where compliant class is 'COVID'

select dep.department_name, string_agg(des.complaint_description, ',') 
from (select  d.department_name, r.complaint_id as ff 
    from department d 
    join employees e ON e.department_code = d.department_code 
    join receivedtest r on e.employee_id = r.employee_id ) dep
join (select cc.complaint_description , r.complaint_id as ff
    from receivedtest r 
    join c_codes cc on r.complaint_code = cc.complaint_code 
    where extract(year from r.c_date) = 2020 AND  cc.complaint_class = 'COVID') des
on dep.ff = des.ff
group by dep.department_name;

-------------------------------------------------------------------------------------------------------------
-- 4. concatenated(first name and last name) of employees who works for fire department who has received a 
--    complaint class as 'SexOffense' in 2020 with the resolved status and complaint description, order alphabetically.

select t2.employee_name, t2.complaint_description, t2.resolution_status, t2.department_code 
from (select CONCAT(e.first_name, ' ', e.last_name) employee_name ,t1.complaint_description, t1.resolution_status, e.department_code 
        from (select r.employee_id, r.resolution_status, cc.complaint_description 
            from receivedtest r
            join c_codes cc on r.complaint_code = cc.complaint_code 
            where cc.complaint_class = 'SexOffense' and (extract(year from r.c_date)) = 2020) t1 
        join employees e on t1.employee_id = e.employee_id
        order by employee_name) t2 
join departments d on t2.department_code = d.department_code
where department_name ='FIRE';

--------------------------------------------------------------------------------------------------------------
--5. Number of complaint_ids issued for each employee , ordered by number of complaints. 
--   output full name, employee_id, department name along with complaint_id count.

select t2.employee_id, t2.employee_name, d.department_name, t2.complaint_count 
from (select t1.employee_id, CONCAT(e.first_name, ' ', e.last_name) as employee_name, e.department_code ,t1.complaint_count 
        from (select r.employee_id, count(*) as complaint_count 
                from receivedtest r
                group by r.employee_id
                order by count(*) desc) t1 
        join employees e on t1.employee_id = e.employee_id) t2 
join departments d on t2.department_code = d.department_code;

---------------------------------------------------------------------------------------------------------------
--6. Accident count by month ordered by month with highest count to lowest count.

select t1.month, t1.count 
from (select extract(month from accident_date) as month, count(*) as count 
        from involved_in 
        group by month
        order by count desc) t1

---------------------------------------------------------------------------------------------------------------
--7. Employees who get salary more than 70000 and recieved more than 5 complaint-ids. 
--   Output employee_id, their position, department that they are working for and complaint count.

select t3.employee_id, p.position_name ,t3.department_name, t3.complaint_count 
from (select t2.employee_id, t2.complaint_count, t2.position_code, d.department_name 
        from (select t1.employee_id, t1.complaint_count, e.position_code, e.department_code 
                from (select r.employee_id, count(*) as complaint_count 
                        from receivedtest r
                        group by r.employee_id
                        having count(*)>5) t1 
                join employees e on t1.employee_id = e.employee_id
                where e.salary >70000) t2 
        join departments d on t2.department_code = d.department_code) t3 
join positions p on t3.position_code = p.position_code;


---------------------------------------------------------------------------------------------------------------
-- 8. Department with highest number of accidents

select departments.department_name, witness.ct from departments
join (select d.department_name ,count(i.accident_id) as ct
      from Involved_in  i 
      join employees e on e.employee_id = i.employee_id
      join departments d on e.department_code = d.department_code
      group by d.department_code
      having count(i.accident_id) >= ALL(select count(i.accident_id) as count from Involved_in  i 
                                         join employees e on e.employee_id = i.employee_id 
                                         join departments d on e.department_code = d.department_code
                                         group by d.department_code)) witness
on witness.department_name = departments.department_name;

----------------------------------------------------------------------------------------------------------------
-- 9. Department with highest number of complaints

select departments.department_name, witness.complaint_count from departments
join (select d.department_name ,count(r.complaint_id) as complaint_count
      from receivedtest  r
      join employees e on e.employee_id = r.employee_id
      join departments d on e.department_code = d.department_code
      group by d.department_code
      having count(r.complaint_id) >= ALL(select count(r.complaint_id) as count from receivedtest  r
                                         join employees e on e.employee_id = r.employee_id 
                                         join departments d on e.department_code = d.department_code
                                         group by d.department_code)) witness
on witness.department_name = departments.department_name;

-----------------------------------------------------------------------------------------------------------------
-- 10. Number of employees in each department in descending order

select d.department_name , count(e.employee_id) as Employee_Count
from employee1 e 
inner join department d 
ON e.department_code = d.department_code 
group by d.department_name
Order by employee_Count desc;

-----------------------------------------------------------------------------------------------------------------
-- 11. Promotion counts for employees who got at least 1 promotion (with their full name) in descending order with their accident count and complaint count.

SELECT CONCAT(e.First_Name, ' ' ,e.Last_Name) as Full_Name , e.promotions as promotions_count , count(i.accident_Type) accident_Count, count(r.complaint_code) complaint_Count  
from employees e   
LEFT JOIN Involved_in i 
ON e.employee_id = i.employee_id  
LEFT JOIN receivedtest r  
ON e.employee_id = r.employee_id    
where e.promotions >= 1 
Group by Full_Name , promotions_count
order by Full_Name desc;

-----------------------------------------------------------------------------------------------------------------
-- 12. Average salary, number of employees for each salary category 

SELECT salary_category ,
AVG (salary) as Avg_Salary ,
count(employee_id) as Employee_Count
From employees
Group By salary_category;

------------------------------------------------------------------------------------------------------------------
-- 13. Number of pending, resovled and non-resolved complaint count for each department.

select o.department_name,d.resolution_status,count(e.*)
from (select distinct d.department_name 
        from departments d 
        join employees e on d.department_code = e.department_code
        join receivedtest r on r.employee_id = e.employee_id) o
        cross join 
        (select distinct r.resolution_status
        from departments d 
        join employees e on d.department_code = e.department_code
        join receivedtest r on r.employee_id = e.employee_id) d
        left join 
        (select *
        from departments d 
        join employees e on d.department_code = e.department_code
        join receivedtest r on r.employee_id = e.employee_id) e
on e.department_name = o.department_name and e.resolution_status = d.resolution_status
group by o.department_name,d.resolution_status
order by o.department_name,d.resolution_status;

-----------------------------------------------------------------------------------------------------------------
-- 14. Top 3 complainees in each department 
 
select t3.department_name,string_agg(t3.employee_name, ',') as top_3_complainees 
from (select t2.department_name, 
            t2.employee_name, 
            t2.sum, 
            row_number() over (partition by t2.department_name order by t2.sum desc) as rank 
        from (select t1.employee_name,t1.department_name, sum(count) as sum 
                from (select CONCAT(e.first_name, ' ', e.last_name) employee_name , d.department_name, count(*) 
                        from receivedtest r 
                        join  employees e on r.employee_id = e.employee_id 
                        join departments d on d.department_code = e.department_code 
                        group by employee_name,d.department_name) as t1 
                group by t1.employee_name,t1.department_name
           ) as t2 
    ) as t3 
where rank <= 3 
group by t3.department_name 


-----------------------------------------------------------------------------------------------------------------
-- 15. Employee who has received highest number of distinct complaint codes

select CONCAT(e.first_name, ' ', e.last_name) as employee_name, witness.ct from employees e
join (select e.employee_id ,count(distinct c.complaint_code) as ct
      from employees  e
      join receivedtest r on e.employee_id = r.employee_id
      join c_codes c on r.complaint_code = c.complaint_code
      group by e.employee_id
      having count(c.complaint_code) >= ALL(select count(distinct c.complaint_code) as count from employees  e
                                            join receivedtest r on e.employee_id = r.employee_id
                                            join c_codes c on r.complaint_code = c.complaint_code
                                            group by e.employee_id)) witness
on witness.employee_id = e.employee_id

-------------------------------------------------------------------------------------------------------------------
-- 16. Employees working for 'FAMILY & SUPPORT' department for more than 30 years, with their promotion count, duration 

select t1.employee_name,t1.promotions,t1.duration 
from (
    select CONCAT(e.first_name, ' ', e.last_name) as employee_name, e.promotions, d.department_name, date_part('year',current_date)-e.start_year as duration
    from employees e join departments d
    on e.department_code = d.department_code ) as t1
where t1.duration >30 and t1.department_name = 'FAMILY & SUPPORT'
order by t1.promotions desc

---------------------------------------------------------------------------------------------------------------------
-- 17. All the positions offered from Department of IT (DoIT) with head count for each position
select p.position_name,  count(*) as number_of_employees
from employees e 
join departments d on e.department_code =d.department_code
join positions p on p.position_code = e.position_code
where d.department_name ='DoIT'
group by p.position_name
order by number_of_employees desc;

















