-- file: goatpj.sql
--
-- to run install all the files into the directory that your
-- database is on 
--
-- in your psql command prompt \i goatpj.sql
--
-- NEXT: ok so it's 95% done just need to figure 
-- out how to do twins score
-- 
-- 
--
--
--*********************************
-- last updated 4/14/2024
-- last update by: Nicholas Valentino
-- 
--
-- INITIAL FILE BY:
-- John DeGood
-- degoodj@tcnj.edu
-- 
DROP TABLE Animal;
CREATE TABLE Animal (
	animal_id integer primary key,
	lrid integer NOT NULL default 0,
	tag varchar(16) NOT NULL default '',
	rfid varchar(15) NOT NULL default '',
	nlis varchar(16) NOT NULL default '',
	is_new integer NOT NULL default 1,
	draft varchar(20) NOT NULL default '',
	sex varchar(20) NOT NULL default '',
	dob timestamp,
	sire varchar(16) NOT NULL default '',
	dam varchar(16) NOT NULL default '',
	breed varchar(20) NOT NULL default '',
	colour varchar(20) NOT NULL default '',
	weaned integer NOT NULL default 0 ,
	prev_tag varchar(10) NOT NULL default '',
	prev_pic varchar(20) NOT NULL default '',
	note varchar(30) NOT NULL default '',
	note_date timestamp,
	is_exported integer NOT NULL default 0,
	is_history integer NOT NULL default 0,
	is_deleted integer NOT NULL default 0,
	tag_sorter varchar(48) NOT NULL default '',
	donordam varchar(16) NOT NULL default '',
	whp timestamp,
	esi timestamp,
	status varchar(20) NOT NULL default '',
	status_date timestamp,
	overall_adg varchar(20) NOT NULL default '',
	current_adg varchar(20) NOT NULL default '',
	last_weight varchar(20) NOT NULL default '',
	last_weight_date timestamp,
	selected integer default 0,
	animal_group varchar(20) NOT NULL default '',
	current_farm varchar(20) NOT NULL default '',
	current_property varchar(20) NOT NULL default '',
	current_area varchar(20) NOT NULL default '', 
	current_farm_date timestamp,
	current_property_date timestamp,
	current_area_date timestamp,
	animal_group_date timestamp,
	sex_date timestamp,
	breed_date timestamp,
	dob_date timestamp,
	colour_date timestamp,
	prev_pic_date timestamp,
	sire_date timestamp,
	dam_date timestamp,
	donordam_date timestamp,
	prev_tag_date timestamp,
	tag_date timestamp,
	rfid_date timestamp,
	nlis_date timestamp,
	modified timestamp,
	full_rfid varchar(16) default '',
	full_rfid_date timestamp);

DROP TABLE Note;
CREATE TABLE Note (
	animal_id integer NOT NULL,
	created timestamp,
	note varchar(30) NOT NULL,
	session_id integer NOT NULL,
	is_deleted integer default 0,
	is_alert integer default 0,
	primary key( animal_id, created ));

DROP TABLE SessionAnimalActivity;
CREATE TABLE SessionAnimalActivity (
	session_id integer NOT NULL,
	animal_id integer NOT NULL,
	activity_code integer NOT NULL,
	when_measured timestamp NOT NULL,
	latestForSessionAnimal integer default 1,
	latestForAnimal integer default 1,
	is_history integer NOT NULL default 0,
	is_exported integer NOT NULL default 0,
	is_deleted integer default 0,
	primary key( session_id, animal_id, activity_code, when_measured ));

DROP TABLE SessionAnimalTrait CASCADE;
CREATE TABLE SessionAnimalTrait (
	session_id integer NOT NULL,
	animal_id integer NOT NULL,
	trait_code integer NOT NULL,
	alpha_value varchar(20) NOT NULL default '',
	alpha_units varchar(10) NOT NULL default '',
	when_measured timestamp NOT NULL,
	latestForSessionAnimal integer default 1,
	latestForAnimal integer default 1,
	is_history integer NOT NULL default 0,
	is_exported integer NOT NULL default 0,
	is_deleted integer default 0,
	primary key(session_id, animal_id, trait_code, when_measured));

DROP TABLE child CASCADE;
Create TABLE child (
animal_id integer NOT NULL,
tag varchar(16) NOT NULL default '',
dam varchar(16) NOT NULL default '',
sex varchar(20) NOT NULL default '',
dob timestamp,
BWT varchar(20) NOT NULL default '',
vigor_sco varchar(20) NOT NULL default '',
milk_Rating varchar(20) NOT NULL default '',
weaning_sco varchar(20) NOT NULL default '',
Mother_sco varchar(20) NOT NULL default '',
Primary Key (animal_id));




