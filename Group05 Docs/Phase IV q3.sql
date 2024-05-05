CREATE VIEW mother_score AS
SELECT DOE.animal_ID, DOE.birth_weight, milk_rating, weaning_score, mother_score, KID.birth_weight, vigor_score, twin_triplet
FROM DOE NATURAL JOIN GOAT, KID NATURAL JOIN GOAT
WHERE DOE.animal_id = KID.mother_ID;

CREATE VIEW goat_astrology AS
SELECT DOB, AVG(sale_weight)
FROM GOAT
GROUP BY DOB;
