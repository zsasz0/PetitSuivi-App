-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jun 14, 2026 at 10:47 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `bkpetitsuivi8`
--

-- --------------------------------------------------------

--
-- Table structure for table `Account`
--

CREATE TABLE `Account` (
  `Adresse` varchar(50) DEFAULT NULL,
  `Approval_status` varchar(50) DEFAULT NULL,
  `Birthdate` date DEFAULT NULL,
  `Cin` int(11) DEFAULT NULL,
  `Email` varchar(50) DEFAULT NULL,
  `Firstname` varchar(50) DEFAULT NULL,
  `Inscriptiondate` date DEFAULT NULL,
  `Is_archived` tinyint(1) DEFAULT NULL,
  `Lastname` varchar(50) DEFAULT NULL,
  `Password` varchar(255) DEFAULT NULL,
  `Phone` int(11) DEFAULT NULL,
  `AccountID` int(11) NOT NULL,
  `RoleID` int(11) DEFAULT NULL,
  `PersonID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Account`
--

INSERT INTO `Account` (`Adresse`, `Approval_status`, `Birthdate`, `Cin`, `Email`, `Firstname`, `Inscriptiondate`, `Is_archived`, `Lastname`, `Password`, `Phone`, `AccountID`, `RoleID`, `PersonID`) VALUES
('1 Launch Street, Tunis', 'approved', '1980-01-01', 10000000, 'admin@test.com', 'System', '2024-01-01', 0, 'Admin', '$2y$04$sEuQdNlG1zMhwvjtx6uBJegNfs8SQBfL9IwehychRqpASrrVzxf.e', 2147483647, 10000000, 2, 10000000),
('afran', 'approved', '2001-04-14', 12345678, 'salah@mail.com', 'salah', '2026-04-06', 0, 'frikha', '$2y$04$qubt1e0FKI6VNkgSFQfnUeY/8cjTT6gda53gpmXil8yLp9Zruw4ae', 12345666, 40000031, 1, 40000032),
('Tunis', 'approved', '1990-05-10', 11112222, 'amina@mail.com', 'Amina', '2026-04-06', 0, 'Trabelsi', '$2y$04$u2TwGUjPEFN/RuMU6jtm3.OwJz9uC0wJTQF8ZGvSfr5UrOhmoyHHW', 98111222, 40000032, 1, 40000033),
('Sousse', 'approved', '1988-11-20', 22223333, 'karim@mail.com', 'Karim', '2026-04-06', 0, 'Gharbi', '$2y$12$.nor2Ry7IOh/NSlNK1uabOt/Tc59AjZ5Rf0MPVe4gpHjqN7jfP2uC', 98222333, 40000033, 1, 40000034),
('Sfax', 'approved', '1995-02-15', 33334444, 'leila@mail.com', 'Leila', '2026-04-06', 0, 'Mansour', '$2y$04$u2TwGUjPEFN/RuMU6jtm3.OwJz9uC0wJTQF8ZGvSfr5UrOhmoyHHW', 98333444, 40000034, 1, 40000035),
('Bizerte', 'approved', '1992-08-30', 44445555, 'nizar@mail.com', 'Nizar', '2026-04-06', 1, 'Chaabane', '$2y$04$u2TwGUjPEFN/RuMU6jtm3.OwJz9uC0wJTQF8ZGvSfr5UrOhmoyHHW', 98444555, 40000035, 1, 40000036),
('afran', 'approved', '2008-04-06', 25825823, 'ttitchalav3@gmail.com', 'amir', '2026-04-06', 0, 'kammoun', '$2y$04$xG.RDFEQn0ghNDsvIFzkjO6kTzHjcZ4wWC9icqAsz8gnTF8K1niKq', 22223322, 40000036, 3, 40000037),
('gtemda', 'approved', '1996-04-06', 25834697, 'rami@mail.com', 'rami', '2026-04-06', 0, 'kammoun', '$2y$04$gkXswKQn3RXi7Y9Lk0cKAep7K5KBHT8..QJzjKjQXmrcsFxDOun8W', 12345678, 40000037, 3, 40000038),
('Tunis', 'approved', '1999-04-09', 55556666, 'ali.teacher@test.com', 'Ali', '2026-04-07', 0, 'Ben Ali', '$2y$04$Mv5oK.vsMisVwF.sTfgMK.EDawnZ7BSvn24l.1yy6vK14IX/.kcR.', 99123456, 40000039, 1, 40000040),
('Rue de Marseille, Tunis', 'approved', '1992-07-18', 75584767, 'salma.parent.75584767@example.com', 'Salma', '2026-04-07', 0, 'Trabelsi', '$2y$04$sVNZFqjyqvN3BCryVpc.LeY8qD5TK5xSbu.6o8ajyp8hXmmw8FQlC', 22755847, 40000041, 3, 40000042),
('Rue de Rome Tunis', 'approved', '1990-01-11', 75584768, 'amina.parent.75584768@example.com', 'Amina', '2026-04-07', 0, 'BenSalem', 'Password@1', 22755868, 40000042, 3, 40000043),
('Rue Alger Tunis', 'approved', '1988-06-22', 75584769, 'hatem.parent.75584769@example.com', 'Hatem', '2026-04-07', 0, 'Gharbi', 'Password@1', 22755869, 40000043, 3, 40000044),
('Rue Palestine Tunis', 'approved', '1993-04-09', 75584770, 'mariem.parent.75584770@example.com', 'Mariem', '2026-04-07', 0, 'Zouari', 'Password@1', 22755870, 40000044, 3, 40000045),
('Avenue Liberte Tunis', 'approved', '1987-12-03', 75584771, 'walid.parent.75584771@example.com', 'Walid', '2026-04-07', 0, 'Mrad', 'Password@1', 22755871, 40000045, 3, 40000046),
('Rue Syrie Ariana', 'approved', '1991-02-17', 75584772, 'ines.parent.75584772@example.com', 'Ines', '2026-04-07', 0, 'Brahmi', 'Password@1', 22755872, 40000046, 3, 40000047),
('Avenue Hedi Nouira Ennasr', 'approved', '1989-08-28', 75584773, 'sami.parent.75584773@example.com', 'Sami', '2026-04-07', 0, 'Jaziri', 'Password@1', 22755873, 40000047, 3, 40000048),
('Rue Lac Biwa Lac1', 'approved', '1994-05-16', 75584774, 'olfa.parent.75584774@example.com', 'Olfa', '2026-04-07', 0, 'Cherif', 'Password@1', 22755874, 40000048, 3, 40000049),
('Rue Mongi Slim Sousse', 'approved', '1986-09-05', 75584775, 'nidhal.parent.75584775@example.com', 'Nidhal', '2026-04-07', 0, 'Saidi', 'Password@1', 22755875, 40000049, 3, 40000050),
('Avenue Farhat Hached Nabeul', 'approved', '1992-11-13', 75584776, 'rim.parent.75584776@example.com', 'Rim', '2026-04-07', 0, 'Tlili', 'Password@1', 22755876, 40000050, 3, 40000051),
('Rue Ibn Khaldoun Bardo', 'approved', '1988-03-21', 75584777, 'yassine.parent.75584777@example.com', 'Yassine', '2026-04-07', 0, 'Hamdi', 'Password@1', 22755877, 40000051, 3, 40000052),
('Rue Marseille Tunis', 'pending', '1990-06-12', 75584778, 'mouna.parent.75584778@example.com', 'Mouna', '2026-04-07', 0, 'Khelifi', '$2y$04$gq8EzskFaprcYjPTCkkBcehcNoVJYjrmxdy4w.4BcukEJdt72Um0W', 22755878, 40000052, 3, 40000053),
('Avenue Carthage Tunis', 'pending', '1987-01-25', 75584779, 'tarek.parent.75584779@example.com', 'Tarek', '2026-04-07', 0, 'BenAmor', '$2y$04$8mmRmIdX/M2wNPkAZogpmeC5yJ7fksxTySYxTryT0I/.Widh6kIGS', 22755879, 40000053, 3, 40000054),
('Rue Espagne Tunis', 'pending', '1993-10-03', 75584780, 'hela.parent.75584780@example.com', 'Hela', '2026-04-07', 0, 'Sfar', '$2y$04$3mQiP1x/v/Ci7P9FQqXM1uGKoKc6QSTudm7w/Q5XeOp3VlnTiU6YO', 22755880, 40000054, 3, 40000055),
('Rue Lac Victoria Lac2', 'pending', '1988-07-14', 75584781, 'fares.parent.75584781@example.com', 'Fares', '2026-04-07', 0, 'Dridi', '$2y$04$04W7DBRS9oNN7Y.l4MJY5eVEMuD3JgZa4d80plP7NX2yAdLu117dy', 22755881, 40000055, 3, 40000056),
('Avenue Taieb Mhiri Sfax', 'pending', '1991-09-29', 75584782, 'chaima.parent.75584782@example.com', 'Chaima', '2026-04-07', 0, 'Miled', '$2y$04$vZY5nyMHZrDKcRIJvwJZ8Om39azq5XyyZ5uax.TEkSw1w6IKYXG3m', 22755882, 40000056, 3, 40000057),
('Rue 2 Mars Ariana', 'pending', '1986-12-18', 75584783, 'karim.parent.75584783@example.com', 'Karim', '2026-04-07', 0, 'Ghannouchi', '$2y$04$wQo4W7aiU4KyCn3Sn6XJXOps1nDsfmcQT7KhH.QI6GBUxv5RybWfu', 22755883, 40000057, 3, 40000058),
('Rue Kairouan Monastir', 'pending', '1994-04-07', 75584784, 'sarra.parent.75584784@example.com', 'Sarra', '2026-04-07', 0, 'Majri', '$2y$04$z6gGKOeReru.caeRXhDVDuwB8I2HpaJN4LnAlBZNu6heAxDa8FJDS', 22755884, 40000058, 3, 40000059),
('Avenue Bourguiba Bizerte', 'approved', '1989-11-22', 75584785, 'nabil.parent.75584785@example.com', 'Nabil', '2026-04-07', 0, 'Boussetta', '$2y$04$jzcXreMqJJQuxFX3gIN.qO/NbcDvRZojXEQtU8CxV4OM2ZPQK6SRa', 22755885, 40000059, 3, 40000060),
('Rue Ibn Sina Sousse', 'approved', '1992-02-08', 75584786, 'rania.parent.75584786@example.com', 'Rania', '2026-04-07', 0, 'Haddad', '$2y$04$wROK1yFppDx.Lg1EIQ.1Uu737Rln4I/mXvHeg0pGUlAKMNdWnU9UG', 22755886, 40000060, 3, 40000061),
('Avenue Habib Thameur Tunis', 'approved', '1987-05-19', 11196006, 'kamel@mail.com', 'Adel', '2026-04-07', 0, 'Toumi', '$2y$04$BIese8goFbNSL88PyvmkMuXTESnCEnq0VrOLYfkesElP3b5OtwEju', 22755887, 40000061, 3, 40000062),
('Rue Athenes Tunis', 'approved', '1991-03-17', 75584788, 'nesrine.parent.75584788@example.com', 'Nesrine', '2026-04-07', 0, 'Abid', '$2y$04$LTkr.yPx9RNJnuZ4DaS1KOHtdRn.rsKpuPkQ8zDxyBhaArppVOsV6', 22755888, 40000062, 3, 40000063),
('Avenue France Tunis', 'approved', '1988-08-09', 75584789, 'bilel.parent.75584789@example.com', 'Bilel', '2026-04-07', 0, 'Mokni', '$2y$04$ahUsYA24y29Lk9PQ/DP8u.mT./bE8nvvlvJypnG5AtanO2ysRalzC', 22755889, 40000063, 3, 40000064),
('Rue Turquie Ariana', 'pending', '1993-01-28', 75584790, 'asma.parent.75584790@example.com', 'Asma', '2026-04-07', 0, 'Bouazizi', '$2y$04$RgN0DyZb7Dbnf2lg299jI.3USXpzFOT.Ir0mnzfMv6EVPrtV0Ndoe', 22755890, 40000064, 3, 40000065),
('Rue Lac Annecy Lac1', 'pending', '1987-06-04', 75584791, 'lotfi.parent.75584791@example.com', 'Lotfi', '2026-04-07', 1, 'BenHassen', '$2y$04$JNMGBWWGovTy/1SFXxduHegdklCW0d0YtfoEXrjbclJkGuXoHyO2O', 22755891, 40000065, 3, 40000066),
('Avenue Ali Belhouane Nabeul', 'pending', '1992-10-15', 75584792, 'wafa.parent.75584792@example.com', 'Wafa', '2026-04-07', 0, 'Masmoudi', '$2y$04$kEQKpLw1OZtMOrgBFhNi2eWhk21StohH.yCt3k1k5x5NEMIQdSOSO', 22755892, 40000066, 3, 40000067),
('Tunis', 'approved', '1995-01-01', 99998888, 'test.teacher@example.com', 'Test', '2026-04-07', 1, 'Teacher', '$2y$04$dtUGhAIJsvW.acGwPWIdwOyPNDUXPoy5dfnzm7kiFsLlDH808j6o2', 99000000, 40000067, 1, 40000068),
('Sousse', 'approved', '1993-06-12', 88887777, 'youssef.benahmed@test.com', 'Youssef', '2026-04-07', 0, 'Ben Ahmed', '$2y$04$EHgl6trB/j/Gc6vcoZtzFOXzqtr2Co1PWqhxzJKBx3f2sGZ6xKAF2', 98123456, 40000068, 1, 40000069),
('sfax', 'approved', '1999-02-02', 12345674, 'germtn14@gmail.com', 'efwef', '2026-04-08', 1, 'wefwef', '$2y$04$qgLtKsH7n9jCb770AS4aCe/vt0wDBqWRUwE5jGlwEnqu0r5vbc6am', 333333333, 40000069, 1, 40000070),
('afran', 'approved', '1996-04-09', 25873695, 'amira@mail.com', 'amira', '2026-04-09', 0, 'masmoudi', '$2y$04$ttYSit1HmySVDy9WM/LgHug7kAbWpk4st7WfdZk6kbJY3iAmst7ce', 99999925, 40000071, 3, 40000072),
('afran', 'pending', '1996-05-30', 11196007, 'kamel1@mail.com', 'kamel', '2026-05-30', 0, 'kammoun', '$2y$04$YAKeJwfIo95fcnitLes7d.8iKPVv2SgIXRdrVHZgnmgIzxqFJwjBu', 99146028, 40000072, 3, 40000073);

--
-- Triggers `Account`
--
DELIMITER $$
CREATE TRIGGER `before_account_insert_unique_email` BEFORE INSERT ON `Account` FOR EACH ROW BEGIN
    IF NEW.Email IS NOT NULL AND TRIM(NEW.Email) <> '' THEN
        IF EXISTS (
            SELECT 1
            FROM Account
            WHERE Email IS NOT NULL
              AND LOWER(TRIM(Email)) = LOWER(TRIM(NEW.Email))
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Duplicate email is not allowed in Account';
        END IF;

        SET NEW.Email = TRIM(NEW.Email);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_account_update_unique_email` BEFORE UPDATE ON `Account` FOR EACH ROW BEGIN
    IF NEW.Email IS NOT NULL AND TRIM(NEW.Email) <> '' THEN
        IF EXISTS (
            SELECT 1
            FROM Account
            WHERE AccountID <> NEW.AccountID
              AND Email IS NOT NULL
              AND LOWER(TRIM(Email)) = LOWER(TRIM(NEW.Email))
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Duplicate email is not allowed in Account';
        END IF;

        SET NEW.Email = TRIM(NEW.Email);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_account_cin_insert` BEFORE INSERT ON `Account` FOR EACH ROW BEGIN
    IF NEW.RoleID = 3 THEN
        IF LENGTH(CAST(NEW.Cin AS CHAR)) != 8 THEN
             SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Parent CIN must be exactly 8 digits.';
        END IF;
    ELSEIF NEW.RoleID = 1 THEN
        IF LENGTH(CAST(NEW.Cin AS CHAR)) < 6 THEN
             SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Teacher CIN must be at least 6 digits.';
        END IF;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_account_cin_update` BEFORE UPDATE ON `Account` FOR EACH ROW BEGIN
    IF NEW.RoleID = 3 THEN
        IF LENGTH(CAST(NEW.Cin AS CHAR)) != 8 THEN
             SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Parent CIN must be exactly 8 digits.';
        END IF;
    ELSEIF NEW.RoleID = 1 THEN
        IF LENGTH(CAST(NEW.Cin AS CHAR)) < 6 THEN
             SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Teacher CIN must be at least 6 digits.';
        END IF;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_account_validate_before_insert` BEFORE INSERT ON `Account` FOR EACH ROW BEGIN
    IF LENGTH(CAST(NEW.Cin AS CHAR)) != 8 OR NEW.Cin < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: CIN must be exactly 8 digits.';
    END IF;
    IF NEW.Email NOT REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Invalid email format.';
    END IF;
    IF TRIM(COALESCE(NEW.Firstname, '')) = '' OR TRIM(COALESCE(NEW.Lastname, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: First name and last name cannot be empty.';
    END IF;
    IF NEW.Birthdate IS NULL OR TIMESTAMPDIFF(YEAR, NEW.Birthdate, CURDATE()) < 18 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: User must be at least 18 years old.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_account_validate_before_update` BEFORE UPDATE ON `Account` FOR EACH ROW BEGIN
    IF LENGTH(CAST(NEW.Cin AS CHAR)) != 8 OR NEW.Cin < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: CIN must be exactly 8 digits.';
    END IF;
    IF NEW.Email NOT REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Invalid email format.';
    END IF;
    IF TRIM(COALESCE(NEW.Firstname, '')) = '' OR TRIM(COALESCE(NEW.Lastname, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: First name and last name cannot be empty.';
    END IF;
    IF NEW.Birthdate IS NULL OR TIMESTAMPDIFF(YEAR, NEW.Birthdate, CURDATE()) < 18 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: User must be at least 18 years old.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Activity`
--

CREATE TABLE `Activity` (
  `Description` varchar(50) DEFAULT NULL,
  `Title` varchar(50) DEFAULT NULL,
  `ActivityID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Activity`
--

INSERT INTO `Activity` (`Description`, `Title`, `ActivityID`) VALUES
('Tradition tunisienne : faire germer des graines da', 'Semer les Lentilles du Printemps', 40),
('Utiliser une lampe pour créer des silhouettes d\'an', 'Le Théâtre d\'Ombres', 41),
('Identifier des fruits ou aliments par le goût et l', 'Le Goûter à l\'Aveugle', 42),
('Jeu de rôle tunisien : acheter et vendre des légum', 'Le Petit Souk', 43),
('Expérimenter avec différents objets dans un bac à ', 'Flotte ou Coule ?', 44),
('S\'arrêter de bouger instantanément dès que la musi', 'La Danse des Statues', 45),
('Classer des boutons par taille, couleur ou nombre', 'Le Tri des Boutons', 46),
('Reconnaître et reproduire les sons de la nature et', 'L\'Imitateur de Cris', 47),
('Apprendre des postures simples (le chat, le chien,', 'Le Yoga des Petits Animaux', 48),
('Initiation artistique utilisant des motifs simples', 'Peinture au Doigt de Henné', 49),
('Un enfant dirige le volume sonore de la classe ave', 'Le Chef d\'Orchestre', 50);

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Child`
--

CREATE TABLE `Child` (
  `Birthdate` date DEFAULT NULL,
  `Firstname` varchar(50) DEFAULT NULL,
  `Lastname` varchar(50) DEFAULT NULL,
  `ChildID` int(11) NOT NULL,
  `ParentID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Child`
--

INSERT INTO `Child` (`Birthdate`, `Firstname`, `Lastname`, `ChildID`, `ParentID`) VALUES
('2023-04-06', 'youssef', 'kammoun', 138, 40000037),
('2023-04-06', 'marwen', 'kammmoun', 139, 40000038),
('2023-04-06', 'omar', 'kammoun', 182, 40000037),
('2023-04-07', 'ismail', 'kammoun', 183, 40000037),
('2022-04-15', 'Adam', 'Trabelsi', 185, 40000042),
('2022-03-14', 'Ranim', 'BenSalem', 186, 40000043),
('2021-11-02', 'Iyed', 'Gharbi', 187, 40000044),
('2022-01-19', 'Syrine', 'Zouari', 188, 40000045),
('2021-09-27', 'Eya', 'Mrad', 189, 40000046),
('2022-07-08', 'Mohamed', 'Brahmi', 190, 40000047),
('2022-02-25', 'Nour', 'Jaziri', 191, 40000048),
('2021-12-30', 'Youssef', 'Cherif', 192, 40000049),
('2022-06-11', 'Meriem', 'Saidi', 193, 40000050),
('2021-10-06', 'Anis', 'Tlili', 194, 40000051),
('2022-08-04', 'Leya', 'Hamdi', 195, 40000052),
('2021-04-12', 'Celia', 'Khelifi', 196, 40000053),
('2021-02-18', 'Rayen', 'BenAmor', 197, 40000054),
('2020-12-21', 'Malek', 'Sfar', 198, 40000055),
('2021-05-09', 'Lina', 'Dridi', 199, 40000056),
('2021-01-30', 'Salah', 'Miled', 200, 40000057),
('2021-03-11', 'Maya', 'Ghannouchi', 201, 40000058),
('2020-11-15', 'Aymen', 'Majri', 202, 40000059),
('2021-06-03', 'Jana', 'Boussetta', 203, 40000060),
('2021-07-17', 'Adam', 'Haddad', 204, 40000061),
('2021-08-26', 'Yara', 'Toumi', 205, 40000062),
('2022-09-12', 'Kenza', 'Abid', 206, 40000063),
('2022-10-05', 'Fares', 'Mokni', 207, 40000064),
('2022-11-16', 'Misk', 'Bouazizi', 208, 40000065),
('2022-12-01', 'Sami', 'BenHassen', 209, 40000066),
('2023-04-09', 'nour', 'kammoun', 211, 40000037),
('2023-04-09', 'amira', 'masmoudi', 213, 40000072),
('2023-05-30', 'marwen', 'kammoun', 214, 40000073);

--
-- Triggers `Child`
--
DELIMITER $$
CREATE TRIGGER `trg_child_age_insert` BEFORE INSERT ON `Child` FOR EACH ROW BEGIN
    DECLARE age_months INT;
    IF NEW.Birthdate IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Child must have a birthdate.';
    END IF;
    SET age_months = TIMESTAMPDIFF(MONTH, NEW.Birthdate, CURDATE());
    IF age_months < 24 OR age_months > 64 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Child age must be between 2 years and 5 years and 4 months.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_child_age_update` BEFORE UPDATE ON `Child` FOR EACH ROW BEGIN
    DECLARE age_months INT;
    IF NEW.Birthdate IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Child must have a birthdate.';
    END IF;
    SET age_months = TIMESTAMPDIFF(MONTH, NEW.Birthdate, CURDATE());
    IF age_months < 24 OR age_months > 64 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Child age must be between 2 years and 5 years and 4 months.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_child_validate_before_insert` BEFORE INSERT ON `Child` FOR EACH ROW BEGIN
    IF TRIM(COALESCE(NEW.Firstname, '')) = '' OR TRIM(COALESCE(NEW.Lastname, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Child first and last name cannot be empty.';
    END IF;
    IF NEW.Birthdate IS NULL OR NEW.Birthdate > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Child birthdate is invalid or in the future.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_child_validate_before_update` BEFORE UPDATE ON `Child` FOR EACH ROW BEGIN
    IF TRIM(COALESCE(NEW.Firstname, '')) = '' OR TRIM(COALESCE(NEW.Lastname, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Child first and last name cannot be empty.';
    END IF;
    IF NEW.Birthdate IS NULL OR NEW.Birthdate > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Child birthdate is invalid or in the future.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `ChildClass`
--

CREATE TABLE `ChildClass` (
  `ChildID` int(11) DEFAULT NULL,
  `ClassID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `ChildClass`
--

INSERT INTO `ChildClass` (`ChildID`, `ClassID`) VALUES
(182, 12),
(139, 12),
(138, 12),
(138, 19),
(183, 20),
(185, 19),
(186, 19),
(187, 19),
(188, 19),
(189, 19),
(190, 19),
(191, 19),
(192, 19),
(193, 19),
(194, 19),
(195, 19),
(203, 20),
(211, 20),
(213, 18),
(206, 18);

--
-- Triggers `ChildClass`
--
DELIMITER $$
CREATE TRIGGER `trg_childclass_match_type_insert` BEFORE INSERT ON `ChildClass` FOR EACH ROW BEGIN
    DECLARE v_class_type_id INT;
    DECLARE v_inscription_type_id INT;
    DECLARE active_inscriptions INT;

    -- Get the Class Type
    SELECT `ClasstypeID` INTO v_class_type_id FROM `Class` WHERE `ClassID` = NEW.ClassID;

    -- Get the active inscription type for the child via Payment link
    SELECT COUNT(*), MAX(i.`InscriptiontypeID`) INTO active_inscriptions, v_inscription_type_id
    FROM `Inscription` i
    JOIN `Payment` p ON i.InscriptionID = p.InscriptionID
    WHERE p.ChildID = NEW.ChildID 
      AND ( i.`Isarchived` = 0 OR i.`Isarchived` IS NULL ); 

    IF active_inscriptions = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Child does not have an active inscription to match class type.';
    END IF;

    IF v_class_type_id != v_inscription_type_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: The class type must match the child s inscription type.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_childclass_match_type_update` BEFORE UPDATE ON `ChildClass` FOR EACH ROW BEGIN
    DECLARE v_class_type_id INT;
    DECLARE v_inscription_type_id INT;
    DECLARE active_inscriptions INT;

    SELECT `ClasstypeID` INTO v_class_type_id FROM `Class` WHERE `ClassID` = NEW.ClassID;

    SELECT COUNT(*), MAX(i.`InscriptiontypeID`) INTO active_inscriptions, v_inscription_type_id
    FROM `Inscription` i
    JOIN `Payment` p ON i.InscriptionID = p.InscriptionID
    WHERE p.ChildID = NEW.ChildID 
      AND ( i.`Isarchived` = 0 OR i.`Isarchived` IS NULL ); 

    IF active_inscriptions = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Child does not have an active inscription to match class type.';
    END IF;

    IF v_class_type_id != v_inscription_type_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: The class type must match the child s inscription type.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_childclass_no_duplicate` BEFORE INSERT ON `ChildClass` FOR EACH ROW BEGIN
    DECLARE is_duplicate INT;
    SELECT COUNT(*) INTO is_duplicate FROM `ChildClass` 
    WHERE `ClassID` = NEW.ClassID AND `ChildID` = NEW.ChildID;
    
    IF is_duplicate > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Child is already enrolled in this exact class.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Childfoodexception`
--

CREATE TABLE `Childfoodexception` (
  `Reason` varchar(1000) DEFAULT NULL,
  `ChildfoodexceptionID` int(11) NOT NULL,
  `ChildID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Childfoodexception`
--

INSERT INTO `Childfoodexception` (`Reason`, `ChildfoodexceptionID`, `ChildID`) VALUES
('Le Couscous au lait (Mesfouf) typically contains sugar as it is often prepared as a sweet dish.', 128, 138),
('Le Bambalouni is a fried doughnut that contains sugar.', 129, 138),
('La Tartine de Chamia consists of bread with Chamia (halva) which is high in sugar.', 130, 138),
('Le Cake Maison usually contains sugar in the recipe.', 131, 138),
('sugar', 134, 138),
('Probable teneur élevée en sucres du lait et des céréales, non adaptée au diabète.', 136, 211),
('Contient du sucre, ce qui est interdit en raison du diabète.', 179, 213),
('Contient du sucre, ce qui est interdit en raison du diabète.', 180, 213),
('Contient probablement du sucre, ce qui est interdit en raison du diabète.', 181, 213),
('Contient probablement du sucre, ce qui est interdit en raison du diabète.', 182, 213),
('Contient probablement du sucre, ce qui est interdit en raison du diabète.', 183, 213);

-- --------------------------------------------------------

--
-- Table structure for table `ChildFoodExceptionMeals`
--

CREATE TABLE `ChildFoodExceptionMeals` (
  `ChildfoodexceptionID` int(11) DEFAULT NULL,
  `MealsID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `ChildFoodExceptionMeals`
--

INSERT INTO `ChildFoodExceptionMeals` (`ChildfoodexceptionID`, `MealsID`) VALUES
(128, 15),
(129, 19),
(130, 20),
(131, 21),
(134, 23),
(136, 15),
(179, 19),
(180, 20),
(181, 21),
(182, 22),
(183, 23);

-- --------------------------------------------------------

--
-- Table structure for table `Childfoodexceptionoverride`
--

CREATE TABLE `Childfoodexceptionoverride` (
  `Dayindex` int(11) DEFAULT NULL,
  `Weekstartdate` date DEFAULT NULL,
  `ChildfoodexceptionoverrideID` int(11) NOT NULL,
  `replacement_meal` int(11) DEFAULT NULL,
  `ChildID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Childfoodexceptionoverride`
--

INSERT INTO `Childfoodexceptionoverride` (`Dayindex`, `Weekstartdate`, `ChildfoodexceptionoverrideID`, `replacement_meal`, `ChildID`) VALUES
(1, '2025-06-30', 8260, 26, 138),
(2, '2025-06-30', 8261, 24, 138),
(2, '2025-06-30', 8264, 26, 138),
(1, '2025-06-23', 8265, 26, NULL),
(2, '2025-06-23', 8266, 24, NULL),
(2, '2025-06-23', 8267, 26, NULL),
(1, '2025-06-23', 8268, 26, 138),
(2, '2025-06-23', 8269, 24, 138),
(2, '2025-06-23', 8270, NULL, 138),
(1, '2025-06-16', 8271, 26, NULL),
(2, '2025-06-16', 8272, 24, NULL),
(2, '2025-06-16', 8273, 26, NULL),
(1, '2025-06-16', 8274, 26, NULL),
(2, '2025-06-16', 8275, 24, NULL),
(2, '2025-06-16', 8276, 26, NULL),
(1, '2025-06-16', 8277, 26, NULL),
(2, '2025-06-16', 8278, 24, NULL),
(2, '2025-06-16', 8279, NULL, NULL),
(1, '2026-04-06', 8280, 26, NULL),
(2, '2026-04-06', 8281, 24, NULL),
(2, '2026-04-06', 8282, 26, NULL),
(1, '2026-04-06', 8283, 26, NULL),
(2, '2026-04-06', 8284, 24, NULL),
(2, '2026-04-06', 8285, 26, NULL),
(1, '2026-04-06', 8286, 26, NULL),
(2, '2026-04-06', 8287, 24, NULL),
(2, '2026-04-06', 8288, NULL, NULL),
(1, '2026-04-06', 8289, 26, NULL),
(2, '2026-04-06', 8290, 24, NULL),
(2, '2026-04-06', 8291, 26, NULL),
(1, '2026-04-06', 8292, 26, NULL),
(2, '2026-04-06', 8293, 24, NULL),
(2, '2026-04-06', 8294, 26, NULL),
(1, '2026-04-06', 8295, 26, NULL),
(2, '2026-04-06', 8296, 24, NULL),
(2, '2026-04-06', 8297, NULL, NULL),
(1, '2026-04-06', 8298, 26, 138),
(2, '2026-04-06', 8299, 24, 138),
(2, '2026-04-06', 8300, 26, 138),
(3, '2025-06-30', 8301, 25, 138),
(1, '2026-04-13', 8302, 26, NULL),
(2, '2026-04-13', 8303, 24, NULL),
(2, '2026-04-13', 8304, 26, NULL),
(1, '2026-04-13', 8305, 26, NULL),
(2, '2026-04-13', 8306, 24, NULL),
(2, '2026-04-13', 8307, 26, NULL),
(1, '2026-04-13', 8308, 26, NULL),
(2, '2026-04-13', 8309, 24, NULL),
(2, '2026-04-13', 8310, NULL, NULL),
(1, '2026-04-13', 8311, 26, NULL),
(2, '2026-04-13', 8312, 24, NULL),
(2, '2026-04-13', 8313, 26, NULL),
(1, '2026-04-13', 8314, 26, NULL),
(2, '2026-04-13', 8315, 24, NULL),
(2, '2026-04-13', 8316, 26, NULL),
(1, '2026-04-13', 8317, 26, NULL),
(2, '2026-04-13', 8318, 24, NULL),
(2, '2026-04-13', 8319, NULL, NULL),
(1, '2026-04-13', 8320, 26, NULL),
(2, '2026-04-13', 8321, 24, NULL),
(2, '2026-04-13', 8322, 26, NULL),
(1, '2026-04-13', 8323, 26, NULL),
(2, '2026-04-13', 8324, 24, NULL),
(2, '2026-04-13', 8325, 26, NULL),
(1, '2026-04-13', 8326, 26, NULL),
(2, '2026-04-13', 8327, 24, NULL),
(2, '2026-04-13', 8328, NULL, NULL),
(1, '2026-04-13', 8329, 26, NULL),
(2, '2026-04-13', 8330, 24, NULL),
(2, '2026-04-13', 8331, 26, NULL),
(1, '2026-04-13', 8332, 26, NULL),
(2, '2026-04-13', 8333, 24, NULL),
(2, '2026-04-13', 8334, 26, NULL),
(1, '2026-04-13', 8335, 26, NULL),
(2, '2026-04-13', 8336, 24, NULL),
(2, '2026-04-13', 8337, NULL, NULL),
(1, '2026-04-13', 8338, 26, NULL),
(2, '2026-04-13', 8339, 24, NULL),
(2, '2026-04-13', 8340, 26, NULL),
(3, '2026-04-13', 8341, 25, NULL),
(1, '2026-04-13', 8342, 26, 138),
(1, '2026-05-25', 8343, 26, NULL),
(2, '2026-05-25', 8344, 24, NULL),
(2, '2026-05-25', 8345, 26, NULL),
(1, '2026-05-25', 8346, 26, NULL),
(2, '2026-05-25', 8347, 24, NULL),
(2, '2026-05-25', 8348, 26, NULL),
(1, '2026-05-25', 8349, 26, NULL),
(2, '2026-05-25', 8350, 24, NULL),
(2, '2026-05-25', 8351, NULL, NULL),
(1, '2026-05-25', 8352, 26, NULL),
(2, '2026-05-25', 8353, 24, NULL),
(2, '2026-05-25', 8354, 26, NULL),
(1, '2026-05-25', 8355, 26, NULL),
(2, '2026-05-25', 8356, 24, NULL),
(2, '2026-05-25', 8357, 26, NULL),
(1, '2026-05-25', 8358, 26, NULL),
(2, '2026-05-25', 8359, 24, NULL),
(2, '2026-05-25', 8360, NULL, NULL),
(1, '2026-05-25', 8361, 26, NULL),
(2, '2026-05-25', 8362, 24, NULL),
(2, '2026-05-25', 8363, 26, NULL),
(1, '2026-05-25', 8364, 26, NULL),
(2, '2026-05-25', 8365, 24, NULL),
(2, '2026-05-25', 8366, 26, NULL),
(1, '2026-05-25', 8367, 26, NULL),
(2, '2026-05-25', 8368, 24, NULL),
(2, '2026-05-25', 8369, NULL, NULL),
(1, '2026-05-25', 8370, 26, NULL),
(2, '2026-05-25', 8371, 24, NULL),
(2, '2026-05-25', 8372, 26, NULL),
(1, '2026-05-25', 8373, 26, NULL),
(2, '2026-05-25', 8374, 24, NULL),
(2, '2026-05-25', 8375, 26, NULL),
(1, '2026-05-25', 8376, 26, NULL),
(2, '2026-05-25', 8377, 24, NULL),
(2, '2026-05-25', 8378, NULL, NULL),
(1, '2026-05-25', 8379, 26, NULL),
(2, '2026-05-25', 8380, 24, NULL),
(2, '2026-05-25', 8381, 26, NULL),
(3, '2026-05-25', 8382, 25, NULL),
(1, '2026-05-25', 8383, 26, NULL),
(2, '2026-05-25', 8384, 24, NULL),
(2, '2026-05-25', 8385, 26, NULL),
(1, '2026-05-25', 8386, 26, NULL),
(2, '2026-05-25', 8387, 24, NULL),
(2, '2026-05-25', 8388, 26, NULL),
(1, '2026-05-25', 8389, 26, NULL),
(2, '2026-05-25', 8390, 24, NULL),
(2, '2026-05-25', 8391, NULL, NULL),
(1, '2026-05-25', 8392, 26, NULL),
(2, '2026-05-25', 8393, 24, NULL),
(2, '2026-05-25', 8394, 26, NULL),
(1, '2026-05-25', 8395, 26, NULL),
(2, '2026-05-25', 8396, 24, NULL),
(2, '2026-05-25', 8397, 26, NULL),
(1, '2026-05-25', 8398, 26, NULL),
(2, '2026-05-25', 8399, 24, NULL),
(2, '2026-05-25', 8400, NULL, NULL),
(1, '2026-05-25', 8401, 26, NULL),
(2, '2026-05-25', 8402, 24, NULL),
(2, '2026-05-25', 8403, 26, NULL),
(1, '2026-05-25', 8404, 26, NULL),
(2, '2026-05-25', 8405, 24, NULL),
(2, '2026-05-25', 8406, 26, NULL),
(1, '2026-05-25', 8407, 26, NULL),
(2, '2026-05-25', 8408, 24, NULL),
(2, '2026-05-25', 8409, NULL, NULL),
(1, '2026-05-25', 8410, 26, NULL),
(2, '2026-05-25', 8411, 24, NULL),
(2, '2026-05-25', 8412, 26, NULL),
(1, '2026-05-25', 8413, 26, NULL),
(2, '2026-05-25', 8414, 24, NULL),
(2, '2026-05-25', 8415, 26, NULL),
(1, '2026-05-25', 8416, 26, NULL),
(2, '2026-05-25', 8417, 24, NULL),
(2, '2026-05-25', 8418, NULL, NULL),
(1, '2026-05-25', 8419, 26, NULL),
(2, '2026-05-25', 8420, 24, NULL),
(2, '2026-05-25', 8421, 26, NULL),
(3, '2026-05-25', 8422, 25, NULL),
(1, '2026-05-25', 8423, 26, NULL),
(1, '2026-06-01', 8424, 26, NULL),
(2, '2026-06-01', 8425, 24, NULL),
(2, '2026-06-01', 8426, 26, NULL),
(1, '2026-06-01', 8427, 26, NULL),
(2, '2026-06-01', 8428, 24, NULL),
(2, '2026-06-01', 8429, 26, NULL),
(1, '2026-06-01', 8430, 26, NULL),
(2, '2026-06-01', 8431, 24, NULL),
(2, '2026-06-01', 8432, NULL, NULL),
(1, '2026-06-01', 8433, 26, NULL),
(2, '2026-06-01', 8434, 24, NULL),
(2, '2026-06-01', 8435, 26, NULL),
(1, '2026-06-01', 8436, 26, NULL),
(2, '2026-06-01', 8437, 24, NULL),
(2, '2026-06-01', 8438, 26, NULL),
(1, '2026-06-01', 8439, 26, NULL),
(2, '2026-06-01', 8440, 24, NULL),
(2, '2026-06-01', 8441, NULL, NULL),
(1, '2026-06-01', 8442, 26, NULL),
(2, '2026-06-01', 8443, 24, NULL),
(2, '2026-06-01', 8444, 26, NULL),
(1, '2026-06-01', 8445, 26, NULL),
(2, '2026-06-01', 8446, 24, NULL),
(2, '2026-06-01', 8447, 26, NULL),
(1, '2026-06-01', 8448, 26, NULL),
(2, '2026-06-01', 8449, 24, NULL),
(2, '2026-06-01', 8450, NULL, NULL),
(1, '2026-06-01', 8451, 26, NULL),
(2, '2026-06-01', 8452, 24, NULL),
(2, '2026-06-01', 8453, 26, NULL),
(1, '2026-06-01', 8454, 26, NULL),
(2, '2026-06-01', 8455, 24, NULL),
(2, '2026-06-01', 8456, 26, NULL),
(1, '2026-06-01', 8457, 26, NULL),
(2, '2026-06-01', 8458, 24, NULL),
(2, '2026-06-01', 8459, NULL, NULL),
(1, '2026-06-01', 8460, 26, NULL),
(2, '2026-06-01', 8461, 24, NULL),
(2, '2026-06-01', 8462, 26, NULL),
(3, '2026-06-01', 8463, 25, NULL),
(1, '2026-06-01', 8464, 26, NULL),
(2, '2026-06-01', 8465, 24, NULL),
(2, '2026-06-01', 8466, 26, NULL),
(1, '2026-06-01', 8467, 26, NULL),
(2, '2026-06-01', 8468, 24, NULL),
(2, '2026-06-01', 8469, 26, NULL),
(1, '2026-06-01', 8470, 26, NULL),
(2, '2026-06-01', 8471, 24, NULL),
(2, '2026-06-01', 8472, NULL, NULL),
(1, '2026-06-01', 8473, 26, NULL),
(2, '2026-06-01', 8474, 24, NULL),
(2, '2026-06-01', 8475, 26, NULL),
(1, '2026-06-01', 8476, 26, NULL),
(2, '2026-06-01', 8477, 24, NULL),
(2, '2026-06-01', 8478, 26, NULL),
(1, '2026-06-01', 8479, 26, NULL),
(2, '2026-06-01', 8480, 24, NULL),
(2, '2026-06-01', 8481, NULL, NULL),
(1, '2026-06-01', 8482, 26, NULL),
(2, '2026-06-01', 8483, 24, NULL),
(2, '2026-06-01', 8484, 26, NULL),
(1, '2026-06-01', 8485, 26, NULL),
(2, '2026-06-01', 8486, 24, NULL),
(2, '2026-06-01', 8487, 26, NULL),
(1, '2026-06-01', 8488, 26, NULL),
(2, '2026-06-01', 8489, 24, NULL),
(2, '2026-06-01', 8490, NULL, NULL),
(1, '2026-06-01', 8491, 26, NULL),
(2, '2026-06-01', 8492, 24, NULL),
(2, '2026-06-01', 8493, 26, NULL),
(1, '2026-06-01', 8494, 26, NULL),
(2, '2026-06-01', 8495, 24, NULL),
(2, '2026-06-01', 8496, 26, NULL),
(1, '2026-06-01', 8497, 26, NULL),
(2, '2026-06-01', 8498, 24, NULL),
(2, '2026-06-01', 8499, NULL, NULL),
(1, '2026-06-01', 8500, 26, NULL),
(2, '2026-06-01', 8501, 24, NULL),
(2, '2026-06-01', 8502, 26, NULL),
(3, '2026-06-01', 8503, 25, NULL),
(1, '2026-06-01', 8504, 26, NULL),
(1, '2026-06-01', 8505, 26, NULL),
(2, '2026-06-01', 8506, 24, NULL),
(2, '2026-06-01', 8507, 26, NULL),
(1, '2026-06-01', 8508, 26, NULL),
(2, '2026-06-01', 8509, 24, NULL),
(2, '2026-06-01', 8510, 26, NULL),
(1, '2026-06-01', 8511, 26, NULL),
(2, '2026-06-01', 8512, 24, NULL),
(2, '2026-06-01', 8513, NULL, NULL),
(1, '2026-06-01', 8514, 26, NULL),
(2, '2026-06-01', 8515, 24, NULL),
(2, '2026-06-01', 8516, 26, NULL),
(1, '2026-06-01', 8517, 26, NULL),
(2, '2026-06-01', 8518, 24, NULL),
(2, '2026-06-01', 8519, 26, NULL),
(1, '2026-06-01', 8520, 26, NULL),
(2, '2026-06-01', 8521, 24, NULL),
(2, '2026-06-01', 8522, NULL, NULL),
(1, '2026-06-01', 8523, 26, NULL),
(2, '2026-06-01', 8524, 24, NULL),
(2, '2026-06-01', 8525, 26, NULL),
(1, '2026-06-01', 8526, 26, NULL),
(2, '2026-06-01', 8527, 24, NULL),
(2, '2026-06-01', 8528, 26, NULL),
(1, '2026-06-01', 8529, 26, NULL),
(2, '2026-06-01', 8530, 24, NULL),
(2, '2026-06-01', 8531, NULL, NULL),
(1, '2026-06-01', 8532, 26, NULL),
(2, '2026-06-01', 8533, 24, NULL),
(2, '2026-06-01', 8534, 26, NULL),
(1, '2026-06-01', 8535, 26, NULL),
(2, '2026-06-01', 8536, 24, NULL),
(2, '2026-06-01', 8537, 26, NULL),
(1, '2026-06-01', 8538, 26, NULL),
(2, '2026-06-01', 8539, 24, NULL),
(2, '2026-06-01', 8540, NULL, NULL),
(1, '2026-06-01', 8541, 26, NULL),
(2, '2026-06-01', 8542, 24, NULL),
(2, '2026-06-01', 8543, 26, NULL),
(3, '2026-06-01', 8544, 25, NULL),
(1, '2026-06-01', 8545, 26, NULL),
(2, '2026-06-01', 8546, 24, NULL),
(2, '2026-06-01', 8547, 26, NULL),
(1, '2026-06-01', 8548, 26, NULL),
(2, '2026-06-01', 8549, 24, NULL),
(2, '2026-06-01', 8550, 26, NULL),
(1, '2026-06-01', 8551, 26, NULL),
(2, '2026-06-01', 8552, 24, NULL),
(2, '2026-06-01', 8553, NULL, NULL),
(1, '2026-06-01', 8554, 26, NULL),
(2, '2026-06-01', 8555, 24, NULL),
(2, '2026-06-01', 8556, 26, NULL),
(1, '2026-06-01', 8557, 26, NULL),
(2, '2026-06-01', 8558, 24, NULL),
(2, '2026-06-01', 8559, 26, NULL),
(1, '2026-06-01', 8560, 26, NULL),
(2, '2026-06-01', 8561, 24, NULL),
(2, '2026-06-01', 8562, NULL, NULL),
(1, '2026-06-01', 8563, 26, NULL),
(2, '2026-06-01', 8564, 24, NULL),
(2, '2026-06-01', 8565, 26, NULL),
(1, '2026-06-01', 8566, 26, NULL),
(2, '2026-06-01', 8567, 24, NULL),
(2, '2026-06-01', 8568, 26, NULL),
(1, '2026-06-01', 8569, 26, NULL),
(2, '2026-06-01', 8570, 24, NULL),
(2, '2026-06-01', 8571, NULL, NULL),
(1, '2026-06-01', 8572, 26, NULL),
(2, '2026-06-01', 8573, 24, NULL),
(2, '2026-06-01', 8574, 26, NULL),
(1, '2026-06-01', 8575, 26, NULL),
(2, '2026-06-01', 8576, 24, NULL),
(2, '2026-06-01', 8577, 26, NULL),
(1, '2026-06-01', 8578, 26, NULL),
(2, '2026-06-01', 8579, 24, NULL),
(2, '2026-06-01', 8580, NULL, NULL),
(1, '2026-06-01', 8581, 26, NULL),
(2, '2026-06-01', 8582, 24, NULL),
(2, '2026-06-01', 8583, 26, NULL),
(3, '2026-06-01', 8584, 25, NULL),
(1, '2026-06-01', 8585, 26, NULL),
(1, '2026-06-08', 8586, 26, NULL),
(2, '2026-06-08', 8587, 24, NULL),
(2, '2026-06-08', 8588, 26, NULL),
(1, '2026-06-08', 8589, 26, NULL),
(2, '2026-06-08', 8590, 24, NULL),
(2, '2026-06-08', 8591, 26, NULL),
(1, '2026-06-08', 8592, 26, NULL),
(2, '2026-06-08', 8593, 24, NULL),
(2, '2026-06-08', 8594, NULL, NULL),
(1, '2026-06-08', 8595, 26, NULL),
(2, '2026-06-08', 8596, 24, NULL),
(2, '2026-06-08', 8597, 26, NULL),
(1, '2026-06-08', 8598, 26, NULL),
(2, '2026-06-08', 8599, 24, NULL),
(2, '2026-06-08', 8600, 26, NULL),
(1, '2026-06-08', 8601, 26, NULL),
(2, '2026-06-08', 8602, 24, NULL),
(2, '2026-06-08', 8603, NULL, NULL),
(1, '2026-06-08', 8604, 26, NULL),
(2, '2026-06-08', 8605, 24, NULL),
(2, '2026-06-08', 8606, 26, NULL),
(1, '2026-06-08', 8607, 26, NULL),
(2, '2026-06-08', 8608, 24, NULL),
(2, '2026-06-08', 8609, 26, NULL),
(1, '2026-06-08', 8610, 26, NULL),
(2, '2026-06-08', 8611, 24, NULL),
(2, '2026-06-08', 8612, NULL, NULL),
(1, '2026-06-08', 8613, 26, NULL),
(2, '2026-06-08', 8614, 24, NULL),
(2, '2026-06-08', 8615, 26, NULL),
(1, '2026-06-08', 8616, 26, NULL),
(2, '2026-06-08', 8617, 24, NULL),
(2, '2026-06-08', 8618, 26, NULL),
(1, '2026-06-08', 8619, 26, NULL),
(2, '2026-06-08', 8620, 24, NULL),
(2, '2026-06-08', 8621, NULL, NULL),
(1, '2026-06-08', 8622, 26, NULL),
(2, '2026-06-08', 8623, 24, NULL),
(2, '2026-06-08', 8624, 26, NULL),
(3, '2026-06-08', 8625, 25, NULL),
(1, '2026-06-08', 8626, 26, NULL),
(2, '2026-06-08', 8627, 24, NULL),
(2, '2026-06-08', 8628, 26, NULL),
(1, '2026-06-08', 8629, 26, NULL),
(2, '2026-06-08', 8630, 24, NULL),
(2, '2026-06-08', 8631, 26, NULL),
(1, '2026-06-08', 8632, 26, NULL),
(2, '2026-06-08', 8633, 24, NULL),
(2, '2026-06-08', 8634, NULL, NULL),
(1, '2026-06-08', 8635, 26, NULL),
(2, '2026-06-08', 8636, 24, NULL),
(2, '2026-06-08', 8637, 26, NULL),
(1, '2026-06-08', 8638, 26, NULL),
(2, '2026-06-08', 8639, 24, NULL),
(2, '2026-06-08', 8640, 26, NULL),
(1, '2026-06-08', 8641, 26, NULL),
(2, '2026-06-08', 8642, 24, NULL),
(2, '2026-06-08', 8643, NULL, NULL),
(1, '2026-06-08', 8644, 26, NULL),
(2, '2026-06-08', 8645, 24, NULL),
(2, '2026-06-08', 8646, 26, NULL),
(1, '2026-06-08', 8647, 26, NULL),
(2, '2026-06-08', 8648, 24, NULL),
(2, '2026-06-08', 8649, 26, NULL),
(1, '2026-06-08', 8650, 26, NULL),
(2, '2026-06-08', 8651, 24, NULL),
(2, '2026-06-08', 8652, NULL, NULL),
(1, '2026-06-08', 8653, 26, NULL),
(2, '2026-06-08', 8654, 24, NULL),
(2, '2026-06-08', 8655, 26, NULL),
(1, '2026-06-08', 8656, 26, NULL),
(2, '2026-06-08', 8657, 24, NULL),
(2, '2026-06-08', 8658, 26, NULL),
(1, '2026-06-08', 8659, 26, NULL),
(2, '2026-06-08', 8660, 24, NULL),
(2, '2026-06-08', 8661, NULL, NULL),
(1, '2026-06-08', 8662, 26, NULL),
(2, '2026-06-08', 8663, 24, NULL),
(2, '2026-06-08', 8664, 26, NULL),
(3, '2026-06-08', 8665, 25, NULL),
(1, '2026-06-08', 8666, 26, NULL),
(1, '2026-06-08', 8667, 26, NULL),
(2, '2026-06-08', 8668, 24, NULL),
(2, '2026-06-08', 8669, 26, NULL),
(1, '2026-06-08', 8670, 26, NULL),
(2, '2026-06-08', 8671, 24, NULL),
(2, '2026-06-08', 8672, 26, NULL),
(1, '2026-06-08', 8673, 26, NULL),
(2, '2026-06-08', 8674, 24, NULL),
(2, '2026-06-08', 8675, NULL, NULL),
(1, '2026-06-08', 8676, 26, NULL),
(2, '2026-06-08', 8677, 24, NULL),
(2, '2026-06-08', 8678, 26, NULL),
(1, '2026-06-08', 8679, 26, NULL),
(2, '2026-06-08', 8680, 24, NULL),
(2, '2026-06-08', 8681, 26, NULL),
(1, '2026-06-08', 8682, 26, NULL),
(2, '2026-06-08', 8683, 24, NULL),
(2, '2026-06-08', 8684, NULL, NULL),
(1, '2026-06-08', 8685, 26, NULL),
(2, '2026-06-08', 8686, 24, NULL),
(2, '2026-06-08', 8687, 26, NULL),
(1, '2026-06-08', 8688, 26, NULL),
(2, '2026-06-08', 8689, 24, NULL),
(2, '2026-06-08', 8690, 26, NULL),
(1, '2026-06-08', 8691, 26, NULL),
(2, '2026-06-08', 8692, 24, NULL),
(2, '2026-06-08', 8693, NULL, NULL),
(1, '2026-06-08', 8694, 26, NULL),
(2, '2026-06-08', 8695, 24, NULL),
(2, '2026-06-08', 8696, 26, NULL),
(1, '2026-06-08', 8697, 26, NULL),
(2, '2026-06-08', 8698, 24, NULL),
(2, '2026-06-08', 8699, 26, NULL),
(1, '2026-06-08', 8700, 26, NULL),
(2, '2026-06-08', 8701, 24, NULL),
(2, '2026-06-08', 8702, NULL, NULL),
(1, '2026-06-08', 8703, 26, NULL),
(2, '2026-06-08', 8704, 24, NULL),
(2, '2026-06-08', 8705, 26, NULL),
(3, '2026-06-08', 8706, 25, NULL),
(1, '2026-06-08', 8707, 26, NULL),
(2, '2026-06-08', 8708, 24, NULL),
(2, '2026-06-08', 8709, 26, NULL),
(1, '2026-06-08', 8710, 26, NULL),
(2, '2026-06-08', 8711, 24, NULL),
(2, '2026-06-08', 8712, 26, NULL),
(1, '2026-06-08', 8713, 26, NULL),
(2, '2026-06-08', 8714, 24, NULL),
(2, '2026-06-08', 8715, NULL, NULL),
(1, '2026-06-08', 8716, 26, NULL),
(2, '2026-06-08', 8717, 24, NULL),
(2, '2026-06-08', 8718, 26, NULL),
(1, '2026-06-08', 8719, 26, NULL),
(2, '2026-06-08', 8720, 24, NULL),
(2, '2026-06-08', 8721, 26, NULL),
(1, '2026-06-08', 8722, 26, NULL),
(2, '2026-06-08', 8723, 24, NULL),
(2, '2026-06-08', 8724, NULL, NULL),
(1, '2026-06-08', 8725, 26, NULL),
(2, '2026-06-08', 8726, 24, NULL),
(2, '2026-06-08', 8727, 26, NULL),
(1, '2026-06-08', 8728, 26, NULL),
(2, '2026-06-08', 8729, 24, NULL),
(2, '2026-06-08', 8730, 26, NULL),
(1, '2026-06-08', 8731, 26, NULL),
(2, '2026-06-08', 8732, 24, NULL),
(2, '2026-06-08', 8733, NULL, NULL),
(1, '2026-06-08', 8734, 26, NULL),
(2, '2026-06-08', 8735, 24, NULL),
(2, '2026-06-08', 8736, 26, NULL),
(1, '2026-06-08', 8737, 26, NULL),
(2, '2026-06-08', 8738, 24, NULL),
(2, '2026-06-08', 8739, 26, NULL),
(1, '2026-06-08', 8740, 26, NULL),
(2, '2026-06-08', 8741, 24, NULL),
(2, '2026-06-08', 8742, NULL, NULL),
(1, '2026-06-08', 8743, 26, NULL),
(2, '2026-06-08', 8744, 24, NULL),
(2, '2026-06-08', 8745, 26, NULL),
(3, '2026-06-08', 8746, 25, NULL),
(1, '2026-06-08', 8747, 26, NULL),
(1, '2026-06-08', 8748, 26, NULL),
(2, '2026-06-08', 8749, 24, NULL),
(2, '2026-06-08', 8750, 26, NULL),
(1, '2026-06-08', 8751, 26, NULL),
(2, '2026-06-08', 8752, 24, NULL),
(2, '2026-06-08', 8753, 26, NULL),
(1, '2026-06-08', 8754, 26, NULL),
(2, '2026-06-08', 8755, 24, NULL),
(2, '2026-06-08', 8756, NULL, NULL),
(1, '2026-06-08', 8757, 26, NULL),
(2, '2026-06-08', 8758, 24, NULL),
(2, '2026-06-08', 8759, 26, NULL),
(1, '2026-06-08', 8760, 26, NULL),
(2, '2026-06-08', 8761, 24, NULL),
(2, '2026-06-08', 8762, 26, NULL),
(1, '2026-06-08', 8763, 26, NULL),
(2, '2026-06-08', 8764, 24, NULL),
(2, '2026-06-08', 8765, NULL, NULL),
(1, '2026-06-08', 8766, 26, NULL),
(2, '2026-06-08', 8767, 24, NULL),
(2, '2026-06-08', 8768, 26, NULL),
(1, '2026-06-08', 8769, 26, NULL),
(2, '2026-06-08', 8770, 24, NULL),
(2, '2026-06-08', 8771, 26, NULL),
(1, '2026-06-08', 8772, 26, NULL),
(2, '2026-06-08', 8773, 24, NULL),
(2, '2026-06-08', 8774, NULL, NULL),
(1, '2026-06-08', 8775, 26, NULL),
(2, '2026-06-08', 8776, 24, NULL),
(2, '2026-06-08', 8777, 26, NULL),
(1, '2026-06-08', 8778, 26, NULL),
(2, '2026-06-08', 8779, 24, NULL),
(2, '2026-06-08', 8780, 26, NULL),
(1, '2026-06-08', 8781, 26, NULL),
(2, '2026-06-08', 8782, 24, NULL),
(2, '2026-06-08', 8783, NULL, NULL),
(1, '2026-06-08', 8784, 26, NULL),
(2, '2026-06-08', 8785, 24, NULL),
(2, '2026-06-08', 8786, 26, NULL),
(3, '2026-06-08', 8787, 25, NULL),
(1, '2026-06-08', 8788, 26, NULL),
(2, '2026-06-08', 8789, 24, NULL),
(2, '2026-06-08', 8790, 26, NULL),
(1, '2026-06-08', 8791, 26, NULL),
(2, '2026-06-08', 8792, 24, NULL),
(2, '2026-06-08', 8793, 26, NULL),
(1, '2026-06-08', 8794, 26, NULL),
(2, '2026-06-08', 8795, 24, NULL),
(2, '2026-06-08', 8796, NULL, NULL),
(1, '2026-06-08', 8797, 26, NULL),
(2, '2026-06-08', 8798, 24, NULL),
(2, '2026-06-08', 8799, 26, NULL),
(1, '2026-06-08', 8800, 26, NULL),
(2, '2026-06-08', 8801, 24, NULL),
(2, '2026-06-08', 8802, 26, NULL),
(1, '2026-06-08', 8803, 26, NULL),
(2, '2026-06-08', 8804, 24, NULL),
(2, '2026-06-08', 8805, NULL, NULL),
(1, '2026-06-08', 8806, 26, NULL),
(2, '2026-06-08', 8807, 24, NULL),
(2, '2026-06-08', 8808, 26, NULL),
(1, '2026-06-08', 8809, 26, NULL),
(2, '2026-06-08', 8810, 24, NULL),
(2, '2026-06-08', 8811, 26, NULL),
(1, '2026-06-08', 8812, 26, NULL),
(2, '2026-06-08', 8813, 24, NULL),
(2, '2026-06-08', 8814, NULL, NULL),
(1, '2026-06-08', 8815, 26, NULL),
(2, '2026-06-08', 8816, 24, NULL),
(2, '2026-06-08', 8817, 26, NULL),
(1, '2026-06-08', 8818, 26, NULL),
(2, '2026-06-08', 8819, 24, NULL),
(2, '2026-06-08', 8820, 26, NULL),
(1, '2026-06-08', 8821, 26, NULL),
(2, '2026-06-08', 8822, 24, NULL),
(2, '2026-06-08', 8823, NULL, NULL),
(1, '2026-06-08', 8824, 26, NULL),
(2, '2026-06-08', 8825, 24, NULL),
(2, '2026-06-08', 8826, 26, NULL),
(3, '2026-06-08', 8827, 25, NULL),
(1, '2026-06-08', 8828, 26, NULL),
(1, '2026-06-08', 8829, 26, NULL),
(2, '2026-06-08', 8830, 24, NULL),
(2, '2026-06-08', 8831, 26, NULL),
(1, '2026-06-08', 8832, 26, NULL),
(2, '2026-06-08', 8833, 24, NULL),
(2, '2026-06-08', 8834, 26, NULL),
(1, '2026-06-08', 8835, 26, NULL),
(2, '2026-06-08', 8836, 24, NULL),
(2, '2026-06-08', 8837, NULL, NULL),
(1, '2026-06-08', 8838, 26, NULL),
(2, '2026-06-08', 8839, 24, NULL),
(2, '2026-06-08', 8840, 26, NULL),
(1, '2026-06-08', 8841, 26, NULL),
(2, '2026-06-08', 8842, 24, NULL),
(2, '2026-06-08', 8843, 26, NULL),
(1, '2026-06-08', 8844, 26, NULL),
(2, '2026-06-08', 8845, 24, NULL),
(2, '2026-06-08', 8846, NULL, NULL),
(1, '2026-06-08', 8847, 26, NULL),
(2, '2026-06-08', 8848, 24, NULL),
(2, '2026-06-08', 8849, 26, NULL),
(1, '2026-06-08', 8850, 26, NULL),
(2, '2026-06-08', 8851, 24, NULL),
(2, '2026-06-08', 8852, 26, NULL),
(1, '2026-06-08', 8853, 26, NULL),
(2, '2026-06-08', 8854, 24, NULL),
(2, '2026-06-08', 8855, NULL, NULL),
(1, '2026-06-08', 8856, 26, NULL),
(2, '2026-06-08', 8857, 24, NULL),
(2, '2026-06-08', 8858, 26, NULL),
(1, '2026-06-08', 8859, 26, NULL),
(2, '2026-06-08', 8860, 24, NULL),
(2, '2026-06-08', 8861, 26, NULL),
(1, '2026-06-08', 8862, 26, NULL),
(2, '2026-06-08', 8863, 24, NULL),
(2, '2026-06-08', 8864, NULL, NULL),
(1, '2026-06-08', 8865, 26, NULL),
(2, '2026-06-08', 8866, 24, NULL),
(2, '2026-06-08', 8867, 26, NULL),
(3, '2026-06-08', 8868, 25, NULL),
(1, '2026-06-08', 8869, 26, NULL),
(2, '2026-06-08', 8870, 24, NULL),
(2, '2026-06-08', 8871, 26, NULL),
(1, '2026-06-08', 8872, 26, NULL),
(2, '2026-06-08', 8873, 24, NULL),
(2, '2026-06-08', 8874, 26, NULL),
(1, '2026-06-08', 8875, 26, NULL),
(2, '2026-06-08', 8876, 24, NULL),
(2, '2026-06-08', 8877, NULL, NULL),
(1, '2026-06-08', 8878, 26, NULL),
(2, '2026-06-08', 8879, 24, NULL),
(2, '2026-06-08', 8880, 26, NULL),
(1, '2026-06-08', 8881, 26, NULL),
(2, '2026-06-08', 8882, 24, NULL),
(2, '2026-06-08', 8883, 26, NULL),
(1, '2026-06-08', 8884, 26, NULL),
(2, '2026-06-08', 8885, 24, NULL),
(2, '2026-06-08', 8886, NULL, NULL),
(1, '2026-06-08', 8887, 26, NULL),
(2, '2026-06-08', 8888, 24, NULL),
(2, '2026-06-08', 8889, 26, NULL),
(1, '2026-06-08', 8890, 26, NULL),
(2, '2026-06-08', 8891, 24, NULL),
(2, '2026-06-08', 8892, 26, NULL),
(1, '2026-06-08', 8893, 26, NULL),
(2, '2026-06-08', 8894, 24, NULL),
(2, '2026-06-08', 8895, NULL, NULL),
(1, '2026-06-08', 8896, 26, NULL),
(2, '2026-06-08', 8897, 24, NULL),
(2, '2026-06-08', 8898, 26, NULL),
(1, '2026-06-08', 8899, 26, NULL),
(2, '2026-06-08', 8900, 24, NULL),
(2, '2026-06-08', 8901, 26, NULL),
(1, '2026-06-08', 8902, 26, NULL),
(2, '2026-06-08', 8903, 24, NULL),
(2, '2026-06-08', 8904, NULL, NULL),
(1, '2026-06-08', 8905, 26, NULL),
(2, '2026-06-08', 8906, 24, NULL),
(2, '2026-06-08', 8907, 26, NULL),
(3, '2026-06-08', 8908, 25, NULL),
(1, '2026-06-08', 8909, 26, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `ChildFoodExceptionOverrideMeals`
--

CREATE TABLE `ChildFoodExceptionOverrideMeals` (
  `original_meal` int(11) DEFAULT NULL,
  `ChildfoodexceptionoverrideID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `ChildFoodExceptionOverrideMeals`
--

INSERT INTO `ChildFoodExceptionOverrideMeals` (`original_meal`, `ChildfoodexceptionoverrideID`) VALUES
(21, 8260),
(19, 8261),
(23, 8264),
(21, 8265),
(19, 8266),
(23, 8267),
(21, 8268),
(19, 8269),
(23, 8270),
(21, 8271),
(19, 8272),
(23, 8273),
(21, 8274),
(19, 8275),
(23, 8276),
(21, 8277),
(19, 8278),
(23, 8279),
(21, 8280),
(19, 8281),
(23, 8282),
(21, 8283),
(19, 8284),
(23, 8285),
(21, 8286),
(19, 8287),
(23, 8288),
(21, 8289),
(19, 8290),
(23, 8291),
(21, 8292),
(19, 8293),
(23, 8294),
(21, 8295),
(19, 8296),
(23, 8297),
(21, 8298),
(19, 8299),
(23, 8300),
(19, 8301),
(21, 8302),
(19, 8303),
(23, 8304),
(21, 8305),
(19, 8306),
(23, 8307),
(21, 8308),
(19, 8309),
(23, 8310),
(21, 8311),
(19, 8312),
(23, 8313),
(21, 8314),
(19, 8315),
(23, 8316),
(21, 8317),
(19, 8318),
(23, 8319),
(21, 8320),
(19, 8321),
(23, 8322),
(21, 8323),
(19, 8324),
(23, 8325),
(21, 8326),
(19, 8327),
(23, 8328),
(21, 8329),
(19, 8330),
(23, 8331),
(21, 8332),
(19, 8333),
(23, 8334),
(21, 8335),
(19, 8336),
(23, 8337),
(21, 8338),
(19, 8339),
(23, 8340),
(19, 8341),
(21, 8342),
(21, 8343),
(19, 8344),
(23, 8345),
(21, 8346),
(19, 8347),
(23, 8348),
(21, 8349),
(19, 8350),
(23, 8351),
(21, 8352),
(19, 8353),
(23, 8354),
(21, 8355),
(19, 8356),
(23, 8357),
(21, 8358),
(19, 8359),
(23, 8360),
(21, 8361),
(19, 8362),
(23, 8363),
(21, 8364),
(19, 8365),
(23, 8366),
(21, 8367),
(19, 8368),
(23, 8369),
(21, 8370),
(19, 8371),
(23, 8372),
(21, 8373),
(19, 8374),
(23, 8375),
(21, 8376),
(19, 8377),
(23, 8378),
(21, 8379),
(19, 8380),
(23, 8381),
(19, 8382),
(21, 8383),
(19, 8384),
(23, 8385),
(21, 8386),
(19, 8387),
(23, 8388),
(21, 8389),
(19, 8390),
(23, 8391),
(21, 8392),
(19, 8393),
(23, 8394),
(21, 8395),
(19, 8396),
(23, 8397),
(21, 8398),
(19, 8399),
(23, 8400),
(21, 8401),
(19, 8402),
(23, 8403),
(21, 8404),
(19, 8405),
(23, 8406),
(21, 8407),
(19, 8408),
(23, 8409),
(21, 8410),
(19, 8411),
(23, 8412),
(21, 8413),
(19, 8414),
(23, 8415),
(21, 8416),
(19, 8417),
(23, 8418),
(21, 8419),
(19, 8420),
(23, 8421),
(19, 8422),
(21, 8423),
(21, 8424),
(19, 8425),
(23, 8426),
(21, 8427),
(19, 8428),
(23, 8429),
(21, 8430),
(19, 8431),
(23, 8432),
(21, 8433),
(19, 8434),
(23, 8435),
(21, 8436),
(19, 8437),
(23, 8438),
(21, 8439),
(19, 8440),
(23, 8441),
(21, 8442),
(19, 8443),
(23, 8444),
(21, 8445),
(19, 8446),
(23, 8447),
(21, 8448),
(19, 8449),
(23, 8450),
(21, 8451),
(19, 8452),
(23, 8453),
(21, 8454),
(19, 8455),
(23, 8456),
(21, 8457),
(19, 8458),
(23, 8459),
(21, 8460),
(19, 8461),
(23, 8462),
(19, 8463),
(21, 8464),
(19, 8465),
(23, 8466),
(21, 8467),
(19, 8468),
(23, 8469),
(21, 8470),
(19, 8471),
(23, 8472),
(21, 8473),
(19, 8474),
(23, 8475),
(21, 8476),
(19, 8477),
(23, 8478),
(21, 8479),
(19, 8480),
(23, 8481),
(21, 8482),
(19, 8483),
(23, 8484),
(21, 8485),
(19, 8486),
(23, 8487),
(21, 8488),
(19, 8489),
(23, 8490),
(21, 8491),
(19, 8492),
(23, 8493),
(21, 8494),
(19, 8495),
(23, 8496),
(21, 8497),
(19, 8498),
(23, 8499),
(21, 8500),
(19, 8501),
(23, 8502),
(19, 8503),
(21, 8504),
(21, 8505),
(19, 8506),
(23, 8507),
(21, 8508),
(19, 8509),
(23, 8510),
(21, 8511),
(19, 8512),
(23, 8513),
(21, 8514),
(19, 8515),
(23, 8516),
(21, 8517),
(19, 8518),
(23, 8519),
(21, 8520),
(19, 8521),
(23, 8522),
(21, 8523),
(19, 8524),
(23, 8525),
(21, 8526),
(19, 8527),
(23, 8528),
(21, 8529),
(19, 8530),
(23, 8531),
(21, 8532),
(19, 8533),
(23, 8534),
(21, 8535),
(19, 8536),
(23, 8537),
(21, 8538),
(19, 8539),
(23, 8540),
(21, 8541),
(19, 8542),
(23, 8543),
(19, 8544),
(21, 8545),
(19, 8546),
(23, 8547),
(21, 8548),
(19, 8549),
(23, 8550),
(21, 8551),
(19, 8552),
(23, 8553),
(21, 8554),
(19, 8555),
(23, 8556),
(21, 8557),
(19, 8558),
(23, 8559),
(21, 8560),
(19, 8561),
(23, 8562),
(21, 8563),
(19, 8564),
(23, 8565),
(21, 8566),
(19, 8567),
(23, 8568),
(21, 8569),
(19, 8570),
(23, 8571),
(21, 8572),
(19, 8573),
(23, 8574),
(21, 8575),
(19, 8576),
(23, 8577),
(21, 8578),
(19, 8579),
(23, 8580),
(21, 8581),
(19, 8582),
(23, 8583),
(19, 8584),
(21, 8585),
(21, 8586),
(19, 8587),
(23, 8588),
(21, 8589),
(19, 8590),
(23, 8591),
(21, 8592),
(19, 8593),
(23, 8594),
(21, 8595),
(19, 8596),
(23, 8597),
(21, 8598),
(19, 8599),
(23, 8600),
(21, 8601),
(19, 8602),
(23, 8603),
(21, 8604),
(19, 8605),
(23, 8606),
(21, 8607),
(19, 8608),
(23, 8609),
(21, 8610),
(19, 8611),
(23, 8612),
(21, 8613),
(19, 8614),
(23, 8615),
(21, 8616),
(19, 8617),
(23, 8618),
(21, 8619),
(19, 8620),
(23, 8621),
(21, 8622),
(19, 8623),
(23, 8624),
(19, 8625),
(21, 8626),
(19, 8627),
(23, 8628),
(21, 8629),
(19, 8630),
(23, 8631),
(21, 8632),
(19, 8633),
(23, 8634),
(21, 8635),
(19, 8636),
(23, 8637),
(21, 8638),
(19, 8639),
(23, 8640),
(21, 8641),
(19, 8642),
(23, 8643),
(21, 8644),
(19, 8645),
(23, 8646),
(21, 8647),
(19, 8648),
(23, 8649),
(21, 8650),
(19, 8651),
(23, 8652),
(21, 8653),
(19, 8654),
(23, 8655),
(21, 8656),
(19, 8657),
(23, 8658),
(21, 8659),
(19, 8660),
(23, 8661),
(21, 8662),
(19, 8663),
(23, 8664),
(19, 8665),
(21, 8666),
(21, 8667),
(19, 8668),
(23, 8669),
(21, 8670),
(19, 8671),
(23, 8672),
(21, 8673),
(19, 8674),
(23, 8675),
(21, 8676),
(19, 8677),
(23, 8678),
(21, 8679),
(19, 8680),
(23, 8681),
(21, 8682),
(19, 8683),
(23, 8684),
(21, 8685),
(19, 8686),
(23, 8687),
(21, 8688),
(19, 8689),
(23, 8690),
(21, 8691),
(19, 8692),
(23, 8693),
(21, 8694),
(19, 8695),
(23, 8696),
(21, 8697),
(19, 8698),
(23, 8699),
(21, 8700),
(19, 8701),
(23, 8702),
(21, 8703),
(19, 8704),
(23, 8705),
(19, 8706),
(21, 8707),
(19, 8708),
(23, 8709),
(21, 8710),
(19, 8711),
(23, 8712),
(21, 8713),
(19, 8714),
(23, 8715),
(21, 8716),
(19, 8717),
(23, 8718),
(21, 8719),
(19, 8720),
(23, 8721),
(21, 8722),
(19, 8723),
(23, 8724),
(21, 8725),
(19, 8726),
(23, 8727),
(21, 8728),
(19, 8729),
(23, 8730),
(21, 8731),
(19, 8732),
(23, 8733),
(21, 8734),
(19, 8735),
(23, 8736),
(21, 8737),
(19, 8738),
(23, 8739),
(21, 8740),
(19, 8741),
(23, 8742),
(21, 8743),
(19, 8744),
(23, 8745),
(19, 8746),
(21, 8747),
(21, 8748),
(19, 8749),
(23, 8750),
(21, 8751),
(19, 8752),
(23, 8753),
(21, 8754),
(19, 8755),
(23, 8756),
(21, 8757),
(19, 8758),
(23, 8759),
(21, 8760),
(19, 8761),
(23, 8762),
(21, 8763),
(19, 8764),
(23, 8765),
(21, 8766),
(19, 8767),
(23, 8768),
(21, 8769),
(19, 8770),
(23, 8771),
(21, 8772),
(19, 8773),
(23, 8774),
(21, 8775),
(19, 8776),
(23, 8777),
(21, 8778),
(19, 8779),
(23, 8780),
(21, 8781),
(19, 8782),
(23, 8783),
(21, 8784),
(19, 8785),
(23, 8786),
(19, 8787),
(21, 8788),
(19, 8789),
(23, 8790),
(21, 8791),
(19, 8792),
(23, 8793),
(21, 8794),
(19, 8795),
(23, 8796),
(21, 8797),
(19, 8798),
(23, 8799),
(21, 8800),
(19, 8801),
(23, 8802),
(21, 8803),
(19, 8804),
(23, 8805),
(21, 8806),
(19, 8807),
(23, 8808),
(21, 8809),
(19, 8810),
(23, 8811),
(21, 8812),
(19, 8813),
(23, 8814),
(21, 8815),
(19, 8816),
(23, 8817),
(21, 8818),
(19, 8819),
(23, 8820),
(21, 8821),
(19, 8822),
(23, 8823),
(21, 8824),
(19, 8825),
(23, 8826),
(19, 8827),
(21, 8828),
(21, 8829),
(19, 8830),
(23, 8831),
(21, 8832),
(19, 8833),
(23, 8834),
(21, 8835),
(19, 8836),
(23, 8837),
(21, 8838),
(19, 8839),
(23, 8840),
(21, 8841),
(19, 8842),
(23, 8843),
(21, 8844),
(19, 8845),
(23, 8846),
(21, 8847),
(19, 8848),
(23, 8849),
(21, 8850),
(19, 8851),
(23, 8852),
(21, 8853),
(19, 8854),
(23, 8855),
(21, 8856),
(19, 8857),
(23, 8858),
(21, 8859),
(19, 8860),
(23, 8861),
(21, 8862),
(19, 8863),
(23, 8864),
(21, 8865),
(19, 8866),
(23, 8867),
(19, 8868),
(21, 8869),
(19, 8870),
(23, 8871),
(21, 8872),
(19, 8873),
(23, 8874),
(21, 8875),
(19, 8876),
(23, 8877),
(21, 8878),
(19, 8879),
(23, 8880),
(21, 8881),
(19, 8882),
(23, 8883),
(21, 8884),
(19, 8885),
(23, 8886),
(21, 8887),
(19, 8888),
(23, 8889),
(21, 8890),
(19, 8891),
(23, 8892),
(21, 8893),
(19, 8894),
(23, 8895),
(21, 8896),
(19, 8897),
(23, 8898),
(21, 8899),
(19, 8900),
(23, 8901),
(21, 8902),
(19, 8903),
(23, 8904),
(21, 8905),
(19, 8906),
(23, 8907),
(19, 8908),
(21, 8909);

-- --------------------------------------------------------

--
-- Table structure for table `Childphoto`
--

CREATE TABLE `Childphoto` (
  `Expiresat` date DEFAULT NULL,
  `Filepath` varchar(255) DEFAULT NULL,
  `ChildphotoID` int(11) NOT NULL,
  `TeacherID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Childphoto`
--

INSERT INTO `Childphoto` (`Expiresat`, `Filepath`, `ChildphotoID`, `TeacherID`) VALUES
('2026-04-09', '/storage/child_photos/b2oNby01K9tY2GOGurBKPO8Qc15b4y6EhlTMOxkF.jpg', 5, 40000032),
('2026-04-17', '/storage/child_photos/JJDLvFo9C3ok39GoYJtkP6kttdP5FmEIaNvt21pp.jpg', 6, 40000032),
('2026-04-17', '/storage/child_photos/42PeKVmJkK87I845apx642YvqnJyIrzQqwNRo06N.jpg', 7, 40000032),
('2026-06-04', '/storage/child_photos/vV3r6YMJkeCKqss5QqdnKk58XP2Ag6eHWtcXiIGT.jpg', 8, 40000032);

-- --------------------------------------------------------

--
-- Table structure for table `Childphotorecipient`
--

CREATE TABLE `Childphotorecipient` (
  `Downloadtime` date DEFAULT NULL,
  `ChildphotorecipientID` int(11) NOT NULL,
  `ChildphotoID` int(11) DEFAULT NULL,
  `ChildID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Childphotorecipient`
--

INSERT INTO `Childphotorecipient` (`Downloadtime`, `ChildphotorecipientID`, `ChildphotoID`, `ChildID`) VALUES
('2026-04-06', 19, 5, 138),
('2026-04-14', 20, 6, 138),
('2026-04-14', 21, 6, 185),
('2026-04-14', 22, 6, 186),
('2026-04-14', 23, 6, 187),
('2026-04-14', 24, 6, 188),
('2026-04-14', 25, 6, 189),
('2026-04-14', 26, 6, 190),
('2026-04-14', 27, 6, 191),
('2026-04-14', 28, 6, 192),
('2026-04-14', 29, 6, 193),
('2026-04-14', 30, 6, 194),
('2026-04-14', 31, 6, 195),
('2026-04-14', 32, 7, 183),
('2026-04-14', 33, 7, 203),
('2026-04-14', 34, 7, 211),
('2026-05-05', 35, 8, 138);

-- --------------------------------------------------------

--
-- Table structure for table `Class`
--

CREATE TABLE `Class` (
  `Capacity` int(11) DEFAULT NULL,
  `Isarchived` tinyint(1) DEFAULT NULL,
  `Name` varchar(50) DEFAULT NULL,
  `Year` int(11) DEFAULT NULL,
  `ClassID` int(11) NOT NULL,
  `ClasstypeID` int(11) DEFAULT NULL,
  `PlanningID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Class`
--

INSERT INTO `Class` (`Capacity`, `Isarchived`, `Name`, `Year`, `ClassID`, `ClasstypeID`, `PlanningID`) VALUES
(26, 1, 'Preschool Section A', 2024, 12, 2, 7),
(27, 1, 'Preschool Section B', 2024, 13, 2, 7),
(17, 1, 'Maternelle Section A', 2024, 16, 1, 7),
(15, 1, 'Maternelle Section B', 2024, 17, 1, 7),
(16, 0, 'Preschool Section A', 2025, 18, 2, 8),
(12, 0, 'Preschool Section B', 2025, 19, 2, 8),
(8, 0, 'Maternelle Section A', 2025, 20, 1, 8),
(17, 0, 'Maternelle Section B', 2025, 21, 1, 8),
(24, 0, 'Preschool Section C', 2025, 22, 2, 8);

--
-- Triggers `Class`
--
DELIMITER $$
CREATE TRIGGER `trg_class_type_insert` BEFORE INSERT ON `Class` FOR EACH ROW BEGIN
    DECLARE v_startdate DATE DEFAULT NULL;

    IF NEW.ClasstypeID IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Class must specify a type (ClasstypeID cannot be null).';
    END IF;

    IF NEW.PlanningID IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Class must be linked to a planning.';
    END IF;

    SELECT `Startdate` INTO v_startdate
    FROM `Planning`
    WHERE `PlanningID` = NEW.PlanningID
    LIMIT 1;

    IF v_startdate IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Class planning does not exist.';
    END IF;

    SET NEW.`Year` = YEAR(v_startdate);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_class_type_update` BEFORE UPDATE ON `Class` FOR EACH ROW BEGIN
    DECLARE v_startdate DATE DEFAULT NULL;

    IF NEW.ClasstypeID IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Class must specify a type (ClasstypeID cannot be null).';
    END IF;

    IF NEW.PlanningID IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Class must be linked to a planning.';
    END IF;

    SELECT `Startdate` INTO v_startdate
    FROM `Planning`
    WHERE `PlanningID` = NEW.PlanningID
    LIMIT 1;

    IF v_startdate IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Class planning does not exist.';
    END IF;

    SET NEW.`Year` = YEAR(v_startdate);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_class_validate_before_insert` BEFORE INSERT ON `Class` FOR EACH ROW BEGIN
    IF NEW.Name IS NULL OR TRIM(NEW.Name) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Class name cannot be empty.';
    END IF;
    IF NEW.Capacity IS NOT NULL AND NEW.Capacity <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Class capacity must be greater than 0.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_class_validate_before_update` BEFORE UPDATE ON `Class` FOR EACH ROW BEGIN
    IF NEW.Name IS NULL OR TRIM(NEW.Name) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Class name cannot be empty.';
    END IF;
    IF NEW.Capacity IS NOT NULL AND NEW.Capacity <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Class capacity must be greater than 0.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Classtype`
--

CREATE TABLE `Classtype` (
  `Name` varchar(50) DEFAULT NULL,
  `ClasstypeID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Classtype`
--

INSERT INTO `Classtype` (`Name`, `ClasstypeID`) VALUES
('Kindergarten', 1),
('Preschool', 2);

-- --------------------------------------------------------

--
-- Table structure for table `Criteria`
--

CREATE TABLE `Criteria` (
  `Name` varchar(50) DEFAULT NULL,
  `CriteriaID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Criteria`
--

INSERT INTO `Criteria` (`Name`, `CriteriaID`) VALUES
('Confiance en soi et expression de soi', 1),
('Discrimination visuelle et auditive des lettres', 2),
('Compétences motrices', 3),
('Respect des règles et des limites', 4),
('Résolution de problèmes', 5),
('Fluidité langagière et phonétique', 6),
('Pensée critique et imagination', 7),
('Coopération et travail d\'équipe', 8),
('Créativité', 10),
('Éthique de l\'écoute et du dialogue', 11),
('Intelligence émotionnelle et sociale', 12),
('Classification et tri', 13);

-- --------------------------------------------------------

--
-- Table structure for table `CriteriaActivity`
--

CREATE TABLE `CriteriaActivity` (
  `ActivityID` int(11) DEFAULT NULL,
  `CriteriaID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `CriteriaActivity`
--

INSERT INTO `CriteriaActivity` (`ActivityID`, `CriteriaID`) VALUES
(40, 13),
(42, 1),
(43, 1),
(43, 12),
(44, 5),
(44, 13),
(47, 1),
(47, 6),
(47, 11),
(49, 3),
(49, 10),
(50, 1),
(50, 11),
(45, 3),
(45, 1),
(41, 10),
(41, 1),
(46, 13),
(46, 2),
(48, 3),
(48, 12);

-- --------------------------------------------------------

--
-- Table structure for table `Dailyplan`
--

CREATE TABLE `Dailyplan` (
  `Date` date DEFAULT NULL,
  `DailyplanID` int(11) NOT NULL,
  `MenuplanningID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Dailyplan`
--

INSERT INTO `Dailyplan` (`Date`, `DailyplanID`, `MenuplanningID`) VALUES
(NULL, 196, 12),
(NULL, 197, 12),
(NULL, 198, 12),
(NULL, 199, 12),
(NULL, 200, 12),
('2025-06-23', 206, 13),
('2025-06-24', 207, 13),
('2025-06-25', 208, 13),
('2025-06-26', 209, 13),
('2025-06-27', 210, 13),
(NULL, 211, 14),
(NULL, 212, 14),
(NULL, 213, 14),
(NULL, 214, 14),
(NULL, 215, 14),
('2025-06-16', 216, 15),
('2025-06-17', 217, 15),
('2025-06-18', 218, 15),
('2025-06-19', 219, 15),
('2025-06-20', 220, 15),
('2026-04-06', 231, 16),
('2026-04-07', 232, 16),
('2026-04-08', 233, 16),
('2026-04-09', 234, 16),
('2026-04-10', 235, 16),
('2025-06-30', 241, 11),
('2025-07-01', 242, 11),
('2025-07-02', 243, 11),
('2025-07-03', 244, 11),
('2025-07-04', 245, 11),
('2026-04-13', 251, 18),
('2026-04-14', 252, 18),
('2026-04-15', 253, 18),
('2026-04-16', 254, 18),
('2026-04-17', 255, 18),
('2026-05-25', 261, 19),
('2026-05-26', 262, 19),
('2026-05-27', 263, 19),
('2026-05-28', 264, 19),
('2026-05-29', 265, 19),
('2026-06-08', 276, 21),
('2026-06-09', 277, 21),
('2026-06-10', 278, 21),
('2026-06-11', 279, 21),
('2026-06-12', 280, 21),
('2026-06-01', 281, 20),
('2026-06-02', 282, 20),
('2026-06-03', 283, 20),
('2026-06-04', 284, 20),
('2026-06-05', 285, 20);

-- --------------------------------------------------------

--
-- Table structure for table `DailyPlanMeals`
--

CREATE TABLE `DailyPlanMeals` (
  `MealsID` int(11) DEFAULT NULL,
  `DailyplanID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `DailyPlanMeals`
--

INSERT INTO `DailyPlanMeals` (`MealsID`, `DailyplanID`) VALUES
(8, 196),
(26, 196),
(14, 197),
(21, 197),
(19, 198),
(23, 198),
(25, 199),
(26, 199),
(16, 200),
(26, 200),
(8, 206),
(26, 206),
(14, 207),
(21, 207),
(19, 208),
(23, 208),
(25, 209),
(26, 209),
(16, 210),
(26, 210),
(8, 211),
(26, 211),
(14, 212),
(21, 212),
(19, 213),
(23, 213),
(25, 214),
(26, 214),
(16, 215),
(26, 215),
(8, 216),
(26, 216),
(14, 217),
(21, 217),
(19, 218),
(23, 218),
(25, 219),
(26, 219),
(16, 220),
(26, 220),
(8, 231),
(26, 231),
(14, 232),
(21, 232),
(19, 233),
(23, 233),
(24, 234),
(26, 234),
(16, 235),
(26, 235),
(8, 241),
(26, 241),
(14, 242),
(21, 242),
(19, 243),
(23, 243),
(19, 244),
(26, 244),
(16, 245),
(26, 245),
(8, 251),
(26, 251),
(14, 252),
(21, 252),
(19, 253),
(23, 253),
(25, 254),
(26, 254),
(16, 255),
(26, 255),
(8, 261),
(26, 261),
(14, 262),
(21, 262),
(19, 263),
(23, 263),
(25, 264),
(26, 264),
(16, 265),
(26, 265),
(19, 276),
(26, 276),
(14, 277),
(21, 277),
(19, 278),
(23, 278),
(25, 279),
(26, 279),
(16, 280),
(26, 280),
(14, 281),
(26, 281),
(14, 282),
(21, 282),
(19, 283),
(23, 283),
(25, 284),
(26, 284),
(16, 285),
(26, 285);

-- --------------------------------------------------------

--
-- Table structure for table `Dietarycomment`
--

CREATE TABLE `Dietarycomment` (
  `Dietarycomment` varchar(1000) DEFAULT NULL,
  `DietarycommentID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `Dietarycomment`
--

INSERT INTO `Dietarycomment` (`Dietarycomment`, `DietarycommentID`) VALUES
('Interdiction de consommer du sucre', 184),
('✅ Aucune restriction alimentaire détectée.', 185),
('✅ Aucune restriction alimentaire détectée.', 186),
('✅ Aucune restriction alimentaire détectée.', 187),
('✅ Aucune restriction alimentaire détectée.', 188),
('✅ Aucune restriction alimentaire détectée.', 189),
('✅ Aucune restriction alimentaire détectée.', 190),
('✅ Aucune restriction alimentaire détectée.', 191),
('✅ Aucune restriction alimentaire détectée.', 192),
('✅ Aucune restriction alimentaire détectée.', 193),
('✅ Aucune restriction alimentaire détectée.', 194),
('✅ Aucune restriction alimentaire détectée.', 195),
('✅ Aucune restriction alimentaire détectée.', 196),
('✅ Aucune restriction alimentaire détectée.', 197),
('✅ Aucune restriction alimentaire détectée.', 198),
('✅ Aucune restriction alimentaire détectée.', 199),
('✅ Aucune restriction alimentaire détectée.', 201),
('Régime adapté au diabète requis, attention à la teneur en sucres des repas et boissons.', 202),
('L\'enfant ne doit pas consommer de sucre.', 203),
('Interdiction de consommer du sucre en raison du diabète.', 204),
('✅ Aucune restriction alimentaire détectée.', 205);

-- --------------------------------------------------------

--
-- Table structure for table `Evaluation`
--

CREATE TABLE `Evaluation` (
  `Activitydescriptionsnapshot` text DEFAULT NULL,
  `Activtitytitlesnapshot` varchar(255) DEFAULT NULL,
  `Date` date DEFAULT NULL,
  `EvaluationID` int(11) NOT NULL,
  `ActivityID` int(11) DEFAULT NULL,
  `SignalementID` int(11) DEFAULT NULL,
  `ChildID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `Evaluation`
--

INSERT INTO `Evaluation` (`Activitydescriptionsnapshot`, `Activtitytitlesnapshot`, `Date`, `EvaluationID`, `ActivityID`, `SignalementID`, `ChildID`) VALUES
('Tradition tunisienne : faire germer des graines da', 'Semer les Lentilles du Printemps', '2024-12-09', 189, 40, NULL, 138),
('Utiliser une lampe pour créer des silhouettes d\'an', 'Le Théâtre d\'Ombres', '2024-12-09', 190, 41, NULL, 138),
(NULL, NULL, '2026-04-06', 193, NULL, 12, 138),
('Expérimenter avec différents objets dans un bac à ', 'Flotte ou Coule ?', '2026-04-07', 194, 44, NULL, 138),
('Apprendre des postures simples (le chat, le chien,', 'Le Yoga des Petits Animaux', '2026-04-07', 195, 48, NULL, 138),
(NULL, NULL, '2026-04-07', 196, NULL, 13, 138),
('Un enfant dirige le volume sonore de la classe ave', 'Le Chef d\'Orchestre', '2026-04-07', 197, 50, NULL, 138),
('Expérimenter avec différents objets dans un bac à ', 'Flotte ou Coule ?', '2026-04-07', 198, 44, NULL, 185),
('Apprendre des postures simples (le chat, le chien,', 'Le Yoga des Petits Animaux', '2026-04-07', 199, 48, NULL, 185),
('Un enfant dirige le volume sonore de la classe ave', 'Le Chef d\'Orchestre', '2026-04-07', 200, 50, NULL, 185),
('Expérimenter avec différents objets dans un bac à ', 'Flotte ou Coule ?', '2026-04-07', 201, 44, NULL, 186),
('Apprendre des postures simples (le chat, le chien,', 'Le Yoga des Petits Animaux', '2026-04-07', 202, 48, NULL, 186),
('Un enfant dirige le volume sonore de la classe ave', 'Le Chef d\'Orchestre', '2026-04-07', 203, 50, NULL, 186),
('Expérimenter avec différents objets dans un bac à ', 'Flotte ou Coule ?', '2026-04-07', 204, 44, NULL, 187),
('Apprendre des postures simples (le chat, le chien,', 'Le Yoga des Petits Animaux', '2026-04-07', 205, 48, NULL, 187),
('Un enfant dirige le volume sonore de la classe ave', 'Le Chef d\'Orchestre', '2026-04-07', 206, 50, NULL, 187),
('Expérimenter avec différents objets dans un bac à ', 'Flotte ou Coule ?', '2026-04-07', 207, 44, NULL, 188),
('Apprendre des postures simples (le chat, le chien,', 'Le Yoga des Petits Animaux', '2026-04-07', 208, 48, NULL, 188),
('Un enfant dirige le volume sonore de la classe ave', 'Le Chef d\'Orchestre', '2026-04-07', 209, 50, NULL, 188),
('Expérimenter avec différents objets dans un bac à ', 'Flotte ou Coule ?', '2026-04-07', 210, 44, NULL, 189),
('Apprendre des postures simples (le chat, le chien,', 'Le Yoga des Petits Animaux', '2026-04-07', 211, 48, NULL, 189),
('Un enfant dirige le volume sonore de la classe ave', 'Le Chef d\'Orchestre', '2026-04-07', 212, 50, NULL, 189),
('Expérimenter avec différents objets dans un bac à ', 'Flotte ou Coule ?', '2026-04-07', 213, 44, NULL, 190),
('Apprendre des postures simples (le chat, le chien,', 'Le Yoga des Petits Animaux', '2026-04-07', 214, 48, NULL, 190),
('Un enfant dirige le volume sonore de la classe ave', 'Le Chef d\'Orchestre', '2026-04-07', 215, 50, NULL, 190),
('Expérimenter avec différents objets dans un bac à ', 'Flotte ou Coule ?', '2026-04-07', 216, 44, NULL, 191),
('Apprendre des postures simples (le chat, le chien,', 'Le Yoga des Petits Animaux', '2026-04-07', 217, 48, NULL, 191),
('Un enfant dirige le volume sonore de la classe ave', 'Le Chef d\'Orchestre', '2026-04-07', 218, 50, NULL, 191),
('Expérimenter avec différents objets dans un bac à ', 'Flotte ou Coule ?', '2026-04-07', 219, 44, NULL, 192),
('Apprendre des postures simples (le chat, le chien,', 'Le Yoga des Petits Animaux', '2026-04-07', 220, 48, NULL, 192),
('Un enfant dirige le volume sonore de la classe ave', 'Le Chef d\'Orchestre', '2026-04-07', 221, 50, NULL, 192),
('Expérimenter avec différents objets dans un bac à ', 'Flotte ou Coule ?', '2026-04-07', 222, 44, NULL, 193),
('Apprendre des postures simples (le chat, le chien,', 'Le Yoga des Petits Animaux', '2026-04-07', 223, 48, NULL, 193),
('Un enfant dirige le volume sonore de la classe ave', 'Le Chef d\'Orchestre', '2026-04-07', 224, 50, NULL, 193),
('Expérimenter avec différents objets dans un bac à ', 'Flotte ou Coule ?', '2026-04-07', 225, 44, NULL, 194),
('Apprendre des postures simples (le chat, le chien,', 'Le Yoga des Petits Animaux', '2026-04-07', 226, 48, NULL, 194),
('Un enfant dirige le volume sonore de la classe ave', 'Le Chef d\'Orchestre', '2026-04-07', 227, 50, NULL, 194),
('Expérimenter avec différents objets dans un bac à ', 'Flotte ou Coule ?', '2026-04-07', 228, 44, NULL, 195),
('Apprendre des postures simples (le chat, le chien,', 'Le Yoga des Petits Animaux', '2026-04-07', 229, 48, NULL, 195),
('Un enfant dirige le volume sonore de la classe ave', 'Le Chef d\'Orchestre', '2026-04-07', 230, 50, NULL, 195);

-- --------------------------------------------------------

--
-- Table structure for table `Events`
--

CREATE TABLE `Events` (
  `Date` date DEFAULT NULL,
  `Description` varchar(500) DEFAULT NULL,
  `Endtime` time DEFAULT NULL,
  `Name` varchar(50) DEFAULT NULL,
  `Notificationsend` tinyint(1) DEFAULT NULL,
  `Starttime` time DEFAULT NULL,
  `Status` varchar(50) DEFAULT NULL,
  `EventsID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Events`
--

INSERT INTO `Events` (`Date`, `Description`, `Endtime`, `Name`, `Notificationsend`, `Starttime`, `Status`, `EventsID`) VALUES
('2026-04-25', 'test 6', '11:00:00', 'test 6', 1, '09:00:00', 'pending', 9),
('2026-05-02', 'test 7', '11:00:00', 'test 7', 1, '09:00:00', 'pending', 11),
('2026-05-30', 'party1', '11:00:00', 'party', 1, '09:00:00', 'pending', 12);

-- --------------------------------------------------------

--
-- Table structure for table `Grade`
--

CREATE TABLE `Grade` (
  `Criterianamesnapshot` varchar(50) DEFAULT NULL,
  `Status` varchar(50) DEFAULT NULL,
  `GradeID` int(11) NOT NULL,
  `EvaluationID` int(11) DEFAULT NULL,
  `CriteriaID` int(11) DEFAULT NULL,
  `StatusID` int(11) DEFAULT NULL,
  `GradestatusID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Grade`
--

INSERT INTO `Grade` (`Criterianamesnapshot`, `Status`, `GradeID`, `EvaluationID`, `CriteriaID`, `StatusID`, `GradestatusID`) VALUES
('Classification et tri', 'À renforcer', 297, 189, 13, NULL, 2),
('Créativité', 'Acquise', 298, 190, 10, NULL, 1),
('Confiance en soi et expression de soi', 'Acquise', 299, 190, 1, NULL, 1),
('Résolution de problèmes', 'Acquise', 300, 194, 5, NULL, 1),
('Classification et tri', 'Acquise', 301, 194, 13, NULL, 1),
('Confiance en soi et expression de soi', 'Acquise', 302, 195, 1, NULL, 1),
('Compétences motrices', 'À renforcer', 303, 195, 3, NULL, 2),
('Confiance en soi et expression de soi', 'Acquise', 304, 197, 1, NULL, 1),
('Éthique de l\'écoute et du dialogue', 'Acquise', 305, 197, 11, NULL, 1),
('Résolution de problèmes', 'Acquise', 306, 198, 5, NULL, 1),
('Classification et tri', 'Acquise', 307, 198, 13, NULL, 1),
('Confiance en soi et expression de soi', 'Acquise', 308, 199, 1, NULL, 1),
('Compétences motrices', 'Acquise', 309, 199, 3, NULL, 1),
('Confiance en soi et expression de soi', 'Acquise', 310, 200, 1, NULL, 1),
('Éthique de l\'écoute et du dialogue', 'Acquise', 311, 200, 11, NULL, 1),
('Résolution de problèmes', 'Acquise', 312, 201, 5, NULL, 1),
('Classification et tri', 'Acquise', 313, 201, 13, NULL, 1),
('Confiance en soi et expression de soi', 'Acquise', 314, 202, 1, NULL, 1),
('Compétences motrices', 'Acquise', 315, 202, 3, NULL, 1),
('Confiance en soi et expression de soi', 'Acquise', 316, 203, 1, NULL, 1),
('Éthique de l\'écoute et du dialogue', 'Acquise', 317, 203, 11, NULL, 1),
('Résolution de problèmes', 'Acquise', 318, 204, 5, NULL, 1),
('Classification et tri', 'Acquise', 319, 204, 13, NULL, 1),
('Confiance en soi et expression de soi', 'Acquise', 320, 205, 1, NULL, 1),
('Compétences motrices', 'Acquise', 321, 205, 3, NULL, 1),
('Confiance en soi et expression de soi', 'Acquise', 322, 206, 1, NULL, 1),
('Éthique de l\'écoute et du dialogue', 'Acquise', 323, 206, 11, NULL, 1),
('Résolution de problèmes', 'Acquise', 324, 207, 5, NULL, 1),
('Classification et tri', 'Acquise', 325, 207, 13, NULL, 1),
('Confiance en soi et expression de soi', 'Acquise', 326, 208, 1, NULL, 1),
('Compétences motrices', 'Acquise', 327, 208, 3, NULL, 1),
('Confiance en soi et expression de soi', 'Acquise', 328, 209, 1, NULL, 1),
('Éthique de l\'écoute et du dialogue', 'Acquise', 329, 209, 11, NULL, 1),
('Résolution de problèmes', 'Acquise', 330, 210, 5, NULL, 1),
('Classification et tri', 'Acquise', 331, 210, 13, NULL, 1),
('Confiance en soi et expression de soi', 'Acquise', 332, 211, 1, NULL, 1),
('Compétences motrices', 'Acquise', 333, 211, 3, NULL, 1),
('Confiance en soi et expression de soi', 'Acquise', 334, 212, 1, NULL, 1),
('Éthique de l\'écoute et du dialogue', 'Acquise', 335, 212, 11, NULL, 1),
('Résolution de problèmes', 'Acquise', 336, 213, 5, NULL, 1),
('Classification et tri', 'Acquise', 337, 213, 13, NULL, 1),
('Confiance en soi et expression de soi', 'Acquise', 338, 214, 1, NULL, 1),
('Compétences motrices', 'Acquise', 339, 214, 3, NULL, 1),
('Confiance en soi et expression de soi', 'Acquise', 340, 215, 1, NULL, 1),
('Éthique de l\'écoute et du dialogue', 'Acquise', 341, 215, 11, NULL, 1),
('Résolution de problèmes', 'Acquise', 342, 216, 5, NULL, 1),
('Classification et tri', 'Acquise', 343, 216, 13, NULL, 1),
('Confiance en soi et expression de soi', 'Acquise', 344, 217, 1, NULL, 1),
('Compétences motrices', 'Acquise', 345, 217, 3, NULL, 1),
('Confiance en soi et expression de soi', 'Acquise', 346, 218, 1, NULL, 1),
('Éthique de l\'écoute et du dialogue', 'Acquise', 347, 218, 11, NULL, 1),
('Résolution de problèmes', 'Acquise', 348, 219, 5, NULL, 1),
('Classification et tri', 'Acquise', 349, 219, 13, NULL, 1),
('Confiance en soi et expression de soi', 'Acquise', 350, 220, 1, NULL, 1),
('Compétences motrices', 'Acquise', 351, 220, 3, NULL, 1),
('Confiance en soi et expression de soi', 'Acquise', 352, 221, 1, NULL, 1),
('Éthique de l\'écoute et du dialogue', 'Acquise', 353, 221, 11, NULL, 1),
('Résolution de problèmes', 'Acquise', 354, 222, 5, NULL, 1),
('Classification et tri', 'Acquise', 355, 222, 13, NULL, 1),
('Confiance en soi et expression de soi', 'Acquise', 356, 223, 1, NULL, 1),
('Compétences motrices', 'Acquise', 357, 223, 3, NULL, 1),
('Confiance en soi et expression de soi', 'Acquise', 358, 224, 1, NULL, 1),
('Éthique de l\'écoute et du dialogue', 'Acquise', 359, 224, 11, NULL, 1),
('Résolution de problèmes', 'Acquise', 360, 225, 5, NULL, 1),
('Classification et tri', 'Acquise', 361, 225, 13, NULL, 1),
('Confiance en soi et expression de soi', 'Acquise', 362, 226, 1, NULL, 1),
('Compétences motrices', 'Acquise', 363, 226, 3, NULL, 1),
('Confiance en soi et expression de soi', 'Acquise', 364, 227, 1, NULL, 1),
('Éthique de l\'écoute et du dialogue', 'Acquise', 365, 227, 11, NULL, 1),
('Résolution de problèmes', 'Acquise', 366, 228, 5, NULL, 1),
('Classification et tri', 'Acquise', 367, 228, 13, NULL, 1),
('Confiance en soi et expression de soi', 'Acquise', 368, 229, 1, NULL, 1),
('Compétences motrices', 'Acquise', 369, 229, 3, NULL, 1),
('Confiance en soi et expression de soi', 'Acquise', 370, 230, 1, NULL, 1),
('Éthique de l\'écoute et du dialogue', 'Acquise', 371, 230, 11, NULL, 1);

-- --------------------------------------------------------

--
-- Table structure for table `Gradestatus`
--

CREATE TABLE `Gradestatus` (
  `Name` varchar(50) DEFAULT NULL,
  `GradestatusID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Gradestatus`
--

INSERT INTO `Gradestatus` (`Name`, `GradestatusID`) VALUES
('Acquise', 1),
('À renforcer', 2);

-- --------------------------------------------------------

--
-- Table structure for table `Healthcomment`
--

CREATE TABLE `Healthcomment` (
  `Healthcomment` varchar(1000) DEFAULT NULL,
  `HealthcommentID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `Healthcomment`
--

INSERT INTO `Healthcomment` (`Healthcomment`, `HealthcommentID`) VALUES
('Le personnel de garde doit veiller à ce que l\'enfant ne consomme pas de sucre en raison d\'un diabète.', 183),
('✅ Aucun problème de santé notable détecté.', 184),
('✅ Aucun problème de santé notable détecté.', 185),
('✅ Aucun problème de santé notable détecté.', 186),
('✅ Aucun problème de santé notable détecté.', 187),
('✅ Aucun problème de santé notable détecté.', 188),
('✅ Aucun problème de santé notable détecté.', 189),
('✅ Aucun problème de santé notable détecté.', 190),
('✅ Aucun problème de santé notable détecté.', 191),
('✅ Aucun problème de santé notable détecté.', 192),
('✅ Aucun problème de santé notable détecté.', 193),
('✅ Aucun problème de santé notable détecté.', 194),
('✅ Aucun problème de santé notable détecté.', 195),
('✅ Aucun problème de santé notable détecté.', 196),
('✅ Aucun problème de santé notable détecté.', 197),
('✅ Aucun problème de santé notable détecté.', 198),
('✅ Aucun problème de santé notable détecté.', 200),
('Présence de diabète : surveillance spécifique recommandée (glycémie, signes d’hypo/hyperglycémie).', 201),
('Diabète et maladies rénales connus ; surveiller la glycémie et éviter toute source de sucre.', 202),
('L\'enfant présente un antécédent de diabète. Il est important de surveiller son alimentation et son niveau de sucre dans le sang.', 203),
('✅ Aucun problème de santé notable détecté.', 204);

-- --------------------------------------------------------

--
-- Table structure for table `Inscription`
--

CREATE TABLE `Inscription` (
  `Basefee` double(10,2) DEFAULT NULL,
  `Date` date DEFAULT NULL,
  `Fraisinscriptionsnapshot` double(10,2) DEFAULT NULL,
  `Inscriptionfeespaymentamount` double(10,2) DEFAULT NULL,
  `Isarchived` int(11) DEFAULT NULL,
  `Mealplanfee` double(10,2) DEFAULT NULL,
  `Totalamount` double(10,2) DEFAULT NULL,
  `InscriptionID` int(11) NOT NULL,
  `MealplanID` int(11) DEFAULT NULL,
  `PaymentmethodID` int(11) DEFAULT NULL,
  `TypeID` int(11) DEFAULT NULL,
  `InscriptiontypeID` int(11) DEFAULT NULL,
  `InscriptionstatusID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Inscription`
--

INSERT INTO `Inscription` (`Basefee`, `Date`, `Fraisinscriptionsnapshot`, `Inscriptionfeespaymentamount`, `Isarchived`, `Mealplanfee`, `Totalamount`, `InscriptionID`, `MealplanID`, `PaymentmethodID`, `TypeID`, `InscriptiontypeID`, `InscriptionstatusID`) VALUES
(350.00, '2024-08-31', 21.00, 21.00, 1, 0.00, 350.00, 121, 4, 1, 2, 2, 1),
(350.00, '2024-08-31', 21.00, NULL, 1, 0.00, 350.00, 122, 4, 2, 2, 2, 1),
(350.00, '2024-08-31', 21.00, 21.00, 1, 50.00, 400.00, 145, 3, 2, 2, 2, 1),
(351.00, '2026-04-07', 22.00, 22.00, 0, 51.00, 402.00, 146, 3, 1, 2, 2, 1),
(351.00, '2026-04-07', 22.00, 22.00, 0, 0.00, 351.00, 147, 4, 2, 1, 1, 1),
(351.00, '2026-04-07', 22.00, 22.00, 0, 301.00, 652.00, 149, 1, 2, 2, 2, 1),
(351.00, '2026-04-07', 22.00, 22.00, 0, 301.00, 652.00, 150, 1, 2, 2, 2, 1),
(351.00, '2026-04-07', 22.00, 22.00, 0, 301.00, 652.00, 151, 1, 1, 2, 2, 1),
(351.00, '2026-04-07', 22.00, NULL, 0, 301.00, 652.00, 152, 1, 2, 2, 2, 1),
(351.00, '2026-04-07', 22.00, NULL, 0, 301.00, 652.00, 153, 1, 1, 2, 2, 1),
(351.00, '2026-04-07', 22.00, 22.00, 0, 301.00, 652.00, 154, 1, 2, 2, 2, 1),
(351.00, '2026-04-07', 22.00, 22.00, 0, 301.00, 652.00, 155, 1, 1, 2, 2, 1),
(351.00, '2026-04-07', 22.00, 22.00, 0, 301.00, 652.00, 156, 1, 2, 2, 2, 1),
(351.00, '2026-04-07', 22.00, 22.00, 0, 301.00, 652.00, 157, 1, 1, 2, 2, 1),
(351.00, '2026-04-07', 22.00, 22.00, 0, 301.00, 652.00, 158, 1, 2, 2, 2, 1),
(351.00, '2026-04-07', 22.00, 22.00, 0, 301.00, 652.00, 159, 1, 1, 2, 2, 1),
(351.00, '2026-04-07', 22.00, NULL, 0, 301.00, 652.00, 160, 1, 2, 1, 1, 3),
(351.00, '2026-04-07', 22.00, NULL, 0, 301.00, 652.00, 161, 1, 1, 1, 1, 3),
(351.00, '2026-04-07', 22.00, NULL, 0, 301.00, 652.00, 162, 1, 2, 1, 1, 3),
(351.00, '2026-04-07', 22.00, NULL, 0, 301.00, 652.00, 163, 1, 1, 1, 1, 3),
(351.00, '2026-04-07', 22.00, NULL, 0, 301.00, 652.00, 164, 1, 2, 1, 1, 3),
(351.00, '2026-04-07', 22.00, NULL, 0, 301.00, 652.00, 165, 1, 1, 1, 1, 3),
(351.00, '2026-04-07', 22.00, NULL, 0, 301.00, 652.00, 166, 1, 2, 1, 1, 3),
(351.00, '2026-04-07', 22.00, 22.00, 0, 301.00, 652.00, 167, 1, 1, 1, 1, 1),
(351.00, '2026-04-07', 22.00, NULL, 0, 301.00, 652.00, 168, 1, 2, 1, 1, 3),
(351.00, '2026-04-07', 22.00, NULL, 0, 301.00, 652.00, 169, 1, 1, 1, 1, 2),
(351.00, '2026-04-07', 22.00, NULL, 0, 301.00, 652.00, 170, 1, 2, 2, 2, 1),
(351.00, '2026-04-07', 22.00, NULL, 0, 301.00, 652.00, 171, 1, 1, 2, 2, 3),
(351.00, '2026-04-07', 22.00, NULL, 0, 301.00, 652.00, 172, 1, 2, 2, 2, 3),
(351.00, '2026-04-07', 22.00, NULL, 0, 301.00, 652.00, 173, 1, 1, 2, 2, 3),
(351.00, '2026-04-09', 22.00, NULL, 0, 301.00, 652.00, 175, 1, 2, 1, 1, 1),
(351.00, '2026-04-09', 22.00, 22.00, 0, 301.00, 652.00, 177, 1, 2, 2, 2, 1),
(351.00, '2026-05-30', 22.00, NULL, 0, 101.00, 452.00, 178, 2, 1, 2, 2, 3);

--
-- Triggers `Inscription`
--
DELIMITER $$
CREATE TRIGGER `trg_inscription_validate_before_insert` BEFORE INSERT ON `Inscription` FOR EACH ROW BEGIN
    IF NEW.Date IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Inscription date cannot be null.';
    END IF;
    IF NEW.Basefee IS NOT NULL AND NEW.Basefee < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Base fee cannot be negative.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_inscription_validate_before_update` BEFORE UPDATE ON `Inscription` FOR EACH ROW BEGIN
    IF NEW.Date IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Inscription date cannot be null.';
    END IF;
    IF NEW.Basefee IS NOT NULL AND NEW.Basefee < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Base fee cannot be negative.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Inscriptionstatus`
--

CREATE TABLE `Inscriptionstatus` (
  `Name` varchar(50) DEFAULT NULL,
  `InscriptionstatusID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Inscriptionstatus`
--

INSERT INTO `Inscriptionstatus` (`Name`, `InscriptionstatusID`) VALUES
('approved', 1),
('rejected', 2),
('pending', 3);

-- --------------------------------------------------------

--
-- Table structure for table `Inscriptiontype`
--

CREATE TABLE `Inscriptiontype` (
  `Name` varchar(50) DEFAULT NULL,
  `InscriptiontypeID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Inscriptiontype`
--

INSERT INTO `Inscriptiontype` (`Name`, `InscriptiontypeID`) VALUES
('Kindergarten', 1),
('Preschool', 2);

-- --------------------------------------------------------

--
-- Table structure for table `Mealplan`
--

CREATE TABLE `Mealplan` (
  `Name` varchar(255) DEFAULT NULL,
  `MealplanID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Mealplan`
--

INSERT INTO `Mealplan` (`Name`, `MealplanID`) VALUES
('Mon enfant prend le déjeuner et le goûter', 1),
('Mon enfant prend seulement le dejeuner', 2),
('Mon enfant prend seulement le gouter', 3),
('Mon enfant ne mange pas à l\'école (le parent le récupère puis le ramène)', 4);

-- --------------------------------------------------------

--
-- Table structure for table `Meals`
--

CREATE TABLE `Meals` (
  `Name` varchar(50) DEFAULT NULL,
  `MealsID` int(11) NOT NULL,
  `MealscategoryID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Meals`
--

INSERT INTO `Meals` (`Name`, `MealsID`, `MealscategoryID`) VALUES
('La Makrouna', 8, 1),
('Le Tajine Tunisien', 14, 1),
('Le Couscous au lait (Mesfouf)', 15, 1),
('Le Fricassé', 16, 1),
('La Marqa Jelbana', 17, 1),
('Le Kaftaji au four', 18, 1),
('Le Bambalouni', 19, 1),
('La Tartine de Chamia', 20, 2),
('Le Cake Maison', 21, 2),
('Les Biscuits', 22, 2),
('Le Youyou', 23, 2),
('Soupe au poulet', 24, 1),
('poisson', 25, 1),
('Avocado', 26, 2);

-- --------------------------------------------------------

--
-- Table structure for table `Mealscategory`
--

CREATE TABLE `Mealscategory` (
  `Name` varchar(50) DEFAULT NULL,
  `MealscategoryID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Mealscategory`
--

INSERT INTO `Mealscategory` (`Name`, `MealscategoryID`) VALUES
('lunch', 1),
('snacks', 2);

-- --------------------------------------------------------

--
-- Table structure for table `MealsChildFoodExceptionOverride`
--

CREATE TABLE `MealsChildFoodExceptionOverride` (
  `ChildfoodexceptionoverrideID` int(11) DEFAULT NULL,
  `replacement_meal` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `MealsChildFoodExceptionOverride`
--

INSERT INTO `MealsChildFoodExceptionOverride` (`ChildfoodexceptionoverrideID`, `replacement_meal`) VALUES
(8260, 26),
(8261, 24),
(8264, 26),
(8265, 26),
(8266, 24),
(8267, 26),
(8268, 26),
(8269, 24),
(8271, 26),
(8272, 24),
(8273, 26),
(8274, 26),
(8275, 24),
(8276, 26),
(8277, 26),
(8278, 24),
(8280, 26),
(8281, 24),
(8282, 26),
(8283, 26),
(8284, 24),
(8285, 26),
(8286, 26),
(8287, 24),
(8289, 26),
(8290, 24),
(8291, 26),
(8292, 26),
(8293, 24),
(8294, 26),
(8295, 26),
(8296, 24),
(8298, 26),
(8299, 24),
(8300, 26),
(8301, 25),
(8302, 26),
(8303, 24),
(8304, 26),
(8305, 26),
(8306, 24),
(8307, 26),
(8308, 26),
(8309, 24),
(8311, 26),
(8312, 24),
(8313, 26),
(8314, 26),
(8315, 24),
(8316, 26),
(8317, 26),
(8318, 24),
(8320, 26),
(8321, 24),
(8322, 26),
(8323, 26),
(8324, 24),
(8325, 26),
(8326, 26),
(8327, 24),
(8329, 26),
(8330, 24),
(8331, 26),
(8332, 26),
(8333, 24),
(8334, 26),
(8335, 26),
(8336, 24),
(8338, 26),
(8339, 24),
(8340, 26),
(8341, 25),
(8342, 26),
(8343, 26),
(8344, 24),
(8345, 26),
(8346, 26),
(8347, 24),
(8348, 26),
(8349, 26),
(8350, 24),
(8352, 26),
(8353, 24),
(8354, 26),
(8355, 26),
(8356, 24),
(8357, 26),
(8358, 26),
(8359, 24),
(8361, 26),
(8362, 24),
(8363, 26),
(8364, 26),
(8365, 24),
(8366, 26),
(8367, 26),
(8368, 24),
(8370, 26),
(8371, 24),
(8372, 26),
(8373, 26),
(8374, 24),
(8375, 26),
(8376, 26),
(8377, 24),
(8379, 26),
(8380, 24),
(8381, 26),
(8382, 25),
(8383, 26),
(8384, 24),
(8385, 26),
(8386, 26),
(8387, 24),
(8388, 26),
(8389, 26),
(8390, 24),
(8392, 26),
(8393, 24),
(8394, 26),
(8395, 26),
(8396, 24),
(8397, 26),
(8398, 26),
(8399, 24),
(8401, 26),
(8402, 24),
(8403, 26),
(8404, 26),
(8405, 24),
(8406, 26),
(8407, 26),
(8408, 24),
(8410, 26),
(8411, 24),
(8412, 26),
(8413, 26),
(8414, 24),
(8415, 26),
(8416, 26),
(8417, 24),
(8419, 26),
(8420, 24),
(8421, 26),
(8422, 25),
(8423, 26),
(8424, 26),
(8425, 24),
(8426, 26),
(8427, 26),
(8428, 24),
(8429, 26),
(8430, 26),
(8431, 24),
(8433, 26),
(8434, 24),
(8435, 26),
(8436, 26),
(8437, 24),
(8438, 26),
(8439, 26),
(8440, 24),
(8442, 26),
(8443, 24),
(8444, 26),
(8445, 26),
(8446, 24),
(8447, 26),
(8448, 26),
(8449, 24),
(8451, 26),
(8452, 24),
(8453, 26),
(8454, 26),
(8455, 24),
(8456, 26),
(8457, 26),
(8458, 24),
(8460, 26),
(8461, 24),
(8462, 26),
(8463, 25),
(8464, 26),
(8465, 24),
(8466, 26),
(8467, 26),
(8468, 24),
(8469, 26),
(8470, 26),
(8471, 24),
(8473, 26),
(8474, 24),
(8475, 26),
(8476, 26),
(8477, 24),
(8478, 26),
(8479, 26),
(8480, 24),
(8482, 26),
(8483, 24),
(8484, 26),
(8485, 26),
(8486, 24),
(8487, 26),
(8488, 26),
(8489, 24),
(8491, 26),
(8492, 24),
(8493, 26),
(8494, 26),
(8495, 24),
(8496, 26),
(8497, 26),
(8498, 24),
(8500, 26),
(8501, 24),
(8502, 26),
(8503, 25),
(8504, 26),
(8505, 26),
(8506, 24),
(8507, 26),
(8508, 26),
(8509, 24),
(8510, 26),
(8511, 26),
(8512, 24),
(8514, 26),
(8515, 24),
(8516, 26),
(8517, 26),
(8518, 24),
(8519, 26),
(8520, 26),
(8521, 24),
(8523, 26),
(8524, 24),
(8525, 26),
(8526, 26),
(8527, 24),
(8528, 26),
(8529, 26),
(8530, 24),
(8532, 26),
(8533, 24),
(8534, 26),
(8535, 26),
(8536, 24),
(8537, 26),
(8538, 26),
(8539, 24),
(8541, 26),
(8542, 24),
(8543, 26),
(8544, 25),
(8545, 26),
(8546, 24),
(8547, 26),
(8548, 26),
(8549, 24),
(8550, 26),
(8551, 26),
(8552, 24),
(8554, 26),
(8555, 24),
(8556, 26),
(8557, 26),
(8558, 24),
(8559, 26),
(8560, 26),
(8561, 24),
(8563, 26),
(8564, 24),
(8565, 26),
(8566, 26),
(8567, 24),
(8568, 26),
(8569, 26),
(8570, 24),
(8572, 26),
(8573, 24),
(8574, 26),
(8575, 26),
(8576, 24),
(8577, 26),
(8578, 26),
(8579, 24),
(8581, 26),
(8582, 24),
(8583, 26),
(8584, 25),
(8585, 26),
(8586, 26),
(8587, 24),
(8588, 26),
(8589, 26),
(8590, 24),
(8591, 26),
(8592, 26),
(8593, 24),
(8595, 26),
(8596, 24),
(8597, 26),
(8598, 26),
(8599, 24),
(8600, 26),
(8601, 26),
(8602, 24),
(8604, 26),
(8605, 24),
(8606, 26),
(8607, 26),
(8608, 24),
(8609, 26),
(8610, 26),
(8611, 24),
(8613, 26),
(8614, 24),
(8615, 26),
(8616, 26),
(8617, 24),
(8618, 26),
(8619, 26),
(8620, 24),
(8622, 26),
(8623, 24),
(8624, 26),
(8625, 25),
(8626, 26),
(8627, 24),
(8628, 26),
(8629, 26),
(8630, 24),
(8631, 26),
(8632, 26),
(8633, 24),
(8635, 26),
(8636, 24),
(8637, 26),
(8638, 26),
(8639, 24),
(8640, 26),
(8641, 26),
(8642, 24),
(8644, 26),
(8645, 24),
(8646, 26),
(8647, 26),
(8648, 24),
(8649, 26),
(8650, 26),
(8651, 24),
(8653, 26),
(8654, 24),
(8655, 26),
(8656, 26),
(8657, 24),
(8658, 26),
(8659, 26),
(8660, 24),
(8662, 26),
(8663, 24),
(8664, 26),
(8665, 25),
(8666, 26),
(8667, 26),
(8668, 24),
(8669, 26),
(8670, 26),
(8671, 24),
(8672, 26),
(8673, 26),
(8674, 24),
(8676, 26),
(8677, 24),
(8678, 26),
(8679, 26),
(8680, 24),
(8681, 26),
(8682, 26),
(8683, 24),
(8685, 26),
(8686, 24),
(8687, 26),
(8688, 26),
(8689, 24),
(8690, 26),
(8691, 26),
(8692, 24),
(8694, 26),
(8695, 24),
(8696, 26),
(8697, 26),
(8698, 24),
(8699, 26),
(8700, 26),
(8701, 24),
(8703, 26),
(8704, 24),
(8705, 26),
(8706, 25),
(8707, 26),
(8708, 24),
(8709, 26),
(8710, 26),
(8711, 24),
(8712, 26),
(8713, 26),
(8714, 24),
(8716, 26),
(8717, 24),
(8718, 26),
(8719, 26),
(8720, 24),
(8721, 26),
(8722, 26),
(8723, 24),
(8725, 26),
(8726, 24),
(8727, 26),
(8728, 26),
(8729, 24),
(8730, 26),
(8731, 26),
(8732, 24),
(8734, 26),
(8735, 24),
(8736, 26),
(8737, 26),
(8738, 24),
(8739, 26),
(8740, 26),
(8741, 24),
(8743, 26),
(8744, 24),
(8745, 26),
(8746, 25),
(8747, 26),
(8748, 26),
(8749, 24),
(8750, 26),
(8751, 26),
(8752, 24),
(8753, 26),
(8754, 26),
(8755, 24),
(8757, 26),
(8758, 24),
(8759, 26),
(8760, 26),
(8761, 24),
(8762, 26),
(8763, 26),
(8764, 24),
(8766, 26),
(8767, 24),
(8768, 26),
(8769, 26),
(8770, 24),
(8771, 26),
(8772, 26),
(8773, 24),
(8775, 26),
(8776, 24),
(8777, 26),
(8778, 26),
(8779, 24),
(8780, 26),
(8781, 26),
(8782, 24),
(8784, 26),
(8785, 24),
(8786, 26),
(8787, 25),
(8788, 26),
(8789, 24),
(8790, 26),
(8791, 26),
(8792, 24),
(8793, 26),
(8794, 26),
(8795, 24),
(8797, 26),
(8798, 24),
(8799, 26),
(8800, 26),
(8801, 24),
(8802, 26),
(8803, 26),
(8804, 24),
(8806, 26),
(8807, 24),
(8808, 26),
(8809, 26),
(8810, 24),
(8811, 26),
(8812, 26),
(8813, 24),
(8815, 26),
(8816, 24),
(8817, 26),
(8818, 26),
(8819, 24),
(8820, 26),
(8821, 26),
(8822, 24),
(8824, 26),
(8825, 24),
(8826, 26),
(8827, 25),
(8828, 26),
(8829, 26),
(8830, 24),
(8831, 26),
(8832, 26),
(8833, 24),
(8834, 26),
(8835, 26),
(8836, 24),
(8838, 26),
(8839, 24),
(8840, 26),
(8841, 26),
(8842, 24),
(8843, 26),
(8844, 26),
(8845, 24),
(8847, 26),
(8848, 24),
(8849, 26),
(8850, 26),
(8851, 24),
(8852, 26),
(8853, 26),
(8854, 24),
(8856, 26),
(8857, 24),
(8858, 26),
(8859, 26),
(8860, 24),
(8861, 26),
(8862, 26),
(8863, 24),
(8865, 26),
(8866, 24),
(8867, 26),
(8868, 25),
(8869, 26),
(8870, 24),
(8871, 26),
(8872, 26),
(8873, 24),
(8874, 26),
(8875, 26),
(8876, 24),
(8878, 26),
(8879, 24),
(8880, 26),
(8881, 26),
(8882, 24),
(8883, 26),
(8884, 26),
(8885, 24),
(8887, 26),
(8888, 24),
(8889, 26),
(8890, 26),
(8891, 24),
(8892, 26),
(8893, 26),
(8894, 24),
(8896, 26),
(8897, 24),
(8898, 26),
(8899, 26),
(8900, 24),
(8901, 26),
(8902, 26),
(8903, 24),
(8905, 26),
(8906, 24),
(8907, 26),
(8908, 25),
(8909, 26);

-- --------------------------------------------------------

--
-- Table structure for table `Medicalform`
--

CREATE TABLE `Medicalform` (
  `Formdata` longtext DEFAULT NULL,
  `MedicalformID` int(11) NOT NULL,
  `DietarycommentID` int(11) DEFAULT NULL,
  `HealthcommentID` int(11) DEFAULT NULL,
  `InscriptionID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Medicalform`
--

INSERT INTO `Medicalform` (`Formdata`, `MedicalformID`, `DietarycommentID`, `HealthcommentID`, `InscriptionID`) VALUES
('{\"text\":{\"childFullName\":\"youssef kammoun\",\"birthDatePlace\":\"2023-04-06\",\"nationality\":\"\\u062a\\u0648\\u0646\\u0633\\u064a\\u0629\",\"address\":\"afran\",\"institutionStudyDuration\":null,\"kinshipDetails\":null,\"fatherName\":\"amir\",\"fatherBirthYear\":\"1996\",\"fatherJob\":\"doxotor\",\"motherName\":\"mariam\",\"motherBirthYear\":null,\"motherJob\":null,\"siblingsAliveBoys\":null,\"siblingsAliveGirls\":null,\"siblingsDeceasedBoys\":null,\"siblingsDeceasedGirls\":null,\"childOrder\":null,\"absenceFromStudy\":null,\"roomsCount\":null,\"healthSupervisingStructure\":null,\"familyDoctor\":null,\"pregnancyHealthDetails\":null,\"deliveryDetails\":null,\"healthAtBirthDetails\":null,\"malformationsDetails\":null,\"diseaseOtherDetails\":null,\"healthConditionOtherDetails\":null,\"hospitalizationDetails\":null,\"surgeriesDetails\":null,\"hospitalAddress\":null,\"allergyDetails\":null,\"medicationDetails\":null,\"treatmentDetails\":null,\"socialAdditionalInfo\":\"\\u0639\\u062f\\u0645 \\u0622\\u0643\\u0644 \\u0627\\u0644\\u0633\\u0643\\u0631\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true,\"family_diabetes\":true,\"family_obesity\":false},\"singleChoice\":{\"social_position_siblings\":\"\\u0648\\u062d\\u064a\\u062f\",\"social_lives_with\":\"\\u0643\\u0644\\u0627 \\u0627\\u0644\\u0648\\u0627\\u0644\\u062f\\u064a\\u0646\",\"social_family_relation\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\",\"social_eating\":\"\\u062c\\u064a\\u062f\",\"social_sleep\":\"\\u062c\\u064a\\u062f\",\"social_time_space\":\"\\u0637\\u0628\\u064a\\u0639\\u064a\",\"motherPregnancyHealth\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\",\"birthPlace\":\"\\u0627\\u0644\\u0645\\u0633\\u062a\\u0634\\u0641\\u0649\",\"birthTiming\":\"\\u0641\\u064a \\u0623\\u0648\\u0627\\u0646\\u0647\\u0627\",\"deliveryType\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\",\"healthAtBirth\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\"},\"multiChoice\":{\"previousEnrollment\":[\"\\u0644\\u0627\"],\"waterSource\":[\"\\u0645\\u0627\\u0621 \\u0645\\u0639\\u0644\\u0628\"],\"diseases\":[],\"diseases2\":[\"\\u0645\\u0631\\u0636 \\u0627\\u0644\\u0633\\u0643\\u0631\\u064a\"],\"social_behavior\":[]},\"updatedAt\":\"2026-04-06T20:15:14.686684\"}', 121, 184, 183, 121),
('{\"text\":{\"childFullName\":\"marwen kammmoun\",\"birthDatePlace\":\"2023-04-06\",\"nationality\":\"\\u062a\\u0648\\u0646\\u0633\\u064a\\u0629\",\"address\":\"gtemda\",\"institutionStudyDuration\":\"t\",\"kinshipDetails\":null,\"fatherName\":null,\"fatherBirthYear\":null,\"fatherJob\":null,\"motherName\":null,\"motherBirthYear\":null,\"motherJob\":null,\"siblingsAliveBoys\":null,\"siblingsAliveGirls\":null,\"siblingsDeceasedBoys\":null,\"siblingsDeceasedGirls\":null,\"childOrder\":null,\"absenceFromStudy\":null,\"roomsCount\":null,\"healthSupervisingStructure\":null,\"familyDoctor\":null,\"pregnancyHealthDetails\":null,\"deliveryDetails\":null,\"healthAtBirthDetails\":null,\"malformationsDetails\":null,\"diseaseOtherDetails\":null,\"healthConditionOtherDetails\":null,\"hospitalizationDetails\":null,\"surgeriesDetails\":null,\"hospitalAddress\":null,\"allergyDetails\":null,\"medicationDetails\":null,\"treatmentDetails\":null,\"socialAdditionalInfo\":null},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"\\u0648\\u062d\\u064a\\u062f\",\"social_lives_with\":\"\\u0643\\u0644\\u0627 \\u0627\\u0644\\u0648\\u0627\\u0644\\u062f\\u064a\\u0646\",\"social_family_relation\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\",\"social_eating\":\"\\u062c\\u064a\\u062f\",\"social_sleep\":\"\\u062c\\u064a\\u062f\",\"social_time_space\":\"\\u0637\\u0628\\u064a\\u0639\\u064a\",\"motherPregnancyHealth\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\",\"birthPlace\":\"\\u0627\\u0644\\u0645\\u0633\\u062a\\u0634\\u0641\\u0649\",\"birthTiming\":\"\\u0641\\u064a \\u0623\\u0648\\u0627\\u0646\\u0647\\u0627\",\"deliveryType\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\",\"healthAtBirth\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\"},\"multiChoice\":{\"previousEnrollment\":[\"\\u0628\\u0631\\u0648\\u0636\\u0629 \\u0623\\u062e\\u0631\\u0649\"],\"waterSource\":[\"\\u0645\\u0627\\u0621 \\u0645\\u0639\\u0644\\u0628\"],\"diseases\":[],\"diseases2\":[],\"social_behavior\":[]},\"updatedAt\":\"2026-04-06T20:24:08.256964\"}', 122, 186, 185, 122),
('{\"text\":{\"childFullName\":\"omar kammoun\",\"birthDatePlace\":\"2023-04-06\",\"nationality\":\"\\u062a\\u0648\\u0646\\u0633\\u064a\\u0629\",\"address\":\"afran\",\"institutionStudyDuration\":null,\"kinshipDetails\":null,\"fatherName\":null,\"fatherBirthYear\":null,\"fatherJob\":null,\"motherName\":null,\"motherBirthYear\":null,\"motherJob\":null,\"siblingsAliveBoys\":null,\"siblingsAliveGirls\":null,\"siblingsDeceasedBoys\":null,\"siblingsDeceasedGirls\":null,\"childOrder\":null,\"absenceFromStudy\":null,\"roomsCount\":null,\"healthSupervisingStructure\":null,\"familyDoctor\":null,\"pregnancyHealthDetails\":null,\"deliveryDetails\":null,\"healthAtBirthDetails\":null,\"malformationsDetails\":null,\"diseaseOtherDetails\":null,\"healthConditionOtherDetails\":null,\"hospitalizationDetails\":null,\"surgeriesDetails\":null,\"hospitalAddress\":null,\"allergyDetails\":null,\"medicationDetails\":null,\"treatmentDetails\":null,\"socialAdditionalInfo\":null},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"\\u0648\\u062d\\u064a\\u062f\",\"social_lives_with\":\"\\u0643\\u0644\\u0627 \\u0627\\u0644\\u0648\\u0627\\u0644\\u062f\\u064a\\u0646\",\"social_family_relation\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\",\"social_eating\":\"\\u062c\\u064a\\u062f\",\"social_sleep\":\"\\u062c\\u064a\\u062f\",\"social_time_space\":\"\\u0637\\u0628\\u064a\\u0639\\u064a\",\"motherPregnancyHealth\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\",\"birthPlace\":\"\\u0627\\u0644\\u0645\\u0633\\u062a\\u0634\\u0641\\u0649\",\"birthTiming\":\"\\u0641\\u064a \\u0623\\u0648\\u0627\\u0646\\u0647\\u0627\",\"deliveryType\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\",\"healthAtBirth\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\"},\"multiChoice\":{\"previousEnrollment\":[\"\\u0644\\u0627\"],\"waterSource\":[\"\\u0645\\u0627\\u0621 \\u0645\\u0639\\u0644\\u0628\"],\"diseases\":[],\"diseases2\":[],\"social_behavior\":[]},\"updatedAt\":\"2026-04-06T23:23:40.831970\"}', 126, 185, 184, 145),
('{\"text\":{\"childFullName\":\"ismail kammoun\",\"birthDatePlace\":\"2023-04-07\",\"nationality\":\"\\u062a\\u0648\\u0646\\u0633\\u064a\\u0629\",\"address\":\"afran\",\"institutionStudyDuration\":null,\"kinshipDetails\":null,\"fatherName\":null,\"fatherBirthYear\":null,\"fatherJob\":null,\"motherName\":null,\"motherBirthYear\":null,\"motherJob\":null,\"siblingsAliveBoys\":null,\"siblingsAliveGirls\":null,\"siblingsDeceasedBoys\":null,\"siblingsDeceasedGirls\":null,\"childOrder\":null,\"absenceFromStudy\":null,\"roomsCount\":null,\"healthSupervisingStructure\":null,\"familyDoctor\":null,\"pregnancyHealthDetails\":null,\"deliveryDetails\":null,\"healthAtBirthDetails\":null,\"malformationsDetails\":null,\"diseaseOtherDetails\":null,\"healthConditionOtherDetails\":null,\"hospitalizationDetails\":null,\"surgeriesDetails\":null,\"hospitalAddress\":null,\"allergyDetails\":null,\"medicationDetails\":null,\"treatmentDetails\":null,\"socialAdditionalInfo\":null},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"\\u0648\\u062d\\u064a\\u062f\",\"social_lives_with\":\"\\u0643\\u0644\\u0627 \\u0627\\u0644\\u0648\\u0627\\u0644\\u062f\\u064a\\u0646\",\"social_family_relation\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\",\"social_eating\":\"\\u062c\\u064a\\u062f\",\"social_sleep\":\"\\u062c\\u064a\\u062f\",\"social_time_space\":\"\\u0637\\u0628\\u064a\\u0639\\u064a\",\"motherPregnancyHealth\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\",\"birthPlace\":\"\\u0627\\u0644\\u0645\\u0633\\u062a\\u0634\\u0641\\u0649\",\"birthTiming\":\"\\u0641\\u064a \\u0623\\u0648\\u0627\\u0646\\u0647\\u0627\",\"deliveryType\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\",\"healthAtBirth\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\"},\"multiChoice\":{\"previousEnrollment\":[\"\\u0644\\u0627\"],\"waterSource\":[\"\\u0645\\u0627\\u0621 \\u0645\\u0639\\u0644\\u0628\"],\"diseases\":[],\"diseases2\":[],\"social_behavior\":[]},\"updatedAt\":\"2026-04-07T14:36:04.071589\"}', 127, 187, 186, 147),
('{\"text\":{\"childFullName\":\"Adam Trabelsi\",\"address\":\"Rue de Marseille, Tunis\",\"birthDatePlace\":\"2022-04-15\",\"nationality\":\"\\u062a\\u0648\\u0646\\u0633\\u064a\\u0629\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"\\u0648\\u062d\\u064a\\u062f\",\"social_lives_with\":\"\\u0643\\u0644\\u0627 \\u0627\\u0644\\u0648\\u0627\\u0644\\u062f\\u064a\\u0646\",\"social_family_relation\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\",\"social_eating\":\"\\u062c\\u064a\\u062f\",\"social_sleep\":\"\\u062c\\u064a\\u062f\",\"social_time_space\":\"\\u0637\\u0628\\u064a\\u0639\\u064a\",\"motherPregnancyHealth\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\",\"birthPlace\":\"\\u0627\\u0644\\u0645\\u0633\\u062a\\u0634\\u0641\\u0649\",\"birthTiming\":\"\\u0641\\u064a \\u0623\\u0648\\u0627\\u0646\\u0647\\u0627\"}}', 129, 188, 187, 149),
('{\"text\":{\"childFullName\":\"Ranim BenSalem\",\"address\":\"Rue de Rome Tunis\",\"birthDatePlace\":\"2022-03-14\",\"nationality\":\"Tunisienne\",\"previousSchool\":\"Les Bambins\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"unique\",\"social_lives_with\":\"deux parents\",\"social_family_relation\":\"normale\",\"social_eating\":\"bien\",\"social_sleep\":\"bien\",\"social_time_space\":\"normal\",\"motherPregnancyHealth\":\"normale\",\"birthPlace\":\"hopital\",\"birthTiming\":\"a terme\"}}', 130, 189, 188, 150),
('{\"text\":{\"childFullName\":\"Iyed Gharbi\",\"address\":\"Rue Alger Tunis\",\"birthDatePlace\":\"2021-11-02\",\"nationality\":\"Tunisienne\",\"previousSchool\":\"Jardin Ennasr\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"unique\",\"social_lives_with\":\"deux parents\",\"social_family_relation\":\"normale\",\"social_eating\":\"bien\",\"social_sleep\":\"bien\",\"social_time_space\":\"normal\",\"motherPregnancyHealth\":\"normale\",\"birthPlace\":\"hopital\",\"birthTiming\":\"a terme\"}}', 131, 190, 189, 151),
('{\"text\":{\"childFullName\":\"Syrine Zouari\",\"address\":\"Rue Palestine Tunis\",\"birthDatePlace\":\"2022-01-19\",\"nationality\":\"Tunisienne\",\"previousSchool\":\"Kids Land\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"unique\",\"social_lives_with\":\"deux parents\",\"social_family_relation\":\"normale\",\"social_eating\":\"bien\",\"social_sleep\":\"bien\",\"social_time_space\":\"normal\",\"motherPregnancyHealth\":\"normale\",\"birthPlace\":\"hopital\",\"birthTiming\":\"a terme\"}}', 132, 191, 190, 152),
('{\"text\":{\"childFullName\":\"Eya Mrad\",\"address\":\"Avenue Liberte Tunis\",\"birthDatePlace\":\"2021-09-27\",\"nationality\":\"Tunisienne\",\"previousSchool\":\"Jardin du Lac\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"unique\",\"social_lives_with\":\"deux parents\",\"social_family_relation\":\"normale\",\"social_eating\":\"bien\",\"social_sleep\":\"bien\",\"social_time_space\":\"normal\",\"motherPregnancyHealth\":\"normale\",\"birthPlace\":\"hopital\",\"birthTiming\":\"a terme\"}}', 133, 192, 191, 153),
('{\"text\":{\"childFullName\":\"Mohamed Brahmi\",\"address\":\"Rue Syrie Ariana\",\"birthDatePlace\":\"2022-07-08\",\"nationality\":\"Tunisienne\",\"previousSchool\":\"Les Coccinelles\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"unique\",\"social_lives_with\":\"deux parents\",\"social_family_relation\":\"normale\",\"social_eating\":\"bien\",\"social_sleep\":\"bien\",\"social_time_space\":\"normal\",\"motherPregnancyHealth\":\"normale\",\"birthPlace\":\"hopital\",\"birthTiming\":\"a terme\"}}', 134, 193, 192, 154),
('{\"text\":{\"childFullName\":\"Nour Jaziri\",\"address\":\"Avenue Hedi Nouira Ennasr\",\"birthDatePlace\":\"2022-02-25\",\"nationality\":\"Tunisienne\",\"previousSchool\":\"Arc en ciel\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"unique\",\"social_lives_with\":\"deux parents\",\"social_family_relation\":\"normale\",\"social_eating\":\"bien\",\"social_sleep\":\"bien\",\"social_time_space\":\"normal\",\"motherPregnancyHealth\":\"normale\",\"birthPlace\":\"hopital\",\"birthTiming\":\"a terme\"}}', 135, 194, 193, 155),
('{\"text\":{\"childFullName\":\"Youssef Cherif\",\"address\":\"Rue Lac Biwa Lac1\",\"birthDatePlace\":\"2021-12-30\",\"nationality\":\"Tunisienne\",\"previousSchool\":\"Happy Kids\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"unique\",\"social_lives_with\":\"deux parents\",\"social_family_relation\":\"normale\",\"social_eating\":\"bien\",\"social_sleep\":\"bien\",\"social_time_space\":\"normal\",\"motherPregnancyHealth\":\"normale\",\"birthPlace\":\"hopital\",\"birthTiming\":\"a terme\"}}', 136, 195, 194, 156),
('{\"text\":{\"childFullName\":\"Meriem Saidi\",\"address\":\"Rue Mongi Slim Sousse\",\"birthDatePlace\":\"2022-06-11\",\"nationality\":\"Tunisienne\",\"previousSchool\":\"Jardin Sousse\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"unique\",\"social_lives_with\":\"deux parents\",\"social_family_relation\":\"normale\",\"social_eating\":\"bien\",\"social_sleep\":\"bien\",\"social_time_space\":\"normal\",\"motherPregnancyHealth\":\"normale\",\"birthPlace\":\"hopital\",\"birthTiming\":\"a terme\"}}', 137, 196, 195, 157),
('{\"text\":{\"childFullName\":\"Anis Tlili\",\"address\":\"Avenue Farhat Hached Nabeul\",\"birthDatePlace\":\"2021-10-06\",\"nationality\":\"Tunisienne\",\"previousSchool\":\"Les Etoiles\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"unique\",\"social_lives_with\":\"deux parents\",\"social_family_relation\":\"normale\",\"social_eating\":\"bien\",\"social_sleep\":\"bien\",\"social_time_space\":\"normal\",\"motherPregnancyHealth\":\"normale\",\"birthPlace\":\"hopital\",\"birthTiming\":\"a terme\"}}', 138, 197, 196, 158),
('{\"text\":{\"childFullName\":\"Leya Hamdi\",\"address\":\"Rue Ibn Khaldoun Bardo\",\"birthDatePlace\":\"2022-08-04\",\"nationality\":\"Tunisienne\",\"previousSchool\":\"Petit Monde\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"unique\",\"social_lives_with\":\"deux parents\",\"social_family_relation\":\"normale\",\"social_eating\":\"bien\",\"social_sleep\":\"bien\",\"social_time_space\":\"normal\",\"motherPregnancyHealth\":\"normale\",\"birthPlace\":\"hopital\",\"birthTiming\":\"a terme\"}}', 139, 198, 197, 159),
('{\"text\":{\"childFullName\":\"Celia Khelifi\",\"address\":\"Rue Marseille Tunis\",\"birthDatePlace\":\"2021-04-12\",\"nationality\":\"Tunisienne\",\"previousSchool\":\"Jardin Carthage\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"unique\",\"social_lives_with\":\"deux parents\",\"social_family_relation\":\"normale\",\"social_eating\":\"bien\",\"social_sleep\":\"bien\",\"social_time_space\":\"normal\",\"motherPregnancyHealth\":\"normale\",\"birthPlace\":\"hopital\",\"birthTiming\":\"a terme\"}}', 140, NULL, NULL, 160),
('{\"text\":{\"childFullName\":\"Rayen BenAmor\",\"address\":\"Avenue Carthage Tunis\",\"birthDatePlace\":\"2021-02-18\",\"nationality\":\"Tunisienne\",\"previousSchool\":\"Les Dauphins\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"unique\",\"social_lives_with\":\"deux parents\",\"social_family_relation\":\"normale\",\"social_eating\":\"bien\",\"social_sleep\":\"bien\",\"social_time_space\":\"normal\",\"motherPregnancyHealth\":\"normale\",\"birthPlace\":\"hopital\",\"birthTiming\":\"a terme\"}}', 141, NULL, NULL, 161),
('{\"text\":{\"childFullName\":\"Malek Sfar\",\"address\":\"Rue Espagne Tunis\",\"birthDatePlace\":\"2020-12-21\",\"nationality\":\"Tunisienne\",\"previousSchool\":\"Jardin Jasmin\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"unique\",\"social_lives_with\":\"deux parents\",\"social_family_relation\":\"normale\",\"social_eating\":\"bien\",\"social_sleep\":\"bien\",\"social_time_space\":\"normal\",\"motherPregnancyHealth\":\"normale\",\"birthPlace\":\"hopital\",\"birthTiming\":\"a terme\"}}', 142, NULL, NULL, 162),
('{\"text\":{\"childFullName\":\"Lina Dridi\",\"address\":\"Rue Lac Victoria Lac2\",\"birthDatePlace\":\"2021-05-09\",\"nationality\":\"Tunisienne\",\"previousSchool\":\"Happy Garden\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"unique\",\"social_lives_with\":\"deux parents\",\"social_family_relation\":\"normale\",\"social_eating\":\"bien\",\"social_sleep\":\"bien\",\"social_time_space\":\"normal\",\"motherPregnancyHealth\":\"normale\",\"birthPlace\":\"hopital\",\"birthTiming\":\"a terme\"}}', 143, NULL, NULL, 163),
('{\"text\":{\"childFullName\":\"Salah Miled\",\"address\":\"Avenue Taieb Mhiri Sfax\",\"birthDatePlace\":\"2021-01-30\",\"nationality\":\"Tunisienne\",\"previousSchool\":\"Petit Prince\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"unique\",\"social_lives_with\":\"deux parents\",\"social_family_relation\":\"normale\",\"social_eating\":\"bien\",\"social_sleep\":\"bien\",\"social_time_space\":\"normal\",\"motherPregnancyHealth\":\"normale\",\"birthPlace\":\"hopital\",\"birthTiming\":\"a terme\"}}', 144, NULL, NULL, 164),
('{\"text\":{\"childFullName\":\"Maya Ghannouchi\",\"address\":\"Rue 2 Mars Ariana\",\"birthDatePlace\":\"2021-03-11\",\"nationality\":\"Tunisienne\",\"previousSchool\":\"Jardin Noor\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"unique\",\"social_lives_with\":\"deux parents\",\"social_family_relation\":\"normale\",\"social_eating\":\"bien\",\"social_sleep\":\"bien\",\"social_time_space\":\"normal\",\"motherPregnancyHealth\":\"normale\",\"birthPlace\":\"hopital\",\"birthTiming\":\"a terme\"}}', 145, NULL, NULL, 165),
('{\"text\":{\"childFullName\":\"Aymen Majri\",\"address\":\"Rue Kairouan Monastir\",\"birthDatePlace\":\"2020-11-15\",\"nationality\":\"Tunisienne\",\"previousSchool\":\"Kids House\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"unique\",\"social_lives_with\":\"deux parents\",\"social_family_relation\":\"normale\",\"social_eating\":\"bien\",\"social_sleep\":\"bien\",\"social_time_space\":\"normal\",\"motherPregnancyHealth\":\"normale\",\"birthPlace\":\"hopital\",\"birthTiming\":\"a terme\"}}', 146, NULL, NULL, 166),
('{\"text\":{\"childFullName\":\"Jana Boussetta\",\"address\":\"Avenue Bourguiba Bizerte\",\"birthDatePlace\":\"2021-06-03\",\"nationality\":\"Tunisienne\",\"previousSchool\":\"Jardin Marine\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"unique\",\"social_lives_with\":\"deux parents\",\"social_family_relation\":\"normale\",\"social_eating\":\"bien\",\"social_sleep\":\"bien\",\"social_time_space\":\"normal\",\"motherPregnancyHealth\":\"normale\",\"birthPlace\":\"hopital\",\"birthTiming\":\"a terme\"}}', 147, 199, 198, 167),
('{\"text\":{\"childFullName\":\"Adam Haddad\",\"address\":\"Rue Ibn Sina Sousse\",\"birthDatePlace\":\"2021-07-17\",\"nationality\":\"Tunisienne\",\"previousSchool\":\"Green Kids\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"unique\",\"social_lives_with\":\"deux parents\",\"social_family_relation\":\"normale\",\"social_eating\":\"bien\",\"social_sleep\":\"bien\",\"social_time_space\":\"normal\",\"motherPregnancyHealth\":\"normale\",\"birthPlace\":\"hopital\",\"birthTiming\":\"a terme\"}}', 148, NULL, NULL, 168),
('{\"text\":{\"childFullName\":\"Yara Toumi\",\"address\":\"Avenue Habib Thameur Tunis\",\"birthDatePlace\":\"2021-08-26\",\"nationality\":\"Tunisienne\",\"previousSchool\":\"Jardin Venus\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"unique\",\"social_lives_with\":\"deux parents\",\"social_family_relation\":\"normale\",\"social_eating\":\"bien\",\"social_sleep\":\"bien\",\"social_time_space\":\"normal\",\"motherPregnancyHealth\":\"normale\",\"birthPlace\":\"hopital\",\"birthTiming\":\"a terme\"}}', 149, 201, 200, 169),
('{\"text\":{\"childFullName\":\"Kenza Abid\",\"address\":\"Rue Athenes Tunis\",\"birthDatePlace\":\"2022-09-12\",\"nationality\":\"Tunisienne\",\"previousSchool\":\"Jardin Olive\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"unique\",\"social_lives_with\":\"deux parents\",\"social_family_relation\":\"normale\",\"social_eating\":\"bien\",\"social_sleep\":\"bien\",\"social_time_space\":\"normal\",\"motherPregnancyHealth\":\"normale\",\"birthPlace\":\"hopital\",\"birthTiming\":\"a terme\"}}', 150, 205, 204, 170),
('{\"text\":{\"childFullName\":\"Fares Mokni\",\"address\":\"Avenue France Tunis\",\"birthDatePlace\":\"2022-10-05\",\"nationality\":\"Tunisienne\",\"previousSchool\":\"Kids Club\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"unique\",\"social_lives_with\":\"deux parents\",\"social_family_relation\":\"normale\",\"social_eating\":\"bien\",\"social_sleep\":\"bien\",\"social_time_space\":\"normal\",\"motherPregnancyHealth\":\"normale\",\"birthPlace\":\"hopital\",\"birthTiming\":\"a terme\"}}', 151, NULL, NULL, 171),
('{\"text\":{\"childFullName\":\"Misk Bouazizi\",\"address\":\"Rue Turquie Ariana\",\"birthDatePlace\":\"2022-11-16\",\"nationality\":\"Tunisienne\",\"previousSchool\":\"Les Poussins\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"unique\",\"social_lives_with\":\"deux parents\",\"social_family_relation\":\"normale\",\"social_eating\":\"bien\",\"social_sleep\":\"bien\",\"social_time_space\":\"normal\",\"motherPregnancyHealth\":\"normale\",\"birthPlace\":\"hopital\",\"birthTiming\":\"a terme\"}}', 152, NULL, NULL, 172),
('{\"text\":{\"childFullName\":\"Sami BenHassen\",\"address\":\"Rue Lac Annecy Lac1\",\"birthDatePlace\":\"2022-12-01\",\"nationality\":\"Tunisienne\",\"previousSchool\":\"Jardin Lac\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"unique\",\"social_lives_with\":\"deux parents\",\"social_family_relation\":\"normale\",\"social_eating\":\"bien\",\"social_sleep\":\"bien\",\"social_time_space\":\"normal\",\"motherPregnancyHealth\":\"normale\",\"birthPlace\":\"hopital\",\"birthTiming\":\"a terme\"}}', 153, NULL, NULL, 173),
('{\"text\":{\"childFullName\":\"nour kammoun\",\"birthDatePlace\":\"2023-04-09\",\"nationality\":\"\\u062a\\u0648\\u0646\\u0633\\u064a\\u0629\",\"address\":\"afran\",\"institutionStudyDuration\":null,\"kinshipDetails\":null,\"fatherName\":null,\"fatherBirthYear\":null,\"fatherJob\":null,\"motherName\":null,\"motherBirthYear\":null,\"motherJob\":null,\"siblingsAliveBoys\":null,\"siblingsAliveGirls\":null,\"siblingsDeceasedBoys\":null,\"siblingsDeceasedGirls\":null,\"childOrder\":null,\"absenceFromStudy\":null,\"roomsCount\":null,\"healthSupervisingStructure\":null,\"familyDoctor\":null,\"pregnancyHealthDetails\":null,\"deliveryDetails\":null,\"healthAtBirthDetails\":null,\"malformationsDetails\":null,\"diseaseOtherDetails\":null,\"healthConditionOtherDetails\":null,\"hospitalizationDetails\":null,\"surgeriesDetails\":null,\"hospitalAddress\":null,\"allergyDetails\":null,\"medicationDetails\":null,\"treatmentDetails\":null,\"socialAdditionalInfo\":\"\\u0645\\u0631\\u0636 \\u0627\\u0644\\u0633\\u0643\\u0631\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true,\"family_diabetes\":true},\"singleChoice\":{\"social_position_siblings\":\"\\u0648\\u062d\\u064a\\u062f\",\"social_lives_with\":\"\\u0643\\u0644\\u0627 \\u0627\\u0644\\u0648\\u0627\\u0644\\u062f\\u064a\\u0646\",\"social_family_relation\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\",\"social_eating\":\"\\u062c\\u064a\\u062f\",\"social_sleep\":\"\\u062c\\u064a\\u062f\",\"social_time_space\":\"\\u0637\\u0628\\u064a\\u0639\\u064a\",\"motherPregnancyHealth\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\",\"birthPlace\":\"\\u0627\\u0644\\u0645\\u0633\\u062a\\u0634\\u0641\\u0649\",\"birthTiming\":\"\\u0641\\u064a \\u0623\\u0648\\u0627\\u0646\\u0647\\u0627\",\"deliveryType\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\",\"healthAtBirth\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\"},\"multiChoice\":{\"previousEnrollment\":[\"\\u0644\\u0627\"],\"waterSource\":[\"\\u0645\\u0627\\u0621 \\u0645\\u0639\\u0644\\u0628\"],\"diseases\":[],\"diseases2\":[],\"social_behavior\":[]},\"updatedAt\":\"2026-04-09T00:47:10.776710\"}', 155, 202, 201, 175),
('{\"text\":{\"childFullName\":\"amira masmoudi\",\"birthDatePlace\":\"2023-04-09\",\"nationality\":\"\\u062a\\u0648\\u0646\\u0633\\u064a\\u0629\",\"address\":\"afran\",\"institutionStudyDuration\":null,\"kinshipDetails\":null,\"fatherName\":null,\"fatherBirthYear\":null,\"fatherJob\":null,\"motherName\":null,\"motherBirthYear\":null,\"motherJob\":null,\"siblingsAliveBoys\":null,\"siblingsAliveGirls\":null,\"siblingsDeceasedBoys\":null,\"siblingsDeceasedGirls\":null,\"childOrder\":null,\"absenceFromStudy\":null,\"roomsCount\":null,\"healthSupervisingStructure\":null,\"familyDoctor\":null,\"pregnancyHealthDetails\":null,\"deliveryDetails\":null,\"healthAtBirthDetails\":null,\"malformationsDetails\":null,\"diseaseOtherDetails\":null,\"healthConditionOtherDetails\":null,\"hospitalizationDetails\":null,\"surgeriesDetails\":null,\"hospitalAddress\":null,\"allergyDetails\":null,\"medicationDetails\":null,\"treatmentDetails\":null,\"socialAdditionalInfo\":\"\\u0639\\u062f\\u0645 \\u0622\\u0643\\u0644 \\u0627\\u0644\\u0633\\u0643\\u0631\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true},\"singleChoice\":{\"social_position_siblings\":\"\\u0648\\u062d\\u064a\\u062f\",\"social_lives_with\":\"\\u0643\\u0644\\u0627 \\u0627\\u0644\\u0648\\u0627\\u0644\\u062f\\u064a\\u0646\",\"social_family_relation\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\",\"social_eating\":\"\\u062c\\u064a\\u062f\",\"social_sleep\":\"\\u062c\\u064a\\u062f\",\"social_time_space\":\"\\u0637\\u0628\\u064a\\u0639\\u064a\",\"motherPregnancyHealth\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\",\"birthPlace\":\"\\u0627\\u0644\\u0645\\u0633\\u062a\\u0634\\u0641\\u0649\",\"birthTiming\":\"\\u0641\\u064a \\u0623\\u0648\\u0627\\u0646\\u0647\\u0627\",\"deliveryType\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\",\"healthAtBirth\":\"\\u0639\\u0627\\u062f\\u064a\\u0629\"},\"multiChoice\":{\"previousEnrollment\":[\"\\u0644\\u0627\"],\"waterSource\":[\"\\u0645\\u0627\\u0621 \\u0645\\u0639\\u0644\\u0628\"],\"diseases\":[],\"diseases2\":[\"\\u0645\\u0631\\u0636 \\u0627\\u0644\\u0633\\u0643\\u0631\\u064a\"],\"social_behavior\":[]},\"updatedAt\":\"2026-04-09T12:59:27.153188\"}', 157, 204, 203, 177),
('{\"text\":{\"childFullName\":\"marwen kammoun\",\"birthDatePlace\":\"2023-05-30\",\"nationality\":\"\\u062a\\u0648\\u0646\\u0633\\u064a\\u0629\",\"address\":\"afran\",\"institutionStudyDuration\":null,\"kinshipDetails\":null,\"fatherName\":\"kamel\",\"fatherBirthYear\":\"1996\",\"fatherJob\":\"medecin\",\"motherName\":\"olfa\",\"motherBirthYear\":\"1996\",\"motherJob\":\"medecin\",\"siblingsAliveBoys\":null,\"siblingsAliveGirls\":null,\"siblingsDeceasedBoys\":null,\"siblingsDeceasedGirls\":null,\"childOrder\":null,\"absenceFromStudy\":null,\"roomsCount\":null,\"healthSupervisingStructure\":null,\"familyDoctor\":null,\"pregnancyHealthDetails\":null,\"deliveryDetails\":null,\"healthAtBirthDetails\":null,\"malformationsDetails\":null,\"diseaseOtherDetails\":null,\"healthConditionOtherDetails\":null,\"hospitalizationDetails\":null,\"surgeriesDetails\":null,\"hospitalAddress\":null,\"allergyDetails\":null,\"medicationDetails\":null,\"treatmentDetails\":null,\"socialAdditionalInfo\":\"\\u0645\\u0631\\u0636 \\u0627\\u0644\\u0633\\u0643\\u0631\\u064a\"},\"checks\":{\"fatherAlive\":true,\"motherAlive\":true,\"fatherLivesWithFamily\":true,\"motherLivesWithFamily\":true,\"family_diabetes\":true},\"singleChoice\":{\"social_position_siblings\":\"\\u0648\\u062d\\u064a\\u062f \\/ Unique\",\"motherPregnancyHealth\":\"\\u0639\\u0627\\u062f\\u064a\\u0629 \\/ Normale\",\"birthPlace\":\"\\u0627\\u0644\\u0645\\u0633\\u062a\\u0634\\u0641\\u0649 \\/ H\\u00f4pital\",\"birthTiming\":\"\\u0641\\u064a \\u0623\\u0648\\u0627\\u0646\\u0647\\u0627 \\/ \\u00c0 terme\",\"deliveryType\":\"\\u0639\\u0627\\u062f\\u064a\\u0629 \\/ Normal\",\"healthAtBirth\":\"\\u0639\\u0627\\u062f\\u064a\\u0629 \\/ Normal\",\"social_lives_with\":\"\\u0643\\u0644\\u0627 \\u0627\\u0644\\u0648\\u0627\\u0644\\u062f\\u064a\\u0646 \\/ Ses deux parents\",\"social_family_relation\":\"\\u0639\\u0627\\u062f\\u064a\\u0629 \\/ Normale\",\"social_eating\":\"\\u062c\\u064a\\u062f \\/ Bonne\",\"social_sleep\":\"\\u062c\\u064a\\u062f \\/ Bon\",\"social_time_space\":\"\\u0637\\u0628\\u064a\\u0639\\u064a \\/ Normaux\"},\"multiChoice\":{\"previousEnrollment\":[\"\\u0644\\u0627 \\/ Non\"],\"waterSource\":[\"\\u062d\\u0646\\u0641\\u064a\\u0629 \\u0641\\u064a \\u0627\\u0644\\u0628\\u064a\\u062a \\/ Robinet \\u00e0 la maison\"],\"diseases\":[],\"diseases2\":[\"\\u0645\\u0631\\u0636 \\u0627\\u0644\\u0633\\u0643\\u0631\\u064a \\/ Diab\\u00e8te\"],\"social_behavior\":[\"\\u0639\\u0627\\u062f\\u064a \\/ Normal\"]},\"updatedAt\":\"2026-05-30T18:20:05.489987\"}', 158, NULL, NULL, 178);

--
-- Triggers `Medicalform`
--
DELIMITER $$
CREATE TRIGGER `trg_medicalform_insert` BEFORE INSERT ON `Medicalform` FOR EACH ROW BEGIN
    DECLARE v_child_id INT;
    DECLARE existing_forms INT;
    DECLARE first_insc_id INT;

    -- Note: DietarycommentID and HealthcommentID can naturally be NULL.

    -- Infer ChildID for this inscription via the Payment table
    SELECT `ChildID` INTO v_child_id FROM `Payment` WHERE `InscriptionID` = NEW.InscriptionID LIMIT 1;
    
    IF v_child_id IS NOT NULL THEN
        -- Check if child already has a medical form via ANY inscription
        SELECT COUNT(*) INTO existing_forms
        FROM `Medicalform` mf
        JOIN `Payment` p ON mf.InscriptionID = p.InscriptionID
        WHERE p.ChildID = v_child_id;

        IF existing_forms > 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: This child already has a medical form.';
        END IF;

        -- Identify the first inscription for this child
        SELECT i.`InscriptionID` INTO first_insc_id
        FROM `Inscription` i
        JOIN `Payment` p ON i.InscriptionID = p.InscriptionID
        WHERE p.ChildID = v_child_id
        ORDER BY i.`Date` ASC, i.`InscriptionID` ASC LIMIT 1;

        IF NEW.InscriptionID != first_insc_id THEN
             SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Medical form must be linked to the child s FIRST inscription.';
        END IF;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_medicalform_update` BEFORE UPDATE ON `Medicalform` FOR EACH ROW BEGIN
    -- Note: DietarycommentID and HealthcommentID can naturally be NULL.
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Menuplanning`
--

CREATE TABLE `Menuplanning` (
  `Name` varchar(50) DEFAULT NULL,
  `MenuplanningID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Menuplanning`
--

INSERT INTO `Menuplanning` (`Name`, `MenuplanningID`) VALUES
('Semaine 2025-06-30', 11),
('a', 12),
('Semaine 2025-06-23', 13),
('b', 14),
('Semaine 2025-06-16', 15),
('Semaine 2026-04-06', 16),
('Semaine 2026-04-13', 18),
('Semaine 2026-05-25', 19),
('Semaine 2026-06-01', 20),
('Semaine 2026-06-08', 21);

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '2026_04_05_192542_create_personal_access_tokens_table', 1),
(2, '2026_04_24_234500_add_director_name_parameter', 2);

-- --------------------------------------------------------

--
-- Table structure for table `Notification`
--

CREATE TABLE `Notification` (
  `Data` text DEFAULT NULL,
  `Isread` tinyint(1) DEFAULT NULL,
  `Message` text DEFAULT NULL,
  `Recipientcin` int(11) DEFAULT NULL,
  `Recipientrole` varchar(50) DEFAULT NULL,
  `Title` varchar(500) DEFAULT NULL,
  `Type` varchar(50) DEFAULT NULL,
  `NotificationID` int(11) NOT NULL,
  `EventsID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `Notification`
--

INSERT INTO `Notification` (`Data`, `Isread`, `Message`, `Recipientcin`, `Recipientrole`, `Title`, `Type`, `NotificationID`, `EventsID`) VALUES
('{\"child_id\":138,\"child_name\":\"youssef kammoun\",\"signalement_type\":\"Pleurs\",\"comment\":\"cries a lot\",\"signalement_date\":\"2026-04-06\"}', 0, 'Un signalement de type Pleurs a ete ajoute pour youssef kammoun.', 25825823, 'parent', 'Nouveau signalement', 'signalement', 22, NULL),
('{\"photo_id\":4,\"child_ids\":[\"138\"],\"child_names\":[\"youssef kammoun\"],\"expires_at\":\"2026-04-09\"}', 1, 'Une nouvelle photo a ete partagee pour youssef kammoun.', 25825823, 'parent', 'Nouvelle photo disponible', 'photo', 23, NULL),
('{\"photo_id\":5,\"child_ids\":[\"138\"],\"child_names\":[\"youssef kammoun\"],\"expires_at\":\"2026-04-09\"}', 1, 'Une nouvelle photo a ete partagee pour youssef kammoun.', 25825823, 'parent', 'Nouvelle photo disponible', 'photo', 24, NULL),
('{\"event_id\":9,\"event_name\":\"test 6\",\"event_description\":\"test 6\",\"event_date\":\"2026-04-25\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'test 6 le 2026-04-25 de 09:00 a 11:00.', 25825823, 'parent', 'Evenement scolaire', 'event', 35, 9),
('{\"event_id\":9,\"event_name\":\"test 6\",\"event_description\":\"test 6\",\"event_date\":\"2026-04-25\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'test 6 le 2026-04-25 de 09:00 a 11:00.', 12345678, 'teacher', 'Evenement scolaire', 'event', 36, 9),
('{\"child_id\":138,\"child_name\":\"youssef kammoun\",\"signalement_type\":\"Pleurs\",\"comment\":null,\"signalement_date\":\"2026-04-07\"}', 1, 'Un signalement de type Pleurs a ete ajoute pour youssef kammoun.', 25825823, 'parent', 'Nouveau signalement', 'signalement', 37, NULL),
('{\"event_id\":11,\"event_name\":\"test 7\",\"event_description\":\"test 7\",\"event_date\":\"2026-05-02\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'test 7 le 2026-05-02 de 09:00 a 11:00.', 25825823, 'parent', 'Evenement scolaire', 'event', 38, 11),
('{\"event_id\":11,\"event_name\":\"test 7\",\"event_description\":\"test 7\",\"event_date\":\"2026-05-02\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'test 7 le 2026-05-02 de 09:00 a 11:00.', 75584767, 'parent', 'Evenement scolaire', 'event', 39, 11),
('{\"event_id\":11,\"event_name\":\"test 7\",\"event_description\":\"test 7\",\"event_date\":\"2026-05-02\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'test 7 le 2026-05-02 de 09:00 a 11:00.', 75584768, 'parent', 'Evenement scolaire', 'event', 40, 11),
('{\"event_id\":11,\"event_name\":\"test 7\",\"event_description\":\"test 7\",\"event_date\":\"2026-05-02\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'test 7 le 2026-05-02 de 09:00 a 11:00.', 75584769, 'parent', 'Evenement scolaire', 'event', 41, 11),
('{\"event_id\":11,\"event_name\":\"test 7\",\"event_description\":\"test 7\",\"event_date\":\"2026-05-02\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'test 7 le 2026-05-02 de 09:00 a 11:00.', 75584770, 'parent', 'Evenement scolaire', 'event', 42, 11),
('{\"event_id\":11,\"event_name\":\"test 7\",\"event_description\":\"test 7\",\"event_date\":\"2026-05-02\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'test 7 le 2026-05-02 de 09:00 a 11:00.', 75584771, 'parent', 'Evenement scolaire', 'event', 43, 11),
('{\"event_id\":11,\"event_name\":\"test 7\",\"event_description\":\"test 7\",\"event_date\":\"2026-05-02\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'test 7 le 2026-05-02 de 09:00 a 11:00.', 75584772, 'parent', 'Evenement scolaire', 'event', 44, 11),
('{\"event_id\":11,\"event_name\":\"test 7\",\"event_description\":\"test 7\",\"event_date\":\"2026-05-02\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'test 7 le 2026-05-02 de 09:00 a 11:00.', 75584773, 'parent', 'Evenement scolaire', 'event', 45, 11),
('{\"event_id\":11,\"event_name\":\"test 7\",\"event_description\":\"test 7\",\"event_date\":\"2026-05-02\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'test 7 le 2026-05-02 de 09:00 a 11:00.', 75584774, 'parent', 'Evenement scolaire', 'event', 46, 11),
('{\"event_id\":11,\"event_name\":\"test 7\",\"event_description\":\"test 7\",\"event_date\":\"2026-05-02\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'test 7 le 2026-05-02 de 09:00 a 11:00.', 75584775, 'parent', 'Evenement scolaire', 'event', 47, 11),
('{\"event_id\":11,\"event_name\":\"test 7\",\"event_description\":\"test 7\",\"event_date\":\"2026-05-02\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'test 7 le 2026-05-02 de 09:00 a 11:00.', 75584776, 'parent', 'Evenement scolaire', 'event', 48, 11),
('{\"event_id\":11,\"event_name\":\"test 7\",\"event_description\":\"test 7\",\"event_date\":\"2026-05-02\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'test 7 le 2026-05-02 de 09:00 a 11:00.', 75584777, 'parent', 'Evenement scolaire', 'event', 49, 11),
('{\"event_id\":11,\"event_name\":\"test 7\",\"event_description\":\"test 7\",\"event_date\":\"2026-05-02\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'test 7 le 2026-05-02 de 09:00 a 11:00.', 12345674, 'teacher', 'Evenement scolaire', 'event', 50, 11),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 25825823, 'parent', 'Evenement scolaire', 'event', 51, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 25834697, 'parent', 'Evenement scolaire', 'event', 52, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584767, 'parent', 'Evenement scolaire', 'event', 53, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584768, 'parent', 'Evenement scolaire', 'event', 54, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584769, 'parent', 'Evenement scolaire', 'event', 55, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584770, 'parent', 'Evenement scolaire', 'event', 56, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584771, 'parent', 'Evenement scolaire', 'event', 57, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584772, 'parent', 'Evenement scolaire', 'event', 58, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584773, 'parent', 'Evenement scolaire', 'event', 59, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584774, 'parent', 'Evenement scolaire', 'event', 60, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584775, 'parent', 'Evenement scolaire', 'event', 61, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584776, 'parent', 'Evenement scolaire', 'event', 62, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584777, 'parent', 'Evenement scolaire', 'event', 63, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584778, 'parent', 'Evenement scolaire', 'event', 64, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584779, 'parent', 'Evenement scolaire', 'event', 65, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584780, 'parent', 'Evenement scolaire', 'event', 66, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584781, 'parent', 'Evenement scolaire', 'event', 67, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584782, 'parent', 'Evenement scolaire', 'event', 68, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584783, 'parent', 'Evenement scolaire', 'event', 69, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584784, 'parent', 'Evenement scolaire', 'event', 70, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584785, 'parent', 'Evenement scolaire', 'event', 71, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584786, 'parent', 'Evenement scolaire', 'event', 72, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584787, 'parent', 'Evenement scolaire', 'event', 73, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584788, 'parent', 'Evenement scolaire', 'event', 74, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584789, 'parent', 'Evenement scolaire', 'event', 75, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584790, 'parent', 'Evenement scolaire', 'event', 76, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 0, 'party le 2026-05-30 de 09:00 a 11:00.', 75584791, 'parent', 'Evenement scolaire', 'event', 77, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 1, 'party le 2026-05-30 de 09:00 a 11:00.', 25873695, 'parent', 'Evenement scolaire', 'event', 78, 12),
('{\"event_id\":12,\"event_name\":\"party\",\"event_description\":\"party1\",\"event_date\":\"2026-05-30\",\"event_start_time\":\"09:00\",\"event_end_time\":\"11:00\",\"status\":\"pending\"}', 1, 'party le 2026-05-30 de 09:00 a 11:00.', 12345678, 'teacher', 'Evenement scolaire', 'event', 79, 12),
('{\"photo_id\":6,\"child_ids\":[\"138\",\"185\",\"186\",\"187\",\"188\",\"189\",\"190\",\"191\",\"192\",\"193\",\"194\",\"195\"],\"child_names\":[\"youssef kammoun\"],\"expires_at\":\"2026-04-17\"}', 0, 'Une nouvelle photo a ete partagee pour youssef kammoun.', 25825823, 'parent', 'Nouvelle photo disponible', 'photo', 80, NULL),
('{\"photo_id\":6,\"child_ids\":[\"138\",\"185\",\"186\",\"187\",\"188\",\"189\",\"190\",\"191\",\"192\",\"193\",\"194\",\"195\"],\"child_names\":[\"Adam Trabelsi\"],\"expires_at\":\"2026-04-17\"}', 0, 'Une nouvelle photo a ete partagee pour Adam Trabelsi.', 75584767, 'parent', 'Nouvelle photo disponible', 'photo', 81, NULL),
('{\"photo_id\":6,\"child_ids\":[\"138\",\"185\",\"186\",\"187\",\"188\",\"189\",\"190\",\"191\",\"192\",\"193\",\"194\",\"195\"],\"child_names\":[\"Ranim BenSalem\"],\"expires_at\":\"2026-04-17\"}', 0, 'Une nouvelle photo a ete partagee pour Ranim BenSalem.', 75584768, 'parent', 'Nouvelle photo disponible', 'photo', 82, NULL),
('{\"photo_id\":6,\"child_ids\":[\"138\",\"185\",\"186\",\"187\",\"188\",\"189\",\"190\",\"191\",\"192\",\"193\",\"194\",\"195\"],\"child_names\":[\"Iyed Gharbi\"],\"expires_at\":\"2026-04-17\"}', 0, 'Une nouvelle photo a ete partagee pour Iyed Gharbi.', 75584769, 'parent', 'Nouvelle photo disponible', 'photo', 83, NULL),
('{\"photo_id\":6,\"child_ids\":[\"138\",\"185\",\"186\",\"187\",\"188\",\"189\",\"190\",\"191\",\"192\",\"193\",\"194\",\"195\"],\"child_names\":[\"Syrine Zouari\"],\"expires_at\":\"2026-04-17\"}', 0, 'Une nouvelle photo a ete partagee pour Syrine Zouari.', 75584770, 'parent', 'Nouvelle photo disponible', 'photo', 84, NULL),
('{\"photo_id\":6,\"child_ids\":[\"138\",\"185\",\"186\",\"187\",\"188\",\"189\",\"190\",\"191\",\"192\",\"193\",\"194\",\"195\"],\"child_names\":[\"Eya Mrad\"],\"expires_at\":\"2026-04-17\"}', 0, 'Une nouvelle photo a ete partagee pour Eya Mrad.', 75584771, 'parent', 'Nouvelle photo disponible', 'photo', 85, NULL),
('{\"photo_id\":6,\"child_ids\":[\"138\",\"185\",\"186\",\"187\",\"188\",\"189\",\"190\",\"191\",\"192\",\"193\",\"194\",\"195\"],\"child_names\":[\"Mohamed Brahmi\"],\"expires_at\":\"2026-04-17\"}', 0, 'Une nouvelle photo a ete partagee pour Mohamed Brahmi.', 75584772, 'parent', 'Nouvelle photo disponible', 'photo', 86, NULL),
('{\"photo_id\":6,\"child_ids\":[\"138\",\"185\",\"186\",\"187\",\"188\",\"189\",\"190\",\"191\",\"192\",\"193\",\"194\",\"195\"],\"child_names\":[\"Nour Jaziri\"],\"expires_at\":\"2026-04-17\"}', 0, 'Une nouvelle photo a ete partagee pour Nour Jaziri.', 75584773, 'parent', 'Nouvelle photo disponible', 'photo', 87, NULL),
('{\"photo_id\":6,\"child_ids\":[\"138\",\"185\",\"186\",\"187\",\"188\",\"189\",\"190\",\"191\",\"192\",\"193\",\"194\",\"195\"],\"child_names\":[\"Youssef Cherif\"],\"expires_at\":\"2026-04-17\"}', 0, 'Une nouvelle photo a ete partagee pour Youssef Cherif.', 75584774, 'parent', 'Nouvelle photo disponible', 'photo', 88, NULL),
('{\"photo_id\":6,\"child_ids\":[\"138\",\"185\",\"186\",\"187\",\"188\",\"189\",\"190\",\"191\",\"192\",\"193\",\"194\",\"195\"],\"child_names\":[\"Meriem Saidi\"],\"expires_at\":\"2026-04-17\"}', 0, 'Une nouvelle photo a ete partagee pour Meriem Saidi.', 75584775, 'parent', 'Nouvelle photo disponible', 'photo', 89, NULL),
('{\"photo_id\":6,\"child_ids\":[\"138\",\"185\",\"186\",\"187\",\"188\",\"189\",\"190\",\"191\",\"192\",\"193\",\"194\",\"195\"],\"child_names\":[\"Anis Tlili\"],\"expires_at\":\"2026-04-17\"}', 0, 'Une nouvelle photo a ete partagee pour Anis Tlili.', 75584776, 'parent', 'Nouvelle photo disponible', 'photo', 90, NULL),
('{\"photo_id\":6,\"child_ids\":[\"138\",\"185\",\"186\",\"187\",\"188\",\"189\",\"190\",\"191\",\"192\",\"193\",\"194\",\"195\"],\"child_names\":[\"Leya Hamdi\"],\"expires_at\":\"2026-04-17\"}', 0, 'Une nouvelle photo a ete partagee pour Leya Hamdi.', 75584777, 'parent', 'Nouvelle photo disponible', 'photo', 91, NULL),
('{\"photo_id\":7,\"child_ids\":[\"183\",\"203\",\"211\"],\"child_names\":[\"ismail kammoun\",\"nour kammoun\"],\"expires_at\":\"2026-04-17\"}', 0, 'De nouvelles photos ont ete partagees pour vos enfants.', 25825823, 'parent', 'Nouvelle photo disponible', 'photo', 92, NULL),
('{\"photo_id\":7,\"child_ids\":[\"183\",\"203\",\"211\"],\"child_names\":[\"Jana Boussetta\"],\"expires_at\":\"2026-04-17\"}', 0, 'Une nouvelle photo a ete partagee pour Jana Boussetta.', 75584785, 'parent', 'Nouvelle photo disponible', 'photo', 93, NULL),
('{\"photo_id\":8,\"child_ids\":[\"138\"],\"child_names\":[\"youssef kammoun\"],\"expires_at\":\"2026-06-04\"}', 0, 'Une nouvelle photo a ete partagee pour youssef kammoun.', 25825823, 'parent', 'Nouvelle photo disponible', 'photo', 94, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `NotificationAccount`
--

CREATE TABLE `NotificationAccount` (
  `AccountID` int(11) DEFAULT NULL,
  `NotificationID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `NotificationAccount`
--

INSERT INTO `NotificationAccount` (`AccountID`, `NotificationID`) VALUES
(40000031, 36),
(40000069, 50),
(40000031, 79);

-- --------------------------------------------------------

--
-- Table structure for table `Parameter`
--

CREATE TABLE `Parameter` (
  `Name` varchar(255) DEFAULT NULL,
  `Value` varchar(255) DEFAULT NULL,
  `ParameterID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Parameter`
--

INSERT INTO `Parameter` (`Name`, `Value`, `ParameterID`) VALUES
('Prix de base', '351', 1),
('Mon enfant prend le dejeuner et le gouter', '301', 2),
('Mon enfant prend seulement le dejeuner', '101', 3),
('Mon enfant prend seulement le gouter', '51', 4),
('Mon enfant ne mange pas à l\'école (le parent le récupère puis le ramène)', '0', 5),
('Exceptions dejeuner : verification enfant', 'true', 6),
('ai_enabled', 'true', 7),
('frais_inscription', '22', 8),
('school_name', 'masociete', 9),
('inscriptions_open', 'true', 14),
('contact_email', 'supp1ort@masociete.com', 15),
('contact_phone', '+21612345678', 16),
('contact_whatsapp', '+21612345671', 17),
('contact_facebook', 'https://facebook.com/masociete1', 18),
('contact_instagram', 'https://instagram.com/masociete1', 19),
('kindergarten_address', '123 Rue de la Maternelle, Tunis1', 20),
('company_name', 'Jardin d\'enfants Ma Société1', 21),
('document_signature_path', '/storage/signatures/7xzyl4ggTyRuRVn2wc0m0YRcHp9SnH1pSRJKRzqw.png', 22),
('director_name', 'mahmoud', 23);

-- --------------------------------------------------------

--
-- Table structure for table `Parent`
--

CREATE TABLE `Parent` (
  `ParentID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Parent`
--

INSERT INTO `Parent` (`ParentID`) VALUES
(40000037),
(40000038),
(40000042),
(40000043),
(40000044),
(40000045),
(40000046),
(40000047),
(40000048),
(40000049),
(40000050),
(40000051),
(40000052),
(40000053),
(40000054),
(40000055),
(40000056),
(40000057),
(40000058),
(40000059),
(40000060),
(40000061),
(40000062),
(40000063),
(40000064),
(40000065),
(40000066),
(40000067),
(40000072),
(40000073);

-- --------------------------------------------------------

--
-- Table structure for table `Partialpayment`
--

CREATE TABLE `Partialpayment` (
  `Date` date DEFAULT NULL,
  `Targetmonth` int(11) DEFAULT NULL,
  `Value` double(10,2) DEFAULT NULL,
  `PartialpaymentID` int(11) NOT NULL,
  `PaymentID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Partialpayment`
--

INSERT INTO `Partialpayment` (`Date`, `Targetmonth`, `Value`, `PartialpaymentID`, `PaymentID`) VALUES
('2025-03-01', 12, 50.00, 355, 119),
('2025-04-01', 1, 50.00, 356, 119),
('2025-05-01', 2, 50.00, 357, 119),
('2026-04-06', NULL, 400.00, 358, 124),
('2026-04-06', 3, 50.00, 359, 119),
('2026-04-06', 4, 50.00, 360, 119),
('2026-04-06', 5, 50.00, 361, 119),
('2026-04-07', NULL, 351.00, 362, 126),
('2026-04-07', 9, 40.20, 363, 125),
('2026-04-07', 10, 40.20, 364, 125),
('2026-04-07', 11, 40.20, 365, 125),
('2026-04-07', 12, 40.20, 366, 125),
('2026-04-07', 1, 40.20, 367, 125),
('2026-04-07', 2, 40.20, 368, 125),
('2026-04-07', 3, 40.20, 369, 125),
('2026-04-07', 4, 40.20, 370, 125),
('2026-04-07', NULL, 652.00, 371, 128),
('2026-04-07', 9, 65.20, 372, 146),
('2026-04-07', 10, 65.20, 373, 146),
('2026-04-07', 11, 65.20, 374, 146),
('2026-04-07', 12, 65.20, 375, 146),
('2026-04-07', 1, 65.20, 376, 146),
('2026-04-07', 9, 65.20, 377, 138),
('2026-04-07', 10, 65.20, 378, 138),
('2026-04-07', 11, 65.20, 379, 138),
('2026-04-07', 12, 65.20, 380, 138),
('2026-04-07', 1, 65.20, 381, 138),
('2026-04-07', NULL, 652.00, 382, 135),
('2026-04-07', NULL, 652.00, 383, 131),
('2026-04-09', 2, 65.20, 384, 146),
('2026-04-09', NULL, 652.00, 385, 156),
('2026-04-11', 3, 65.20, 386, 146),
('2026-04-11', 4, 65.20, 387, 146),
('2026-04-11', NULL, 652.00, 388, 133);

-- --------------------------------------------------------

--
-- Table structure for table `Payment`
--

CREATE TABLE `Payment` (
  `Amount` double(10,2) DEFAULT NULL,
  `Date` date DEFAULT NULL,
  `PaymentID` int(11) NOT NULL,
  `InscriptionID` int(11) DEFAULT NULL,
  `ChildID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Payment`
--

INSERT INTO `Payment` (`Amount`, `Date`, `PaymentID`, `InscriptionID`, `ChildID`) VALUES
(350.00, '2024-08-31', 119, 121, 138),
(350.00, '2024-08-31', 120, 122, 139),
(400.00, '2026-04-06', 124, 145, 182),
(402.00, '2026-04-07', 125, 146, 138),
(351.00, '2026-04-07', 126, 147, 183),
(652.00, '2026-04-07', 128, 149, 185),
(652.00, '2026-04-07', 129, 150, 186),
(652.00, '2026-04-07', 130, 151, 187),
(652.00, '2026-04-07', 131, 152, 188),
(652.00, '2026-04-07', 132, 153, 189),
(652.00, '2026-04-07', 133, 154, 190),
(652.00, '2026-04-07', 134, 155, 191),
(652.00, '2026-04-07', 135, 156, 192),
(652.00, '2026-04-07', 136, 157, 193),
(652.00, '2026-04-07', 137, 158, 194),
(652.00, '2026-04-07', 138, 159, 195),
(652.00, '2026-04-07', 139, 160, 196),
(652.00, '2026-04-07', 140, 161, 197),
(652.00, '2026-04-07', 141, 162, 198),
(652.00, '2026-04-07', 142, 163, 199),
(652.00, '2026-04-07', 143, 164, 200),
(652.00, '2026-04-07', 144, 165, 201),
(652.00, '2026-04-07', 145, 166, 202),
(652.00, '2026-04-07', 146, 167, 203),
(652.00, '2026-04-07', 147, 168, 204),
(652.00, '2026-04-07', 148, 169, 205),
(652.00, '2026-04-07', 149, 170, 206),
(652.00, '2026-04-07', 150, 171, 207),
(652.00, '2026-04-07', 151, 172, 208),
(652.00, '2026-04-07', 152, 173, 209),
(652.00, '2026-04-08', 154, 175, 211),
(652.00, '2026-04-09', 156, 177, 213),
(452.00, '2026-05-30', 157, 178, 214);

--
-- Triggers `Payment`
--
DELIMITER $$
CREATE TRIGGER `trg_payment_null_check_insert` BEFORE INSERT ON `Payment` FOR EACH ROW BEGIN
    IF NEW.InscriptionID IS NULL OR NEW.ChildID IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Payment must have both an InscriptionID and a ChildID.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_payment_null_check_update` BEFORE UPDATE ON `Payment` FOR EACH ROW BEGIN
    IF NEW.InscriptionID IS NULL OR NEW.ChildID IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Payment must have both an InscriptionID and a ChildID.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_payment_validate_before_insert` BEFORE INSERT ON `Payment` FOR EACH ROW BEGIN
    IF NEW.Amount IS NULL OR NEW.Amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Payment amount must be strictly greater than 0.';
    END IF;
    IF NEW.Date IS NULL OR NEW.Date > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Payment date cannot be null or in the future.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_payment_validate_before_update` BEFORE UPDATE ON `Payment` FOR EACH ROW BEGIN
    IF NEW.Amount IS NULL OR NEW.Amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Payment amount must be strictly greater than 0.';
    END IF;
    IF NEW.Date IS NULL OR NEW.Date > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Payment date cannot be null or in the future.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Paymentmethod`
--

CREATE TABLE `Paymentmethod` (
  `Name` varchar(50) DEFAULT NULL,
  `PaymentmethodID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Paymentmethod`
--

INSERT INTO `Paymentmethod` (`Name`, `PaymentmethodID`) VALUES
('monthlyPartial', 1),
('oneShot', 2);

-- --------------------------------------------------------

--
-- Table structure for table `Person`
--

CREATE TABLE `Person` (
  `PersonID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Person`
--

INSERT INTO `Person` (`PersonID`) VALUES
(10000000),
(40000032),
(40000033),
(40000034),
(40000035),
(40000036),
(40000037),
(40000038),
(40000040),
(40000042),
(40000043),
(40000044),
(40000045),
(40000046),
(40000047),
(40000048),
(40000049),
(40000050),
(40000051),
(40000052),
(40000053),
(40000054),
(40000055),
(40000056),
(40000057),
(40000058),
(40000059),
(40000060),
(40000061),
(40000062),
(40000063),
(40000064),
(40000065),
(40000066),
(40000067),
(40000068),
(40000069),
(40000070),
(40000072),
(40000073);

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` text NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(31, 'App\\Models\\Account', 40000036, 'mobile-parent', 'aa33c2e826b57b9b3e6c3ab4eb5c5189f4a6cf008aa38ce928e30bac072beba7', '[\"*\"]', '2026-04-06 18:22:45', NULL, '2026-04-06 18:19:55', '2026-04-06 18:22:45'),
(32, 'App\\Models\\Account', 40000037, 'mobile-parent', '47803bd2ef18db89e99877401eb4eefeb25c87dd34454cbcd8521484ac40fe4e', '[\"*\"]', '2026-04-06 18:25:35', NULL, '2026-04-06 18:25:17', '2026-04-06 18:25:35'),
(33, 'App\\Models\\Account', 40000036, 'mobile-parent', 'e159d0fcd3eb70776670a0cd512ad3812a0af690d91240fa75e2129d247afc67', '[\"*\"]', '2026-04-06 19:47:51', NULL, '2026-04-06 18:25:44', '2026-04-06 19:47:51'),
(34, 'App\\Models\\Account', 40000036, 'mobile-parent', '54af8e39ba047f19757f853e32813a8ea44eba065bb9962e717f2bcfc5b521d1', '[\"*\"]', '2026-04-06 20:07:02', NULL, '2026-04-06 19:48:27', '2026-04-06 20:07:02'),
(35, 'App\\Models\\Account', 40000031, 'mobile-teacher', '192d430fae809602823f67d96d2af8e7f7bc2d9163a2ba916d83273aac4d2cd1', '[\"*\"]', '2026-04-06 20:09:19', NULL, '2026-04-06 20:07:21', '2026-04-06 20:09:19'),
(36, 'App\\Models\\Account', 40000036, 'mobile-parent', '9f780fd42bd7cadc8e1e0f650bc7abaf912bfd9eb10ef8b0b575a6ac9b2900b4', '[\"*\"]', '2026-04-06 20:14:46', NULL, '2026-04-06 20:09:54', '2026-04-06 20:14:46'),
(37, 'App\\Models\\Account', 40000031, 'mobile-teacher', 'b2bd634e1ce5bc47a9d84fae849499e1b7de716b38fcd62671277145f7ab9396', '[\"*\"]', '2026-04-06 20:32:21', NULL, '2026-04-06 20:15:00', '2026-04-06 20:32:21'),
(38, 'App\\Models\\Account', 40000036, 'mobile-parent', '5b541734eb0f48356b785a4cc22fdd48b468eabdbc73f1a7599cd5b592a5e988', '[\"*\"]', '2026-04-06 20:38:00', NULL, '2026-04-06 20:32:36', '2026-04-06 20:38:00'),
(39, 'App\\Models\\Account', 40000031, 'mobile-teacher', 'ab6f5cd6d09c7a0661b55713a8d654baf855adfc074d170dcd316e67fbebe0f6', '[\"*\"]', '2026-04-06 20:39:13', NULL, '2026-04-06 20:38:12', '2026-04-06 20:39:13'),
(40, 'App\\Models\\Account', 40000036, 'mobile-parent', '569a26816b174ce07e3f632e6761975de6b0e4940c0903047267f82da8d53c51', '[\"*\"]', '2026-04-06 20:39:47', NULL, '2026-04-06 20:39:23', '2026-04-06 20:39:47'),
(41, 'App\\Models\\Account', 40000031, 'mobile-teacher', '00a693a8fa05e4f1da8b6ee26e506243ab65e7961a19b4606bbb8609b2823cde', '[\"*\"]', '2026-04-06 20:40:47', NULL, '2026-04-06 20:40:01', '2026-04-06 20:40:47'),
(42, 'App\\Models\\Account', 40000036, 'mobile-parent', 'b88ab1b7ba5526b1908b75c97b36869b92b6575d8b623203e0685d59842bc356', '[\"*\"]', '2026-04-06 20:44:49', NULL, '2026-04-06 20:40:58', '2026-04-06 20:44:49'),
(43, 'App\\Models\\Account', 40000031, 'mobile-teacher', '8e07d54d35480e00f0e4c829b489eae701ac35c3ab17dea0d12f282a4539ca21', '[\"*\"]', '2026-04-06 20:45:33', NULL, '2026-04-06 20:45:07', '2026-04-06 20:45:33'),
(44, 'App\\Models\\Account', 40000036, 'mobile-parent', '7358e966878bfc5d679d257bd1e4fa2cae92ff8988d1358acbd9ae8e9df45984', '[\"*\"]', '2026-04-06 20:51:06', NULL, '2026-04-06 20:45:50', '2026-04-06 20:51:06'),
(45, 'App\\Models\\Account', 40000031, 'mobile-teacher', 'aff5f3785e634e18dc42ef0cc3b4b6061008a1ffd059e5447647ccd0068c610e', '[\"*\"]', '2026-04-06 20:51:38', NULL, '2026-04-06 20:51:17', '2026-04-06 20:51:38'),
(46, 'App\\Models\\Account', 40000036, 'mobile-parent', '18b787d61f373aa023cd198a2fd6ff2a1772283368d418c450a1d9874422bcfc', '[\"*\"]', '2026-04-06 20:53:32', NULL, '2026-04-06 20:51:48', '2026-04-06 20:53:32'),
(47, 'App\\Models\\Account', 40000031, 'mobile-teacher', '560f2db7ca6a7091079b6109bff03bcf81d961d921c238b3cbc838d299b5ce4d', '[\"*\"]', '2026-04-06 20:54:04', NULL, '2026-04-06 20:53:43', '2026-04-06 20:54:04'),
(48, 'App\\Models\\Account', 40000031, 'mobile-teacher', '8d1bddf05bfa802e61b6f6de293d38f01981da51cd5f34f79f731fa66c9dde88', '[\"*\"]', '2026-04-06 20:54:44', NULL, '2026-04-06 20:54:44', '2026-04-06 20:54:44'),
(49, 'App\\Models\\Account', 40000036, 'mobile-parent', '2925e6c842ec3a033dfa8415c630f025af167ba9eadbee18f2a316e77ead9e77', '[\"*\"]', '2026-04-06 20:57:26', NULL, '2026-04-06 20:54:56', '2026-04-06 20:57:26'),
(50, 'App\\Models\\Account', 40000031, 'mobile-teacher', 'ac63eee8433cd8c65df1656168fff3cff072ba01b6f84d826dd7d894969c4ef6', '[\"*\"]', '2026-04-06 20:58:04', NULL, '2026-04-06 20:57:38', '2026-04-06 20:58:04'),
(51, 'App\\Models\\Account', 40000036, 'mobile-parent', '655ffa55d8dd2e4adda10289b71e3efb1c41fc025c6ac4e3412a7fe9849c029b', '[\"*\"]', '2026-04-06 20:58:49', NULL, '2026-04-06 20:58:18', '2026-04-06 20:58:49'),
(52, 'App\\Models\\Account', 40000031, 'mobile-teacher', '19d6bdf560eccb3567a6912e3aa2f671f8c59887fb0cb8faf45494c88c727b0a', '[\"*\"]', '2026-04-06 21:00:24', NULL, '2026-04-06 20:59:09', '2026-04-06 21:00:24'),
(53, 'App\\Models\\Account', 40000036, 'mobile-parent', '96f3c64323ee03f888d79c5a7e2baced063ec4ed25cf76d900e085030ac9a83c', '[\"*\"]', '2026-04-06 21:13:59', NULL, '2026-04-06 21:01:04', '2026-04-06 21:13:59'),
(54, 'App\\Models\\Account', 40000036, 'mobile-parent', '1fc50124c700a9b166cc80dd29bb0b07b9a27a680bf4c21542519b11c08b651a', '[\"*\"]', '2026-04-06 21:23:55', NULL, '2026-04-06 21:14:06', '2026-04-06 21:23:55'),
(55, 'App\\Models\\Account', 40000036, 'mobile-parent', '6e36b622cc08b07b411f659b4b5c9fe6f076f36eef25354c38ffc6fbcf1b815e', '[\"*\"]', '2026-04-06 21:25:20', NULL, '2026-04-06 21:24:01', '2026-04-06 21:25:20'),
(56, 'App\\Models\\Account', 40000036, 'mobile-parent', '87dec3903a60dadbe653b0a7b412cf514d1c2f54b81f18f2d2481a68b9aa98c9', '[\"*\"]', '2026-04-06 21:27:35', NULL, '2026-04-06 21:25:28', '2026-04-06 21:27:35'),
(57, 'App\\Models\\Account', 40000031, 'mobile-teacher', 'c757ec3f02441a5fe819a38df2bee1ecdbca150ef618b13783f030fbb88307c5', '[\"*\"]', '2026-04-06 21:44:04', NULL, '2026-04-06 21:32:03', '2026-04-06 21:44:04'),
(58, 'App\\Models\\Account', 40000036, 'mobile-parent', '2f99711bb35b27af5d5c1169a31c04e055824c41ec5f26ec7f9c9023dab2d4e5', '[\"*\"]', '2026-04-06 21:46:26', NULL, '2026-04-06 21:44:25', '2026-04-06 21:46:26'),
(59, 'App\\Models\\Account', 40000031, 'mobile-teacher', '2943bdc931923d40d68ae96909aee8116e1fa07312854a23f51b9b8ff8be269c', '[\"*\"]', '2026-04-07 10:40:45', NULL, '2026-04-07 10:39:10', '2026-04-07 10:40:45'),
(60, 'App\\Models\\Account', 40000031, 'mobile-teacher', '4f979a08a6a803e02d50c71d6cb9425abe440a95b6d2077acc84ddf359c93e3a', '[\"*\"]', '2026-04-07 10:40:59', NULL, '2026-04-07 10:40:56', '2026-04-07 10:40:59'),
(61, 'App\\Models\\Account', 40000036, 'mobile-parent', 'b24e9f47b2ecac32e949ac415b7e818f925deedad6497e46e2403126806953c9', '[\"*\"]', '2026-04-07 10:44:11', NULL, '2026-04-07 10:41:10', '2026-04-07 10:44:11'),
(62, 'App\\Models\\Account', 40000031, 'mobile-teacher', 'bcc7aabc1548e6bfd99eb93971e62d6ea6ef26c61934e44b2f3f9a31b7788c86', '[\"*\"]', '2026-04-07 10:56:12', NULL, '2026-04-07 10:44:22', '2026-04-07 10:56:12'),
(63, 'App\\Models\\Account', 40000031, 'mobile-teacher', '26c72e29d12aeff130d1866d0160813327670109dd05919e761d0d78e0d73d4b', '[\"*\"]', '2026-04-07 10:56:55', NULL, '2026-04-07 10:56:48', '2026-04-07 10:56:55'),
(64, 'App\\Models\\Account', 40000036, 'mobile-parent', '22eb90acab41ce5ef20021aca5709714dc7468df4a8dfa79d0c73138fa27c425', '[\"*\"]', '2026-04-07 11:01:42', NULL, '2026-04-07 10:57:09', '2026-04-07 11:01:42'),
(65, 'App\\Models\\Account', 40000031, 'mobile-teacher', '3def69bdde01bfdb20da40c2c583e341bb11cab2633e5f7eb06605f958398420', '[\"*\"]', '2026-04-07 11:46:57', NULL, '2026-04-07 11:01:56', '2026-04-07 11:46:57'),
(66, 'App\\Models\\Account', 40000031, 'mobile-teacher', '3a06952ac96d36929a3b012ff35d6be3c11b1f3fec87e1fb8231052f5b6efdb6', '[\"*\"]', '2026-04-07 12:11:53', NULL, '2026-04-07 12:11:35', '2026-04-07 12:11:53'),
(67, 'App\\Models\\Account', 40000036, 'mobile-parent', '9f1ad6c6be2ba3a160d6e95fc2ae9cf84bf6a5a5d880d71389fa4ea40f34a84e', '[\"*\"]', '2026-04-07 12:29:26', NULL, '2026-04-07 12:12:06', '2026-04-07 12:29:26'),
(68, 'App\\Models\\Account', 40000036, 'mobile-parent', '255e13e68ff6dd20ff3adc2b47c34c9cf5ae958c18edcc693a1b81577704763b', '[\"*\"]', '2026-04-07 12:34:01', NULL, '2026-04-07 12:29:55', '2026-04-07 12:34:01'),
(69, 'App\\Models\\Account', 40000031, 'mobile-teacher', 'bb927e6e8e363aa17895907a889827dccada53bf75e383d0e058ee962468ed47', '[\"*\"]', '2026-04-07 12:35:04', NULL, '2026-04-07 12:34:13', '2026-04-07 12:35:04'),
(70, 'App\\Models\\Account', 40000036, 'mobile-parent', 'e48c16cf4e229469eee21db36fe793d0c3242f64b07fcb04829c32e2775d5671', '[\"*\"]', '2026-04-07 12:53:22', NULL, '2026-04-07 12:35:13', '2026-04-07 12:53:22'),
(71, 'App\\Models\\Account', 40000031, 'mobile-teacher', 'f22d57e342b1d79e046b062a8071d2626fb9ce3d15806e83fcc728f593c33ef4', '[\"*\"]', '2026-04-07 18:08:21', NULL, '2026-04-07 12:53:35', '2026-04-07 18:08:21'),
(73, 'App\\Models\\Account', 10000000, 'auth-token', '0fade703f88f42b7bd0501af68270a58de755fb933be46e0e4e41091c4bcbad1', '[\"*\"]', '2026-04-07 20:36:35', NULL, '2026-04-07 13:55:00', '2026-04-07 20:36:35'),
(75, 'App\\Models\\Account', 10000000, 'auth-token', 'f46d65256821d82e207af7b810f69b93d2570a1a3f331ff73d96f2991837c4ac', '[\"*\"]', '2026-04-08 23:38:35', NULL, '2026-04-07 15:25:57', '2026-04-08 23:38:35'),
(76, 'App\\Models\\Account', 10000000, 'auth-token', 'daf82d974f9cc3ea17dcc60930564fd06aefbd9f39b3618d0f88dff0b36c956f', '[\"*\"]', '2026-04-07 16:21:50', NULL, '2026-04-07 16:21:49', '2026-04-07 16:21:50'),
(77, 'App\\Models\\Account', 10000000, 'auth-token', '07d241260ae292485c933b1c016e238ccf6bcbbc5127a8cb840d517465f39c50', '[\"*\"]', '2026-04-07 16:26:55', NULL, '2026-04-07 16:23:00', '2026-04-07 16:26:55'),
(78, 'App\\Models\\Account', 40000031, 'mobile-teacher', '4cd9482bc1262378623d626c561a7f3e31bc3a3da250d23fd96a1793a28af5c9', '[\"*\"]', '2026-04-07 17:26:12', NULL, '2026-04-07 17:25:59', '2026-04-07 17:26:12'),
(79, 'App\\Models\\Account', 40000036, 'mobile-parent', 'fe03c01b1e597dd2c495df1e5581e2b99bad8e655215991ce728568be57cbcdd', '[\"*\"]', '2026-04-07 19:56:25', NULL, '2026-04-07 17:26:24', '2026-04-07 19:56:25'),
(80, 'App\\Models\\Account', 40000036, 'mobile-parent', '7aa5193425fb9855d212e45afe234c8d6c7ad733c8aeb36407968202e85260e4', '[\"*\"]', '2026-04-07 18:08:52', NULL, '2026-04-07 18:08:41', '2026-04-07 18:08:52'),
(81, 'App\\Models\\Account', 40000031, 'mobile-teacher', '682ae705b08af6660520f9ef85dc74f444b5019846304ca95808955efae15041', '[\"*\"]', '2026-04-07 18:11:11', NULL, '2026-04-07 18:09:06', '2026-04-07 18:11:11'),
(85, 'App\\Models\\Account', 10000000, 'auth-token', 'add100695d68ca96d426c29502b9ab8b1f0ee8f0e895a2fe87b5a4a11ef0c405', '[\"*\"]', '2026-04-08 22:11:08', NULL, '2026-04-08 22:11:08', '2026-04-08 22:11:08'),
(86, 'App\\Models\\Account', 40000036, 'mobile-parent', '7c60f34f2ce3dda8be024568d16905a19517df7d6de8543dfe063cd201f10171', '[\"*\"]', '2026-04-08 22:52:04', NULL, '2026-04-08 22:46:19', '2026-04-08 22:52:04'),
(87, 'App\\Models\\Account', 40000031, 'mobile-teacher', '1e8427e99c3cfda08e2bd7b464c226f614472494ad208223491f1e37a08ea846', '[\"*\"]', '2026-04-09 10:00:34', NULL, '2026-04-08 22:52:17', '2026-04-09 10:00:34'),
(88, 'App\\Models\\Account', 10000000, 'auth-token', 'cfcc6f8f862088b50936c53e5296c5f260eb2bf8958e8f0b7340d6ff49fee77d', '[\"*\"]', '2026-04-09 10:34:06', NULL, '2026-04-09 10:27:37', '2026-04-09 10:34:06'),
(89, 'App\\Models\\Account', 10000000, 'auth-token', '31e4f3ec953f8e8dbb146bc32a973bf5c440c0c6b7d62a61911170a05298c920', '[\"*\"]', '2026-04-09 16:53:45', NULL, '2026-04-09 10:29:40', '2026-04-09 16:53:45'),
(90, 'App\\Models\\Account', 10000000, 'auth-token', '7c7bd49d472d96ab6a0a146e5c659fdf5593cf764c8d63c7387e3a67b6d2db3a', '[\"*\"]', '2026-04-09 11:53:01', NULL, '2026-04-09 11:53:00', '2026-04-09 11:53:01'),
(91, 'App\\Models\\Account', 10000000, 'auth-token', '0ecf9c36af9926c664fdb2fa78d12e0c17394619a1cb5dcc778e197af6dd2828', '[\"*\"]', '2026-04-09 18:18:43', NULL, '2026-04-09 18:12:33', '2026-04-09 18:18:43'),
(93, 'App\\Models\\Account', 10000000, 'auth-token', '817599759ae2667fadfc7e3f88c34ffa44924aa05073ec6e800f0e8f5d79fc04', '[\"*\"]', '2026-04-10 11:42:34', NULL, '2026-04-10 11:32:44', '2026-04-10 11:42:34'),
(94, 'App\\Models\\Account', 10000000, 'auth-token', '478d99960c96d289ebfba0b00b065afe4c6b1d50a27492fe6ad65211061fe463', '[\"*\"]', NULL, NULL, '2026-04-10 14:52:42', '2026-04-10 14:52:42'),
(95, 'App\\Models\\Account', 10000000, 'auth-token', '5d503803b9b188d29a1f8bbb6692af8f4e8e8d3df86477e762d2a58fcd18f17d', '[\"*\"]', NULL, NULL, '2026-04-10 14:52:43', '2026-04-10 14:52:43'),
(97, 'App\\Models\\Account', 10000000, 'auth-token', 'a826c4e7b3db9f267afb88a0b1f9dbbd7d5610627bc0c701644ba091d811dd74', '[\"*\"]', NULL, NULL, '2026-04-10 14:57:33', '2026-04-10 14:57:33'),
(99, 'App\\Models\\Account', 40000071, 'mobile-parent', '4cfddeb3e08412fdfcf7bc8d10769de5236fdbc631d403852106dcd12b6f9a89', '[\"*\"]', '2026-04-10 15:39:53', NULL, '2026-04-10 15:39:48', '2026-04-10 15:39:53'),
(103, 'App\\Models\\Account', 10000000, 'debug', '85afe61467281519e713d1c918343ad9ce82883a8f408014597f4f6349bf3db8', '[\"*\"]', NULL, NULL, '2026-04-10 17:08:39', '2026-04-10 17:08:39'),
(104, 'App\\Models\\Account', 10000000, 'debug', 'b911387fea8d585236a4301e882a74c62032314dce66dfa41388412dc26d4378', '[\"*\"]', NULL, NULL, '2026-04-10 17:09:18', '2026-04-10 17:09:18'),
(106, 'App\\Models\\Account', 10000000, 'auth-token', 'c1961ef1ac5123370939086bb8a736ec651de4ddc0918002a8d2476d5f3b2eb5', '[\"*\"]', NULL, NULL, '2026-04-10 17:11:44', '2026-04-10 17:11:44'),
(107, 'App\\Models\\Account', 10000000, 'auth-token', '42bc8d61b499e20e75676312207095289a4a063825a36553d08b7db4a81f191f', '[\"*\"]', NULL, NULL, '2026-04-10 17:12:08', '2026-04-10 17:12:08'),
(108, 'App\\Models\\Account', 10000000, 'auth-token', '112ae39113d778fb3d69bbdc5702a28a5c0ed75ba1e2671eafe7861917c0de91', '[\"*\"]', NULL, NULL, '2026-04-10 17:12:36', '2026-04-10 17:12:36'),
(109, 'App\\Models\\Account', 10000000, 'auth-token', '5a8a0eb2b0773ba0742c97d1d157e74406c2503693bee296c4711d1280088995', '[\"*\"]', NULL, NULL, '2026-04-10 17:13:11', '2026-04-10 17:13:11'),
(110, 'App\\Models\\Account', 10000000, 'auth-token', '80de820e1fca11bb28d80f36ec3ffdef151500f40b20f9b8310153f43addf359', '[\"*\"]', '2026-04-10 17:17:59', NULL, '2026-04-10 17:17:59', '2026-04-10 17:17:59'),
(111, 'App\\Models\\Account', 10000000, 'auth-token', '978e2f18eefa82f61211f0abbe005be2abb1232e7525f5b612bd698ba6e29bdc', '[\"*\"]', '2026-04-10 17:21:15', NULL, '2026-04-10 17:20:55', '2026-04-10 17:21:15'),
(112, 'App\\Models\\Account', 10000000, 'auth-token', 'fb4b0a5adf09140829ddd53e7cfef520a51bd07e1aa265f0d80fa57440ad054a', '[\"*\"]', '2026-04-10 17:22:36', NULL, '2026-04-10 17:22:35', '2026-04-10 17:22:36'),
(113, 'App\\Models\\Account', 10000000, 'auth-token', '15309c57b2194fe05f725f929a5247243db08ee0cdd3e2e59111486c9c721f3a', '[\"*\"]', '2026-04-10 17:26:11', NULL, '2026-04-10 17:26:11', '2026-04-10 17:26:11'),
(118, 'App\\Models\\Account', 40000071, 'mobile-parent', 'fb6999d1a39f0b2fbba2fd895c649c530b8db9898f2d669e168a13fa6a356771', '[\"*\"]', '2026-04-11 13:47:25', NULL, '2026-04-11 01:44:56', '2026-04-11 13:47:25'),
(119, 'App\\Models\\Account', 10000000, 'auth-token', '05d5a63591e70188225d3b96f39326ed9eba5ebf56893fa5715254c32ff87c98', '[\"*\"]', '2026-04-14 17:58:45', NULL, '2026-04-11 13:47:00', '2026-04-14 17:58:45'),
(120, 'App\\Models\\Account', 40000071, 'mobile-parent', '97d9be2fb0414f057411545c5e60ac2c36851c2e0a6ce211f37d440ec3175fdb', '[\"*\"]', '2026-04-11 13:47:43', NULL, '2026-04-11 13:47:36', '2026-04-11 13:47:43'),
(121, 'App\\Models\\Account', 10000000, 'auth-token', '71a61d9c349f0ad2c25946eb221c7052db0759b16cd4afc7a14f3f8bc97fd4e8', '[\"*\"]', '2026-04-12 10:12:26', NULL, '2026-04-12 10:11:36', '2026-04-12 10:12:26'),
(122, 'App\\Models\\Account', 10000000, 'auth-token', '4acf118a04a80b00a0b667cb03424a1808ff94bfbfcbd155d645340ab794519d', '[\"*\"]', '2026-04-13 17:05:16', NULL, '2026-04-13 16:26:52', '2026-04-13 17:05:16'),
(124, 'App\\Models\\Account', 40000071, 'mobile-parent', 'af09e66d30fdda36b69057ab919981104ada04133df5a19d96a0ae40bda3efc0', '[\"*\"]', '2026-04-14 10:16:25', NULL, '2026-04-14 10:16:08', '2026-04-14 10:16:25'),
(125, 'App\\Models\\Account', 40000036, 'mobile-parent', 'c5689fc69c72d93ab85466f3d111fd01976070669cff5628a83dbbcbe804f384', '[\"*\"]', '2026-04-14 10:17:23', NULL, '2026-04-14 10:16:43', '2026-04-14 10:17:23'),
(126, 'App\\Models\\Account', 40000031, 'mobile-teacher', '99d6c8712464147bb15b738a0edee7c985b2728b39fc6d3be622bb3e494496a4', '[\"*\"]', '2026-04-14 10:20:22', NULL, '2026-04-14 10:17:34', '2026-04-14 10:20:22'),
(127, 'App\\Models\\Account', 40000031, 'mobile-teacher', 'dc088a23aa3832709024d48d6763a4721a68240bb749ab44944626a1f51a3e56', '[\"*\"]', '2026-04-14 13:02:44', NULL, '2026-04-14 12:59:49', '2026-04-14 13:02:44'),
(128, 'App\\Models\\Account', 40000036, 'mobile-parent', 'b8b524c2179f457b0f428f4aa3cd6e5ec750d0726d69997d85b09fb37f4c4785', '[\"*\"]', '2026-04-14 13:03:37', NULL, '2026-04-14 13:02:58', '2026-04-14 13:03:37'),
(129, 'App\\Models\\Account', 40000031, 'mobile-teacher', 'fe77e282c6642daaf9aa3726478887a36339283bfacfafd8e7763eaf00b8b0c5', '[\"*\"]', '2026-04-14 13:04:28', NULL, '2026-04-14 13:03:51', '2026-04-14 13:04:28'),
(130, 'App\\Models\\Account', 40000036, 'mobile-parent', '022ef45ee83d1fd94563bc310807444e840da0b323fe26091ba7ec88c988f362', '[\"*\"]', '2026-04-14 13:18:50', NULL, '2026-04-14 13:04:47', '2026-04-14 13:18:50'),
(131, 'App\\Models\\Account', 40000033, 'mobile-teacher', '495ceb64d3846a188c188c9c8f5ff498c5d8bf1dfc3a77c4bbe46af0385edb4b', '[\"*\"]', '2026-04-14 13:20:53', NULL, '2026-04-14 13:18:59', '2026-04-14 13:20:53'),
(132, 'App\\Models\\Account', 40000036, 'mobile-parent', '4cb3ae37f5b473362b8d067b5452ae966e64e035b4923a6bebf6a0e44bf61f34', '[\"*\"]', '2026-04-14 13:21:19', NULL, '2026-04-14 13:21:11', '2026-04-14 13:21:19'),
(133, 'App\\Models\\Account', 40000036, 'mobile-parent', 'bd1d047596c471853016ed1ff5c7d55097b05119e137fb4a532eb7aa15996d3e', '[\"*\"]', '2026-04-14 13:29:33', NULL, '2026-04-14 13:29:02', '2026-04-14 13:29:33'),
(134, 'App\\Models\\Account', 40000036, 'mobile-parent', '89e82f1deeda5304cda6ab38353336998239917cc55f31ec4459a68b15ad386b', '[\"*\"]', '2026-04-14 13:45:07', NULL, '2026-04-14 13:44:56', '2026-04-14 13:45:07'),
(135, 'App\\Models\\Account', 40000036, 'mobile-parent', '9e623a14567e1e1f6e740b09c8e470b9bb15b19ac12bd707d550aa7735ce6f30', '[\"*\"]', '2026-04-14 14:07:58', NULL, '2026-04-14 13:49:37', '2026-04-14 14:07:58'),
(136, 'App\\Models\\Account', 40000036, 'mobile-parent', '2205eb95eace62cddf541043b86b1f95e47043749f6a1b130f6dcad329e23497', '[\"*\"]', '2026-04-14 14:18:19', NULL, '2026-04-14 14:08:16', '2026-04-14 14:18:19'),
(137, 'App\\Models\\Account', 40000031, 'mobile-teacher', '423e4e8268b04ed64257bbecd9df5fe9ed4f98d3113d3e3d2a69cb74837bf99e', '[\"*\"]', '2026-04-14 14:22:43', NULL, '2026-04-14 14:19:34', '2026-04-14 14:22:43'),
(138, 'App\\Models\\Account', 40000031, 'mobile-teacher', 'f89caedd3081e3d8dd311443575970e97bc5f9a57ff26db2a80a2291ed802c14', '[\"*\"]', '2026-04-14 14:56:55', NULL, '2026-04-14 14:34:12', '2026-04-14 14:56:55'),
(139, 'App\\Models\\Account', 10000000, 'auth-token', 'df2be26912dcef68d853d3a77724f6c370224fb8c411a87ce7cfa14eea018e32', '[\"*\"]', '2026-04-15 02:53:32', NULL, '2026-04-15 01:49:26', '2026-04-15 02:53:32'),
(140, 'App\\Models\\Account', 10000000, 'auth-token', '1d30afab3ab97081d50a99b4e7b7ba0b2845de8eac7fd3680c72a81770b7c4b2', '[\"*\"]', '2026-04-15 02:49:23', NULL, '2026-04-15 02:45:50', '2026-04-15 02:49:23'),
(141, 'App\\Models\\Account', 10000000, 'auth-token', 'd0b3cefd822ae299613c2c3c0e165e1f45be867132a04bc27794b1b88b908a4d', '[\"*\"]', '2026-04-15 10:45:06', NULL, '2026-04-15 10:45:05', '2026-04-15 10:45:06'),
(143, 'App\\Models\\Account', 10000000, 'auth-token', 'd7c95e4c113c5841dfd95969801e1ca67f1c5a9681a6717bde61d88ea08b9e8d', '[\"*\"]', '2026-05-05 20:11:37', NULL, '2026-04-24 21:22:19', '2026-05-05 20:11:37'),
(144, 'App\\Models\\Account', 40000036, 'mobile-parent', 'b9a64141a592ae0200324ff730590845209233e1df13de320c36f551f6aef731', '[\"*\"]', '2026-04-25 20:29:26', NULL, '2026-04-25 20:25:56', '2026-04-25 20:29:26'),
(145, 'App\\Models\\Account', 40000031, 'mobile-teacher', 'd1ff0d92ab58b68be80ae8fc9f7c90adf0dcb01377d6c8190eabe62e3ac4402a', '[\"*\"]', '2026-04-25 20:55:56', NULL, '2026-04-25 20:29:56', '2026-04-25 20:55:56'),
(146, 'App\\Models\\Account', 10000000, 'auth-token', '221a392ac9d2ef2f66cf056d2b6e8cae8032b0233d22258afab07c3d3e8a1558', '[\"*\"]', '2026-05-02 10:50:30', NULL, '2026-05-02 06:00:26', '2026-05-02 10:50:30'),
(147, 'App\\Models\\Account', 40000031, 'mobile-teacher', 'a11b5881d8bcbbbd3f824c3c341dceac6ca43f74ef1b94fc5b826a81e2d9f694', '[\"*\"]', '2026-05-04 09:08:04', NULL, '2026-05-04 08:54:31', '2026-05-04 09:08:04'),
(148, 'App\\Models\\Account', 40000036, 'mobile-parent', 'c0d705bbb00c326503c162df6f67a0b8c3d16909b133f7327615ae51162beb16', '[\"*\"]', '2026-05-04 09:27:40', NULL, '2026-05-04 09:08:19', '2026-05-04 09:27:40'),
(149, 'App\\Models\\Account', 40000031, 'mobile-teacher', '6c6d2cea30aa7047553c4ca7e8d6c2a3f7c8ecf0b721d9d296aba2787b40a7aa', '[\"*\"]', '2026-05-04 09:44:55', NULL, '2026-05-04 09:27:55', '2026-05-04 09:44:55'),
(150, 'App\\Models\\Account', 40000031, 'mobile-teacher', 'd8085d08a999fa09528323e4f7351061bbec8a2fb7fccd30e197f65349276a74', '[\"*\"]', '2026-05-05 17:49:30', NULL, '2026-05-05 17:48:22', '2026-05-05 17:49:30'),
(152, 'App\\Models\\Account', 40000031, 'mobile-teacher', '8bd8911d511cecf98d49dd15ad813c4661b0e01a74593fe235d065888c0736ea', '[\"*\"]', NULL, NULL, '2026-05-05 18:38:36', '2026-05-05 18:38:36'),
(153, 'App\\Models\\Account', 40000031, 'mobile-teacher', '34857d40484768fae8180067949fbcbb7a3b92082e267a9027d3a5995b70059c', '[\"*\"]', NULL, NULL, '2026-05-05 18:38:44', '2026-05-05 18:38:44'),
(154, 'App\\Models\\Account', 40000036, 'mobile-parent', '75a861d5b3fad46cf2f1e3305041b45fe4a17b50aa053d7402629eccacfacdc2', '[\"*\"]', '2026-05-05 18:39:07', NULL, '2026-05-05 18:39:05', '2026-05-05 18:39:07'),
(155, 'App\\Models\\Account', 40000031, 'mobile-teacher', '0ee21818991dea26cd88b3f43e31b5fddb31591c4feb029623a4f7db0555ac5e', '[\"*\"]', NULL, NULL, '2026-05-05 18:39:17', '2026-05-05 18:39:17'),
(156, 'App\\Models\\Account', 40000031, 'mobile-teacher', '1e4c9006d2de53b91a72bab7e80d0bf8e7c6538bc3d9a34f51afab12a0a5c270', '[\"*\"]', NULL, NULL, '2026-05-05 18:39:29', '2026-05-05 18:39:29'),
(157, 'App\\Models\\Account', 40000032, 'mobile-teacher', '0d2c6097e8dc9573a7d20dcb18204785eb2b98862044d0ac06eeffd778eb7c1a', '[\"*\"]', NULL, NULL, '2026-05-05 18:40:15', '2026-05-05 18:40:15'),
(158, 'App\\Models\\Account', 40000031, 'mobile-teacher', '469ccd64324ece2005d39914608c33845cbe8ec230bbaf902aee56b423ad51a5', '[\"*\"]', NULL, NULL, '2026-05-05 18:40:21', '2026-05-05 18:40:21'),
(159, 'App\\Models\\Account', 40000031, 'mobile-teacher', '6b3da9f520673118d114d4757bd06438a170c6a4ee2abef2b302cf2aecf6031e', '[\"*\"]', NULL, NULL, '2026-05-05 18:41:17', '2026-05-05 18:41:17'),
(160, 'App\\Models\\Account', 40000031, 'mobile-teacher', '8d3ea29f4bbb2d1f4e97cfaecea28c663ae5a95d7e2f67af4b733a3f42e04d24', '[\"*\"]', NULL, NULL, '2026-05-05 18:41:48', '2026-05-05 18:41:48'),
(161, 'App\\Models\\Account', 40000031, 'mobile-teacher', '677128887970b17bac27cb6163479b62c1784e1bb6e682a7b5539fe04dede0fa', '[\"*\"]', NULL, NULL, '2026-05-05 18:44:47', '2026-05-05 18:44:47'),
(162, 'App\\Models\\Account', 40000031, 'mobile-teacher', '98a48715fd0ca912522d9fb91c0d4c01f20007fac064309e70e499bb00f1f02a', '[\"*\"]', NULL, NULL, '2026-05-05 18:47:30', '2026-05-05 18:47:30'),
(163, 'App\\Models\\Account', 40000031, 'mobile-teacher', 'f22a449a893e8c3061c8384d3cd46e319a19116b4bf9aab90fe4517efd9680ab', '[\"*\"]', '2026-05-05 18:49:16', NULL, '2026-05-05 18:49:12', '2026-05-05 18:49:16'),
(164, 'App\\Models\\Account', 40000031, 'mobile-teacher', 'a8d0e534dd0626fc5914a2705d9974ea2199ea0f862acb114c7fa35eca4a2f74', '[\"*\"]', '2026-05-05 18:54:33', NULL, '2026-05-05 18:54:12', '2026-05-05 18:54:33'),
(165, 'App\\Models\\Account', 40000036, 'mobile-parent', 'a36ce73d18cebf03eef8bdb621eed180f1a14fc51232fbc8860e547b0ac9d66f', '[\"*\"]', '2026-05-05 18:54:46', NULL, '2026-05-05 18:54:40', '2026-05-05 18:54:46'),
(166, 'App\\Models\\Account', 40000031, 'mobile-teacher', '220ac15fa905512c7991ed3b71938350f9da0f46042c52a59941b7a070898116', '[\"*\"]', '2026-05-05 18:55:18', NULL, '2026-05-05 18:54:55', '2026-05-05 18:55:18'),
(167, 'App\\Models\\Account', 40000036, 'mobile-parent', 'd034abd67db3e297b04db10b3dc0a4a4b0ddda5026d0c1d9e2424c7b9cdeb8c2', '[\"*\"]', '2026-05-05 18:55:33', NULL, '2026-05-05 18:55:28', '2026-05-05 18:55:33'),
(168, 'App\\Models\\Account', 40000036, 'mobile-parent', '26f89dd0f88dc4c3cc794cb85fb849d842992a23130b81a334cdb9cd99103897', '[\"*\"]', '2026-05-05 19:23:56', NULL, '2026-05-05 19:23:50', '2026-05-05 19:23:56'),
(170, 'App\\Models\\Account', 10000000, 'auth-token', 'cce5e792ae059a998bfc9152d21792f4586ebdebed3900a7e051125dd7eb8528', '[\"*\"]', '2026-05-09 11:14:14', NULL, '2026-05-05 19:34:07', '2026-05-09 11:14:14'),
(171, 'App\\Models\\Account', 10000000, 'auth-token', 'f80912c5686eb54b8cae48fb652d34da74a745fafbe0ceb82016008910db4c56', '[\"*\"]', '2026-05-05 19:52:44', NULL, '2026-05-05 19:52:43', '2026-05-05 19:52:44'),
(172, 'App\\Models\\Account', 10000000, 'auth-token', 'ff095ed96e25127a3e8e50e4fca7ee61c253d8e7c40b8bcc3b7deb69ad7476eb', '[\"*\"]', '2026-05-05 19:52:58', NULL, '2026-05-05 19:52:57', '2026-05-05 19:52:58'),
(173, 'App\\Models\\Account', 10000000, 'auth-token', '9d4a4cee0b1fda03137f26c3195935a5ee53149b5c743b9dddb2e92d78e18d50', '[\"*\"]', '2026-05-05 19:54:40', NULL, '2026-05-05 19:54:40', '2026-05-05 19:54:40'),
(174, 'App\\Models\\Account', 10000000, 'auth-token', 'b01d50b37f51bfe5241d930828ecf3e730a76e4ede0c0b5a878b523fd8589ca2', '[\"*\"]', '2026-05-05 20:01:38', NULL, '2026-05-05 20:01:25', '2026-05-05 20:01:38'),
(175, 'App\\Models\\Account', 40000036, 'mobile-parent', 'a5f0dee3998d4512a6b882ceccc6f505e7b1902af636cd3d42f68fc4187dcf4d', '[\"*\"]', '2026-05-09 10:42:31', NULL, '2026-05-09 10:42:08', '2026-05-09 10:42:31'),
(176, 'App\\Models\\Account', 40000036, 'mobile-parent', '7b96213f09f4b8e7d02b4eaa4db5cd2c6d3277c9024c0b57d7974dd190064a68', '[\"*\"]', '2026-05-09 11:05:21', NULL, '2026-05-09 10:51:27', '2026-05-09 11:05:21'),
(177, 'App\\Models\\Account', 40000031, 'mobile-teacher', '478abb21c36a97aa1f64765e9dbf0afdef7ee7e5b0a688ddaefa420de934f4b6', '[\"*\"]', '2026-05-09 11:12:56', NULL, '2026-05-09 11:09:24', '2026-05-09 11:12:56'),
(178, 'App\\Models\\Account', 10000000, 'auth-token', '29493d67abd488423a4c31cfe8e6711e592f0a8af228e443df6490d913ba539d', '[\"*\"]', '2026-05-30 06:56:47', NULL, '2026-05-30 06:56:01', '2026-05-30 06:56:47'),
(179, 'App\\Models\\Account', 10000000, 'auth-token', '724890f37ad5cd370c05c590b4a911f381ee56d32cb1a26cc07caa418b063da1', '[\"*\"]', '2026-05-30 18:21:41', NULL, '2026-05-30 18:20:36', '2026-05-30 18:21:41'),
(180, 'App\\Models\\Account', 10000000, 'auth-token', '0f353ba34b05363c2098ba0db5a733d1d61e8a4d9b6f5dd2f75e8847df685b88', '[\"*\"]', '2026-05-30 21:52:25', NULL, '2026-05-30 21:50:52', '2026-05-30 21:52:25'),
(181, 'App\\Models\\Account', 10000000, 'auth-token', 'b1a47aabc6fe44ed83e0d05f9fab9cf47f924ffd942483cc06da7b61efc7c9fc', '[\"*\"]', '2026-05-31 08:16:05', NULL, '2026-05-31 08:14:19', '2026-05-31 08:16:05');

-- --------------------------------------------------------

--
-- Table structure for table `Pickupnotifications`
--

CREATE TABLE `Pickupnotifications` (
  `Duration` int(11) DEFAULT NULL,
  `PickupnotificationsID` int(11) NOT NULL,
  `ParentID` int(11) DEFAULT NULL,
  `PickupnotificationsstatusID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Pickupnotifications`
--

INSERT INTO `Pickupnotifications` (`Duration`, `PickupnotificationsID`, `ParentID`, `PickupnotificationsstatusID`) VALUES
(40, 7, 40000037, 5);

-- --------------------------------------------------------

--
-- Table structure for table `Pickupnotificationsstatus`
--

CREATE TABLE `Pickupnotificationsstatus` (
  `Name` varchar(50) DEFAULT NULL,
  `PickupnotificationsstatusID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Pickupnotificationsstatus`
--

INSERT INTO `Pickupnotificationsstatus` (`Name`, `PickupnotificationsstatusID`) VALUES
('unread', 4),
('read', 5);

-- --------------------------------------------------------

--
-- Table structure for table `PickupNotificationsTeacher`
--

CREATE TABLE `PickupNotificationsTeacher` (
  `TeacherID` int(11) DEFAULT NULL,
  `PickupnotificationsID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `PickupNotificationsTeacher`
--

INSERT INTO `PickupNotificationsTeacher` (`TeacherID`, `PickupnotificationsID`) VALUES
(40000032, 7);

-- --------------------------------------------------------

--
-- Table structure for table `Planday`
--

CREATE TABLE `Planday` (
  `Date` date DEFAULT NULL,
  `PlandayID` int(11) NOT NULL,
  `PlanningID` int(11) DEFAULT NULL,
  `ClassID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Planday`
--

INSERT INTO `Planday` (`Date`, `PlandayID`, `PlanningID`, `ClassID`) VALUES
('2024-12-09', 1597, 7, 12),
('2024-12-15', 1598, 7, 12),
('2024-12-10', 1599, 7, 12),
('2026-04-07', 1600, 8, 18),
('2026-04-07', 1601, 8, 19),
('2025-09-15', 1618, 8, 18),
('2025-09-15', 1619, 8, 19),
('2025-09-15', 1620, 8, 20),
('2025-09-15', 1621, 8, 21),
('2025-09-17', 1622, 8, 18),
('2025-09-17', 1623, 8, 19),
('2025-09-17', 1624, 8, 20),
('2025-09-17', 1625, 8, 21),
('2025-09-18', 1626, 8, 18),
('2025-09-18', 1627, 8, 19),
('2025-09-18', 1628, 8, 20),
('2025-09-18', 1629, 8, 21),
('2025-09-19', 1630, 8, 18),
('2025-09-19', 1631, 8, 19),
('2025-09-19', 1632, 8, 20),
('2025-09-19', 1633, 8, 21),
('2025-09-22', 1634, 8, 18),
('2025-09-24', 1635, 8, 18),
('2025-09-25', 1636, 8, 18),
('2025-09-26', 1637, 8, 18),
('2025-09-29', 1638, 8, 18),
('2025-10-01', 1639, 8, 18),
('2025-10-02', 1640, 8, 18),
('2025-10-03', 1641, 8, 18),
('2025-10-06', 1642, 8, 18),
('2025-09-22', 1643, 8, 19),
('2025-09-24', 1644, 8, 19),
('2025-09-25', 1645, 8, 19),
('2025-09-26', 1646, 8, 19),
('2025-09-29', 1647, 8, 19),
('2025-10-01', 1648, 8, 19),
('2025-10-02', 1649, 8, 19),
('2025-10-03', 1650, 8, 19),
('2025-10-06', 1651, 8, 19),
('2025-09-22', 1652, 8, 20),
('2025-09-24', 1653, 8, 20),
('2025-09-25', 1654, 8, 20),
('2025-09-26', 1655, 8, 20),
('2025-09-29', 1656, 8, 20),
('2025-10-01', 1657, 8, 20),
('2025-10-02', 1658, 8, 20),
('2025-10-03', 1659, 8, 20),
('2025-10-06', 1660, 8, 20),
('2025-09-22', 1661, 8, 21),
('2025-09-24', 1662, 8, 21),
('2025-09-25', 1663, 8, 21),
('2025-09-26', 1664, 8, 21),
('2025-09-29', 1665, 8, 21),
('2025-10-01', 1666, 8, 21),
('2025-10-02', 1667, 8, 21),
('2025-10-03', 1668, 8, 21),
('2025-10-06', 1669, 8, 21),
('2025-10-08', 1670, 8, 18),
('2025-10-09', 1671, 8, 18),
('2025-10-10', 1672, 8, 18),
('2025-10-13', 1673, 8, 18),
('2025-10-15', 1674, 8, 18),
('2025-10-16', 1675, 8, 18),
('2025-10-17', 1676, 8, 18),
('2025-10-20', 1677, 8, 18),
('2025-10-22', 1678, 8, 18),
('2025-10-23', 1679, 8, 18),
('2025-10-24', 1680, 8, 18),
('2025-10-27', 1681, 8, 18),
('2025-10-29', 1682, 8, 18),
('2025-10-08', 1683, 8, 19),
('2025-10-09', 1684, 8, 19),
('2025-10-10', 1685, 8, 19),
('2025-10-13', 1686, 8, 19),
('2025-10-15', 1687, 8, 19),
('2025-10-16', 1688, 8, 19),
('2025-10-17', 1689, 8, 19),
('2025-10-20', 1690, 8, 19),
('2025-10-22', 1691, 8, 19),
('2025-10-23', 1692, 8, 19),
('2025-10-24', 1693, 8, 19),
('2025-10-27', 1694, 8, 19),
('2025-10-29', 1695, 8, 19),
('2025-10-08', 1696, 8, 20),
('2025-10-09', 1697, 8, 20),
('2025-10-10', 1698, 8, 20),
('2025-10-13', 1699, 8, 20),
('2025-10-15', 1700, 8, 20),
('2025-10-16', 1701, 8, 20),
('2025-10-17', 1702, 8, 20),
('2025-10-20', 1703, 8, 20),
('2025-10-22', 1704, 8, 20),
('2025-10-23', 1705, 8, 20),
('2025-10-24', 1706, 8, 20),
('2025-10-27', 1707, 8, 20),
('2025-10-29', 1708, 8, 20),
('2025-10-08', 1709, 8, 21),
('2025-10-09', 1710, 8, 21),
('2025-10-10', 1711, 8, 21),
('2025-10-13', 1712, 8, 21),
('2025-10-15', 1713, 8, 21),
('2025-10-16', 1714, 8, 21),
('2025-10-17', 1715, 8, 21),
('2025-10-20', 1716, 8, 21),
('2025-10-22', 1717, 8, 21),
('2025-10-23', 1718, 8, 21),
('2025-10-24', 1719, 8, 21),
('2025-10-27', 1720, 8, 21),
('2025-10-29', 1721, 8, 21),
('2025-10-30', 1722, 8, 18),
('2025-10-31', 1723, 8, 18),
('2025-11-03', 1724, 8, 18),
('2025-11-05', 1725, 8, 18),
('2025-11-06', 1726, 8, 18),
('2025-11-07', 1727, 8, 18),
('2025-11-10', 1728, 8, 18),
('2025-11-12', 1729, 8, 18),
('2025-11-13', 1730, 8, 18),
('2025-11-14', 1731, 8, 18),
('2025-11-17', 1732, 8, 18),
('2025-11-19', 1733, 8, 18),
('2025-11-20', 1734, 8, 18),
('2025-10-30', 1735, 8, 19),
('2025-10-31', 1736, 8, 19),
('2025-11-03', 1737, 8, 19),
('2025-11-05', 1738, 8, 19),
('2025-11-06', 1739, 8, 19),
('2025-11-07', 1740, 8, 19),
('2025-11-10', 1741, 8, 19),
('2025-11-12', 1742, 8, 19),
('2025-11-13', 1743, 8, 19),
('2025-11-14', 1744, 8, 19),
('2025-11-17', 1745, 8, 19),
('2025-11-19', 1746, 8, 19),
('2025-11-20', 1747, 8, 19),
('2025-10-30', 1748, 8, 20),
('2025-10-31', 1749, 8, 20),
('2025-11-03', 1750, 8, 20),
('2025-11-05', 1751, 8, 20),
('2025-11-06', 1752, 8, 20),
('2025-11-07', 1753, 8, 20),
('2025-11-10', 1754, 8, 20),
('2025-11-12', 1755, 8, 20),
('2025-11-13', 1756, 8, 20),
('2025-11-14', 1757, 8, 20),
('2025-11-17', 1758, 8, 20),
('2025-11-19', 1759, 8, 20),
('2025-11-20', 1760, 8, 20),
('2025-10-30', 1761, 8, 21),
('2025-10-31', 1762, 8, 21),
('2025-11-03', 1763, 8, 21),
('2025-11-05', 1764, 8, 21),
('2025-11-06', 1765, 8, 21),
('2025-11-07', 1766, 8, 21),
('2025-11-10', 1767, 8, 21),
('2025-11-12', 1768, 8, 21),
('2025-11-13', 1769, 8, 21),
('2025-11-14', 1770, 8, 21),
('2025-11-17', 1771, 8, 21),
('2025-11-19', 1772, 8, 21),
('2025-11-20', 1773, 8, 21),
('2025-11-21', 1774, 8, 18),
('2025-11-24', 1775, 8, 18),
('2025-11-26', 1776, 8, 18),
('2025-11-27', 1777, 8, 18),
('2025-11-28', 1778, 8, 18),
('2025-12-01', 1779, 8, 18),
('2025-12-03', 1780, 8, 18),
('2025-12-04', 1781, 8, 18),
('2025-12-05', 1782, 8, 18),
('2025-12-08', 1783, 8, 18),
('2025-12-10', 1784, 8, 18),
('2025-12-11', 1785, 8, 18),
('2025-12-12', 1786, 8, 18),
('2025-11-21', 1787, 8, 19),
('2025-11-24', 1788, 8, 19),
('2025-11-26', 1789, 8, 19),
('2025-11-27', 1790, 8, 19),
('2025-11-28', 1791, 8, 19),
('2025-12-01', 1792, 8, 19),
('2025-12-03', 1793, 8, 19),
('2025-12-04', 1794, 8, 19),
('2025-12-05', 1795, 8, 19),
('2025-12-08', 1796, 8, 19),
('2025-12-10', 1797, 8, 19),
('2025-12-11', 1798, 8, 19),
('2025-12-12', 1799, 8, 19),
('2025-11-21', 1800, 8, 20),
('2025-11-24', 1801, 8, 20),
('2025-11-26', 1802, 8, 20),
('2025-11-27', 1803, 8, 20),
('2025-11-28', 1804, 8, 20),
('2025-12-01', 1805, 8, 20),
('2025-12-03', 1806, 8, 20),
('2025-12-04', 1807, 8, 20),
('2025-12-05', 1808, 8, 20),
('2025-12-08', 1809, 8, 20),
('2025-12-10', 1810, 8, 20),
('2025-12-11', 1811, 8, 20),
('2025-12-12', 1812, 8, 20),
('2025-11-21', 1813, 8, 21),
('2025-11-24', 1814, 8, 21),
('2025-11-26', 1815, 8, 21),
('2025-11-27', 1816, 8, 21),
('2025-11-28', 1817, 8, 21),
('2025-12-01', 1818, 8, 21),
('2025-12-03', 1819, 8, 21),
('2025-12-04', 1820, 8, 21),
('2025-12-05', 1821, 8, 21),
('2025-12-08', 1822, 8, 21),
('2025-12-10', 1823, 8, 21),
('2025-12-11', 1824, 8, 21),
('2025-12-12', 1825, 8, 21),
('2025-12-15', 1826, 8, 18),
('2025-12-17', 1827, 8, 18),
('2025-12-18', 1828, 8, 18),
('2025-12-19', 1829, 8, 18),
('2025-12-22', 1830, 8, 18),
('2025-12-24', 1831, 8, 18),
('2025-12-25', 1832, 8, 18),
('2025-12-26', 1833, 8, 18),
('2025-12-29', 1834, 8, 18),
('2025-12-31', 1835, 8, 18),
('2026-01-01', 1836, 8, 18),
('2026-01-02', 1837, 8, 18),
('2026-01-05', 1838, 8, 18),
('2025-12-15', 1839, 8, 19),
('2025-12-17', 1840, 8, 19),
('2025-12-18', 1841, 8, 19),
('2025-12-19', 1842, 8, 19),
('2025-12-22', 1843, 8, 19),
('2025-12-24', 1844, 8, 19),
('2025-12-25', 1845, 8, 19),
('2025-12-26', 1846, 8, 19),
('2025-12-29', 1847, 8, 19),
('2025-12-31', 1848, 8, 19),
('2026-01-01', 1849, 8, 19),
('2026-01-02', 1850, 8, 19),
('2026-01-05', 1851, 8, 19),
('2025-12-15', 1852, 8, 20),
('2025-12-17', 1853, 8, 20),
('2025-12-18', 1854, 8, 20),
('2025-12-19', 1855, 8, 20),
('2025-12-22', 1856, 8, 20),
('2025-12-24', 1857, 8, 20),
('2025-12-25', 1858, 8, 20),
('2025-12-26', 1859, 8, 20),
('2025-12-29', 1860, 8, 20),
('2025-12-31', 1861, 8, 20),
('2026-01-01', 1862, 8, 20),
('2026-01-02', 1863, 8, 20),
('2026-01-05', 1864, 8, 20),
('2025-12-15', 1865, 8, 21),
('2025-12-17', 1866, 8, 21),
('2025-12-18', 1867, 8, 21),
('2025-12-19', 1868, 8, 21),
('2025-12-22', 1869, 8, 21),
('2025-12-24', 1870, 8, 21),
('2025-12-25', 1871, 8, 21),
('2025-12-26', 1872, 8, 21),
('2025-12-29', 1873, 8, 21),
('2025-12-31', 1874, 8, 21),
('2026-01-01', 1875, 8, 21),
('2026-01-02', 1876, 8, 21),
('2026-01-05', 1877, 8, 21),
('2026-01-07', 1878, 8, 18),
('2026-01-08', 1879, 8, 18),
('2026-01-09', 1880, 8, 18),
('2026-01-12', 1881, 8, 18),
('2026-01-14', 1882, 8, 18),
('2026-01-15', 1883, 8, 18),
('2026-01-16', 1884, 8, 18),
('2026-01-19', 1885, 8, 18),
('2026-01-21', 1886, 8, 18),
('2026-01-22', 1887, 8, 18),
('2026-01-23', 1888, 8, 18),
('2026-01-26', 1889, 8, 18),
('2026-01-28', 1890, 8, 18),
('2026-01-07', 1891, 8, 19),
('2026-01-08', 1892, 8, 19),
('2026-01-09', 1893, 8, 19),
('2026-01-12', 1894, 8, 19),
('2026-01-14', 1895, 8, 19),
('2026-01-15', 1896, 8, 19),
('2026-01-16', 1897, 8, 19),
('2026-01-19', 1898, 8, 19),
('2026-01-21', 1899, 8, 19),
('2026-01-22', 1900, 8, 19),
('2026-01-23', 1901, 8, 19),
('2026-01-26', 1902, 8, 19),
('2026-01-28', 1903, 8, 19),
('2026-01-07', 1904, 8, 20),
('2026-01-08', 1905, 8, 20),
('2026-01-09', 1906, 8, 20),
('2026-01-12', 1907, 8, 20),
('2026-01-14', 1908, 8, 20),
('2026-01-15', 1909, 8, 20),
('2026-01-16', 1910, 8, 20),
('2026-01-19', 1911, 8, 20),
('2026-01-21', 1912, 8, 20),
('2026-01-22', 1913, 8, 20),
('2026-01-23', 1914, 8, 20),
('2026-01-26', 1915, 8, 20),
('2026-01-28', 1916, 8, 20),
('2026-01-07', 1917, 8, 21),
('2026-01-08', 1918, 8, 21),
('2026-01-09', 1919, 8, 21),
('2026-01-12', 1920, 8, 21),
('2026-01-14', 1921, 8, 21),
('2026-01-15', 1922, 8, 21),
('2026-01-16', 1923, 8, 21),
('2026-01-19', 1924, 8, 21),
('2026-01-21', 1925, 8, 21),
('2026-01-22', 1926, 8, 21),
('2026-01-23', 1927, 8, 21),
('2026-01-26', 1928, 8, 21),
('2026-01-28', 1929, 8, 21),
('2026-01-29', 1930, 8, 18),
('2026-01-30', 1931, 8, 18),
('2026-02-02', 1932, 8, 18),
('2026-02-04', 1933, 8, 18),
('2026-02-05', 1934, 8, 18),
('2026-02-06', 1935, 8, 18),
('2026-02-09', 1936, 8, 18),
('2026-02-11', 1937, 8, 18),
('2026-02-12', 1938, 8, 18),
('2026-02-13', 1939, 8, 18),
('2026-02-16', 1940, 8, 18),
('2026-02-18', 1941, 8, 18),
('2026-02-19', 1942, 8, 18),
('2026-01-29', 1943, 8, 19),
('2026-01-30', 1944, 8, 19),
('2026-02-02', 1945, 8, 19),
('2026-02-04', 1946, 8, 19),
('2026-02-05', 1947, 8, 19),
('2026-02-06', 1948, 8, 19),
('2026-02-09', 1949, 8, 19),
('2026-02-11', 1950, 8, 19),
('2026-02-12', 1951, 8, 19),
('2026-02-13', 1952, 8, 19),
('2026-02-16', 1953, 8, 19),
('2026-02-18', 1954, 8, 19),
('2026-02-19', 1955, 8, 19),
('2026-01-29', 1956, 8, 20),
('2026-01-30', 1957, 8, 20),
('2026-02-02', 1958, 8, 20),
('2026-02-04', 1959, 8, 20),
('2026-02-05', 1960, 8, 20),
('2026-02-06', 1961, 8, 20),
('2026-02-09', 1962, 8, 20),
('2026-02-11', 1963, 8, 20),
('2026-02-12', 1964, 8, 20),
('2026-02-13', 1965, 8, 20),
('2026-02-16', 1966, 8, 20),
('2026-02-18', 1967, 8, 20),
('2026-02-19', 1968, 8, 20),
('2026-01-29', 1969, 8, 21),
('2026-01-30', 1970, 8, 21),
('2026-02-02', 1971, 8, 21),
('2026-02-04', 1972, 8, 21),
('2026-02-05', 1973, 8, 21),
('2026-02-06', 1974, 8, 21),
('2026-02-09', 1975, 8, 21),
('2026-02-11', 1976, 8, 21),
('2026-02-12', 1977, 8, 21),
('2026-02-13', 1978, 8, 21),
('2026-02-16', 1979, 8, 21),
('2026-02-18', 1980, 8, 21),
('2026-02-19', 1981, 8, 21),
('2026-02-20', 1982, 8, 18),
('2026-02-23', 1983, 8, 18),
('2026-02-25', 1984, 8, 18),
('2026-02-26', 1985, 8, 18),
('2026-02-27', 1986, 8, 18),
('2026-03-02', 1987, 8, 18),
('2026-03-04', 1988, 8, 18),
('2026-03-05', 1989, 8, 18),
('2026-03-06', 1990, 8, 18),
('2026-03-09', 1991, 8, 18),
('2026-03-11', 1992, 8, 18),
('2026-03-12', 1993, 8, 18),
('2026-03-13', 1994, 8, 18),
('2026-02-20', 1995, 8, 19),
('2026-02-23', 1996, 8, 19),
('2026-02-25', 1997, 8, 19),
('2026-02-26', 1998, 8, 19),
('2026-02-27', 1999, 8, 19),
('2026-03-02', 2000, 8, 19),
('2026-03-04', 2001, 8, 19),
('2026-03-05', 2002, 8, 19),
('2026-03-06', 2003, 8, 19),
('2026-03-09', 2004, 8, 19),
('2026-03-11', 2005, 8, 19),
('2026-03-12', 2006, 8, 19),
('2026-03-13', 2007, 8, 19),
('2026-02-20', 2008, 8, 20),
('2026-02-23', 2009, 8, 20),
('2026-02-25', 2010, 8, 20),
('2026-02-26', 2011, 8, 20),
('2026-02-27', 2012, 8, 20),
('2026-03-02', 2013, 8, 20),
('2026-03-04', 2014, 8, 20),
('2026-03-05', 2015, 8, 20),
('2026-03-06', 2016, 8, 20),
('2026-03-09', 2017, 8, 20),
('2026-03-11', 2018, 8, 20),
('2026-03-12', 2019, 8, 20),
('2026-03-13', 2020, 8, 20),
('2026-02-20', 2021, 8, 21),
('2026-02-23', 2022, 8, 21),
('2026-02-25', 2023, 8, 21),
('2026-02-26', 2024, 8, 21),
('2026-02-27', 2025, 8, 21),
('2026-03-02', 2026, 8, 21),
('2026-03-04', 2027, 8, 21),
('2026-03-05', 2028, 8, 21),
('2026-03-06', 2029, 8, 21),
('2026-03-09', 2030, 8, 21),
('2026-03-11', 2031, 8, 21),
('2026-03-12', 2032, 8, 21),
('2026-03-13', 2033, 8, 21),
('2026-03-16', 2034, 8, 18),
('2026-03-18', 2035, 8, 18),
('2026-03-19', 2036, 8, 18),
('2026-03-20', 2037, 8, 18),
('2026-03-23', 2038, 8, 18),
('2026-03-25', 2039, 8, 18),
('2026-03-26', 2040, 8, 18),
('2026-03-27', 2041, 8, 18),
('2026-03-30', 2042, 8, 18),
('2026-04-01', 2043, 8, 18),
('2026-04-02', 2044, 8, 18),
('2026-04-03', 2045, 8, 18),
('2026-04-06', 2046, 8, 18),
('2026-03-16', 2047, 8, 19),
('2026-03-18', 2048, 8, 19),
('2026-03-19', 2049, 8, 19),
('2026-03-20', 2050, 8, 19),
('2026-03-23', 2051, 8, 19),
('2026-03-25', 2052, 8, 19),
('2026-03-26', 2053, 8, 19),
('2026-03-27', 2054, 8, 19),
('2026-03-30', 2055, 8, 19),
('2026-04-01', 2056, 8, 19),
('2026-04-02', 2057, 8, 19),
('2026-04-03', 2058, 8, 19),
('2026-04-06', 2059, 8, 19),
('2026-03-16', 2060, 8, 20),
('2026-03-18', 2061, 8, 20),
('2026-03-19', 2062, 8, 20),
('2026-03-20', 2063, 8, 20),
('2026-03-23', 2064, 8, 20),
('2026-03-25', 2065, 8, 20),
('2026-03-26', 2066, 8, 20),
('2026-03-27', 2067, 8, 20),
('2026-03-30', 2068, 8, 20),
('2026-04-01', 2069, 8, 20),
('2026-04-02', 2070, 8, 20),
('2026-04-03', 2071, 8, 20),
('2026-04-06', 2072, 8, 20),
('2026-03-16', 2073, 8, 21),
('2026-03-18', 2074, 8, 21),
('2026-03-19', 2075, 8, 21),
('2026-03-20', 2076, 8, 21),
('2026-03-23', 2077, 8, 21),
('2026-03-25', 2078, 8, 21),
('2026-03-26', 2079, 8, 21),
('2026-03-27', 2080, 8, 21),
('2026-03-30', 2081, 8, 21),
('2026-04-01', 2082, 8, 21),
('2026-04-02', 2083, 8, 21),
('2026-04-03', 2084, 8, 21),
('2026-04-06', 2085, 8, 21),
('2026-04-08', 2086, 8, 18),
('2026-04-09', 2087, 8, 18),
('2026-04-10', 2088, 8, 18),
('2026-04-13', 2089, 8, 18),
('2026-04-15', 2090, 8, 18),
('2026-04-16', 2091, 8, 18),
('2026-04-17', 2092, 8, 18),
('2026-04-20', 2093, 8, 18),
('2026-04-22', 2094, 8, 18),
('2026-04-23', 2095, 8, 18),
('2026-04-24', 2096, 8, 18),
('2026-04-27', 2097, 8, 18),
('2026-04-29', 2098, 8, 18),
('2026-04-08', 2099, 8, 19),
('2026-04-09', 2100, 8, 19),
('2026-04-10', 2101, 8, 19),
('2026-04-13', 2102, 8, 19),
('2026-04-15', 2103, 8, 19),
('2026-04-16', 2104, 8, 19),
('2026-04-17', 2105, 8, 19),
('2026-04-20', 2106, 8, 19),
('2026-04-22', 2107, 8, 19),
('2026-04-23', 2108, 8, 19),
('2026-04-24', 2109, 8, 19),
('2026-04-27', 2110, 8, 19),
('2026-04-29', 2111, 8, 19),
('2026-04-08', 2112, 8, 20),
('2026-04-09', 2113, 8, 20),
('2026-04-10', 2114, 8, 20),
('2026-04-13', 2115, 8, 20),
('2026-04-15', 2116, 8, 20),
('2026-04-16', 2117, 8, 20),
('2026-04-17', 2118, 8, 20),
('2026-04-20', 2119, 8, 20),
('2026-04-22', 2120, 8, 20),
('2026-04-23', 2121, 8, 20),
('2026-04-24', 2122, 8, 20),
('2026-04-27', 2123, 8, 20),
('2026-04-29', 2124, 8, 20),
('2026-04-08', 2125, 8, 21),
('2026-04-09', 2126, 8, 21),
('2026-04-10', 2127, 8, 21),
('2026-04-13', 2128, 8, 21),
('2026-04-15', 2129, 8, 21),
('2026-04-16', 2130, 8, 21),
('2026-04-17', 2131, 8, 21),
('2026-04-20', 2132, 8, 21),
('2026-04-22', 2133, 8, 21),
('2026-04-23', 2134, 8, 21),
('2026-04-24', 2135, 8, 21),
('2026-04-27', 2136, 8, 21),
('2026-04-29', 2137, 8, 21),
('2026-04-30', 2138, 8, 18),
('2026-05-01', 2139, 8, 18),
('2026-05-04', 2140, 8, 18),
('2026-05-06', 2141, 8, 18),
('2026-05-07', 2142, 8, 18),
('2026-05-08', 2143, 8, 18),
('2026-05-11', 2144, 8, 18),
('2026-05-13', 2145, 8, 18),
('2026-05-14', 2146, 8, 18),
('2026-05-15', 2147, 8, 18),
('2026-05-18', 2148, 8, 18),
('2026-05-20', 2149, 8, 18),
('2026-05-21', 2150, 8, 18),
('2026-04-30', 2151, 8, 19),
('2026-05-01', 2152, 8, 19),
('2026-05-04', 2153, 8, 19),
('2026-05-06', 2154, 8, 19),
('2026-05-07', 2155, 8, 19),
('2026-05-08', 2156, 8, 19),
('2026-05-11', 2157, 8, 19),
('2026-05-13', 2158, 8, 19),
('2026-05-14', 2159, 8, 19),
('2026-05-15', 2160, 8, 19),
('2026-05-18', 2161, 8, 19),
('2026-05-20', 2162, 8, 19),
('2026-05-21', 2163, 8, 19),
('2026-04-30', 2164, 8, 20),
('2026-05-01', 2165, 8, 20),
('2026-05-04', 2166, 8, 20),
('2026-05-06', 2167, 8, 20),
('2026-05-07', 2168, 8, 20),
('2026-05-08', 2169, 8, 20),
('2026-05-11', 2170, 8, 20),
('2026-05-13', 2171, 8, 20),
('2026-05-14', 2172, 8, 20),
('2026-05-15', 2173, 8, 20),
('2026-05-18', 2174, 8, 20),
('2026-05-20', 2175, 8, 20),
('2026-05-21', 2176, 8, 20),
('2026-04-30', 2177, 8, 21),
('2026-05-01', 2178, 8, 21),
('2026-05-04', 2179, 8, 21),
('2026-05-06', 2180, 8, 21),
('2026-05-07', 2181, 8, 21),
('2026-05-08', 2182, 8, 21),
('2026-05-11', 2183, 8, 21),
('2026-05-13', 2184, 8, 21),
('2026-05-14', 2185, 8, 21),
('2026-05-15', 2186, 8, 21),
('2026-05-18', 2187, 8, 21),
('2026-05-20', 2188, 8, 21),
('2026-05-21', 2189, 8, 21),
('2026-05-22', 2190, 8, 18),
('2026-05-25', 2191, 8, 18),
('2026-05-27', 2192, 8, 18),
('2026-05-28', 2193, 8, 18),
('2026-05-29', 2194, 8, 18),
('2026-06-01', 2195, 8, 18),
('2026-06-03', 2196, 8, 18),
('2026-06-04', 2197, 8, 18),
('2026-06-05', 2198, 8, 18),
('2026-06-08', 2199, 8, 18),
('2026-06-10', 2200, 8, 18),
('2026-06-11', 2201, 8, 18),
('2026-06-12', 2202, 8, 18),
('2026-05-22', 2203, 8, 19),
('2026-05-25', 2204, 8, 19),
('2026-05-27', 2205, 8, 19),
('2026-05-28', 2206, 8, 19),
('2026-05-29', 2207, 8, 19),
('2026-06-01', 2208, 8, 19),
('2026-06-03', 2209, 8, 19),
('2026-06-04', 2210, 8, 19),
('2026-06-05', 2211, 8, 19),
('2026-06-08', 2212, 8, 19),
('2026-06-10', 2213, 8, 19),
('2026-06-11', 2214, 8, 19),
('2026-06-12', 2215, 8, 19),
('2026-05-22', 2216, 8, 20),
('2026-05-25', 2217, 8, 20),
('2026-05-27', 2218, 8, 20),
('2026-05-28', 2219, 8, 20),
('2026-05-29', 2220, 8, 20),
('2026-06-01', 2221, 8, 20),
('2026-06-03', 2222, 8, 20),
('2026-06-04', 2223, 8, 20),
('2026-06-05', 2224, 8, 20),
('2026-06-08', 2225, 8, 20),
('2026-06-10', 2226, 8, 20),
('2026-06-11', 2227, 8, 20),
('2026-06-12', 2228, 8, 20),
('2026-05-22', 2229, 8, 21),
('2026-05-25', 2230, 8, 21),
('2026-05-27', 2231, 8, 21),
('2026-05-28', 2232, 8, 21),
('2026-05-29', 2233, 8, 21),
('2026-06-01', 2234, 8, 21),
('2026-06-03', 2235, 8, 21),
('2026-06-04', 2236, 8, 21),
('2026-06-05', 2237, 8, 21),
('2026-06-08', 2238, 8, 21),
('2026-06-10', 2239, 8, 21),
('2026-06-11', 2240, 8, 21),
('2026-06-12', 2241, 8, 21),
('2026-06-15', 2242, 8, 18),
('2026-06-17', 2243, 8, 18),
('2026-06-18', 2244, 8, 18),
('2026-06-19', 2245, 8, 18),
('2026-06-22', 2246, 8, 18),
('2026-06-24', 2247, 8, 18),
('2026-06-25', 2248, 8, 18),
('2026-06-26', 2249, 8, 18),
('2026-06-29', 2250, 8, 18),
('2026-06-15', 2251, 8, 19),
('2026-06-17', 2252, 8, 19),
('2026-06-18', 2253, 8, 19),
('2026-06-19', 2254, 8, 19),
('2026-06-22', 2255, 8, 19),
('2026-06-24', 2256, 8, 19),
('2026-06-25', 2257, 8, 19),
('2026-06-26', 2258, 8, 19),
('2026-06-29', 2259, 8, 19),
('2026-06-15', 2260, 8, 20),
('2026-06-17', 2261, 8, 20),
('2026-06-18', 2262, 8, 20),
('2026-06-19', 2263, 8, 20),
('2026-06-22', 2264, 8, 20),
('2026-06-24', 2265, 8, 20),
('2026-06-25', 2266, 8, 20),
('2026-06-26', 2267, 8, 20),
('2026-06-29', 2268, 8, 20),
('2026-06-15', 2269, 8, 21),
('2026-06-17', 2270, 8, 21),
('2026-06-18', 2271, 8, 21),
('2026-06-19', 2272, 8, 21),
('2026-06-22', 2273, 8, 21),
('2026-06-24', 2274, 8, 21),
('2026-06-25', 2275, 8, 21),
('2026-06-26', 2276, 8, 21),
('2026-06-29', 2277, 8, 21),
('2026-04-07', 2658, 8, 20),
('2026-04-14', 2659, 8, 18),
('2026-04-14', 2660, 8, 19),
('2026-04-14', 2661, 8, 21),
('2026-04-14', 2662, 8, 20),
('2026-04-14', 2663, 8, 22);

-- --------------------------------------------------------

--
-- Table structure for table `Plandayactivity`
--

CREATE TABLE `Plandayactivity` (
  `Endtime` time DEFAULT NULL,
  `Starttime` time DEFAULT NULL,
  `Status` varchar(50) DEFAULT NULL,
  `PlandayactivityID` int(11) NOT NULL,
  `ActivityID` int(11) DEFAULT NULL,
  `PlandayID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Plandayactivity`
--

INSERT INTO `Plandayactivity` (`Endtime`, `Starttime`, `Status`, `PlandayactivityID`, `ActivityID`, `PlandayID`) VALUES
('11:00:00', '09:00:00', 'executed', 4373, 40, 1597),
('13:00:00', '11:00:00', 'executed', 4375, 41, 1597),
('11:00:00', '09:00:00', 'approved', 4376, 46, 1599),
('11:00:00', '09:00:00', 'executed', 4377, 40, 1600),
('13:00:00', '11:00:00', 'executed', 4378, 46, 1600),
('11:00:00', '09:00:00', 'executed', 4379, 44, 1601),
('13:00:00', '11:00:00', 'executed', 4380, 48, 1601),
('11:00:00', '09:00:00', 'approved', 4387, 41, 1618),
('11:00:00', '09:00:00', 'approved', 4388, 41, 1619),
('11:00:00', '09:00:00', 'approved', 4390, 48, 1620),
('11:00:00', '09:00:00', 'approved', 4391, 48, 1621),
('11:00:00', '09:30:00', 'approved', 4393, 43, 1622),
('11:00:00', '09:30:00', 'approved', 4394, 43, 1623),
('11:00:00', '09:30:00', 'approved', 4395, 43, 1624),
('11:00:00', '09:30:00', 'approved', 4396, 43, 1625),
('12:00:00', '10:00:00', 'approved', 4400, 44, 1626),
('12:00:00', '10:00:00', 'approved', 4401, 44, 1627),
('12:00:00', '10:00:00', 'approved', 4403, 49, 1628),
('12:00:00', '10:00:00', 'approved', 4404, 49, 1629),
('12:30:00', '11:00:00', 'approved', 4406, 46, 1630),
('12:30:00', '11:00:00', 'approved', 4407, 46, 1631),
('12:30:00', '11:00:00', 'approved', 4409, 47, 1632),
('12:30:00', '11:00:00', 'approved', 4410, 47, 1633),
('11:00:00', '09:00:00', 'approved', 4412, 41, 1630),
('11:00:00', '09:00:00', 'approved', 4413, 43, 1631),
('11:00:00', '09:00:00', 'approved', 4414, 44, 1632),
('11:00:00', '09:00:00', 'approved', 4415, 46, 1633),
('11:00:00', '09:00:00', 'approved', 4416, 46, 1634),
('11:00:00', '09:00:00', 'approved', 4417, 48, 1635),
('11:00:00', '09:00:00', 'approved', 4418, 49, 1636),
('11:00:00', '09:00:00', 'approved', 4419, 50, 1637),
('11:00:00', '09:00:00', 'approved', 4420, 44, 1638),
('11:00:00', '09:00:00', 'approved', 4421, 47, 1639),
('11:00:00', '09:00:00', 'approved', 4422, 48, 1640),
('11:00:00', '09:00:00', 'approved', 4423, 49, 1641),
('11:00:00', '09:00:00', 'approved', 4424, 43, 1642),
('11:00:00', '09:00:00', 'approved', 4425, 47, 1643),
('11:00:00', '09:00:00', 'approved', 4426, 49, 1644),
('11:00:00', '09:00:00', 'approved', 4427, 50, 1645),
('11:00:00', '09:00:00', 'approved', 4428, 41, 1646),
('11:00:00', '09:00:00', 'approved', 4429, 46, 1647),
('11:00:00', '09:00:00', 'approved', 4430, 48, 1648),
('11:00:00', '09:00:00', 'approved', 4431, 49, 1649),
('11:00:00', '09:00:00', 'approved', 4432, 50, 1650),
('11:00:00', '09:00:00', 'approved', 4433, 44, 1651),
('11:00:00', '09:00:00', 'approved', 4434, 48, 1652),
('11:00:00', '09:00:00', 'approved', 4435, 50, 1653),
('11:00:00', '09:00:00', 'approved', 4436, 41, 1654),
('11:00:00', '09:00:00', 'approved', 4437, 43, 1655),
('11:00:00', '09:00:00', 'approved', 4438, 47, 1656),
('11:00:00', '09:00:00', 'approved', 4439, 49, 1657),
('11:00:00', '09:00:00', 'approved', 4440, 50, 1658),
('11:00:00', '09:00:00', 'approved', 4441, 41, 1659),
('11:00:00', '09:00:00', 'approved', 4442, 46, 1660),
('11:00:00', '09:00:00', 'approved', 4443, 49, 1661),
('11:00:00', '09:00:00', 'approved', 4444, 41, 1662),
('11:00:00', '09:00:00', 'approved', 4445, 43, 1663),
('11:00:00', '09:00:00', 'approved', 4446, 44, 1664),
('11:00:00', '09:00:00', 'approved', 4447, 48, 1665),
('11:00:00', '09:00:00', 'approved', 4448, 50, 1666),
('11:00:00', '09:00:00', 'approved', 4449, 41, 1667),
('11:00:00', '09:00:00', 'approved', 4450, 43, 1668),
('11:00:00', '09:00:00', 'approved', 4451, 47, 1669),
('11:00:00', '09:00:00', 'approved', 4452, 46, 1670),
('11:00:00', '09:00:00', 'approved', 4453, 47, 1671),
('11:00:00', '09:00:00', 'approved', 4454, 48, 1672),
('11:00:00', '09:00:00', 'approved', 4455, 41, 1673),
('11:00:00', '09:00:00', 'approved', 4456, 44, 1674),
('11:00:00', '09:00:00', 'approved', 4457, 46, 1675),
('11:00:00', '09:00:00', 'approved', 4458, 47, 1676),
('11:00:00', '09:00:00', 'approved', 4459, 50, 1677),
('11:00:00', '09:00:00', 'approved', 4460, 43, 1678),
('11:00:00', '09:00:00', 'approved', 4461, 44, 1679),
('11:00:00', '09:00:00', 'approved', 4462, 46, 1680),
('11:00:00', '09:00:00', 'approved', 4463, 49, 1681),
('11:00:00', '09:00:00', 'approved', 4464, 41, 1682),
('11:00:00', '09:00:00', 'approved', 4465, 47, 1683),
('11:00:00', '09:00:00', 'approved', 4466, 48, 1684),
('11:00:00', '09:00:00', 'approved', 4467, 49, 1685),
('11:00:00', '09:00:00', 'approved', 4468, 43, 1686),
('11:00:00', '09:00:00', 'approved', 4469, 46, 1687),
('11:00:00', '09:00:00', 'approved', 4470, 47, 1688),
('11:00:00', '09:00:00', 'approved', 4471, 48, 1689),
('11:00:00', '09:00:00', 'approved', 4472, 41, 1690),
('11:00:00', '09:00:00', 'approved', 4473, 44, 1691),
('11:00:00', '09:00:00', 'approved', 4474, 46, 1692),
('11:00:00', '09:00:00', 'approved', 4475, 47, 1693),
('11:00:00', '09:00:00', 'approved', 4476, 50, 1694),
('11:00:00', '09:00:00', 'approved', 4477, 43, 1695),
('11:00:00', '09:00:00', 'approved', 4478, 48, 1696),
('11:00:00', '09:00:00', 'approved', 4479, 49, 1697),
('11:00:00', '09:00:00', 'approved', 4480, 50, 1698),
('11:00:00', '09:00:00', 'approved', 4481, 44, 1699),
('11:00:00', '09:00:00', 'approved', 4482, 47, 1700),
('11:00:00', '09:00:00', 'approved', 4483, 48, 1701),
('11:00:00', '09:00:00', 'approved', 4484, 49, 1702),
('11:00:00', '09:00:00', 'approved', 4485, 43, 1703),
('11:00:00', '09:00:00', 'approved', 4486, 46, 1704),
('11:00:00', '09:00:00', 'approved', 4487, 47, 1705),
('11:00:00', '09:00:00', 'approved', 4488, 48, 1706),
('11:00:00', '09:00:00', 'approved', 4489, 41, 1707),
('11:00:00', '09:00:00', 'approved', 4490, 44, 1708),
('11:00:00', '09:00:00', 'approved', 4491, 49, 1709),
('11:00:00', '09:00:00', 'approved', 4492, 50, 1710),
('11:00:00', '09:00:00', 'approved', 4493, 41, 1711),
('11:00:00', '09:00:00', 'approved', 4494, 46, 1712),
('11:00:00', '09:00:00', 'approved', 4495, 48, 1713),
('11:00:00', '09:00:00', 'approved', 4496, 49, 1714),
('11:00:00', '09:00:00', 'approved', 4497, 50, 1715),
('11:00:00', '09:00:00', 'approved', 4498, 44, 1716),
('11:00:00', '09:00:00', 'approved', 4499, 47, 1717),
('11:00:00', '09:00:00', 'approved', 4500, 48, 1718),
('11:00:00', '09:00:00', 'approved', 4501, 49, 1719),
('11:00:00', '09:00:00', 'approved', 4502, 43, 1720),
('11:00:00', '09:00:00', 'approved', 4503, 46, 1721),
('11:00:00', '09:00:00', 'approved', 4504, 43, 1722),
('11:00:00', '09:00:00', 'approved', 4505, 44, 1723),
('11:00:00', '09:00:00', 'approved', 4506, 48, 1724),
('11:00:00', '09:00:00', 'approved', 4507, 50, 1725),
('11:00:00', '09:00:00', 'approved', 4508, 41, 1726),
('11:00:00', '09:00:00', 'approved', 4509, 43, 1727),
('11:00:00', '09:00:00', 'approved', 4510, 47, 1728),
('11:00:00', '09:00:00', 'approved', 4511, 49, 1729),
('11:00:00', '09:00:00', 'approved', 4512, 50, 1730),
('11:00:00', '09:00:00', 'approved', 4513, 41, 1731),
('11:00:00', '09:00:00', 'approved', 4514, 46, 1732),
('11:00:00', '09:00:00', 'approved', 4515, 48, 1733),
('11:00:00', '09:00:00', 'approved', 4516, 49, 1734),
('11:00:00', '09:00:00', 'approved', 4517, 44, 1735),
('11:00:00', '09:00:00', 'approved', 4518, 46, 1736),
('11:00:00', '09:00:00', 'approved', 4519, 49, 1737),
('11:00:00', '09:00:00', 'approved', 4520, 41, 1738),
('11:00:00', '09:00:00', 'approved', 4521, 43, 1739),
('11:00:00', '09:00:00', 'approved', 4522, 44, 1740),
('11:00:00', '09:00:00', 'approved', 4523, 48, 1741),
('11:00:00', '09:00:00', 'approved', 4524, 50, 1742),
('11:00:00', '09:00:00', 'approved', 4525, 41, 1743),
('11:00:00', '09:00:00', 'approved', 4526, 43, 1744),
('11:00:00', '09:00:00', 'approved', 4527, 47, 1745),
('11:00:00', '09:00:00', 'approved', 4528, 49, 1746),
('11:00:00', '09:00:00', 'approved', 4529, 50, 1747),
('11:00:00', '09:00:00', 'approved', 4530, 46, 1748),
('11:00:00', '09:00:00', 'approved', 4531, 47, 1749),
('11:00:00', '09:00:00', 'approved', 4532, 50, 1750),
('11:00:00', '09:00:00', 'approved', 4533, 43, 1751),
('11:00:00', '09:00:00', 'approved', 4534, 44, 1752),
('11:00:00', '09:00:00', 'approved', 4535, 46, 1753),
('11:00:00', '09:00:00', 'approved', 4536, 49, 1754),
('11:00:00', '09:00:00', 'approved', 4537, 41, 1755),
('11:00:00', '09:00:00', 'approved', 4538, 43, 1756),
('11:00:00', '09:00:00', 'approved', 4539, 44, 1757),
('11:00:00', '09:00:00', 'approved', 4540, 48, 1758),
('11:00:00', '09:00:00', 'approved', 4541, 50, 1759),
('11:00:00', '09:00:00', 'approved', 4542, 41, 1760),
('11:00:00', '09:00:00', 'approved', 4543, 47, 1761),
('11:00:00', '09:00:00', 'approved', 4544, 48, 1762),
('11:00:00', '09:00:00', 'approved', 4545, 41, 1763),
('11:00:00', '09:00:00', 'approved', 4546, 44, 1764),
('11:00:00', '09:00:00', 'approved', 4547, 46, 1765),
('11:00:00', '09:00:00', 'approved', 4548, 47, 1766),
('11:00:00', '09:00:00', 'approved', 4549, 50, 1767),
('11:00:00', '09:00:00', 'approved', 4550, 43, 1768),
('11:00:00', '09:00:00', 'approved', 4551, 44, 1769),
('11:00:00', '09:00:00', 'approved', 4552, 46, 1770),
('11:00:00', '09:00:00', 'approved', 4553, 49, 1771),
('11:00:00', '09:00:00', 'approved', 4554, 41, 1772),
('11:00:00', '09:00:00', 'approved', 4555, 43, 1773),
('11:00:00', '09:00:00', 'approved', 4556, 50, 1774),
('11:00:00', '09:00:00', 'approved', 4557, 44, 1775),
('11:00:00', '09:00:00', 'approved', 4558, 47, 1776),
('11:00:00', '09:00:00', 'approved', 4559, 48, 1777),
('11:00:00', '09:00:00', 'approved', 4560, 49, 1778),
('11:00:00', '09:00:00', 'approved', 4561, 43, 1779),
('11:00:00', '09:00:00', 'approved', 4562, 46, 1780),
('11:00:00', '09:00:00', 'approved', 4563, 47, 1781),
('11:00:00', '09:00:00', 'approved', 4564, 48, 1782),
('11:00:00', '09:00:00', 'approved', 4565, 41, 1783),
('11:00:00', '09:00:00', 'approved', 4566, 44, 1784),
('11:00:00', '09:00:00', 'approved', 4567, 46, 1785),
('11:00:00', '09:00:00', 'approved', 4568, 47, 1786),
('11:00:00', '09:00:00', 'approved', 4569, 41, 1787),
('11:00:00', '09:00:00', 'approved', 4570, 46, 1788),
('11:00:00', '09:00:00', 'approved', 4571, 48, 1789),
('11:00:00', '09:00:00', 'approved', 4572, 49, 1790),
('11:00:00', '09:00:00', 'approved', 4573, 50, 1791),
('11:00:00', '09:00:00', 'approved', 4574, 44, 1792),
('11:00:00', '09:00:00', 'approved', 4575, 47, 1793),
('11:00:00', '09:00:00', 'approved', 4576, 48, 1794),
('11:00:00', '09:00:00', 'approved', 4577, 49, 1795),
('11:00:00', '09:00:00', 'approved', 4578, 43, 1796),
('11:00:00', '09:00:00', 'approved', 4579, 46, 1797),
('11:00:00', '09:00:00', 'approved', 4580, 47, 1798),
('11:00:00', '09:00:00', 'approved', 4581, 48, 1799),
('11:00:00', '09:00:00', 'approved', 4582, 43, 1800),
('11:00:00', '09:00:00', 'approved', 4583, 47, 1801),
('11:00:00', '09:00:00', 'approved', 4584, 49, 1802),
('11:00:00', '09:00:00', 'approved', 4585, 50, 1803),
('11:00:00', '09:00:00', 'approved', 4586, 41, 1804),
('11:00:00', '09:00:00', 'approved', 4587, 46, 1805),
('11:00:00', '09:00:00', 'approved', 4588, 48, 1806),
('11:00:00', '09:00:00', 'approved', 4589, 49, 1807),
('11:00:00', '09:00:00', 'approved', 4590, 50, 1808),
('11:00:00', '09:00:00', 'approved', 4591, 44, 1809),
('11:00:00', '09:00:00', 'approved', 4592, 47, 1810),
('11:00:00', '09:00:00', 'approved', 4593, 48, 1811),
('11:00:00', '09:00:00', 'approved', 4594, 49, 1812),
('11:00:00', '09:00:00', 'approved', 4595, 44, 1813),
('11:00:00', '09:00:00', 'approved', 4596, 48, 1814),
('11:00:00', '09:00:00', 'approved', 4597, 50, 1815),
('11:00:00', '09:00:00', 'approved', 4598, 41, 1816),
('11:00:00', '09:00:00', 'approved', 4599, 43, 1817),
('11:00:00', '09:00:00', 'approved', 4600, 47, 1818),
('11:00:00', '09:00:00', 'approved', 4601, 49, 1819),
('11:00:00', '09:00:00', 'approved', 4602, 50, 1820),
('11:00:00', '09:00:00', 'approved', 4603, 41, 1821),
('11:00:00', '09:00:00', 'approved', 4604, 46, 1822),
('11:00:00', '09:00:00', 'approved', 4605, 48, 1823),
('11:00:00', '09:00:00', 'approved', 4606, 49, 1824),
('11:00:00', '09:00:00', 'approved', 4607, 50, 1825),
('11:00:00', '09:00:00', 'approved', 4608, 50, 1826),
('11:00:00', '09:00:00', 'approved', 4609, 43, 1827),
('11:00:00', '09:00:00', 'approved', 4610, 44, 1828),
('11:00:00', '09:00:00', 'approved', 4611, 46, 1829),
('11:00:00', '09:00:00', 'approved', 4612, 49, 1830),
('11:00:00', '09:00:00', 'approved', 4613, 41, 1831),
('11:00:00', '09:00:00', 'approved', 4614, 43, 1832),
('11:00:00', '09:00:00', 'approved', 4615, 44, 1833),
('11:00:00', '09:00:00', 'approved', 4616, 48, 1834),
('11:00:00', '09:00:00', 'approved', 4617, 50, 1835),
('11:00:00', '09:00:00', 'approved', 4618, 41, 1836),
('11:00:00', '09:00:00', 'approved', 4619, 43, 1837),
('11:00:00', '09:00:00', 'approved', 4620, 47, 1838),
('11:00:00', '09:00:00', 'approved', 4621, 41, 1839),
('11:00:00', '09:00:00', 'approved', 4622, 44, 1840),
('11:00:00', '09:00:00', 'approved', 4623, 46, 1841),
('11:00:00', '09:00:00', 'approved', 4624, 47, 1842),
('11:00:00', '09:00:00', 'approved', 4625, 50, 1843),
('11:00:00', '09:00:00', 'approved', 4626, 43, 1844),
('11:00:00', '09:00:00', 'approved', 4627, 44, 1845),
('11:00:00', '09:00:00', 'approved', 4628, 46, 1846),
('11:00:00', '09:00:00', 'approved', 4629, 49, 1847),
('11:00:00', '09:00:00', 'approved', 4630, 41, 1848),
('11:00:00', '09:00:00', 'approved', 4631, 43, 1849),
('11:00:00', '09:00:00', 'approved', 4632, 44, 1850),
('11:00:00', '09:00:00', 'approved', 4633, 48, 1851),
('11:00:00', '09:00:00', 'approved', 4634, 43, 1852),
('11:00:00', '09:00:00', 'approved', 4635, 46, 1853),
('11:00:00', '09:00:00', 'approved', 4636, 47, 1854),
('11:00:00', '09:00:00', 'approved', 4637, 48, 1855),
('11:00:00', '09:00:00', 'approved', 4638, 41, 1856),
('11:00:00', '09:00:00', 'approved', 4639, 44, 1857),
('11:00:00', '09:00:00', 'approved', 4640, 46, 1858),
('11:00:00', '09:00:00', 'approved', 4641, 47, 1859),
('11:00:00', '09:00:00', 'approved', 4642, 50, 1860),
('11:00:00', '09:00:00', 'approved', 4643, 43, 1861),
('11:00:00', '09:00:00', 'approved', 4644, 44, 1862),
('11:00:00', '09:00:00', 'approved', 4645, 46, 1863),
('11:00:00', '09:00:00', 'approved', 4646, 49, 1864),
('11:00:00', '09:00:00', 'approved', 4647, 44, 1865),
('11:00:00', '09:00:00', 'approved', 4648, 47, 1866),
('11:00:00', '09:00:00', 'approved', 4649, 48, 1867),
('11:00:00', '09:00:00', 'approved', 4650, 49, 1868),
('11:00:00', '09:00:00', 'approved', 4651, 43, 1869),
('11:00:00', '09:00:00', 'approved', 4652, 46, 1870),
('11:00:00', '09:00:00', 'approved', 4653, 47, 1871),
('11:00:00', '09:00:00', 'approved', 4654, 48, 1872),
('11:00:00', '09:00:00', 'approved', 4655, 41, 1873),
('11:00:00', '09:00:00', 'approved', 4656, 44, 1874),
('11:00:00', '09:00:00', 'approved', 4657, 46, 1875),
('11:00:00', '09:00:00', 'approved', 4658, 47, 1876),
('11:00:00', '09:00:00', 'approved', 4659, 50, 1877),
('11:00:00', '09:00:00', 'approved', 4660, 49, 1878),
('11:00:00', '09:00:00', 'approved', 4661, 50, 1879),
('11:00:00', '09:00:00', 'approved', 4662, 41, 1880),
('11:00:00', '09:00:00', 'approved', 4663, 46, 1881),
('11:00:00', '09:00:00', 'approved', 4664, 48, 1882),
('11:00:00', '09:00:00', 'approved', 4665, 49, 1883),
('11:00:00', '09:00:00', 'approved', 4666, 50, 1884),
('11:00:00', '09:00:00', 'approved', 4667, 44, 1885),
('11:00:00', '09:00:00', 'approved', 4668, 47, 1886),
('11:00:00', '09:00:00', 'approved', 4669, 48, 1887),
('11:00:00', '09:00:00', 'approved', 4670, 49, 1888),
('11:00:00', '09:00:00', 'approved', 4671, 43, 1889),
('11:00:00', '09:00:00', 'approved', 4672, 46, 1890),
('11:00:00', '09:00:00', 'approved', 4673, 50, 1891),
('11:00:00', '09:00:00', 'approved', 4674, 41, 1892),
('11:00:00', '09:00:00', 'approved', 4675, 43, 1893),
('11:00:00', '09:00:00', 'approved', 4676, 47, 1894),
('11:00:00', '09:00:00', 'approved', 4677, 49, 1895),
('11:00:00', '09:00:00', 'approved', 4678, 50, 1896),
('11:00:00', '09:00:00', 'approved', 4679, 41, 1897),
('11:00:00', '09:00:00', 'approved', 4680, 46, 1898),
('11:00:00', '09:00:00', 'approved', 4681, 48, 1899),
('11:00:00', '09:00:00', 'approved', 4682, 49, 1900),
('11:00:00', '09:00:00', 'approved', 4683, 50, 1901),
('11:00:00', '09:00:00', 'approved', 4684, 44, 1902),
('11:00:00', '09:00:00', 'approved', 4685, 47, 1903),
('11:00:00', '09:00:00', 'approved', 4686, 41, 1904),
('11:00:00', '09:00:00', 'approved', 4687, 43, 1905),
('11:00:00', '09:00:00', 'approved', 4688, 44, 1906),
('11:00:00', '09:00:00', 'approved', 4689, 48, 1907),
('11:00:00', '09:00:00', 'approved', 4690, 50, 1908),
('11:00:00', '09:00:00', 'approved', 4691, 41, 1909),
('11:00:00', '09:00:00', 'approved', 4692, 43, 1910),
('11:00:00', '09:00:00', 'approved', 4693, 47, 1911),
('11:00:00', '09:00:00', 'approved', 4694, 49, 1912),
('11:00:00', '09:00:00', 'approved', 4695, 50, 1913),
('11:00:00', '09:00:00', 'approved', 4696, 41, 1914),
('11:00:00', '09:00:00', 'approved', 4697, 46, 1915),
('11:00:00', '09:00:00', 'approved', 4698, 48, 1916),
('11:00:00', '09:00:00', 'approved', 4699, 43, 1917),
('11:00:00', '09:00:00', 'approved', 4700, 44, 1918),
('11:00:00', '09:00:00', 'approved', 4701, 46, 1919),
('11:00:00', '09:00:00', 'approved', 4702, 49, 1920),
('11:00:00', '09:00:00', 'approved', 4703, 41, 1921),
('11:00:00', '09:00:00', 'approved', 4704, 43, 1922),
('11:00:00', '09:00:00', 'approved', 4705, 44, 1923),
('11:00:00', '09:00:00', 'approved', 4706, 48, 1924),
('11:00:00', '09:00:00', 'approved', 4707, 50, 1925),
('11:00:00', '09:00:00', 'approved', 4708, 41, 1926),
('11:00:00', '09:00:00', 'approved', 4709, 43, 1927),
('11:00:00', '09:00:00', 'approved', 4710, 47, 1928),
('11:00:00', '09:00:00', 'approved', 4711, 49, 1929),
('11:00:00', '09:00:00', 'approved', 4712, 47, 1930),
('11:00:00', '09:00:00', 'approved', 4713, 48, 1931),
('11:00:00', '09:00:00', 'approved', 4714, 41, 1932),
('11:00:00', '09:00:00', 'approved', 4715, 44, 1933),
('11:00:00', '09:00:00', 'approved', 4716, 46, 1934),
('11:00:00', '09:00:00', 'approved', 4717, 47, 1935),
('11:00:00', '09:00:00', 'approved', 4718, 50, 1936),
('11:00:00', '09:00:00', 'approved', 4719, 43, 1937),
('11:00:00', '09:00:00', 'approved', 4720, 44, 1938),
('11:00:00', '09:00:00', 'approved', 4721, 46, 1939),
('11:00:00', '09:00:00', 'approved', 4722, 49, 1940),
('11:00:00', '09:00:00', 'approved', 4723, 41, 1941),
('11:00:00', '09:00:00', 'approved', 4724, 43, 1942),
('11:00:00', '09:00:00', 'approved', 4725, 48, 1943),
('11:00:00', '09:00:00', 'approved', 4726, 49, 1944),
('11:00:00', '09:00:00', 'approved', 4727, 43, 1945),
('11:00:00', '09:00:00', 'approved', 4728, 46, 1946),
('11:00:00', '09:00:00', 'approved', 4729, 47, 1947),
('11:00:00', '09:00:00', 'approved', 4730, 48, 1948),
('11:00:00', '09:00:00', 'approved', 4731, 41, 1949),
('11:00:00', '09:00:00', 'approved', 4732, 44, 1950),
('11:00:00', '09:00:00', 'approved', 4733, 46, 1951),
('11:00:00', '09:00:00', 'approved', 4734, 47, 1952),
('11:00:00', '09:00:00', 'approved', 4735, 50, 1953),
('11:00:00', '09:00:00', 'approved', 4736, 43, 1954),
('11:00:00', '09:00:00', 'approved', 4737, 44, 1955),
('11:00:00', '09:00:00', 'approved', 4738, 49, 1956),
('11:00:00', '09:00:00', 'approved', 4739, 50, 1957),
('11:00:00', '09:00:00', 'approved', 4740, 44, 1958),
('11:00:00', '09:00:00', 'approved', 4741, 47, 1959),
('11:00:00', '09:00:00', 'approved', 4742, 48, 1960),
('11:00:00', '09:00:00', 'approved', 4743, 49, 1961),
('11:00:00', '09:00:00', 'approved', 4744, 43, 1962),
('11:00:00', '09:00:00', 'approved', 4745, 46, 1963),
('11:00:00', '09:00:00', 'approved', 4746, 47, 1964),
('11:00:00', '09:00:00', 'approved', 4747, 48, 1965),
('11:00:00', '09:00:00', 'approved', 4748, 41, 1966),
('11:00:00', '09:00:00', 'approved', 4749, 44, 1967),
('11:00:00', '09:00:00', 'approved', 4750, 46, 1968),
('11:00:00', '09:00:00', 'approved', 4751, 50, 1969),
('11:00:00', '09:00:00', 'approved', 4752, 41, 1970),
('11:00:00', '09:00:00', 'approved', 4753, 46, 1971),
('11:00:00', '09:00:00', 'approved', 4754, 48, 1972),
('11:00:00', '09:00:00', 'approved', 4755, 49, 1973),
('11:00:00', '09:00:00', 'approved', 4756, 50, 1974),
('11:00:00', '09:00:00', 'approved', 4757, 44, 1975),
('11:00:00', '09:00:00', 'approved', 4758, 47, 1976),
('11:00:00', '09:00:00', 'approved', 4759, 48, 1977),
('11:00:00', '09:00:00', 'approved', 4760, 49, 1978),
('11:00:00', '09:00:00', 'approved', 4761, 43, 1979),
('11:00:00', '09:00:00', 'approved', 4762, 46, 1980),
('11:00:00', '09:00:00', 'approved', 4763, 47, 1981),
('11:00:00', '09:00:00', 'approved', 4764, 44, 1982),
('11:00:00', '09:00:00', 'approved', 4765, 48, 1983),
('11:00:00', '09:00:00', 'approved', 4766, 50, 1984),
('11:00:00', '09:00:00', 'approved', 4767, 41, 1985),
('11:00:00', '09:00:00', 'approved', 4768, 43, 1986),
('11:00:00', '09:00:00', 'approved', 4769, 47, 1987),
('11:00:00', '09:00:00', 'approved', 4770, 49, 1988),
('11:00:00', '09:00:00', 'approved', 4771, 50, 1989),
('11:00:00', '09:00:00', 'approved', 4772, 41, 1990),
('11:00:00', '09:00:00', 'approved', 4773, 46, 1991),
('11:00:00', '09:00:00', 'approved', 4774, 48, 1992),
('11:00:00', '09:00:00', 'approved', 4775, 49, 1993),
('11:00:00', '09:00:00', 'approved', 4776, 50, 1994),
('11:00:00', '09:00:00', 'approved', 4777, 46, 1995),
('11:00:00', '09:00:00', 'approved', 4778, 49, 1996),
('11:00:00', '09:00:00', 'approved', 4779, 41, 1997),
('11:00:00', '09:00:00', 'approved', 4780, 43, 1998),
('11:00:00', '09:00:00', 'approved', 4781, 44, 1999),
('11:00:00', '09:00:00', 'approved', 4782, 48, 2000),
('11:00:00', '09:00:00', 'approved', 4783, 50, 2001),
('11:00:00', '09:00:00', 'approved', 4784, 41, 2002),
('11:00:00', '09:00:00', 'approved', 4785, 43, 2003),
('11:00:00', '09:00:00', 'approved', 4786, 47, 2004),
('11:00:00', '09:00:00', 'approved', 4787, 49, 2005),
('11:00:00', '09:00:00', 'approved', 4788, 50, 2006),
('11:00:00', '09:00:00', 'approved', 4789, 41, 2007),
('11:00:00', '09:00:00', 'approved', 4790, 47, 2008),
('11:00:00', '09:00:00', 'approved', 4791, 50, 2009),
('11:00:00', '09:00:00', 'approved', 4792, 43, 2010),
('11:00:00', '09:00:00', 'approved', 4793, 44, 2011),
('11:00:00', '09:00:00', 'approved', 4794, 46, 2012),
('11:00:00', '09:00:00', 'approved', 4795, 49, 2013),
('11:00:00', '09:00:00', 'approved', 4796, 41, 2014),
('11:00:00', '09:00:00', 'approved', 4797, 43, 2015),
('11:00:00', '09:00:00', 'approved', 4798, 44, 2016),
('11:00:00', '09:00:00', 'approved', 4799, 48, 2017),
('11:00:00', '09:00:00', 'approved', 4800, 50, 2018),
('11:00:00', '09:00:00', 'approved', 4801, 41, 2019),
('11:00:00', '09:00:00', 'approved', 4802, 43, 2020),
('11:00:00', '09:00:00', 'approved', 4803, 48, 2021),
('11:00:00', '09:00:00', 'approved', 4804, 41, 2022),
('11:00:00', '09:00:00', 'approved', 4805, 44, 2023),
('11:00:00', '09:00:00', 'approved', 4806, 46, 2024),
('11:00:00', '09:00:00', 'approved', 4807, 47, 2025),
('11:00:00', '09:00:00', 'approved', 4808, 50, 2026),
('11:00:00', '09:00:00', 'approved', 4809, 43, 2027),
('11:00:00', '09:00:00', 'approved', 4810, 44, 2028),
('11:00:00', '09:00:00', 'approved', 4811, 46, 2029),
('11:00:00', '09:00:00', 'approved', 4812, 49, 2030),
('11:00:00', '09:00:00', 'approved', 4813, 41, 2031),
('11:00:00', '09:00:00', 'approved', 4814, 43, 2032),
('11:00:00', '09:00:00', 'approved', 4815, 44, 2033),
('11:00:00', '09:00:00', 'approved', 4816, 44, 2034),
('11:00:00', '09:00:00', 'approved', 4817, 47, 2035),
('11:00:00', '09:00:00', 'approved', 4818, 48, 2036),
('11:00:00', '09:00:00', 'approved', 4819, 49, 2037),
('11:00:00', '09:00:00', 'approved', 4820, 43, 2038),
('11:00:00', '09:00:00', 'approved', 4821, 46, 2039),
('11:00:00', '09:00:00', 'approved', 4822, 47, 2040),
('11:00:00', '09:00:00', 'approved', 4823, 48, 2041),
('11:00:00', '09:00:00', 'approved', 4824, 41, 2042),
('11:00:00', '09:00:00', 'approved', 4825, 44, 2043),
('11:00:00', '09:00:00', 'approved', 4826, 46, 2044),
('11:00:00', '09:00:00', 'approved', 4827, 47, 2045),
('11:00:00', '09:00:00', 'approved', 4828, 50, 2046),
('11:00:00', '09:00:00', 'approved', 4829, 46, 2047),
('11:00:00', '09:00:00', 'approved', 4830, 48, 2048),
('11:00:00', '09:00:00', 'approved', 4831, 49, 2049),
('11:00:00', '09:00:00', 'approved', 4832, 50, 2050),
('11:00:00', '09:00:00', 'approved', 4833, 44, 2051),
('11:00:00', '09:00:00', 'approved', 4834, 47, 2052),
('11:00:00', '09:00:00', 'approved', 4835, 48, 2053),
('11:00:00', '09:00:00', 'approved', 4836, 49, 2054),
('11:00:00', '09:00:00', 'approved', 4837, 43, 2055),
('11:00:00', '09:00:00', 'approved', 4838, 46, 2056),
('11:00:00', '09:00:00', 'approved', 4839, 47, 2057),
('11:00:00', '09:00:00', 'approved', 4840, 48, 2058),
('11:00:00', '09:00:00', 'approved', 4841, 41, 2059),
('11:00:00', '09:00:00', 'approved', 4842, 47, 2060),
('11:00:00', '09:00:00', 'approved', 4843, 49, 2061),
('11:00:00', '09:00:00', 'approved', 4844, 50, 2062),
('11:00:00', '09:00:00', 'approved', 4845, 41, 2063),
('11:00:00', '09:00:00', 'approved', 4846, 46, 2064),
('11:00:00', '09:00:00', 'approved', 4847, 48, 2065),
('11:00:00', '09:00:00', 'approved', 4848, 49, 2066),
('11:00:00', '09:00:00', 'approved', 4849, 50, 2067),
('11:00:00', '09:00:00', 'approved', 4850, 44, 2068),
('11:00:00', '09:00:00', 'approved', 4851, 47, 2069),
('11:00:00', '09:00:00', 'approved', 4852, 48, 2070),
('11:00:00', '09:00:00', 'approved', 4853, 49, 2071),
('11:00:00', '09:00:00', 'approved', 4854, 43, 2072),
('11:00:00', '09:00:00', 'approved', 4855, 48, 2073),
('11:00:00', '09:00:00', 'approved', 4856, 50, 2074),
('11:00:00', '09:00:00', 'approved', 4857, 41, 2075),
('11:00:00', '09:00:00', 'approved', 4858, 43, 2076),
('11:00:00', '09:00:00', 'approved', 4859, 47, 2077),
('11:00:00', '09:00:00', 'approved', 4860, 49, 2078),
('11:00:00', '09:00:00', 'approved', 4861, 50, 2079),
('11:00:00', '09:00:00', 'approved', 4862, 41, 2080),
('11:00:00', '09:00:00', 'approved', 4863, 46, 2081),
('11:00:00', '09:00:00', 'approved', 4864, 48, 2082),
('11:00:00', '09:00:00', 'approved', 4865, 49, 2083),
('11:00:00', '09:00:00', 'approved', 4866, 50, 2084),
('11:00:00', '09:00:00', 'approved', 4867, 44, 2085),
('11:00:00', '09:00:00', 'approved', 4868, 43, 2086),
('11:00:00', '09:00:00', 'approved', 4869, 44, 2087),
('11:00:00', '09:00:00', 'approved', 4870, 46, 2088),
('11:00:00', '09:00:00', 'approved', 4871, 49, 2089),
('11:00:00', '09:00:00', 'approved', 4872, 41, 2090),
('11:00:00', '09:00:00', 'approved', 4873, 43, 2091),
('11:00:00', '09:00:00', 'approved', 4874, 44, 2092),
('11:00:00', '09:00:00', 'approved', 4875, 48, 2093),
('11:00:00', '09:00:00', 'approved', 4876, 50, 2094),
('11:00:00', '09:00:00', 'approved', 4877, 41, 2095),
('11:00:00', '09:00:00', 'approved', 4878, 43, 2096),
('11:00:00', '09:00:00', 'approved', 4879, 47, 2097),
('11:00:00', '09:00:00', 'approved', 4880, 49, 2098),
('11:00:00', '09:00:00', 'approved', 4881, 44, 2099),
('11:00:00', '09:00:00', 'approved', 4882, 46, 2100),
('11:00:00', '09:00:00', 'approved', 4883, 47, 2101),
('11:00:00', '09:00:00', 'approved', 4884, 50, 2102),
('11:00:00', '09:00:00', 'approved', 4885, 43, 2103),
('11:00:00', '09:00:00', 'approved', 4886, 44, 2104),
('11:00:00', '09:00:00', 'approved', 4887, 46, 2105),
('11:00:00', '09:00:00', 'approved', 4888, 49, 2106),
('11:00:00', '09:00:00', 'approved', 4889, 41, 2107),
('11:00:00', '09:00:00', 'approved', 4890, 43, 2108),
('11:00:00', '09:00:00', 'approved', 4891, 44, 2109),
('11:00:00', '09:00:00', 'approved', 4892, 48, 2110),
('11:00:00', '09:00:00', 'approved', 4893, 50, 2111),
('11:00:00', '09:00:00', 'approved', 4894, 46, 2112),
('11:00:00', '09:00:00', 'approved', 4895, 47, 2113),
('11:00:00', '09:00:00', 'approved', 4896, 48, 2114),
('11:00:00', '09:00:00', 'approved', 4897, 41, 2115),
('11:00:00', '09:00:00', 'approved', 4898, 44, 2116),
('11:00:00', '09:00:00', 'approved', 4899, 46, 2117),
('11:00:00', '09:00:00', 'approved', 4900, 47, 2118),
('11:00:00', '09:00:00', 'approved', 4901, 50, 2119),
('11:00:00', '09:00:00', 'approved', 4902, 43, 2120),
('11:00:00', '09:00:00', 'approved', 4903, 44, 2121),
('11:00:00', '09:00:00', 'approved', 4904, 46, 2122),
('11:00:00', '09:00:00', 'approved', 4905, 49, 2123),
('11:00:00', '09:00:00', 'approved', 4906, 41, 2124),
('11:00:00', '09:00:00', 'approved', 4907, 47, 2125),
('11:00:00', '09:00:00', 'approved', 4908, 48, 2126),
('11:00:00', '09:00:00', 'approved', 4909, 49, 2127),
('11:00:00', '09:00:00', 'approved', 4910, 43, 2128),
('11:00:00', '09:00:00', 'approved', 4911, 46, 2129),
('11:00:00', '09:00:00', 'approved', 4912, 47, 2130),
('11:00:00', '09:00:00', 'approved', 4913, 48, 2131),
('11:00:00', '09:00:00', 'approved', 4914, 41, 2132),
('11:00:00', '09:00:00', 'approved', 4915, 44, 2133),
('11:00:00', '09:00:00', 'approved', 4916, 46, 2134),
('11:00:00', '09:00:00', 'approved', 4917, 47, 2135),
('11:00:00', '09:00:00', 'approved', 4918, 50, 2136),
('11:00:00', '09:00:00', 'approved', 4919, 43, 2137),
('11:00:00', '09:00:00', 'approved', 4920, 50, 2138),
('11:00:00', '09:00:00', 'approved', 4921, 41, 2139),
('11:00:00', '09:00:00', 'approved', 4922, 46, 2140),
('11:00:00', '09:00:00', 'approved', 4923, 48, 2141),
('11:00:00', '09:00:00', 'approved', 4924, 49, 2142),
('11:00:00', '09:00:00', 'approved', 4925, 50, 2143),
('11:00:00', '09:00:00', 'approved', 4926, 44, 2144),
('11:00:00', '09:00:00', 'approved', 4927, 47, 2145),
('11:00:00', '09:00:00', 'approved', 4928, 48, 2146),
('11:00:00', '09:00:00', 'approved', 4929, 49, 2147),
('11:00:00', '09:00:00', 'approved', 4930, 43, 2148),
('11:00:00', '09:00:00', 'approved', 4931, 46, 2149),
('11:00:00', '09:00:00', 'approved', 4932, 47, 2150),
('11:00:00', '09:00:00', 'approved', 4933, 41, 2151),
('11:00:00', '09:00:00', 'approved', 4934, 43, 2152),
('11:00:00', '09:00:00', 'approved', 4935, 47, 2153),
('11:00:00', '09:00:00', 'approved', 4936, 49, 2154),
('11:00:00', '09:00:00', 'approved', 4937, 50, 2155),
('11:00:00', '09:00:00', 'approved', 4938, 41, 2156),
('11:00:00', '09:00:00', 'approved', 4939, 46, 2157),
('11:00:00', '09:00:00', 'approved', 4940, 48, 2158),
('11:00:00', '09:00:00', 'approved', 4941, 49, 2159),
('11:00:00', '09:00:00', 'approved', 4942, 50, 2160),
('11:00:00', '09:00:00', 'approved', 4943, 44, 2161),
('11:00:00', '09:00:00', 'approved', 4944, 47, 2162),
('11:00:00', '09:00:00', 'approved', 4945, 48, 2163),
('11:00:00', '09:00:00', 'approved', 4946, 43, 2164),
('11:00:00', '09:00:00', 'approved', 4947, 44, 2165),
('11:00:00', '09:00:00', 'approved', 4948, 48, 2166),
('11:00:00', '09:00:00', 'approved', 4949, 50, 2167),
('11:00:00', '09:00:00', 'approved', 4950, 41, 2168),
('11:00:00', '09:00:00', 'approved', 4951, 43, 2169),
('11:00:00', '09:00:00', 'approved', 4952, 47, 2170),
('11:00:00', '09:00:00', 'approved', 4953, 49, 2171),
('11:00:00', '09:00:00', 'approved', 4954, 50, 2172),
('11:00:00', '09:00:00', 'approved', 4955, 41, 2173),
('11:00:00', '09:00:00', 'approved', 4956, 46, 2174),
('11:00:00', '09:00:00', 'approved', 4957, 48, 2175),
('11:00:00', '09:00:00', 'approved', 4958, 49, 2176),
('11:00:00', '09:00:00', 'approved', 4959, 44, 2177),
('11:00:00', '09:00:00', 'approved', 4960, 46, 2178),
('11:00:00', '09:00:00', 'approved', 4961, 49, 2179),
('11:00:00', '09:00:00', 'approved', 4962, 41, 2180),
('11:00:00', '09:00:00', 'approved', 4963, 43, 2181),
('11:00:00', '09:00:00', 'approved', 4964, 44, 2182),
('11:00:00', '09:00:00', 'approved', 4965, 48, 2183),
('11:00:00', '09:00:00', 'approved', 4966, 50, 2184),
('11:00:00', '09:00:00', 'approved', 4967, 41, 2185),
('11:00:00', '09:00:00', 'approved', 4968, 43, 2186),
('11:00:00', '09:00:00', 'approved', 4969, 47, 2187),
('11:00:00', '09:00:00', 'approved', 4970, 49, 2188),
('11:00:00', '09:00:00', 'approved', 4971, 50, 2189),
('11:00:00', '09:00:00', 'approved', 4972, 48, 2190),
('11:00:00', '09:00:00', 'approved', 4973, 41, 2191),
('11:00:00', '09:00:00', 'approved', 4974, 44, 2192),
('11:00:00', '09:00:00', 'approved', 4975, 46, 2193),
('11:00:00', '09:00:00', 'approved', 4976, 47, 2194),
('11:00:00', '09:00:00', 'approved', 4977, 50, 2195),
('11:00:00', '09:00:00', 'approved', 4978, 43, 2196),
('11:00:00', '09:00:00', 'approved', 4979, 44, 2197),
('11:00:00', '09:00:00', 'approved', 4980, 46, 2198),
('11:00:00', '09:00:00', 'approved', 4981, 49, 2199),
('11:00:00', '09:00:00', 'approved', 4982, 41, 2200),
('11:00:00', '09:00:00', 'approved', 4983, 43, 2201),
('11:00:00', '09:00:00', 'approved', 4984, 44, 2202),
('11:00:00', '09:00:00', 'approved', 4985, 49, 2203),
('11:00:00', '09:00:00', 'approved', 4986, 43, 2204),
('11:00:00', '09:00:00', 'approved', 4987, 46, 2205),
('11:00:00', '09:00:00', 'approved', 4988, 47, 2206),
('11:00:00', '09:00:00', 'approved', 4989, 48, 2207),
('11:00:00', '09:00:00', 'approved', 4990, 41, 2208),
('11:00:00', '09:00:00', 'approved', 4991, 44, 2209),
('11:00:00', '09:00:00', 'approved', 4992, 46, 2210),
('11:00:00', '09:00:00', 'approved', 4993, 47, 2211),
('11:00:00', '09:00:00', 'approved', 4994, 50, 2212),
('11:00:00', '09:00:00', 'approved', 4995, 43, 2213),
('11:00:00', '09:00:00', 'approved', 4996, 44, 2214),
('11:00:00', '09:00:00', 'approved', 4997, 46, 2215),
('11:00:00', '09:00:00', 'approved', 4998, 50, 2216),
('11:00:00', '09:00:00', 'approved', 4999, 44, 2217),
('11:00:00', '09:00:00', 'approved', 5000, 47, 2218),
('11:00:00', '09:00:00', 'approved', 5001, 48, 2219),
('11:00:00', '09:00:00', 'approved', 5002, 49, 2220),
('11:00:00', '09:00:00', 'approved', 5003, 43, 2221),
('11:00:00', '09:00:00', 'approved', 5004, 46, 2222),
('11:00:00', '09:00:00', 'approved', 5005, 47, 2223),
('11:00:00', '09:00:00', 'approved', 5006, 48, 2224),
('11:00:00', '09:00:00', 'approved', 5007, 41, 2225),
('11:00:00', '09:00:00', 'approved', 5008, 44, 2226),
('11:00:00', '09:00:00', 'approved', 5009, 46, 2227),
('11:00:00', '09:00:00', 'approved', 5010, 47, 2228),
('11:00:00', '09:00:00', 'approved', 5011, 41, 2229),
('11:00:00', '09:00:00', 'approved', 5012, 46, 2230),
('11:00:00', '09:00:00', 'approved', 5013, 48, 2231),
('11:00:00', '09:00:00', 'approved', 5014, 49, 2232),
('11:00:00', '09:00:00', 'approved', 5015, 50, 2233),
('11:00:00', '09:00:00', 'approved', 5016, 44, 2234),
('11:00:00', '09:00:00', 'approved', 5017, 47, 2235),
('11:00:00', '09:00:00', 'approved', 5018, 48, 2236),
('11:00:00', '09:00:00', 'approved', 5019, 49, 2237),
('11:00:00', '09:00:00', 'approved', 5020, 43, 2238),
('11:00:00', '09:00:00', 'approved', 5021, 46, 2239),
('11:00:00', '09:00:00', 'approved', 5022, 47, 2240),
('11:00:00', '09:00:00', 'approved', 5023, 48, 2241),
('11:00:00', '09:00:00', 'approved', 5024, 48, 2242),
('11:00:00', '09:00:00', 'approved', 5025, 50, 2243),
('11:00:00', '09:00:00', 'approved', 5026, 41, 2244),
('11:00:00', '09:00:00', 'approved', 5027, 43, 2245),
('11:00:00', '09:00:00', 'approved', 5028, 47, 2246),
('11:00:00', '09:00:00', 'approved', 5029, 49, 2247),
('11:00:00', '09:00:00', 'approved', 5030, 50, 2248),
('11:00:00', '09:00:00', 'approved', 5031, 41, 2249),
('11:00:00', '09:00:00', 'approved', 5032, 46, 2250),
('11:00:00', '09:00:00', 'approved', 5033, 49, 2251),
('11:00:00', '09:00:00', 'approved', 5034, 41, 2252),
('11:00:00', '09:00:00', 'approved', 5035, 43, 2253),
('11:00:00', '09:00:00', 'approved', 5036, 44, 2254),
('11:00:00', '09:00:00', 'approved', 5037, 48, 2255),
('11:00:00', '09:00:00', 'approved', 5038, 50, 2256),
('11:00:00', '09:00:00', 'approved', 5039, 41, 2257),
('11:00:00', '09:00:00', 'approved', 5040, 43, 2258),
('11:00:00', '09:00:00', 'approved', 5041, 47, 2259),
('11:00:00', '09:00:00', 'approved', 5042, 50, 2260),
('11:00:00', '09:00:00', 'approved', 5043, 43, 2261),
('11:00:00', '09:00:00', 'approved', 5044, 44, 2262),
('11:00:00', '09:00:00', 'approved', 5045, 46, 2263),
('11:00:00', '09:00:00', 'approved', 5046, 49, 2264),
('11:00:00', '09:00:00', 'approved', 5047, 41, 2265),
('11:00:00', '09:00:00', 'approved', 5048, 43, 2266),
('11:00:00', '09:00:00', 'approved', 5049, 44, 2267),
('11:00:00', '09:00:00', 'approved', 5050, 48, 2268),
('11:00:00', '09:00:00', 'approved', 5051, 41, 2269),
('11:00:00', '09:00:00', 'approved', 5052, 44, 2270),
('11:00:00', '09:00:00', 'approved', 5053, 46, 2271),
('11:00:00', '09:00:00', 'approved', 5054, 47, 2272),
('11:00:00', '09:00:00', 'approved', 5055, 50, 2273),
('11:00:00', '09:00:00', 'approved', 5056, 43, 2274),
('11:00:00', '09:00:00', 'approved', 5057, 44, 2275),
('11:00:00', '09:00:00', 'approved', 5058, 46, 2276),
('11:00:00', '09:00:00', 'approved', 5059, 49, 2277),
('13:00:00', '11:00:00', 'approved', 5435, 50, 1618),
('13:00:00', '11:00:00', 'approved', 5436, 41, 1619),
('13:00:00', '11:00:00', 'approved', 5437, 43, 1620),
('13:00:00', '11:00:00', 'approved', 5438, 44, 1621),
('13:00:00', '11:00:00', 'approved', 5439, 43, 1622),
('13:00:00', '11:00:00', 'approved', 5440, 44, 1623),
('13:00:00', '11:00:00', 'approved', 5441, 46, 1624),
('13:00:00', '11:00:00', 'approved', 5442, 47, 1625),
('13:00:00', '11:00:00', 'approved', 5443, 49, 1634),
('13:00:00', '11:00:00', 'approved', 5444, 41, 1635),
('13:00:00', '11:00:00', 'approved', 5445, 43, 1636),
('13:00:00', '11:00:00', 'approved', 5446, 44, 1637),
('13:00:00', '11:00:00', 'approved', 5447, 48, 1638),
('13:00:00', '11:00:00', 'approved', 5448, 50, 1639),
('13:00:00', '11:00:00', 'approved', 5449, 41, 1640),
('13:00:00', '11:00:00', 'approved', 5450, 43, 1641),
('13:00:00', '11:00:00', 'approved', 5451, 47, 1642),
('13:00:00', '11:00:00', 'approved', 5452, 50, 1643),
('13:00:00', '11:00:00', 'approved', 5453, 43, 1644),
('13:00:00', '11:00:00', 'approved', 5454, 44, 1645),
('13:00:00', '11:00:00', 'approved', 5455, 46, 1646),
('13:00:00', '11:00:00', 'approved', 5456, 49, 1647),
('13:00:00', '11:00:00', 'approved', 5457, 41, 1648),
('13:00:00', '11:00:00', 'approved', 5458, 43, 1649),
('13:00:00', '11:00:00', 'approved', 5459, 44, 1650),
('13:00:00', '11:00:00', 'approved', 5460, 48, 1651),
('13:00:00', '11:00:00', 'approved', 5461, 41, 1652),
('13:00:00', '11:00:00', 'approved', 5462, 44, 1653),
('13:00:00', '11:00:00', 'approved', 5463, 46, 1654),
('13:00:00', '11:00:00', 'approved', 5464, 47, 1655),
('13:00:00', '11:00:00', 'approved', 5465, 50, 1656),
('13:00:00', '11:00:00', 'approved', 5466, 43, 1657),
('13:00:00', '11:00:00', 'approved', 5467, 44, 1658),
('13:00:00', '11:00:00', 'approved', 5468, 46, 1659),
('13:00:00', '11:00:00', 'approved', 5469, 49, 1660),
('13:00:00', '11:00:00', 'approved', 5470, 43, 1661),
('13:00:00', '11:00:00', 'approved', 5471, 46, 1662),
('13:00:00', '11:00:00', 'approved', 5472, 47, 1663),
('13:00:00', '11:00:00', 'approved', 5473, 48, 1664),
('13:00:00', '11:00:00', 'approved', 5474, 41, 1665),
('13:00:00', '11:00:00', 'approved', 5475, 44, 1666),
('13:00:00', '11:00:00', 'approved', 5476, 46, 1667),
('13:00:00', '11:00:00', 'approved', 5477, 47, 1668),
('13:00:00', '11:00:00', 'approved', 5478, 50, 1669),
('13:00:00', '11:00:00', 'approved', 5479, 49, 1670),
('13:00:00', '11:00:00', 'approved', 5480, 50, 1671),
('13:00:00', '11:00:00', 'approved', 5481, 41, 1672),
('13:00:00', '11:00:00', 'approved', 5482, 46, 1673),
('13:00:00', '11:00:00', 'approved', 5483, 48, 1674),
('13:00:00', '11:00:00', 'approved', 5484, 49, 1675),
('13:00:00', '11:00:00', 'approved', 5485, 50, 1676),
('13:00:00', '11:00:00', 'approved', 5486, 44, 1677),
('13:00:00', '11:00:00', 'approved', 5487, 47, 1678),
('13:00:00', '11:00:00', 'approved', 5488, 48, 1679),
('13:00:00', '11:00:00', 'approved', 5489, 49, 1680),
('13:00:00', '11:00:00', 'approved', 5490, 43, 1681),
('13:00:00', '11:00:00', 'approved', 5491, 46, 1682),
('13:00:00', '11:00:00', 'approved', 5492, 50, 1683),
('13:00:00', '11:00:00', 'approved', 5493, 41, 1684),
('13:00:00', '11:00:00', 'approved', 5494, 43, 1685),
('13:00:00', '11:00:00', 'approved', 5495, 47, 1686),
('13:00:00', '11:00:00', 'approved', 5496, 49, 1687),
('13:00:00', '11:00:00', 'approved', 5497, 50, 1688),
('13:00:00', '11:00:00', 'approved', 5498, 41, 1689),
('13:00:00', '11:00:00', 'approved', 5499, 46, 1690),
('13:00:00', '11:00:00', 'approved', 5500, 48, 1691),
('13:00:00', '11:00:00', 'approved', 5501, 49, 1692),
('13:00:00', '11:00:00', 'approved', 5502, 50, 1693),
('13:00:00', '11:00:00', 'approved', 5503, 44, 1694),
('13:00:00', '11:00:00', 'approved', 5504, 47, 1695),
('13:00:00', '11:00:00', 'approved', 5505, 41, 1696),
('13:00:00', '11:00:00', 'approved', 5506, 43, 1697),
('13:00:00', '11:00:00', 'approved', 5507, 44, 1698),
('13:00:00', '11:00:00', 'approved', 5508, 48, 1699),
('13:00:00', '11:00:00', 'approved', 5509, 50, 1700),
('13:00:00', '11:00:00', 'approved', 5510, 41, 1701),
('13:00:00', '11:00:00', 'approved', 5511, 43, 1702),
('13:00:00', '11:00:00', 'approved', 5512, 47, 1703),
('13:00:00', '11:00:00', 'approved', 5513, 49, 1704),
('13:00:00', '11:00:00', 'approved', 5514, 50, 1705),
('13:00:00', '11:00:00', 'approved', 5515, 41, 1706),
('13:00:00', '11:00:00', 'approved', 5516, 46, 1707),
('13:00:00', '11:00:00', 'approved', 5517, 48, 1708),
('13:00:00', '11:00:00', 'approved', 5518, 43, 1709),
('13:00:00', '11:00:00', 'approved', 5519, 44, 1710),
('13:00:00', '11:00:00', 'approved', 5520, 46, 1711),
('13:00:00', '11:00:00', 'approved', 5521, 49, 1712),
('13:00:00', '11:00:00', 'approved', 5522, 41, 1713),
('13:00:00', '11:00:00', 'approved', 5523, 43, 1714),
('13:00:00', '11:00:00', 'approved', 5524, 44, 1715),
('13:00:00', '11:00:00', 'approved', 5525, 48, 1716),
('13:00:00', '11:00:00', 'approved', 5526, 50, 1717),
('13:00:00', '11:00:00', 'approved', 5527, 41, 1718),
('13:00:00', '11:00:00', 'approved', 5528, 43, 1719),
('13:00:00', '11:00:00', 'approved', 5529, 47, 1720),
('13:00:00', '11:00:00', 'approved', 5530, 49, 1721),
('13:00:00', '11:00:00', 'approved', 5531, 47, 1722),
('13:00:00', '11:00:00', 'approved', 5532, 48, 1723),
('13:00:00', '11:00:00', 'approved', 5533, 41, 1724),
('13:00:00', '11:00:00', 'approved', 5534, 44, 1725),
('13:00:00', '11:00:00', 'approved', 5535, 46, 1726),
('13:00:00', '11:00:00', 'approved', 5536, 47, 1727),
('13:00:00', '11:00:00', 'approved', 5537, 50, 1728),
('13:00:00', '11:00:00', 'approved', 5538, 43, 1729),
('13:00:00', '11:00:00', 'approved', 5539, 44, 1730),
('13:00:00', '11:00:00', 'approved', 5540, 46, 1731),
('13:00:00', '11:00:00', 'approved', 5541, 49, 1732),
('13:00:00', '11:00:00', 'approved', 5542, 41, 1733),
('13:00:00', '11:00:00', 'approved', 5543, 43, 1734),
('13:00:00', '11:00:00', 'approved', 5544, 48, 1735),
('13:00:00', '11:00:00', 'approved', 5545, 49, 1736),
('13:00:00', '11:00:00', 'approved', 5546, 43, 1737),
('13:00:00', '11:00:00', 'approved', 5547, 46, 1738),
('13:00:00', '11:00:00', 'approved', 5548, 47, 1739),
('13:00:00', '11:00:00', 'approved', 5549, 48, 1740),
('13:00:00', '11:00:00', 'approved', 5550, 41, 1741),
('13:00:00', '11:00:00', 'approved', 5551, 44, 1742),
('13:00:00', '11:00:00', 'approved', 5552, 46, 1743),
('13:00:00', '11:00:00', 'approved', 5553, 47, 1744),
('13:00:00', '11:00:00', 'approved', 5554, 50, 1745),
('13:00:00', '11:00:00', 'approved', 5555, 43, 1746),
('13:00:00', '11:00:00', 'approved', 5556, 44, 1747),
('13:00:00', '11:00:00', 'approved', 5557, 49, 1748),
('13:00:00', '11:00:00', 'approved', 5558, 50, 1749),
('13:00:00', '11:00:00', 'approved', 5559, 44, 1750),
('13:00:00', '11:00:00', 'approved', 5560, 47, 1751),
('13:00:00', '11:00:00', 'approved', 5561, 48, 1752),
('13:00:00', '11:00:00', 'approved', 5562, 49, 1753),
('13:00:00', '11:00:00', 'approved', 5563, 43, 1754),
('13:00:00', '11:00:00', 'approved', 5564, 46, 1755),
('13:00:00', '11:00:00', 'approved', 5565, 47, 1756),
('13:00:00', '11:00:00', 'approved', 5566, 48, 1757),
('13:00:00', '11:00:00', 'approved', 5567, 41, 1758),
('13:00:00', '11:00:00', 'approved', 5568, 44, 1759),
('13:00:00', '11:00:00', 'approved', 5569, 46, 1760),
('13:00:00', '11:00:00', 'approved', 5570, 50, 1761),
('13:00:00', '11:00:00', 'approved', 5571, 41, 1762),
('13:00:00', '11:00:00', 'approved', 5572, 46, 1763),
('13:00:00', '11:00:00', 'approved', 5573, 48, 1764),
('13:00:00', '11:00:00', 'approved', 5574, 49, 1765),
('13:00:00', '11:00:00', 'approved', 5575, 50, 1766),
('13:00:00', '11:00:00', 'approved', 5576, 44, 1767),
('13:00:00', '11:00:00', 'approved', 5577, 47, 1768),
('13:00:00', '11:00:00', 'approved', 5578, 48, 1769),
('13:00:00', '11:00:00', 'approved', 5579, 49, 1770),
('13:00:00', '11:00:00', 'approved', 5580, 43, 1771),
('13:00:00', '11:00:00', 'approved', 5581, 46, 1772),
('13:00:00', '11:00:00', 'approved', 5582, 47, 1773),
('13:00:00', '11:00:00', 'approved', 5583, 44, 1774),
('13:00:00', '11:00:00', 'approved', 5584, 48, 1775),
('13:00:00', '11:00:00', 'approved', 5585, 50, 1776),
('13:00:00', '11:00:00', 'approved', 5586, 41, 1777),
('13:00:00', '11:00:00', 'approved', 5587, 43, 1778),
('13:00:00', '11:00:00', 'approved', 5588, 47, 1779),
('13:00:00', '11:00:00', 'approved', 5589, 49, 1780),
('13:00:00', '11:00:00', 'approved', 5590, 50, 1781),
('13:00:00', '11:00:00', 'approved', 5591, 41, 1782),
('13:00:00', '11:00:00', 'approved', 5592, 46, 1783),
('13:00:00', '11:00:00', 'approved', 5593, 48, 1784),
('13:00:00', '11:00:00', 'approved', 5594, 49, 1785),
('13:00:00', '11:00:00', 'approved', 5595, 50, 1786),
('13:00:00', '11:00:00', 'approved', 5596, 46, 1787),
('13:00:00', '11:00:00', 'approved', 5597, 49, 1788),
('13:00:00', '11:00:00', 'approved', 5598, 41, 1789),
('13:00:00', '11:00:00', 'approved', 5599, 43, 1790),
('13:00:00', '11:00:00', 'approved', 5600, 44, 1791),
('13:00:00', '11:00:00', 'approved', 5601, 48, 1792),
('13:00:00', '11:00:00', 'approved', 5602, 50, 1793),
('13:00:00', '11:00:00', 'approved', 5603, 41, 1794),
('13:00:00', '11:00:00', 'approved', 5604, 43, 1795),
('13:00:00', '11:00:00', 'approved', 5605, 47, 1796),
('13:00:00', '11:00:00', 'approved', 5606, 49, 1797),
('13:00:00', '11:00:00', 'approved', 5607, 50, 1798),
('13:00:00', '11:00:00', 'approved', 5608, 41, 1799),
('13:00:00', '11:00:00', 'approved', 5609, 47, 1800),
('13:00:00', '11:00:00', 'approved', 5610, 50, 1801),
('13:00:00', '11:00:00', 'approved', 5611, 43, 1802),
('13:00:00', '11:00:00', 'approved', 5612, 44, 1803),
('13:00:00', '11:00:00', 'approved', 5613, 46, 1804),
('13:00:00', '11:00:00', 'approved', 5614, 49, 1805),
('13:00:00', '11:00:00', 'approved', 5615, 41, 1806),
('13:00:00', '11:00:00', 'approved', 5616, 43, 1807),
('13:00:00', '11:00:00', 'approved', 5617, 44, 1808),
('13:00:00', '11:00:00', 'approved', 5618, 48, 1809),
('13:00:00', '11:00:00', 'approved', 5619, 50, 1810),
('13:00:00', '11:00:00', 'approved', 5620, 41, 1811),
('13:00:00', '11:00:00', 'approved', 5621, 43, 1812),
('13:00:00', '11:00:00', 'approved', 5622, 48, 1813),
('13:00:00', '11:00:00', 'approved', 5623, 41, 1814),
('13:00:00', '11:00:00', 'approved', 5624, 44, 1815),
('13:00:00', '11:00:00', 'approved', 5625, 46, 1816),
('13:00:00', '11:00:00', 'approved', 5626, 47, 1817),
('13:00:00', '11:00:00', 'approved', 5627, 50, 1818),
('13:00:00', '11:00:00', 'approved', 5628, 43, 1819),
('13:00:00', '11:00:00', 'approved', 5629, 44, 1820),
('13:00:00', '11:00:00', 'approved', 5630, 46, 1821),
('13:00:00', '11:00:00', 'approved', 5631, 49, 1822),
('13:00:00', '11:00:00', 'approved', 5632, 41, 1823),
('13:00:00', '11:00:00', 'approved', 5633, 43, 1824),
('13:00:00', '11:00:00', 'approved', 5634, 44, 1825),
('13:00:00', '11:00:00', 'approved', 5635, 44, 1826),
('13:00:00', '11:00:00', 'approved', 5636, 47, 1827),
('13:00:00', '11:00:00', 'approved', 5637, 48, 1828),
('13:00:00', '11:00:00', 'approved', 5638, 49, 1829),
('13:00:00', '11:00:00', 'approved', 5639, 43, 1830),
('13:00:00', '11:00:00', 'approved', 5640, 46, 1831),
('13:00:00', '11:00:00', 'approved', 5641, 47, 1832),
('13:00:00', '11:00:00', 'approved', 5642, 48, 1833),
('13:00:00', '11:00:00', 'approved', 5643, 41, 1834),
('13:00:00', '11:00:00', 'approved', 5644, 44, 1835),
('13:00:00', '11:00:00', 'approved', 5645, 46, 1836),
('13:00:00', '11:00:00', 'approved', 5646, 47, 1837),
('13:00:00', '11:00:00', 'approved', 5647, 50, 1838),
('13:00:00', '11:00:00', 'approved', 5648, 46, 1839),
('13:00:00', '11:00:00', 'approved', 5649, 48, 1840),
('13:00:00', '11:00:00', 'approved', 5650, 49, 1841),
('13:00:00', '11:00:00', 'approved', 5651, 50, 1842),
('13:00:00', '11:00:00', 'approved', 5652, 44, 1843),
('13:00:00', '11:00:00', 'approved', 5653, 47, 1844),
('13:00:00', '11:00:00', 'approved', 5654, 48, 1845),
('13:00:00', '11:00:00', 'approved', 5655, 49, 1846),
('13:00:00', '11:00:00', 'approved', 5656, 43, 1847),
('13:00:00', '11:00:00', 'approved', 5657, 46, 1848),
('13:00:00', '11:00:00', 'approved', 5658, 47, 1849),
('13:00:00', '11:00:00', 'approved', 5659, 48, 1850),
('13:00:00', '11:00:00', 'approved', 5660, 41, 1851),
('13:00:00', '11:00:00', 'approved', 5661, 47, 1852),
('13:00:00', '11:00:00', 'approved', 5662, 49, 1853),
('13:00:00', '11:00:00', 'approved', 5663, 50, 1854),
('13:00:00', '11:00:00', 'approved', 5664, 41, 1855),
('13:00:00', '11:00:00', 'approved', 5665, 46, 1856),
('13:00:00', '11:00:00', 'approved', 5666, 48, 1857),
('13:00:00', '11:00:00', 'approved', 5667, 49, 1858),
('13:00:00', '11:00:00', 'approved', 5668, 50, 1859),
('13:00:00', '11:00:00', 'approved', 5669, 44, 1860),
('13:00:00', '11:00:00', 'approved', 5670, 47, 1861),
('13:00:00', '11:00:00', 'approved', 5671, 48, 1862),
('13:00:00', '11:00:00', 'approved', 5672, 49, 1863),
('13:00:00', '11:00:00', 'approved', 5673, 43, 1864),
('13:00:00', '11:00:00', 'approved', 5674, 48, 1865),
('13:00:00', '11:00:00', 'approved', 5675, 50, 1866),
('13:00:00', '11:00:00', 'approved', 5676, 41, 1867),
('13:00:00', '11:00:00', 'approved', 5677, 43, 1868),
('13:00:00', '11:00:00', 'approved', 5678, 47, 1869),
('13:00:00', '11:00:00', 'approved', 5679, 49, 1870),
('13:00:00', '11:00:00', 'approved', 5680, 50, 1871),
('13:00:00', '11:00:00', 'approved', 5681, 41, 1872),
('13:00:00', '11:00:00', 'approved', 5682, 46, 1873),
('13:00:00', '11:00:00', 'approved', 5683, 48, 1874),
('13:00:00', '11:00:00', 'approved', 5684, 49, 1875),
('13:00:00', '11:00:00', 'approved', 5685, 50, 1876),
('13:00:00', '11:00:00', 'approved', 5686, 44, 1877),
('13:00:00', '11:00:00', 'approved', 5687, 43, 1878),
('13:00:00', '11:00:00', 'approved', 5688, 44, 1879),
('13:00:00', '11:00:00', 'approved', 5689, 46, 1880),
('13:00:00', '11:00:00', 'approved', 5690, 49, 1881),
('13:00:00', '11:00:00', 'approved', 5691, 41, 1882),
('13:00:00', '11:00:00', 'approved', 5692, 43, 1883),
('13:00:00', '11:00:00', 'approved', 5693, 44, 1884),
('13:00:00', '11:00:00', 'approved', 5694, 48, 1885),
('13:00:00', '11:00:00', 'approved', 5695, 50, 1886),
('13:00:00', '11:00:00', 'approved', 5696, 41, 1887),
('13:00:00', '11:00:00', 'approved', 5697, 43, 1888),
('13:00:00', '11:00:00', 'approved', 5698, 47, 1889),
('13:00:00', '11:00:00', 'approved', 5699, 49, 1890),
('13:00:00', '11:00:00', 'approved', 5700, 44, 1891),
('13:00:00', '11:00:00', 'approved', 5701, 46, 1892),
('13:00:00', '11:00:00', 'approved', 5702, 47, 1893),
('13:00:00', '11:00:00', 'approved', 5703, 50, 1894),
('13:00:00', '11:00:00', 'approved', 5704, 43, 1895),
('13:00:00', '11:00:00', 'approved', 5705, 44, 1896),
('13:00:00', '11:00:00', 'approved', 5706, 46, 1897),
('13:00:00', '11:00:00', 'approved', 5707, 49, 1898),
('13:00:00', '11:00:00', 'approved', 5708, 41, 1899),
('13:00:00', '11:00:00', 'approved', 5709, 43, 1900),
('13:00:00', '11:00:00', 'approved', 5710, 44, 1901),
('13:00:00', '11:00:00', 'approved', 5711, 48, 1902),
('13:00:00', '11:00:00', 'approved', 5712, 50, 1903),
('13:00:00', '11:00:00', 'approved', 5713, 46, 1904),
('13:00:00', '11:00:00', 'approved', 5714, 47, 1905),
('13:00:00', '11:00:00', 'approved', 5715, 48, 1906),
('13:00:00', '11:00:00', 'approved', 5716, 41, 1907),
('13:00:00', '11:00:00', 'approved', 5717, 44, 1908),
('13:00:00', '11:00:00', 'approved', 5718, 46, 1909),
('13:00:00', '11:00:00', 'approved', 5719, 47, 1910),
('13:00:00', '11:00:00', 'approved', 5720, 50, 1911),
('13:00:00', '11:00:00', 'approved', 5721, 43, 1912),
('13:00:00', '11:00:00', 'approved', 5722, 44, 1913);
INSERT INTO `Plandayactivity` (`Endtime`, `Starttime`, `Status`, `PlandayactivityID`, `ActivityID`, `PlandayID`) VALUES
('13:00:00', '11:00:00', 'approved', 5723, 46, 1914),
('13:00:00', '11:00:00', 'approved', 5724, 49, 1915),
('13:00:00', '11:00:00', 'approved', 5725, 41, 1916),
('13:00:00', '11:00:00', 'approved', 5726, 47, 1917),
('13:00:00', '11:00:00', 'approved', 5727, 48, 1918),
('13:00:00', '11:00:00', 'approved', 5728, 49, 1919),
('13:00:00', '11:00:00', 'approved', 5729, 43, 1920),
('13:00:00', '11:00:00', 'approved', 5730, 46, 1921),
('13:00:00', '11:00:00', 'approved', 5731, 47, 1922),
('13:00:00', '11:00:00', 'approved', 5732, 48, 1923),
('13:00:00', '11:00:00', 'approved', 5733, 41, 1924),
('13:00:00', '11:00:00', 'approved', 5734, 44, 1925),
('13:00:00', '11:00:00', 'approved', 5735, 46, 1926),
('13:00:00', '11:00:00', 'approved', 5736, 47, 1927),
('13:00:00', '11:00:00', 'approved', 5737, 50, 1928),
('13:00:00', '11:00:00', 'approved', 5738, 43, 1929),
('13:00:00', '11:00:00', 'approved', 5739, 50, 1930),
('13:00:00', '11:00:00', 'approved', 5740, 41, 1931),
('13:00:00', '11:00:00', 'approved', 5741, 46, 1932),
('13:00:00', '11:00:00', 'approved', 5742, 48, 1933),
('13:00:00', '11:00:00', 'approved', 5743, 49, 1934),
('13:00:00', '11:00:00', 'approved', 5744, 50, 1935),
('13:00:00', '11:00:00', 'approved', 5745, 44, 1936),
('13:00:00', '11:00:00', 'approved', 5746, 47, 1937),
('13:00:00', '11:00:00', 'approved', 5747, 48, 1938),
('13:00:00', '11:00:00', 'approved', 5748, 49, 1939),
('13:00:00', '11:00:00', 'approved', 5749, 43, 1940),
('13:00:00', '11:00:00', 'approved', 5750, 46, 1941),
('13:00:00', '11:00:00', 'approved', 5751, 47, 1942),
('13:00:00', '11:00:00', 'approved', 5752, 41, 1943),
('13:00:00', '11:00:00', 'approved', 5753, 43, 1944),
('13:00:00', '11:00:00', 'approved', 5754, 47, 1945),
('13:00:00', '11:00:00', 'approved', 5755, 49, 1946),
('13:00:00', '11:00:00', 'approved', 5756, 50, 1947),
('13:00:00', '11:00:00', 'approved', 5757, 41, 1948),
('13:00:00', '11:00:00', 'approved', 5758, 46, 1949),
('13:00:00', '11:00:00', 'approved', 5759, 48, 1950),
('13:00:00', '11:00:00', 'approved', 5760, 49, 1951),
('13:00:00', '11:00:00', 'approved', 5761, 50, 1952),
('13:00:00', '11:00:00', 'approved', 5762, 44, 1953),
('13:00:00', '11:00:00', 'approved', 5763, 47, 1954),
('13:00:00', '11:00:00', 'approved', 5764, 48, 1955),
('13:00:00', '11:00:00', 'approved', 5765, 43, 1956),
('13:00:00', '11:00:00', 'approved', 5766, 44, 1957),
('13:00:00', '11:00:00', 'approved', 5767, 48, 1958),
('13:00:00', '11:00:00', 'approved', 5768, 50, 1959),
('13:00:00', '11:00:00', 'approved', 5769, 41, 1960),
('13:00:00', '11:00:00', 'approved', 5770, 43, 1961),
('13:00:00', '11:00:00', 'approved', 5771, 47, 1962),
('13:00:00', '11:00:00', 'approved', 5772, 49, 1963),
('13:00:00', '11:00:00', 'approved', 5773, 50, 1964),
('13:00:00', '11:00:00', 'approved', 5774, 41, 1965),
('13:00:00', '11:00:00', 'approved', 5775, 46, 1966),
('13:00:00', '11:00:00', 'approved', 5776, 48, 1967),
('13:00:00', '11:00:00', 'approved', 5777, 49, 1968),
('13:00:00', '11:00:00', 'approved', 5778, 44, 1969),
('13:00:00', '11:00:00', 'approved', 5779, 46, 1970),
('13:00:00', '11:00:00', 'approved', 5780, 49, 1971),
('13:00:00', '11:00:00', 'approved', 5781, 41, 1972),
('13:00:00', '11:00:00', 'approved', 5782, 43, 1973),
('13:00:00', '11:00:00', 'approved', 5783, 44, 1974),
('13:00:00', '11:00:00', 'approved', 5784, 48, 1975),
('13:00:00', '11:00:00', 'approved', 5785, 50, 1976),
('13:00:00', '11:00:00', 'approved', 5786, 41, 1977),
('13:00:00', '11:00:00', 'approved', 5787, 43, 1978),
('13:00:00', '11:00:00', 'approved', 5788, 47, 1979),
('13:00:00', '11:00:00', 'approved', 5789, 49, 1980),
('13:00:00', '11:00:00', 'approved', 5790, 50, 1981),
('13:00:00', '11:00:00', 'approved', 5791, 48, 1982),
('13:00:00', '11:00:00', 'approved', 5792, 41, 1983),
('13:00:00', '11:00:00', 'approved', 5793, 44, 1984),
('13:00:00', '11:00:00', 'approved', 5794, 46, 1985),
('13:00:00', '11:00:00', 'approved', 5795, 47, 1986),
('13:00:00', '11:00:00', 'approved', 5796, 50, 1987),
('13:00:00', '11:00:00', 'approved', 5797, 43, 1988),
('13:00:00', '11:00:00', 'approved', 5798, 44, 1989),
('13:00:00', '11:00:00', 'approved', 5799, 46, 1990),
('13:00:00', '11:00:00', 'approved', 5800, 49, 1991),
('13:00:00', '11:00:00', 'approved', 5801, 41, 1992),
('13:00:00', '11:00:00', 'approved', 5802, 43, 1993),
('13:00:00', '11:00:00', 'approved', 5803, 44, 1994),
('13:00:00', '11:00:00', 'approved', 5804, 49, 1995),
('13:00:00', '11:00:00', 'approved', 5805, 43, 1996),
('13:00:00', '11:00:00', 'approved', 5806, 46, 1997),
('13:00:00', '11:00:00', 'approved', 5807, 47, 1998),
('13:00:00', '11:00:00', 'approved', 5808, 48, 1999),
('13:00:00', '11:00:00', 'approved', 5809, 41, 2000),
('13:00:00', '11:00:00', 'approved', 5810, 44, 2001),
('13:00:00', '11:00:00', 'approved', 5811, 46, 2002),
('13:00:00', '11:00:00', 'approved', 5812, 47, 2003),
('13:00:00', '11:00:00', 'approved', 5813, 50, 2004),
('13:00:00', '11:00:00', 'approved', 5814, 43, 2005),
('13:00:00', '11:00:00', 'approved', 5815, 44, 2006),
('13:00:00', '11:00:00', 'approved', 5816, 46, 2007),
('13:00:00', '11:00:00', 'approved', 5817, 50, 2008),
('13:00:00', '11:00:00', 'approved', 5818, 44, 2009),
('13:00:00', '11:00:00', 'approved', 5819, 47, 2010),
('13:00:00', '11:00:00', 'approved', 5820, 48, 2011),
('13:00:00', '11:00:00', 'approved', 5821, 49, 2012),
('13:00:00', '11:00:00', 'approved', 5822, 43, 2013),
('13:00:00', '11:00:00', 'approved', 5823, 46, 2014),
('13:00:00', '11:00:00', 'approved', 5824, 47, 2015),
('13:00:00', '11:00:00', 'approved', 5825, 48, 2016),
('13:00:00', '11:00:00', 'approved', 5826, 41, 2017),
('13:00:00', '11:00:00', 'approved', 5827, 44, 2018),
('13:00:00', '11:00:00', 'approved', 5828, 46, 2019),
('13:00:00', '11:00:00', 'approved', 5829, 47, 2020),
('13:00:00', '11:00:00', 'approved', 5830, 41, 2021),
('13:00:00', '11:00:00', 'approved', 5831, 46, 2022),
('13:00:00', '11:00:00', 'approved', 5832, 48, 2023),
('13:00:00', '11:00:00', 'approved', 5833, 49, 2024),
('13:00:00', '11:00:00', 'approved', 5834, 50, 2025),
('13:00:00', '11:00:00', 'approved', 5835, 44, 2026),
('13:00:00', '11:00:00', 'approved', 5836, 47, 2027),
('13:00:00', '11:00:00', 'approved', 5837, 48, 2028),
('13:00:00', '11:00:00', 'approved', 5838, 49, 2029),
('13:00:00', '11:00:00', 'approved', 5839, 43, 2030),
('13:00:00', '11:00:00', 'approved', 5840, 46, 2031),
('13:00:00', '11:00:00', 'approved', 5841, 47, 2032),
('13:00:00', '11:00:00', 'approved', 5842, 48, 2033),
('13:00:00', '11:00:00', 'approved', 5843, 48, 2034),
('13:00:00', '11:00:00', 'approved', 5844, 50, 2035),
('13:00:00', '11:00:00', 'approved', 5845, 41, 2036),
('13:00:00', '11:00:00', 'approved', 5846, 43, 2037),
('13:00:00', '11:00:00', 'approved', 5847, 47, 2038),
('13:00:00', '11:00:00', 'approved', 5848, 49, 2039),
('13:00:00', '11:00:00', 'approved', 5849, 50, 2040),
('13:00:00', '11:00:00', 'approved', 5850, 41, 2041),
('13:00:00', '11:00:00', 'approved', 5851, 46, 2042),
('13:00:00', '11:00:00', 'approved', 5852, 48, 2043),
('13:00:00', '11:00:00', 'approved', 5853, 49, 2044),
('13:00:00', '11:00:00', 'approved', 5854, 50, 2045),
('13:00:00', '11:00:00', 'approved', 5855, 44, 2046),
('13:00:00', '11:00:00', 'approved', 5856, 49, 2047),
('13:00:00', '11:00:00', 'approved', 5857, 41, 2048),
('13:00:00', '11:00:00', 'approved', 5858, 43, 2049),
('13:00:00', '11:00:00', 'approved', 5859, 44, 2050),
('13:00:00', '11:00:00', 'approved', 5860, 48, 2051),
('13:00:00', '11:00:00', 'approved', 5861, 50, 2052),
('13:00:00', '11:00:00', 'approved', 5862, 41, 2053),
('13:00:00', '11:00:00', 'approved', 5863, 43, 2054),
('13:00:00', '11:00:00', 'approved', 5864, 47, 2055),
('13:00:00', '11:00:00', 'approved', 5865, 49, 2056),
('13:00:00', '11:00:00', 'approved', 5866, 50, 2057),
('13:00:00', '11:00:00', 'approved', 5867, 41, 2058),
('13:00:00', '11:00:00', 'approved', 5868, 46, 2059),
('13:00:00', '11:00:00', 'approved', 5869, 50, 2060),
('13:00:00', '11:00:00', 'approved', 5870, 43, 2061),
('13:00:00', '11:00:00', 'approved', 5871, 44, 2062),
('13:00:00', '11:00:00', 'approved', 5872, 46, 2063),
('13:00:00', '11:00:00', 'approved', 5873, 49, 2064),
('13:00:00', '11:00:00', 'approved', 5874, 41, 2065),
('13:00:00', '11:00:00', 'approved', 5875, 43, 2066),
('13:00:00', '11:00:00', 'approved', 5876, 44, 2067),
('13:00:00', '11:00:00', 'approved', 5877, 48, 2068),
('13:00:00', '11:00:00', 'approved', 5878, 50, 2069),
('13:00:00', '11:00:00', 'approved', 5879, 41, 2070),
('13:00:00', '11:00:00', 'approved', 5880, 43, 2071),
('13:00:00', '11:00:00', 'approved', 5881, 47, 2072),
('13:00:00', '11:00:00', 'approved', 5882, 41, 2073),
('13:00:00', '11:00:00', 'approved', 5883, 44, 2074),
('13:00:00', '11:00:00', 'approved', 5884, 46, 2075),
('13:00:00', '11:00:00', 'approved', 5885, 47, 2076),
('13:00:00', '11:00:00', 'approved', 5886, 50, 2077),
('13:00:00', '11:00:00', 'approved', 5887, 43, 2078),
('13:00:00', '11:00:00', 'approved', 5888, 44, 2079),
('13:00:00', '11:00:00', 'approved', 5889, 46, 2080),
('13:00:00', '11:00:00', 'approved', 5890, 49, 2081),
('13:00:00', '11:00:00', 'approved', 5891, 41, 2082),
('13:00:00', '11:00:00', 'approved', 5892, 43, 2083),
('13:00:00', '11:00:00', 'approved', 5893, 44, 2084),
('13:00:00', '11:00:00', 'approved', 5894, 48, 2085),
('13:00:00', '11:00:00', 'approved', 5895, 47, 2086),
('13:00:00', '11:00:00', 'approved', 5896, 48, 2087),
('13:00:00', '11:00:00', 'approved', 5897, 49, 2088),
('13:00:00', '11:00:00', 'approved', 5898, 43, 2089),
('13:00:00', '11:00:00', 'approved', 5899, 46, 2090),
('13:00:00', '11:00:00', 'approved', 5900, 47, 2091),
('13:00:00', '11:00:00', 'approved', 5901, 48, 2092),
('13:00:00', '11:00:00', 'approved', 5902, 41, 2093),
('13:00:00', '11:00:00', 'approved', 5903, 44, 2094),
('13:00:00', '11:00:00', 'approved', 5904, 46, 2095),
('13:00:00', '11:00:00', 'approved', 5905, 47, 2096),
('13:00:00', '11:00:00', 'approved', 5906, 50, 2097),
('13:00:00', '11:00:00', 'approved', 5907, 43, 2098),
('13:00:00', '11:00:00', 'approved', 5908, 48, 2099),
('13:00:00', '11:00:00', 'approved', 5909, 49, 2100),
('13:00:00', '11:00:00', 'approved', 5910, 50, 2101),
('13:00:00', '11:00:00', 'approved', 5911, 44, 2102),
('13:00:00', '11:00:00', 'approved', 5912, 47, 2103),
('13:00:00', '11:00:00', 'approved', 5913, 48, 2104),
('13:00:00', '11:00:00', 'approved', 5914, 49, 2105),
('13:00:00', '11:00:00', 'approved', 5915, 43, 2106),
('13:00:00', '11:00:00', 'approved', 5916, 46, 2107),
('13:00:00', '11:00:00', 'approved', 5917, 47, 2108),
('13:00:00', '11:00:00', 'approved', 5918, 48, 2109),
('13:00:00', '11:00:00', 'approved', 5919, 41, 2110),
('13:00:00', '11:00:00', 'approved', 5920, 44, 2111),
('13:00:00', '11:00:00', 'approved', 5921, 49, 2112),
('13:00:00', '11:00:00', 'approved', 5922, 50, 2113),
('13:00:00', '11:00:00', 'approved', 5923, 41, 2114),
('13:00:00', '11:00:00', 'approved', 5924, 46, 2115),
('13:00:00', '11:00:00', 'approved', 5925, 48, 2116),
('13:00:00', '11:00:00', 'approved', 5926, 49, 2117),
('13:00:00', '11:00:00', 'approved', 5927, 50, 2118),
('13:00:00', '11:00:00', 'approved', 5928, 44, 2119),
('13:00:00', '11:00:00', 'approved', 5929, 47, 2120),
('13:00:00', '11:00:00', 'approved', 5930, 48, 2121),
('13:00:00', '11:00:00', 'approved', 5931, 49, 2122),
('13:00:00', '11:00:00', 'approved', 5932, 43, 2123),
('13:00:00', '11:00:00', 'approved', 5933, 46, 2124),
('13:00:00', '11:00:00', 'approved', 5934, 50, 2125),
('13:00:00', '11:00:00', 'approved', 5935, 41, 2126),
('13:00:00', '11:00:00', 'approved', 5936, 43, 2127),
('13:00:00', '11:00:00', 'approved', 5937, 47, 2128),
('13:00:00', '11:00:00', 'approved', 5938, 49, 2129),
('13:00:00', '11:00:00', 'approved', 5939, 50, 2130),
('13:00:00', '11:00:00', 'approved', 5940, 41, 2131),
('13:00:00', '11:00:00', 'approved', 5941, 46, 2132),
('13:00:00', '11:00:00', 'approved', 5942, 48, 2133),
('13:00:00', '11:00:00', 'approved', 5943, 49, 2134),
('13:00:00', '11:00:00', 'approved', 5944, 50, 2135),
('13:00:00', '11:00:00', 'approved', 5945, 44, 2136),
('13:00:00', '11:00:00', 'approved', 5946, 47, 2137),
('13:00:00', '11:00:00', 'approved', 5947, 44, 2138),
('13:00:00', '11:00:00', 'approved', 5948, 46, 2139),
('13:00:00', '11:00:00', 'approved', 5949, 49, 2140),
('13:00:00', '11:00:00', 'approved', 5950, 41, 2141),
('13:00:00', '11:00:00', 'approved', 5951, 43, 2142),
('13:00:00', '11:00:00', 'approved', 5952, 44, 2143),
('13:00:00', '11:00:00', 'approved', 5953, 48, 2144),
('13:00:00', '11:00:00', 'approved', 5954, 50, 2145),
('13:00:00', '11:00:00', 'approved', 5955, 41, 2146),
('13:00:00', '11:00:00', 'approved', 5956, 43, 2147),
('13:00:00', '11:00:00', 'approved', 5957, 47, 2148),
('13:00:00', '11:00:00', 'approved', 5958, 49, 2149),
('13:00:00', '11:00:00', 'approved', 5959, 50, 2150),
('13:00:00', '11:00:00', 'approved', 5960, 46, 2151),
('13:00:00', '11:00:00', 'approved', 5961, 47, 2152),
('13:00:00', '11:00:00', 'approved', 5962, 50, 2153),
('13:00:00', '11:00:00', 'approved', 5963, 43, 2154),
('13:00:00', '11:00:00', 'approved', 5964, 44, 2155),
('13:00:00', '11:00:00', 'approved', 5965, 46, 2156),
('13:00:00', '11:00:00', 'approved', 5966, 49, 2157),
('13:00:00', '11:00:00', 'approved', 5967, 41, 2158),
('13:00:00', '11:00:00', 'approved', 5968, 43, 2159),
('13:00:00', '11:00:00', 'approved', 5969, 44, 2160),
('13:00:00', '11:00:00', 'approved', 5970, 48, 2161),
('13:00:00', '11:00:00', 'approved', 5971, 50, 2162),
('13:00:00', '11:00:00', 'approved', 5972, 41, 2163),
('13:00:00', '11:00:00', 'approved', 5973, 47, 2164),
('13:00:00', '11:00:00', 'approved', 5974, 48, 2165),
('13:00:00', '11:00:00', 'approved', 5975, 41, 2166),
('13:00:00', '11:00:00', 'approved', 5976, 44, 2167),
('13:00:00', '11:00:00', 'approved', 5977, 46, 2168),
('13:00:00', '11:00:00', 'approved', 5978, 47, 2169),
('13:00:00', '11:00:00', 'approved', 5979, 50, 2170),
('13:00:00', '11:00:00', 'approved', 5980, 43, 2171),
('13:00:00', '11:00:00', 'approved', 5981, 44, 2172),
('13:00:00', '11:00:00', 'approved', 5982, 46, 2173),
('13:00:00', '11:00:00', 'approved', 5983, 49, 2174),
('13:00:00', '11:00:00', 'approved', 5984, 41, 2175),
('13:00:00', '11:00:00', 'approved', 5985, 43, 2176),
('13:00:00', '11:00:00', 'approved', 5986, 48, 2177),
('13:00:00', '11:00:00', 'approved', 5987, 49, 2178),
('13:00:00', '11:00:00', 'approved', 5988, 43, 2179),
('13:00:00', '11:00:00', 'approved', 5989, 46, 2180),
('13:00:00', '11:00:00', 'approved', 5990, 47, 2181),
('13:00:00', '11:00:00', 'approved', 5991, 48, 2182),
('13:00:00', '11:00:00', 'approved', 5992, 41, 2183),
('13:00:00', '11:00:00', 'approved', 5993, 44, 2184),
('13:00:00', '11:00:00', 'approved', 5994, 46, 2185),
('13:00:00', '11:00:00', 'approved', 5995, 47, 2186),
('13:00:00', '11:00:00', 'approved', 5996, 50, 2187),
('13:00:00', '11:00:00', 'approved', 5997, 43, 2188),
('13:00:00', '11:00:00', 'approved', 5998, 44, 2189),
('13:00:00', '11:00:00', 'approved', 5999, 41, 2190),
('13:00:00', '11:00:00', 'approved', 6000, 46, 2191),
('13:00:00', '11:00:00', 'approved', 6001, 48, 2192),
('13:00:00', '11:00:00', 'approved', 6002, 49, 2193),
('13:00:00', '11:00:00', 'approved', 6003, 50, 2194),
('13:00:00', '11:00:00', 'approved', 6004, 44, 2195),
('13:00:00', '11:00:00', 'approved', 6005, 47, 2196),
('13:00:00', '11:00:00', 'approved', 6006, 48, 2197),
('13:00:00', '11:00:00', 'approved', 6007, 49, 2198),
('13:00:00', '11:00:00', 'approved', 6008, 43, 2199),
('13:00:00', '11:00:00', 'approved', 6009, 46, 2200),
('13:00:00', '11:00:00', 'approved', 6010, 47, 2201),
('13:00:00', '11:00:00', 'approved', 6011, 48, 2202),
('13:00:00', '11:00:00', 'approved', 6012, 43, 2203),
('13:00:00', '11:00:00', 'approved', 6013, 47, 2204),
('13:00:00', '11:00:00', 'approved', 6014, 49, 2205),
('13:00:00', '11:00:00', 'approved', 6015, 50, 2206),
('13:00:00', '11:00:00', 'approved', 6016, 41, 2207),
('13:00:00', '11:00:00', 'approved', 6017, 46, 2208),
('13:00:00', '11:00:00', 'approved', 6018, 48, 2209),
('13:00:00', '11:00:00', 'approved', 6019, 49, 2210),
('13:00:00', '11:00:00', 'approved', 6020, 50, 2211),
('13:00:00', '11:00:00', 'approved', 6021, 44, 2212),
('13:00:00', '11:00:00', 'approved', 6022, 47, 2213),
('13:00:00', '11:00:00', 'approved', 6023, 48, 2214),
('13:00:00', '11:00:00', 'approved', 6024, 49, 2215),
('13:00:00', '11:00:00', 'approved', 6025, 44, 2216),
('13:00:00', '11:00:00', 'approved', 6026, 48, 2217),
('13:00:00', '11:00:00', 'approved', 6027, 50, 2218),
('13:00:00', '11:00:00', 'approved', 6028, 41, 2219),
('13:00:00', '11:00:00', 'approved', 6029, 43, 2220),
('13:00:00', '11:00:00', 'approved', 6030, 47, 2221),
('13:00:00', '11:00:00', 'approved', 6031, 49, 2222),
('13:00:00', '11:00:00', 'approved', 6032, 50, 2223),
('13:00:00', '11:00:00', 'approved', 6033, 41, 2224),
('13:00:00', '11:00:00', 'approved', 6034, 46, 2225),
('13:00:00', '11:00:00', 'approved', 6035, 48, 2226),
('13:00:00', '11:00:00', 'approved', 6036, 49, 2227),
('13:00:00', '11:00:00', 'approved', 6037, 50, 2228),
('13:00:00', '11:00:00', 'approved', 6038, 46, 2229),
('13:00:00', '11:00:00', 'approved', 6039, 49, 2230),
('13:00:00', '11:00:00', 'approved', 6040, 41, 2231),
('13:00:00', '11:00:00', 'approved', 6041, 43, 2232),
('13:00:00', '11:00:00', 'approved', 6042, 44, 2233),
('13:00:00', '11:00:00', 'approved', 6043, 48, 2234),
('13:00:00', '11:00:00', 'approved', 6044, 50, 2235),
('13:00:00', '11:00:00', 'approved', 6045, 41, 2236),
('13:00:00', '11:00:00', 'approved', 6046, 43, 2237),
('13:00:00', '11:00:00', 'approved', 6047, 47, 2238),
('13:00:00', '11:00:00', 'approved', 6048, 49, 2239),
('13:00:00', '11:00:00', 'approved', 6049, 50, 2240),
('13:00:00', '11:00:00', 'approved', 6050, 41, 2241),
('13:00:00', '11:00:00', 'approved', 6051, 41, 2242),
('13:00:00', '11:00:00', 'approved', 6052, 44, 2243),
('13:00:00', '11:00:00', 'approved', 6053, 46, 2244),
('13:00:00', '11:00:00', 'approved', 6054, 47, 2245),
('13:00:00', '11:00:00', 'approved', 6055, 50, 2246),
('13:00:00', '11:00:00', 'approved', 6056, 43, 2247),
('13:00:00', '11:00:00', 'approved', 6057, 44, 2248),
('13:00:00', '11:00:00', 'approved', 6058, 46, 2249),
('13:00:00', '11:00:00', 'approved', 6059, 49, 2250),
('13:00:00', '11:00:00', 'approved', 6060, 43, 2251),
('13:00:00', '11:00:00', 'approved', 6061, 46, 2252),
('13:00:00', '11:00:00', 'approved', 6062, 47, 2253),
('13:00:00', '11:00:00', 'approved', 6063, 48, 2254),
('13:00:00', '11:00:00', 'approved', 6064, 41, 2255),
('13:00:00', '11:00:00', 'approved', 6065, 44, 2256),
('13:00:00', '11:00:00', 'approved', 6066, 46, 2257),
('13:00:00', '11:00:00', 'approved', 6067, 47, 2258),
('13:00:00', '11:00:00', 'approved', 6068, 50, 2259),
('13:00:00', '11:00:00', 'approved', 6069, 44, 2260),
('13:00:00', '11:00:00', 'approved', 6070, 47, 2261),
('13:00:00', '11:00:00', 'approved', 6071, 48, 2262),
('13:00:00', '11:00:00', 'approved', 6072, 49, 2263),
('13:00:00', '11:00:00', 'approved', 6073, 43, 2264),
('13:00:00', '11:00:00', 'approved', 6074, 46, 2265),
('13:00:00', '11:00:00', 'approved', 6075, 47, 2266),
('13:00:00', '11:00:00', 'approved', 6076, 48, 2267),
('13:00:00', '11:00:00', 'approved', 6077, 41, 2268),
('13:00:00', '11:00:00', 'approved', 6078, 46, 2269),
('13:00:00', '11:00:00', 'approved', 6079, 48, 2270),
('13:00:00', '11:00:00', 'approved', 6080, 49, 2271),
('13:00:00', '11:00:00', 'approved', 6081, 50, 2272),
('13:00:00', '11:00:00', 'approved', 6082, 44, 2273),
('13:00:00', '11:00:00', 'approved', 6083, 47, 2274),
('13:00:00', '11:00:00', 'approved', 6084, 48, 2275),
('13:00:00', '11:00:00', 'approved', 6085, 49, 2276),
('13:00:00', '11:00:00', 'approved', 6086, 43, 2277),
('14:00:00', '12:00:00', 'approved', 6458, 50, 1626),
('14:00:00', '12:00:00', 'approved', 6459, 47, 1627),
('14:00:00', '12:00:00', 'approved', 6460, 43, 1628),
('14:00:00', '12:00:00', 'approved', 6461, 46, 1629),
('11:00:00', '09:00:00', 'approved', 6465, 41, 2658),
('18:00:00', '16:00:00', 'approved', 6466, 50, 1601),
('11:00:00', '09:00:00', 'approved', 6467, 43, 2659),
('11:00:00', '09:00:00', 'approved', 6468, 43, 2660),
('11:00:00', '09:00:00', 'approved', 6469, 43, 2661),
('11:00:00', '09:00:00', 'approved', 6470, 43, 2662),
('11:00:00', '09:00:00', 'approved', 6471, 43, 2663),
('13:00:00', '11:00:00', 'approved', 6472, 45, 2659),
('13:00:00', '11:00:00', 'approved', 6473, 45, 2660),
('13:00:00', '11:00:00', 'approved', 6474, 45, 2662),
('13:00:00', '11:00:00', 'approved', 6475, 45, 2661),
('13:00:00', '11:00:00', 'approved', 6476, 45, 2663);

--
-- Triggers `Plandayactivity`
--
DELIMITER $$
CREATE TRIGGER `trg_plandayactivity_validate_insert` BEFORE INSERT ON `Plandayactivity` FOR EACH ROW BEGIN
    DECLARE v_date DATE;
    DECLARE v_class_id INT;
    DECLARE v_day_of_week INT;
    DECLARE v_overlap_count INT DEFAULT 0;

    IF NEW.PlandayID IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Planned activity must reference a plan day.';
    END IF;

    IF NEW.Starttime IS NULL OR NEW.Endtime IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Planned activity must have both Starttime and Endtime.';
    END IF;

    IF NEW.Starttime >= NEW.Endtime THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Planned activity Endtime must be after Starttime.';
    END IF;

    SELECT `Date`, `ClassID` INTO v_date, v_class_id
    FROM `Planday`
    WHERE `PlandayID` = NEW.PlandayID
    LIMIT 1;

    IF v_date IS NULL OR v_class_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Referenced plan day is invalid.';
    END IF;

    SET v_day_of_week = DAYOFWEEK(v_date);
    IF v_day_of_week IN (1, 7) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Activities cannot be scheduled on Sunday or Saturday.';
    END IF;

    SELECT COUNT(*) INTO v_overlap_count
    FROM `Plandayactivity` pa
    JOIN `Planday` pd_existing ON pa.PlandayID = pd_existing.PlandayID
    WHERE pd_existing.`Date` = v_date
      AND pd_existing.`ClassID` = v_class_id
      AND pa.Starttime < NEW.Endtime
      AND pa.Endtime > NEW.Starttime;

    IF v_overlap_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Planned activities cannot overlap for the same class and date.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Planning`
--

CREATE TABLE `Planning` (
  `Isarchived` tinyint(1) DEFAULT NULL,
  `Startdate` date DEFAULT NULL,
  `Enddate` date DEFAULT NULL,
  `Label` varchar(50) DEFAULT NULL,
  `PlanningID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Planning`
--

INSERT INTO `Planning` (`Isarchived`, `Startdate`, `Enddate`, `Label`, `PlanningID`) VALUES
(1, '2024-12-09', '2025-06-30', '2024/2025', 7),
(0, '2025-09-15', '2026-06-30', '2025/2026', 8);

--
-- Triggers `Planning`
--
DELIMITER $$
CREATE TRIGGER `trg_planning_insert` BEFORE INSERT ON `Planning` FOR EACH ROW BEGIN
    IF NEW.Startdate IS NULL OR NEW.Enddate IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Planning must have both Startdate and Enddate.';
    END IF;
    IF NEW.Startdate >= NEW.Enddate THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Startdate must be before Enddate.';
    END IF;
    SET NEW.Label = CONCAT(YEAR(NEW.Startdate), '/', YEAR(NEW.Enddate));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_planning_sync_class_years` AFTER UPDATE ON `Planning` FOR EACH ROW BEGIN
    IF NEW.Startdate <> OLD.Startdate THEN
        UPDATE `Class`
        SET `Year` = YEAR(NEW.Startdate)
        WHERE `PlanningID` = NEW.PlanningID;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_planning_update` BEFORE UPDATE ON `Planning` FOR EACH ROW BEGIN
    IF NEW.Startdate IS NULL OR NEW.Enddate IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Planning must have both Startdate and Enddate.';
    END IF;
    IF NEW.Startdate >= NEW.Enddate THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Validation Error: Startdate must be before Enddate.';
    END IF;
    SET NEW.Label = CONCAT(YEAR(NEW.Startdate), '/', YEAR(NEW.Enddate));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Presence`
--

CREATE TABLE `Presence` (
  `Date` date DEFAULT NULL,
  `PresenceID` int(11) NOT NULL,
  `ChildID` int(11) DEFAULT NULL,
  `PresencestatusID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Presence`
--

INSERT INTO `Presence` (`Date`, `PresenceID`, `ChildID`, `PresencestatusID`) VALUES
('2024-12-09', 19, 138, 1),
('2026-04-07', 20, 138, 1);

--
-- Triggers `Presence`
--
DELIMITER $$
CREATE TRIGGER `trg_presence_no_future_date_insert` BEFORE INSERT ON `Presence` FOR EACH ROW BEGIN
    IF NEW.Date > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot record presence for a future date';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_presence_no_future_date_update` BEFORE UPDATE ON `Presence` FOR EACH ROW BEGIN
    IF NEW.Date > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot record presence for a future date';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Presencestatus`
--

CREATE TABLE `Presencestatus` (
  `Name` varchar(50) DEFAULT NULL,
  `PresencestatusID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Presencestatus`
--

INSERT INTO `Presencestatus` (`Name`, `PresencestatusID`) VALUES
('present', 1),
('absent', 2);

-- --------------------------------------------------------

--
-- Table structure for table `Reportanalysishistory`
--

CREATE TABLE `Reportanalysishistory` (
  `Analysisresult` text DEFAULT NULL,
  `Date` date DEFAULT NULL,
  `ReportanalysishistoryID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Reportanalysishistory`
--

INSERT INTO `Reportanalysishistory` (`Analysisresult`, `Date`, `ReportanalysishistoryID`) VALUES
('{\"nom\":\"youssef kammoun\",\"classe\":\"Preschool Section A\",\"synthese\":\"Youssef présente des pleurs fréquents en classe, signalés par l’équipe pédagogique. Ce comportement pourrait indiquer une difficulté d’adaptation, une anxiété de séparation ou un besoin non verbal encore inidentifié.\",\"recommandations\":\"Observer le contexte des pleurs afin d’en identifier les déclencheurs éventuels. Favoriser une communication bienveillante avec Youssef, l’accompagner dans les moments de transition (arrivées, départs) et renforcer le sentiment de sécurité affective. Si le comportement persiste, envisager un échange avec la famille pour recueillir des informations complémentaires sur l’environnement familial ou d’éventuels changements récents.\"}', '2026-04-07', 8),
('{\"nom\":\"youssef kammoun\",\"classe\":\"Preschool Section B\",\"synthese\":\"Youssef a été signalé pour des pleurs lors de la journée du 4 juillet 2026. Ce comportement peut refléter un besoin d’expression émotionnelle, une difficulté momentanée d’adaptation, ou autre source de malaise non précisée dans le signalement.\",\"recommandations\":\"Observer la fréquence et les circonstances des pleurs afin d’identifier les déclencheurs éventuels. Dialoguer doucement avec Youssef pour comprendre l’origine de sa tristesse et renforcer le sentiment de sécurité affective. Impliquer la famille pour obtenir d’éventuels éléments contextuels. Encourager l’expression des émotions et proposer des activités favorisant le bien-être.\"}', '2026-04-07', 9),
('{\"nom\":\"youssef kammoun\",\"classe\":\"Preschool Section B\",\"synthese\":\"Youssef a été signalé en situation de pleurs le 7 avril 2026. Le contexte précis de l\'événement n\'est pas détaillé, ce qui limite l\'analyse des causes potentielles (fatigue, frustration, besoin d\'attention, etc.).\",\"recommandations\":\"Observer les circonstances précédant les pleurs afin d\'identifier les déclencheurs possibles (interactions sociales, transitions, besoins non comblés). Mettre en place un accompagnement verbal rassurant, proposer des alternatives d\'expression des émotions et dialoguer régulièrement avec la famille pour un suivi global. Consigner tout nouveau signalement pour suivre l\'évolution.\"}', '2026-04-09', 10);

-- --------------------------------------------------------

--
-- Table structure for table `Role`
--

CREATE TABLE `Role` (
  `Value` int(11) DEFAULT NULL,
  `RoleID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Role`
--

INSERT INTO `Role` (`Value`, `RoleID`) VALUES
(1, 1),
(2, 2),
(3, 3);

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Signalement`
--

CREATE TABLE `Signalement` (
  `Comment` text DEFAULT NULL,
  `Incident_date` date DEFAULT NULL,
  `SignalementID` int(11) NOT NULL,
  `ReportanalysishistoryID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `Signalement`
--

INSERT INTO `Signalement` (`Comment`, `Incident_date`, `SignalementID`, `ReportanalysishistoryID`) VALUES
('[Pleurs] cries a lot', '2025-04-01', 12, 8),
('[Pleurs] ', '2026-04-07', 13, 10);

-- --------------------------------------------------------

--
-- Table structure for table `Teacher`
--

CREATE TABLE `Teacher` (
  `TeacherID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `Teacher`
--

INSERT INTO `Teacher` (`TeacherID`) VALUES
(40000032),
(40000033),
(40000034),
(40000035),
(40000036),
(40000040),
(40000068),
(40000069),
(40000070);

-- --------------------------------------------------------

--
-- Table structure for table `TeacherClass`
--

CREATE TABLE `TeacherClass` (
  `TeacherID` int(11) NOT NULL,
  `ClassID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `TeacherClass`
--

INSERT INTO `TeacherClass` (`TeacherID`, `ClassID`) VALUES
(40000032, 12),
(40000032, 13),
(40000032, 16),
(40000032, 18),
(40000032, 19),
(40000032, 20),
(40000033, 17),
(40000033, 18),
(40000033, 22),
(40000034, 19),
(40000034, 20),
(40000034, 21),
(40000034, 22),
(40000035, 22);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Account`
--
ALTER TABLE `Account`
  ADD PRIMARY KEY (`AccountID`),
  ADD KEY `FK_Account_Role` (`RoleID`),
  ADD KEY `FK_Account_Person` (`PersonID`);

--
-- Indexes for table `Activity`
--
ALTER TABLE `Activity`
  ADD PRIMARY KEY (`ActivityID`);

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `Child`
--
ALTER TABLE `Child`
  ADD PRIMARY KEY (`ChildID`),
  ADD KEY `FK_Child_Parent` (`ParentID`);

--
-- Indexes for table `ChildClass`
--
ALTER TABLE `ChildClass`
  ADD KEY `FK_ChildClass_Child` (`ChildID`),
  ADD KEY `FK_ChildClass_Class` (`ClassID`);

--
-- Indexes for table `Childfoodexception`
--
ALTER TABLE `Childfoodexception`
  ADD PRIMARY KEY (`ChildfoodexceptionID`),
  ADD KEY `FK_Childfoodexception_Child` (`ChildID`);

--
-- Indexes for table `ChildFoodExceptionMeals`
--
ALTER TABLE `ChildFoodExceptionMeals`
  ADD KEY `FK_ChildFoodExceptionMeals_ChildFoodException` (`ChildfoodexceptionID`),
  ADD KEY `FK_ChildFoodExceptionMeals_Meals` (`MealsID`);

--
-- Indexes for table `Childfoodexceptionoverride`
--
ALTER TABLE `Childfoodexceptionoverride`
  ADD PRIMARY KEY (`ChildfoodexceptionoverrideID`),
  ADD KEY `FK_Childfoodexceptionoverride_Meals` (`replacement_meal`),
  ADD KEY `fk_override_child` (`ChildID`);

--
-- Indexes for table `ChildFoodExceptionOverrideMeals`
--
ALTER TABLE `ChildFoodExceptionOverrideMeals`
  ADD KEY `FK_ChildFoodExceptionOverrideMeals_original_meal` (`original_meal`),
  ADD KEY `FK_ChildFoodExceptionOverrideMeals_ChildFoodExceptionOverride` (`ChildfoodexceptionoverrideID`);

--
-- Indexes for table `Childphoto`
--
ALTER TABLE `Childphoto`
  ADD PRIMARY KEY (`ChildphotoID`),
  ADD KEY `FK_Childphoto_Teacher` (`TeacherID`);

--
-- Indexes for table `Childphotorecipient`
--
ALTER TABLE `Childphotorecipient`
  ADD PRIMARY KEY (`ChildphotorecipientID`),
  ADD KEY `FK_ChildPhotoRecipient_ChildPhoto` (`ChildphotoID`),
  ADD KEY `FK_ChildPhotoRecipient_Child` (`ChildID`);

--
-- Indexes for table `Class`
--
ALTER TABLE `Class`
  ADD PRIMARY KEY (`ClassID`),
  ADD KEY `FK_Class_Classtype` (`ClasstypeID`),
  ADD KEY `FK_Class_Planning` (`PlanningID`);

--
-- Indexes for table `Classtype`
--
ALTER TABLE `Classtype`
  ADD PRIMARY KEY (`ClasstypeID`);

--
-- Indexes for table `Criteria`
--
ALTER TABLE `Criteria`
  ADD PRIMARY KEY (`CriteriaID`);

--
-- Indexes for table `CriteriaActivity`
--
ALTER TABLE `CriteriaActivity`
  ADD KEY `FK_CriteriaActivity_Activity` (`ActivityID`),
  ADD KEY `FK_CriteriaActivity_Criteria` (`CriteriaID`);

--
-- Indexes for table `Dailyplan`
--
ALTER TABLE `Dailyplan`
  ADD PRIMARY KEY (`DailyplanID`),
  ADD KEY `FK_Dailyplan_Menuplanning` (`MenuplanningID`);

--
-- Indexes for table `DailyPlanMeals`
--
ALTER TABLE `DailyPlanMeals`
  ADD KEY `FK_DailyPlanMeals_Meals` (`MealsID`),
  ADD KEY `FK_DailyPlanMeals_DailyPlan` (`DailyplanID`);

--
-- Indexes for table `Dietarycomment`
--
ALTER TABLE `Dietarycomment`
  ADD PRIMARY KEY (`DietarycommentID`);

--
-- Indexes for table `Evaluation`
--
ALTER TABLE `Evaluation`
  ADD PRIMARY KEY (`EvaluationID`),
  ADD KEY `FK_Evaluation_Activity` (`ActivityID`),
  ADD KEY `FK_Evaluation_Signalement` (`SignalementID`),
  ADD KEY `FK_Evaluation_Child` (`ChildID`);

--
-- Indexes for table `Events`
--
ALTER TABLE `Events`
  ADD PRIMARY KEY (`EventsID`);

--
-- Indexes for table `Grade`
--
ALTER TABLE `Grade`
  ADD PRIMARY KEY (`GradeID`),
  ADD KEY `FK_Grade_Evaluation` (`EvaluationID`),
  ADD KEY `FK_Grade_Criteria` (`CriteriaID`),
  ADD KEY `FK_Grade_Gradestatus` (`GradestatusID`);

--
-- Indexes for table `Gradestatus`
--
ALTER TABLE `Gradestatus`
  ADD PRIMARY KEY (`GradestatusID`);

--
-- Indexes for table `Healthcomment`
--
ALTER TABLE `Healthcomment`
  ADD PRIMARY KEY (`HealthcommentID`);

--
-- Indexes for table `Inscription`
--
ALTER TABLE `Inscription`
  ADD PRIMARY KEY (`InscriptionID`),
  ADD KEY `FK_Inscription_Mealplan` (`MealplanID`),
  ADD KEY `FK_Inscription_Paymentmethod` (`PaymentmethodID`),
  ADD KEY `FK_Inscription_Inscriptiontype` (`InscriptiontypeID`),
  ADD KEY `FK_Inscription_Inscriptionstatus` (`InscriptionstatusID`);

--
-- Indexes for table `Inscriptionstatus`
--
ALTER TABLE `Inscriptionstatus`
  ADD PRIMARY KEY (`InscriptionstatusID`);

--
-- Indexes for table `Inscriptiontype`
--
ALTER TABLE `Inscriptiontype`
  ADD PRIMARY KEY (`InscriptiontypeID`);

--
-- Indexes for table `Mealplan`
--
ALTER TABLE `Mealplan`
  ADD PRIMARY KEY (`MealplanID`);

--
-- Indexes for table `Meals`
--
ALTER TABLE `Meals`
  ADD PRIMARY KEY (`MealsID`),
  ADD KEY `FK_Meals_Mealscategory` (`MealscategoryID`);

--
-- Indexes for table `Mealscategory`
--
ALTER TABLE `Mealscategory`
  ADD PRIMARY KEY (`MealscategoryID`);

--
-- Indexes for table `MealsChildFoodExceptionOverride`
--
ALTER TABLE `MealsChildFoodExceptionOverride`
  ADD KEY `FK_MealsChildFoodExceptionOverride_ChildFoodExceptionOverride` (`ChildfoodexceptionoverrideID`),
  ADD KEY `FK_MealsChildFoodExceptionOverride_replacement_meal` (`replacement_meal`);

--
-- Indexes for table `Medicalform`
--
ALTER TABLE `Medicalform`
  ADD PRIMARY KEY (`MedicalformID`),
  ADD KEY `FK_Medicalform_Dietarycomment` (`DietarycommentID`),
  ADD KEY `FK_Medicalform_Healthcomment` (`HealthcommentID`),
  ADD KEY `FK_Medicalform_Inscription` (`InscriptionID`);

--
-- Indexes for table `Menuplanning`
--
ALTER TABLE `Menuplanning`
  ADD PRIMARY KEY (`MenuplanningID`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `Notification`
--
ALTER TABLE `Notification`
  ADD PRIMARY KEY (`NotificationID`),
  ADD KEY `FK_Notification_Events` (`EventsID`);

--
-- Indexes for table `NotificationAccount`
--
ALTER TABLE `NotificationAccount`
  ADD KEY `FK_NotificationAccount_Account` (`AccountID`),
  ADD KEY `FK_NotificationAccount_Notification` (`NotificationID`);

--
-- Indexes for table `Parameter`
--
ALTER TABLE `Parameter`
  ADD PRIMARY KEY (`ParameterID`);

--
-- Indexes for table `Parent`
--
ALTER TABLE `Parent`
  ADD PRIMARY KEY (`ParentID`);

--
-- Indexes for table `Partialpayment`
--
ALTER TABLE `Partialpayment`
  ADD PRIMARY KEY (`PartialpaymentID`),
  ADD KEY `FK_Partialpayment_Payment` (`PaymentID`);

--
-- Indexes for table `Payment`
--
ALTER TABLE `Payment`
  ADD PRIMARY KEY (`PaymentID`),
  ADD KEY `FK_Payment_Inscription` (`InscriptionID`),
  ADD KEY `FK_Payment_Child` (`ChildID`);

--
-- Indexes for table `Paymentmethod`
--
ALTER TABLE `Paymentmethod`
  ADD PRIMARY KEY (`PaymentmethodID`);

--
-- Indexes for table `Person`
--
ALTER TABLE `Person`
  ADD PRIMARY KEY (`PersonID`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  ADD KEY `personal_access_tokens_expires_at_index` (`expires_at`);

--
-- Indexes for table `Pickupnotifications`
--
ALTER TABLE `Pickupnotifications`
  ADD PRIMARY KEY (`PickupnotificationsID`),
  ADD KEY `FK_Pickupnotifications_Parent` (`ParentID`),
  ADD KEY `FK_Pickupnotifications_Pickupnotificationsstatus` (`PickupnotificationsstatusID`);

--
-- Indexes for table `Pickupnotificationsstatus`
--
ALTER TABLE `Pickupnotificationsstatus`
  ADD PRIMARY KEY (`PickupnotificationsstatusID`);

--
-- Indexes for table `PickupNotificationsTeacher`
--
ALTER TABLE `PickupNotificationsTeacher`
  ADD KEY `FK_PickupNotificationsTeacher_Teacher` (`TeacherID`),
  ADD KEY `FK_PickupNotificationsTeacher_PickupNotifications` (`PickupnotificationsID`);

--
-- Indexes for table `Planday`
--
ALTER TABLE `Planday`
  ADD PRIMARY KEY (`PlandayID`),
  ADD KEY `FK_Planday_Planning` (`PlanningID`),
  ADD KEY `fk_planday_class` (`ClassID`);

--
-- Indexes for table `Plandayactivity`
--
ALTER TABLE `Plandayactivity`
  ADD PRIMARY KEY (`PlandayactivityID`),
  ADD KEY `FK_planDayActivity_Activity` (`ActivityID`),
  ADD KEY `FK_planDayActivity_planDay` (`PlandayID`);

--
-- Indexes for table `Planning`
--
ALTER TABLE `Planning`
  ADD PRIMARY KEY (`PlanningID`);

--
-- Indexes for table `Presence`
--
ALTER TABLE `Presence`
  ADD PRIMARY KEY (`PresenceID`),
  ADD KEY `FK_Presence_Child` (`ChildID`),
  ADD KEY `FK_Presence_Presencestatus` (`PresencestatusID`);

--
-- Indexes for table `Presencestatus`
--
ALTER TABLE `Presencestatus`
  ADD PRIMARY KEY (`PresencestatusID`);

--
-- Indexes for table `Reportanalysishistory`
--
ALTER TABLE `Reportanalysishistory`
  ADD PRIMARY KEY (`ReportanalysishistoryID`);

--
-- Indexes for table `Role`
--
ALTER TABLE `Role`
  ADD PRIMARY KEY (`RoleID`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `Signalement`
--
ALTER TABLE `Signalement`
  ADD PRIMARY KEY (`SignalementID`),
  ADD KEY `FK_Signalement_Reportanalysishistory` (`ReportanalysishistoryID`);

--
-- Indexes for table `Teacher`
--
ALTER TABLE `Teacher`
  ADD PRIMARY KEY (`TeacherID`);

--
-- Indexes for table `TeacherClass`
--
ALTER TABLE `TeacherClass`
  ADD PRIMARY KEY (`TeacherID`,`ClassID`),
  ADD KEY `ClassID` (`ClassID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Account`
--
ALTER TABLE `Account`
  MODIFY `AccountID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40000073;

--
-- AUTO_INCREMENT for table `Activity`
--
ALTER TABLE `Activity`
  MODIFY `ActivityID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=57;

--
-- AUTO_INCREMENT for table `Child`
--
ALTER TABLE `Child`
  MODIFY `ChildID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=215;

--
-- AUTO_INCREMENT for table `Childfoodexception`
--
ALTER TABLE `Childfoodexception`
  MODIFY `ChildfoodexceptionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=184;

--
-- AUTO_INCREMENT for table `Childfoodexceptionoverride`
--
ALTER TABLE `Childfoodexceptionoverride`
  MODIFY `ChildfoodexceptionoverrideID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8910;

--
-- AUTO_INCREMENT for table `Childphoto`
--
ALTER TABLE `Childphoto`
  MODIFY `ChildphotoID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `Childphotorecipient`
--
ALTER TABLE `Childphotorecipient`
  MODIFY `ChildphotorecipientID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT for table `Class`
--
ALTER TABLE `Class`
  MODIFY `ClassID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `Classtype`
--
ALTER TABLE `Classtype`
  MODIFY `ClasstypeID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `Criteria`
--
ALTER TABLE `Criteria`
  MODIFY `CriteriaID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `Dailyplan`
--
ALTER TABLE `Dailyplan`
  MODIFY `DailyplanID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=286;

--
-- AUTO_INCREMENT for table `Dietarycomment`
--
ALTER TABLE `Dietarycomment`
  MODIFY `DietarycommentID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=206;

--
-- AUTO_INCREMENT for table `Evaluation`
--
ALTER TABLE `Evaluation`
  MODIFY `EvaluationID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=231;

--
-- AUTO_INCREMENT for table `Events`
--
ALTER TABLE `Events`
  MODIFY `EventsID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `Grade`
--
ALTER TABLE `Grade`
  MODIFY `GradeID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=372;

--
-- AUTO_INCREMENT for table `Gradestatus`
--
ALTER TABLE `Gradestatus`
  MODIFY `GradestatusID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `Healthcomment`
--
ALTER TABLE `Healthcomment`
  MODIFY `HealthcommentID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=205;

--
-- AUTO_INCREMENT for table `Inscription`
--
ALTER TABLE `Inscription`
  MODIFY `InscriptionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=179;

--
-- AUTO_INCREMENT for table `Inscriptionstatus`
--
ALTER TABLE `Inscriptionstatus`
  MODIFY `InscriptionstatusID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `Inscriptiontype`
--
ALTER TABLE `Inscriptiontype`
  MODIFY `InscriptiontypeID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `Mealplan`
--
ALTER TABLE `Mealplan`
  MODIFY `MealplanID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `Meals`
--
ALTER TABLE `Meals`
  MODIFY `MealsID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `Mealscategory`
--
ALTER TABLE `Mealscategory`
  MODIFY `MealscategoryID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `Medicalform`
--
ALTER TABLE `Medicalform`
  MODIFY `MedicalformID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=159;

--
-- AUTO_INCREMENT for table `Menuplanning`
--
ALTER TABLE `Menuplanning`
  MODIFY `MenuplanningID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `Notification`
--
ALTER TABLE `Notification`
  MODIFY `NotificationID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=95;

--
-- AUTO_INCREMENT for table `Parameter`
--
ALTER TABLE `Parameter`
  MODIFY `ParameterID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `Parent`
--
ALTER TABLE `Parent`
  MODIFY `ParentID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40000074;

--
-- AUTO_INCREMENT for table `Partialpayment`
--
ALTER TABLE `Partialpayment`
  MODIFY `PartialpaymentID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=389;

--
-- AUTO_INCREMENT for table `Payment`
--
ALTER TABLE `Payment`
  MODIFY `PaymentID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=158;

--
-- AUTO_INCREMENT for table `Paymentmethod`
--
ALTER TABLE `Paymentmethod`
  MODIFY `PaymentmethodID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `Person`
--
ALTER TABLE `Person`
  MODIFY `PersonID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40000074;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=182;

--
-- AUTO_INCREMENT for table `Pickupnotifications`
--
ALTER TABLE `Pickupnotifications`
  MODIFY `PickupnotificationsID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `Pickupnotificationsstatus`
--
ALTER TABLE `Pickupnotificationsstatus`
  MODIFY `PickupnotificationsstatusID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `Planday`
--
ALTER TABLE `Planday`
  MODIFY `PlandayID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2664;

--
-- AUTO_INCREMENT for table `Plandayactivity`
--
ALTER TABLE `Plandayactivity`
  MODIFY `PlandayactivityID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6477;

--
-- AUTO_INCREMENT for table `Planning`
--
ALTER TABLE `Planning`
  MODIFY `PlanningID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `Presence`
--
ALTER TABLE `Presence`
  MODIFY `PresenceID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `Presencestatus`
--
ALTER TABLE `Presencestatus`
  MODIFY `PresencestatusID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `Reportanalysishistory`
--
ALTER TABLE `Reportanalysishistory`
  MODIFY `ReportanalysishistoryID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `Role`
--
ALTER TABLE `Role`
  MODIFY `RoleID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `Signalement`
--
ALTER TABLE `Signalement`
  MODIFY `SignalementID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `Teacher`
--
ALTER TABLE `Teacher`
  MODIFY `TeacherID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40000071;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `Account`
--
ALTER TABLE `Account`
  ADD CONSTRAINT `FK_Account_Person` FOREIGN KEY (`PersonID`) REFERENCES `Person` (`PersonID`),
  ADD CONSTRAINT `FK_Account_Role` FOREIGN KEY (`RoleID`) REFERENCES `Role` (`RoleID`);

--
-- Constraints for table `Child`
--
ALTER TABLE `Child`
  ADD CONSTRAINT `FK_Child_Parent` FOREIGN KEY (`ParentID`) REFERENCES `Parent` (`ParentID`);

--
-- Constraints for table `ChildClass`
--
ALTER TABLE `ChildClass`
  ADD CONSTRAINT `FK_ChildClass_Child` FOREIGN KEY (`ChildID`) REFERENCES `Child` (`ChildID`),
  ADD CONSTRAINT `FK_ChildClass_Class` FOREIGN KEY (`ClassID`) REFERENCES `Class` (`ClassID`);

--
-- Constraints for table `Childfoodexception`
--
ALTER TABLE `Childfoodexception`
  ADD CONSTRAINT `FK_Childfoodexception_Child` FOREIGN KEY (`ChildID`) REFERENCES `Child` (`ChildID`);

--
-- Constraints for table `ChildFoodExceptionMeals`
--
ALTER TABLE `ChildFoodExceptionMeals`
  ADD CONSTRAINT `FK_ChildFoodExceptionMeals_ChildFoodException` FOREIGN KEY (`ChildfoodexceptionID`) REFERENCES `Childfoodexception` (`ChildfoodexceptionID`),
  ADD CONSTRAINT `FK_ChildFoodExceptionMeals_Meals` FOREIGN KEY (`MealsID`) REFERENCES `Meals` (`MealsID`);

--
-- Constraints for table `Childfoodexceptionoverride`
--
ALTER TABLE `Childfoodexceptionoverride`
  ADD CONSTRAINT `FK_Childfoodexceptionoverride_Meals` FOREIGN KEY (`replacement_meal`) REFERENCES `Meals` (`MealsID`),
  ADD CONSTRAINT `fk_override_child` FOREIGN KEY (`ChildID`) REFERENCES `Child` (`ChildID`);

--
-- Constraints for table `ChildFoodExceptionOverrideMeals`
--
ALTER TABLE `ChildFoodExceptionOverrideMeals`
  ADD CONSTRAINT `FK_ChildFoodExceptionOverrideMeals_ChildFoodExceptionOverride` FOREIGN KEY (`ChildfoodexceptionoverrideID`) REFERENCES `Childfoodexceptionoverride` (`ChildfoodexceptionoverrideID`),
  ADD CONSTRAINT `FK_ChildFoodExceptionOverrideMeals_original_meal` FOREIGN KEY (`original_meal`) REFERENCES `Meals` (`MealsID`);

--
-- Constraints for table `Childphoto`
--
ALTER TABLE `Childphoto`
  ADD CONSTRAINT `FK_Childphoto_Teacher` FOREIGN KEY (`TeacherID`) REFERENCES `Teacher` (`TeacherID`);

--
-- Constraints for table `Childphotorecipient`
--
ALTER TABLE `Childphotorecipient`
  ADD CONSTRAINT `FK_ChildPhotoRecipient_Child` FOREIGN KEY (`ChildID`) REFERENCES `Child` (`ChildID`),
  ADD CONSTRAINT `FK_ChildPhotoRecipient_ChildPhoto` FOREIGN KEY (`ChildphotoID`) REFERENCES `Childphoto` (`ChildphotoID`);

--
-- Constraints for table `Class`
--
ALTER TABLE `Class`
  ADD CONSTRAINT `FK_Class_Classtype` FOREIGN KEY (`ClasstypeID`) REFERENCES `Classtype` (`ClasstypeID`),
  ADD CONSTRAINT `FK_Class_Planning` FOREIGN KEY (`PlanningID`) REFERENCES `Planning` (`PlanningID`);

--
-- Constraints for table `CriteriaActivity`
--
ALTER TABLE `CriteriaActivity`
  ADD CONSTRAINT `FK_CriteriaActivity_Activity` FOREIGN KEY (`ActivityID`) REFERENCES `Activity` (`ActivityID`),
  ADD CONSTRAINT `FK_CriteriaActivity_Criteria` FOREIGN KEY (`CriteriaID`) REFERENCES `Criteria` (`CriteriaID`);

--
-- Constraints for table `Dailyplan`
--
ALTER TABLE `Dailyplan`
  ADD CONSTRAINT `FK_Dailyplan_Menuplanning` FOREIGN KEY (`MenuplanningID`) REFERENCES `Menuplanning` (`MenuplanningID`);

--
-- Constraints for table `DailyPlanMeals`
--
ALTER TABLE `DailyPlanMeals`
  ADD CONSTRAINT `FK_DailyPlanMeals_DailyPlan` FOREIGN KEY (`DailyplanID`) REFERENCES `Dailyplan` (`DailyplanID`),
  ADD CONSTRAINT `FK_DailyPlanMeals_Meals` FOREIGN KEY (`MealsID`) REFERENCES `Meals` (`MealsID`);

--
-- Constraints for table `Evaluation`
--
ALTER TABLE `Evaluation`
  ADD CONSTRAINT `FK_Evaluation_Activity` FOREIGN KEY (`ActivityID`) REFERENCES `Activity` (`ActivityID`),
  ADD CONSTRAINT `FK_Evaluation_Child` FOREIGN KEY (`ChildID`) REFERENCES `Child` (`ChildID`),
  ADD CONSTRAINT `FK_Evaluation_Signalement` FOREIGN KEY (`SignalementID`) REFERENCES `Signalement` (`SignalementID`);

--
-- Constraints for table `Grade`
--
ALTER TABLE `Grade`
  ADD CONSTRAINT `FK_Grade_Criteria` FOREIGN KEY (`CriteriaID`) REFERENCES `Criteria` (`CriteriaID`),
  ADD CONSTRAINT `FK_Grade_Evaluation` FOREIGN KEY (`EvaluationID`) REFERENCES `Evaluation` (`EvaluationID`),
  ADD CONSTRAINT `FK_Grade_Gradestatus` FOREIGN KEY (`GradestatusID`) REFERENCES `Gradestatus` (`GradestatusID`);

--
-- Constraints for table `Inscription`
--
ALTER TABLE `Inscription`
  ADD CONSTRAINT `FK_Inscription_Inscriptionstatus` FOREIGN KEY (`InscriptionstatusID`) REFERENCES `Inscriptionstatus` (`InscriptionstatusID`),
  ADD CONSTRAINT `FK_Inscription_Inscriptiontype` FOREIGN KEY (`InscriptiontypeID`) REFERENCES `Inscriptiontype` (`InscriptiontypeID`),
  ADD CONSTRAINT `FK_Inscription_Mealplan` FOREIGN KEY (`MealplanID`) REFERENCES `Mealplan` (`MealplanID`),
  ADD CONSTRAINT `FK_Inscription_Paymentmethod` FOREIGN KEY (`PaymentmethodID`) REFERENCES `Paymentmethod` (`PaymentmethodID`);

--
-- Constraints for table `Meals`
--
ALTER TABLE `Meals`
  ADD CONSTRAINT `FK_Meals_Mealscategory` FOREIGN KEY (`MealscategoryID`) REFERENCES `Mealscategory` (`MealscategoryID`);

--
-- Constraints for table `MealsChildFoodExceptionOverride`
--
ALTER TABLE `MealsChildFoodExceptionOverride`
  ADD CONSTRAINT `FK_MealsChildFoodExceptionOverride_ChildFoodExceptionOverride` FOREIGN KEY (`ChildfoodexceptionoverrideID`) REFERENCES `Childfoodexceptionoverride` (`ChildfoodexceptionoverrideID`),
  ADD CONSTRAINT `FK_MealsChildFoodExceptionOverride_replacement_meal` FOREIGN KEY (`replacement_meal`) REFERENCES `Meals` (`MealsID`);

--
-- Constraints for table `Medicalform`
--
ALTER TABLE `Medicalform`
  ADD CONSTRAINT `FK_Medicalform_Dietarycomment` FOREIGN KEY (`DietarycommentID`) REFERENCES `Dietarycomment` (`DietarycommentID`),
  ADD CONSTRAINT `FK_Medicalform_Healthcomment` FOREIGN KEY (`HealthcommentID`) REFERENCES `Healthcomment` (`HealthcommentID`),
  ADD CONSTRAINT `FK_Medicalform_Inscription` FOREIGN KEY (`InscriptionID`) REFERENCES `Inscription` (`InscriptionID`);

--
-- Constraints for table `Notification`
--
ALTER TABLE `Notification`
  ADD CONSTRAINT `FK_Notification_Events` FOREIGN KEY (`EventsID`) REFERENCES `Events` (`EventsID`);

--
-- Constraints for table `NotificationAccount`
--
ALTER TABLE `NotificationAccount`
  ADD CONSTRAINT `FK_NotificationAccount_Account` FOREIGN KEY (`AccountID`) REFERENCES `Account` (`AccountID`),
  ADD CONSTRAINT `FK_NotificationAccount_Notification` FOREIGN KEY (`NotificationID`) REFERENCES `Notification` (`NotificationID`);

--
-- Constraints for table `Parent`
--
ALTER TABLE `Parent`
  ADD CONSTRAINT `FK_Parent_Person` FOREIGN KEY (`ParentID`) REFERENCES `Person` (`PersonID`);

--
-- Constraints for table `Partialpayment`
--
ALTER TABLE `Partialpayment`
  ADD CONSTRAINT `FK_Partialpayment_Payment` FOREIGN KEY (`PaymentID`) REFERENCES `Payment` (`PaymentID`);

--
-- Constraints for table `Payment`
--
ALTER TABLE `Payment`
  ADD CONSTRAINT `FK_Payment_Child` FOREIGN KEY (`ChildID`) REFERENCES `Child` (`ChildID`),
  ADD CONSTRAINT `FK_Payment_Inscription` FOREIGN KEY (`InscriptionID`) REFERENCES `Inscription` (`InscriptionID`);

--
-- Constraints for table `Pickupnotifications`
--
ALTER TABLE `Pickupnotifications`
  ADD CONSTRAINT `FK_Pickupnotifications_Parent` FOREIGN KEY (`ParentID`) REFERENCES `Parent` (`ParentID`),
  ADD CONSTRAINT `FK_Pickupnotifications_Pickupnotificationsstatus` FOREIGN KEY (`PickupnotificationsstatusID`) REFERENCES `Pickupnotificationsstatus` (`PickupnotificationsstatusID`);

--
-- Constraints for table `PickupNotificationsTeacher`
--
ALTER TABLE `PickupNotificationsTeacher`
  ADD CONSTRAINT `FK_PickupNotificationsTeacher_PickupNotifications` FOREIGN KEY (`PickupnotificationsID`) REFERENCES `Pickupnotifications` (`PickupnotificationsID`),
  ADD CONSTRAINT `FK_PickupNotificationsTeacher_Teacher` FOREIGN KEY (`TeacherID`) REFERENCES `Teacher` (`TeacherID`);

--
-- Constraints for table `Planday`
--
ALTER TABLE `Planday`
  ADD CONSTRAINT `FK_Planday_Planning` FOREIGN KEY (`PlanningID`) REFERENCES `Planning` (`PlanningID`),
  ADD CONSTRAINT `fk_planday_class` FOREIGN KEY (`ClassID`) REFERENCES `Class` (`ClassID`) ON DELETE CASCADE;

--
-- Constraints for table `Plandayactivity`
--
ALTER TABLE `Plandayactivity`
  ADD CONSTRAINT `FK_planDayActivity_Activity` FOREIGN KEY (`ActivityID`) REFERENCES `Activity` (`ActivityID`),
  ADD CONSTRAINT `FK_planDayActivity_planDay` FOREIGN KEY (`PlandayID`) REFERENCES `Planday` (`PlandayID`);

--
-- Constraints for table `Presence`
--
ALTER TABLE `Presence`
  ADD CONSTRAINT `FK_Presence_Child` FOREIGN KEY (`ChildID`) REFERENCES `Child` (`ChildID`),
  ADD CONSTRAINT `FK_Presence_Presencestatus` FOREIGN KEY (`PresencestatusID`) REFERENCES `Presencestatus` (`PresencestatusID`);

--
-- Constraints for table `Signalement`
--
ALTER TABLE `Signalement`
  ADD CONSTRAINT `FK_Signalement_Reportanalysishistory` FOREIGN KEY (`ReportanalysishistoryID`) REFERENCES `Reportanalysishistory` (`ReportanalysishistoryID`);

--
-- Constraints for table `Teacher`
--
ALTER TABLE `Teacher`
  ADD CONSTRAINT `FK_Teacher_Person` FOREIGN KEY (`TeacherID`) REFERENCES `Person` (`PersonID`);

--
-- Constraints for table `TeacherClass`
--
ALTER TABLE `TeacherClass`
  ADD CONSTRAINT `TeacherClass_ibfk_1` FOREIGN KEY (`TeacherID`) REFERENCES `Teacher` (`TeacherID`) ON DELETE CASCADE,
  ADD CONSTRAINT `TeacherClass_ibfk_2` FOREIGN KEY (`ClassID`) REFERENCES `Class` (`ClassID`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