-- read the CSV file into the table
\copy Animal from 'Animal.csv' WITH DELIMITER ',' CSV HEADER;

-- read the CSV file into the table
\copy Note from 'Note.csv' WITH DELIMITER ',' CSV HEADER;

-- read the CSV file into the table
\copy SessionAnimalActivity from 'SessionAnimalActivity.csv' WITH DELIMITER ',' CSV HEADER;

-- read the CSV file into the table
\copy SessionAnimalTrait from 'SessionAnimalTrait.csv' WITH DELIMITER ',' CSV HEADER;





-- create view that figures out BWT code:357 --
DROP view wght;
create view wght as Select animal_id,trait_code,alpha_value,alpha_units from SessionAnimalTrait
where (trait_code=357);

-- create view that fnds out sale weight code:create table kid as

--this appeared?
--SET vigor_sco = v.alpha_value
--FROM vig v
--WHERE child.animal_id = v.animal_id;

DROP view ywt;
create view ywt as Select animal_id,trait_code,alpha_value,alpha_units from SessionAnimalTrait
where (trait_code=524);

-- create view that finds out vigor score code:230 --
DROP view vig;
create view vig as Select animal_id,trait_code,alpha_value,alpha_units from SessionAnimalTrait
where (trait_code=230);

-- creat view that finds out milk rating code:475 --
DROP view milkrat;
create view milkrat as Select animal_id,trait_code,alpha_value,alpha_units from SessionAnimalTrait
where (trait_code=475);

-- create view that finds out weaning score code:2228  -- 
DROP view wean;
create view wean as Select animal_id,trait_code,alpha_value,alpha_units from SessionAnimalTrait
where (trait_code=2228);

-- create view that finds out mother code: 935 and 740 --
DROP view moscore;
create view moscore as Select animal_id,trait_code,alpha_value,alpha_units from SessionAnimalTrait
where (trait_code=935)or(trait_code=740);


--insert primary data into child --
INSERT INTO child (animal_id,tag,dam,sex,dob) 
Select animal_id,tag,dam,sex,dob
from Animal;
-- add the BWT from wght BWT=alpha_value--
UPDATE child c
SET BWT = w.alpha_value
FROM wght w
WHERE c.animal_id = w.animal_id;


-- add vigor to child --
UPDATE child c
SET vigor_sco = v.alpha_value
FROM vig v
WHERE c.animal_id = v.animal_id;

-- add milk rating to child--
UPDATE child c
SET milk_Rating = m.alpha_value
FROM milkrat m 
WHERE c.animal_id = m.animal_id;

-- add weaning score to child--
UPDATE child c
SET weaning_sco = w.alpha_value
FROM wean w
WHERE c.animal_id = w.animal_id;

--add mother to child
UPDATE child c
SET Mother_sco = m.alpha_value
FROM moscore m 
WHERE c.animal_id = m.animal_id;

-- this is the information we will need from the child --
DROP table kid CASCADE;
create table kid as
select animal_id, tag, dam, vigor_sco
from child
where dam <> '' AND dam <> 'UNKNOWN';

ALTER TABLE kid ADD column kid_sco integer DEFAULT 0;


-- kids dealing with birth weight --
UPDATE kid 
SET kid_sco = kid_sco + 5
FROM child
WHERE child.BWT <> '' AND child.animal_id = kid.animal_id
AND child.BWT::numeric > 6;

UPDATE kid 
SET kid_sco = kid_sco + 3
FROM child
WHERE child.BWT <> '' AND child.animal_id = kid.animal_id
AND child.BWT::numeric < 6;

-- kids dealing with vigor score
UPDATE kid 
SET kid_sco = kid_sco + 5
WHERE vigor_sco <> ''
AND vigor_sco::numeric = 1;

UPDATE kid 
SET kid_sco = kid_sco + 2
WHERE vigor_sco <> ''
AND vigor_sco::numeric < 2;

UPDATE kid 
SET kid_sco = kid_sco + 0
WHERE vigor_sco <> ''
AND vigor_sco::numeric < 3;

--***********dealing with the kids is over*****************--

--find out who are mothers--

DROP table mom;
create table mom as
select a.animal_id, a.tag, c.milk_Rating,c.weaning_sco, c.Mother_sco
from animal a
INNER JOIN child c ON a.tag = c.tag
WHERE EXISTS (SELECT * 
			FROM child
			WHERE child.dam = a.tag);
