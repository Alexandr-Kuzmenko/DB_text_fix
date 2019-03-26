# Creating table from data of 'SHOW CREATE TABLE tbl_name' command:
CREATE TABLE `hle_dev_test_alexandr_kuzmenko` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `candidate_office_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7486 DEFAULT CHARSET=latin1;

# Insert starting data from initial table;
Insert into hle_dev_test_alexandr_kuzmenko (id, candidate_office_name) select id, candidate_office_name from hle_dev_test_candidates;

# Adding columns
ALTER TABLE hle_dev_test_alexandr_kuzmenko
ADD COLUMN clean_name varchar(155) AFTER candidate_office_name,
ADD COLUMN sentence varchar(155) AFTER clean_name;

# useful update rows to watch reusing updating script
UPDATE hle_dev_test_alexandr_kuzmenko SET clean_name = CONCAT(candidate_office_name);
UPDATE hle_dev_test_alexandr_kuzmenko SET clean_name = '';
UPDATE hle_dev_test_alexandr_kuzmenko SET sentence = '';