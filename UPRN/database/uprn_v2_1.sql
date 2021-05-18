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
use uprn_v2;
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
  KEY `X5` (`post`,`bno`,`build`,`flat`),
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