--ADDED WHERE clause so mom's are only goats with kids

ALTER TABLE mom ADD column twin_triplet integer DEFAULT 0;
ALTER TABLE mom ADD column Total_score integer DEFAULT 0;

--*************************TWIN Queries**************************************
--This is more complicated than it needs to be

--Find size of litter each kid was born in
DROP VIEW SING_TWIN_TRIP CASCADE;
CREATE VIEW SING_TWIN_TRIP AS
SELECT a.animal_id, COUNT(a.animal_id)
FROM (kid NATURAL JOIN child) a LEFT JOIN (kid NATURAL JOIN child) b ON a.dob = b.dob
WHERE a.dam = b.dam AND a.dam <> ''
GROUP BY a.animal_id;

--LISTS EACH DAM based on how many singles they had, how many twins/trips
DROP TABLE SINGLE;
CREATE TABLE SINGLE AS
SELECT dam, count(SING_TWIN_TRIP.animal_id)
FROM SING_TWIN_TRIP NATURAL JOIN kid
WHERE COUNT = 1
GROUP BY dam;

DROP TABLE TWIN;
CREATE TABLE TWIN AS
SELECT dam, count(SING_TWIN_TRIP.animal_id)
FROM SING_TWIN_TRIP NATURAL JOIN kid
WHERE COUNT = 2
GROUP BY dam;
--count value is 2x higher
UPDATE TWIN
SET count = (count/2);

DROP TABLE TRIPLET;
CREATE TABLE TRIPLET AS
SELECT dam, count(SING_TWIN_TRIP.animal_id)
FROM SING_TWIN_TRIP NATURAL JOIN kid
WHERE COUNT = 3
GROUP BY dam;
--count is 3x higher
UPDATE TRIPLET
SET count = (count/3);

-- ADD these scores up then divide to get AVG
UPDATE mom
SET twin_triplet = twin_triplet + (SINGLE.count * 2)
FROM SINGLE, child
WHERE mom.animal_id = child.animal_id AND child.tag = SINGLE.dam;

UPDATE mom
SET twin_triplet = twin_triplet + (TWIN.count * 6)
FROM TWIN, child
WHERE mom.animal_id = child.animal_id AND child.tag = TWIN.dam;

UPDATE mom
SET twin_triplet = twin_triplet + (TRIPLET.count * 3)
FROM TRIPLET, child
WHERE mom.animal_id = child.animal_id AND child.tag = TRIPLET.dam;

DROP VIEW SING_TWIN_TRIP;
DROP TABLE SINGLE; DROP TABLE TWIN; DROP TABLE TRIPLET; 
--**********************END TWIN SCORE****************************--

-- mothering score cakulculation (has a defoult update because
-- anything under good +1)--

update mom 
set Total_score = Total_score + 1; 

update mom 
set Total_score = Total_score + 4 
where LOWER(mother_sco) <> 'good mom';

--milk score calculation (default of 1 again)--

UPDATE mom 
SET Total_score = Total_score + 1;

UPDATE mom
SET Total_score = Total_score + 4
where LOWER(milk_Rating) <> '1 Good Milk';


-- BWT calculation --
UPDATE mom 
SET Total_score = Total_score + 5
FROM child
WHERE child.BWT <> '' AND child.animal_id = mom.animal_id
AND BWT::numeric > 6;

UPDATE mom 
SET Total_score = Total_score + 3
FROM child
WHERE child.BWT <> '' AND child.animal_id = mom.animal_id
AND BWT::numeric < 6; 

UPDATE mom
SET Total_score = Total_score + twin_triplet;


--Score table to hold just dam and their score
DROP TABLE scores;
create Table scores AS 
select m.tag,m.animal_id,SUM(k.kid_sco) AS Total_Mother_Score
from mom NATURAL JOIN child m JOIN kid k
on m.tag=k.dam
group by m.animal_id;

update scores
set Total_Mother_Score = Total_Mother_Score + 
(select Total_score from mom where mom.animal_id=scores.animal_id);

/* This is just annoying to have at the end
select * from scores
order by Total_Mother_Score DESC;
*/
-- this will sum up all the kids scores--

--**************************** Astrology Queries *********************************--
DROP VIEW Astrology;
CREATE VIEW Astrology AS
SELECT tag, dob, kid_sco
FROM child NATURAL JOIN kid
WHERE dob is NOT NULL
ORDER BY kid_sco;