-- phpMyAdmin SQL Dump
-- version 4.5.1
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: May 22, 2017 at 07:56 PM
-- Server version: 10.1.10-MariaDB
-- PHP Version: 5.6.19

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `xenon_gaming_rp`
--

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `ModeName` varchar(32) NOT NULL,
  `SpawnX` float NOT NULL DEFAULT '-182.836',
  `SpawnY` float NOT NULL DEFAULT '1132.67',
  `SpawnZ` float NOT NULL DEFAULT '19.4722',
  `SpawnA` float NOT NULL DEFAULT '0',
  `SpawnInterior` int(11) NOT NULL DEFAULT '0',
  `SpawnVW` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`ModeName`, `SpawnX`, `SpawnY`, `SpawnZ`, `SpawnA`, `SpawnInterior`, `SpawnVW`) VALUES
('Xenon Gaming RP', -182.836, 1132.67, 19.4722, 0, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `AccountID` int(11) NOT NULL,
  `AccountPassword` varchar(256) NOT NULL,
  `AccountName` varchar(32) NOT NULL,
  `AccountIP` varchar(32) NOT NULL DEFAULT '127.0.0.1',
  `AccountDisabled` tinyint(1) NOT NULL DEFAULT '0',
  `AccountBanned` tinyint(1) NOT NULL DEFAULT '0',
  `AccountSpawnX` float NOT NULL DEFAULT '-182.836',
  `AccountSpawnY` float NOT NULL DEFAULT '1132.67',
  `AccountSpawnZ` float NOT NULL DEFAULT '19.7422',
  `AccountSpawnA` float NOT NULL DEFAULT '360',
  `AccountSpawnInt` int(11) NOT NULL DEFAULT '0',
  `AccountSpawnWorld` int(11) NOT NULL DEFAULT '0',
  `AccountLevel` int(11) NOT NULL DEFAULT '1',
  `AccountAdmin` int(11) NOT NULL DEFAULT '0',
  `AccountMoney` int(11) NOT NULL DEFAULT '0',
  `AccountKills` int(11) NOT NULL DEFAULT '0',
  `AccountDeaths` int(11) NOT NULL DEFAULT '0',
  `AccountSkin` int(11) NOT NULL DEFAULT '299'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`AccountID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `AccountID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
