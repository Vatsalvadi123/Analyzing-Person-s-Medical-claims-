create database test;
use test;

alter table dim_drug 
add primary key(drug_ndc); 

alter table dim_drug_brand_generic_code
add primary key(drug_brand_generic_code); 

alter table dim_drug_from_code
modify drug_form_code varchar(3);

alter table dim_drug
modify drug_form_code varchar(3);

alter table dim_drug
modify drug_brand_generic_code int(3);

alter table dim_drug
modify drug_ndc varchar(10);

alter table dim_drug
modify drug_name varchar(20);

alter table dim_drug_brand_generic_code
modify drug_brand_generic_desc varchar(20);

alter table dim_drug_from_code
modify drug_form_desc varchar(20);

alter table dim_fill_date
modify Fill_date varchar(15);

alter table dim_member
modify member_first_name varchar(10);

alter table dim_member
modify member_last_name varchar(10);

alter table dim_member
modify member_birth_date Date;

alter table dim_member
modify member_gender varchar(1);

alter table dim_member
modify member_id varchar(10);

alter table dim_drug_from_code
add primary key(drug_form_code); 

alter table dim_fill_date
add primary key(Fill_date_id); 

alter table dim_member 
add primary key(member_id); 

alter table fact_claim
modify member_id varchar(10);
alter table fact_claim
modify drug_ndc varchar(10);
alter table fact_claim
modify Date varchar(10);

alter table fact_claim 
add primary key(member_id,drug_ndc,DATE); 

alter table dim_drug
add foreign  key dim_drug_drug_form_code_fk(drug_form_code)
references dim_drug_from_code(drug_form_code)
on delete restrict
on update set null;

alter table dim_drug
add foreign  key dim_drug_drug_form_desc_fk(drug_brand_generic_code)
references dim_drug_brand_generic_code(drug_brand_generic_code)
on delete restrict
on update set null;

alter table fact_claim
add foreign  key fact_claim_member_id_fk(member_id)
references dim_member(member_id)
on delete restrict
on update restrict;

alter table fact_claim
add foreign  key fact_claim_drug_ndc_fk(drug_ndc)
references dim_drug(drug_ndc)
on delete restrict
on update restrict;

alter table fact_claim
add foreign  key fact_claim_fill_date_fk(fill_date)
references dim_fill_date(Fill_date_id)
on delete restrict
on update set null;


select a.member_id, a.drug_ndc, b.drug_name
from fact_claim a
left join dim_drug b
on a.drug_ndc = b.drug_ndc
group by b.drug_name,a.date
order by b.drug_name, a.member_id;


drop table if exists q2;
create table q2 as  
select a.*, b.member_age 
from fact_claim a
join dim_member b
on a.member_id = b.member_id;

SELECT count(member_id) as count_of_total_prescreptions, count(distinct member_id) as count_of_distinct_members,sum(copay)as total_copay,sum(insurancepaid) as total_insurance_paid,  
CASE
    WHEN member_age > 65 THEN "> 65"
    WHEN member_age < 65 THEN "< 65"
END AS age 
FROM q2
group by age
order by age;

drop table if exists q3;
create table q3 as  
select a.*, b.member_age, b.member_first_name, b.member_last_name, c.Fill_date, d.drug_name 
from fact_claim a
join dim_member b
on a.member_id = b.member_id
join dim_fill_date c
on c.Fill_date_id = a.Fill_date_id
join dim_drug d
on d.drug_ndc = a.drug_ndc;


select b.member_id,b.member_first_name,b.member_last_name,b.drug_name, b.insurancepaid as Most_recent_insurrance_pay,b.Date as most_recent_fill_date
from (select member_id,member_first_name,member_last_name,Fill_date,drug_name,insurancepaid,Date, row_number() over (partition by member_id  order by member_id, Date desc) as flag 
		from q3) as b
        where flag = 1; 


