-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 17, 2019 at 06:26 AM
-- Server version: 10.1.31-MariaDB
-- PHP Version: 5.6.38

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `sampkeki`
--

-- --------------------------------------------------------

--
-- Table structure for table `board_sys`
--

CREATE TABLE `board_sys` (
  `boardId` int(11) NOT NULL,
  `boardX` float NOT NULL,
  `boardY` float NOT NULL,
  `boardZ` float NOT NULL,
  `boardA` float NOT NULL,
  `boardField` varchar(32) NOT NULL,
  `boardInfo` varchar(16) NOT NULL,
  `boardType` int(11) NOT NULL DEFAULT '0',
  `boardMaxPlayer` int(11) NOT NULL DEFAULT '0',
  `boardText1` varchar(64) NOT NULL,
  `boardText2` varchar(64) NOT NULL,
  `boardText3` varchar(64) NOT NULL,
  `boardText4` varchar(64) NOT NULL,
  `boardText5` varchar(64) NOT NULL,
  `boardText6` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `board_sys`
--
ALTER TABLE `board_sys`
  ADD PRIMARY KEY (`boardId`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `board_sys`
--
ALTER TABLE `board_sys`
  MODIFY `boardId` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
