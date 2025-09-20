INSERT INTO `addon_account` (name, label, shared) VALUES 
	('society_bennys','bennys',1)
;

INSERT INTO `datastore` (name, label, shared) VALUES 
	('society_bennys','bennys',1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES 
	('society_bennys', 'bennys', 1)
;

INSERT INTO `jobs` (`name`, `label`) VALUES
('bennys', "Benny's")
;

INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('bennys', 0, 'novice', 'Débutant', 200, 'null', 'null'),
('bennys', 1, 'expert', 'Mecano', 400, 'null', 'null'),
('bennys', 2, 'chef', "Chef d'atelier", 600, 'null', 'null'),
('bennys', 3, 'boss', 'Patron', 1000, 'null', 'null')
;
