-- MySQL dump 10.13  Distrib 5.7.33, for Win64 (x86_64)
--
-- Host: localhost    Database: abp
-- ------------------------------------------------------
-- Server version	5.7.23-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `baseline`
--

DROP TABLE IF EXISTS `baseline`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `baseline` (
  `id` bigint(20) NOT NULL,
  `ID21_BLPU_UPRN` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `ID21_BLPU_ PARENT_UPRN` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `Table` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `KEY` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `ADDRESS_STRING` varchar(3071) COLLATE latin1_bin DEFAULT NULL,
  `ORGANISATION` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID24_LPI.SAO_TEXT` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID24_LPI.SAO_START_NUMBER` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID24_LPI.START_SUFFIX` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID24_LPI.SAO_END_NUMBER` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID24_LPI.SAO_END_SUFFIX` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID24_LPI.PAO_TEXT` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID24_LPI.PAO_START_NUMBER` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID24_LPI.PAO_START_SUFFIX` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID24_LPI.PAO_END_NUMBER` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID24_LPI.PAO_END_SUFFIX` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID15_STREET DESCRIPTOR.STREET_DESCRIPTION` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID15_STREET DESCRIPTOR.LOCALITY` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID15_STREET DESCRIPTOR.TOWN_NAME` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID21_BLPU.POSTCODE_LOCATOR` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID28_DPA_RECORDS.DEPARTMENT_NAME` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID28_DPA_RECORDS.ORGANISATION_NAME` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID28_DPA_RECORDS.SUB_BUILDING_NAME` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID28_DPA_RECORDS.BUILDING_NAME` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID28_DPA_RECORDS.BUILDING_NUMBER` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID28_DPA_RECORDS.PO_BOX_NUMBER` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID28_DPA_RECORDS.DEPENDENT_THOROUGHFARE` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID28_DPA_RECORDS.THOROUGHFARE` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID28_DPA_RECORDS.DOUBLE_DEPENDENT_LOCALITY` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID28_DPA_RECORDS.DEPENDENT_LOCALITY` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID28_DPA_RECORDS.POST_TOWN` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID28_DPA_RECORDS.POSTCODE` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ID32_Class_Records.CLASSIFICATION_CODE` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `ID24_LPI.LOGICAL_STATUS` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `ID24_LPI.START_DATE` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `ID24_LPI.END_DATE` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `ID24_LPI.LEVEL` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `ID21_BLPU.X_COORDINATE` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `ID21_BLPU.Y_COORDINATE` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `EPOCH` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `COU TYPE` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_baseline_uprn` (`ID21_BLPU_UPRN`),
  KEY `idx_baseline_epoch` (`EPOCH`),
  KEY `idx_baseline_adr` (`ADDRESS_STRING`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `blpu_records`
--

DROP TABLE IF EXISTS `blpu_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `blpu_records` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `record_identifier` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `change_type` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `pro_order` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `uprn` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `logical_status` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `blpu_state` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `blpu_state_date` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `parent_uprn` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `x_coordinate` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `y_coordinate` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `latitude` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `longitude` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `rpc` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `local_custodian_code` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `country` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `start_date` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `end_date` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `last_update_date` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `entry_date` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `addressbase_postal` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `postcode_locator` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `multi_occ_count` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `epoch` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11781827 DEFAULT CHARSET=latin1 COLLATE=latin1_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `class_records`
--

DROP TABLE IF EXISTS `class_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `class_records` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `record_identifier` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `change_type` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `pro_order` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `uprn` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `class_key` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `classification_code` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `class_scheme` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `scheme_version` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `start_date` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `end_date` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `last_update_date` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `entry_date` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `epoch` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13021799 DEFAULT CHARSET=latin1 COLLATE=latin1_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dpa_records`
--

DROP TABLE IF EXISTS `dpa_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dpa_records` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `record_identifier` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `change_type` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `pro_order` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `uprn` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `uduprn` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `organization_name` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `department_name` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `sub_building_name` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `building_name` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `building_number` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `dependent_throughfare` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `throughfare` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `double_dependent_locality` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `dependent_locality` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `post_town` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `post_code` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `postcode_type` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `delivery_point_suffix` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `welsh_dependent_throughfare` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `welsh_throughfare` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `welsh_double_dependent_locality` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `welsh_dependent_locality` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `welsh_post_town` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `po_box_number` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `process_date` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `start_date` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `end_date` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `last_update_date` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `entry_date` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `epoch` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8625627 DEFAULT CHARSET=latin1 COLLATE=latin1_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lpi_records`
--

DROP TABLE IF EXISTS `lpi_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lpi_records` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `record_identifier` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `change_type` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `pro_order` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `uprn` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `lpi_key` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `language` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `logical_status` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `start_date` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `end_date` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `last_update_date` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `entry_date` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `sao_start_number` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `sao_start_suffix` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `sao_end_number` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `sao_end_suffix` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `sao_text` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `pao_start_number` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `pao_start_fuffix` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `pao_end_number` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `pao_end_suffix` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `pao_text` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `usrn` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `usrn_match_indicator` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `area_name` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `level` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `official_flag` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `epoch` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12565401 DEFAULT CHARSET=latin1 COLLATE=latin1_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `qareport`
--

DROP TABLE IF EXISTS `qareport`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `qareport` (
  `id` bigint(20) NOT NULL,
  `patient_address_id` bigint(20) NOT NULL,
  `patient_address_match_id` bigint(20) NOT NULL,
  `patient_address_string` varchar(3071) COLLATE latin1_bin DEFAULT '',
  `existing_epoch` varchar(45) COLLATE latin1_bin DEFAULT '',
  `existing_alg_version` varchar(45) COLLATE latin1_bin DEFAULT '',
  `existing_uprn` varchar(45) COLLATE latin1_bin DEFAULT '',
  `existing_match_rule` varchar(45) COLLATE latin1_bin DEFAULT '',
  `existing_qualifier` varchar(45) COLLATE latin1_bin DEFAULT '',
  `existing_class_code` varchar(45) COLLATE latin1_bin DEFAULT '',
  `existing_start_date` varchar(45) COLLATE latin1_bin DEFAULT '',
  `existing_postcode` varchar(45) COLLATE latin1_bin DEFAULT '',
  `new_epoch` varchar(45) COLLATE latin1_bin DEFAULT '',
  `new_alg_version` varchar(45) COLLATE latin1_bin DEFAULT '',
  `new_uprn` varchar(45) COLLATE latin1_bin DEFAULT '',
  `new_match_rule` varchar(45) COLLATE latin1_bin DEFAULT '',
  `new_qualifier` varchar(45) COLLATE latin1_bin DEFAULT '',
  `new_class_code` varchar(45) COLLATE latin1_bin DEFAULT '',
  `new_start_date` varchar(45) COLLATE latin1_bin DEFAULT '',
  `new_postcode` varchar(45) COLLATE latin1_bin DEFAULT '',
  `new_uprn_existing_epoch` varchar(45) COLLATE latin1_bin DEFAULT '',
  `new_uprn_new_epoch` varchar(45) COLLATE latin1_bin DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `streetdesc_records`
--

DROP TABLE IF EXISTS `streetdesc_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `streetdesc_records` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `record_identifier` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `change_type` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `pro_order` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `usrn` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `street_description` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `locality` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `town_name` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `administrative_area` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `language` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `start_date` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `end_date` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `last_update_date` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `entry_date` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `epoch` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=185061 DEFAULT CHARSET=latin1 COLLATE=latin1_bin;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-05-07 11:43:29
-- MySQL dump 10.13  Distrib 5.7.33, for Win64 (x86_64)
--
-- Host: localhost    Database: uprn_v2
-- ------------------------------------------------------
-- Server version	5.7.23-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `temp_import_u`
--

DROP TABLE IF EXISTS `temp_import_u`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `temp_import_u` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `table` varchar(2) COLLATE latin1_bin DEFAULT NULL,
  `uprn` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `key` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `flat` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `build` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `bno` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `depth` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `street` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `deploc` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `loc` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `town` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `post` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `org` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `dep` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `ptype` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `admin` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `name` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `uprn_blpu`
--

DROP TABLE IF EXISTS `uprn_blpu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `uprn_blpu` (
  `id` bigint(20) NOT NULL,
  `uprn` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `adpost` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `post` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `status` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `bpstat` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `insdate` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `update` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `coord1` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `local` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `uprn_class`
--

DROP TABLE IF EXISTS `uprn_class`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `uprn_class` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uprn` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `code` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `uprn_classification`
--

DROP TABLE IF EXISTS `uprn_classification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `uprn_classification` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `code` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `term` varchar(512) COLLATE latin1_bin DEFAULT NULL,
  `residential` varchar(1) COLLATE latin1_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `uprn_county`
--

DROP TABLE IF EXISTS `uprn_county`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `uprn_county` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `county` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `population` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `region` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `uprn_dictionary`
--

DROP TABLE IF EXISTS `uprn_dictionary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `uprn_dictionary` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `n1` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `n2` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `n3` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `data` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1386 DEFAULT CHARSET=latin1 COLLATE=latin1_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `uprn_l`
--

DROP TABLE IF EXISTS `uprn_l`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `uprn_l` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uprn` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `level` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `uprn_lpstr`
--

DROP TABLE IF EXISTS `uprn_lpstr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `uprn_lpstr` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `usrn` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `lang` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `name` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `locality` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `admin` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `town` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `uprn_main`
--

DROP TABLE IF EXISTS `uprn_main`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `uprn_main` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `node` varchar(45) COLLATE latin1_bin DEFAULT NULL,
  `uprn` varchar(45) COLLATE latin1_bin DEFAULT NULL COMMENT 'unique property reference number',
  `table` varchar(45) COLLATE latin1_bin DEFAULT NULL COMMENT 'D=DPA, L=LPI',
  `key` varchar(45) COLLATE latin1_bin DEFAULT NULL COMMENT 'udprn (unique delivery point reference number)',
  `post` varchar(45) COLLATE latin1_bin DEFAULT NULL COMMENT 'post code',
  `indrec` varchar(255) COLLATE latin1_bin DEFAULT NULL,
  `bno` varchar(45) COLLATE latin1_bin DEFAULT NULL COMMENT 'building number',
  `build` varchar(45) COLLATE latin1_bin DEFAULT NULL COMMENT 'building name',
  `flat` varchar(45) COLLATE latin1_bin DEFAULT NULL COMMENT 'sub building name or flat',
  `street` varchar(45) COLLATE latin1_bin DEFAULT NULL COMMENT 'throughfare or street',
  `name` varchar(255) COLLATE latin1_bin DEFAULT NULL COMMENT 'street description',
  `admin` varchar(45) COLLATE latin1_bin DEFAULT NULL COMMENT 'administrative area',
  `town` varchar(45) COLLATE latin1_bin DEFAULT NULL COMMENT 'post town',
  `deploc` varchar(45) COLLATE latin1_bin DEFAULT NULL COMMENT 'double dependent locality',
  `loc` varchar(45) COLLATE latin1_bin DEFAULT NULL COMMENT 'dependent locality',
  `org` varchar(255) COLLATE latin1_bin DEFAULT NULL COMMENT 'organisation',
  `dep` varchar(255) COLLATE latin1_bin DEFAULT NULL COMMENT 'department',
  PRIMARY KEY (`id`),
  KEY `X5` (`post`,`n1`,`bno`,`build`,`flat`),
  KEY `X1` (`post`,`uprn`),
  KEY `X2` (`build`,`street`,`flat`,`post`,`bno`,`uprn`,`table`,`key`),
  KEY `X3` (`build`,`flat`,`post`,`uprn`,`table`,`key`),
  KEY `X4` (`post`,`street`,`bno`,`flat`,`build`,`uprn`,`table`,`key`),
  KEY `X5A` (`post`,`street`,`build`,`flat`,`bno`,`uprn`,`table`,`key`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2021-05-07 11:43:29
