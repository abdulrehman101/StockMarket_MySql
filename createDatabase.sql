DROP DATABASE IF EXISTS StockMarket;
CREATE DATABASE StockMarket;
USE StockMarket;


DROP TABLE IF EXISTS `Company`;
CREATE TABLE `Company` (
  `CompanyID` int(11) DEFAULT NULL,
  `CompanyName` varchar(60) DEFAULT NULL,
  `TickerName` varchar(4) DEFAULT NULL,
  PRIMARY KEY (`CompanyID`)
);

DROP TABLE IF EXISTS `Person`;
CREATE TABLE `Person` (
  `AccountID` int(11) NOT NULL AUTO_INCREMENT,
  `Balance` decimal(14,2) DEFAULT NULL,
  `AccountName` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`AccountID`)
);

DROP TABLE IF EXISTS `Stock`;
CREATE TABLE `Stock` (
  `StockID` int(11) NOT NULL AUTO_INCREMENT,
  `CompanyID` int(11) NOT NULL,
  `AccountID` int(11) NOT NULL,
  `Quantity` int(11) NOT NULL DEFAULT 1,
  PRIMARY KEY (`StockID`),
  FOREIGN KEY (`CompanyID`) REFERENCES `Company` (`CompanyID`),
  FOREIGN KEY (`AccountID`) REFERENCES `Person` (`AccountID`)
) ;

DROP TABLE IF EXISTS `SellOrder`;
CREATE TABLE `SellOrder` (
  `LotID` int(11) NOT NULL AUTO_INCREMENT,
  `StockID` int(11) NOT NULL,
  `Price` decimal(6,2) DEFAULT 1,
  PRIMARY KEY (`LotID`),
  FOREIGN KEY (`StockID`) REFERENCES `Stock` (`StockID`)
);

INSERT INTO `Company` VALUES (1,'A','A'),(2,'B','B'),(3,'C','C'),(1001,'Alphabet','GOOG'),(55,'Oracle','ORCL'),(124,'Caterpillar','CAT'),(125,'Dow 30','DOG');
INSERT INTO `Person` VALUES (1,15216.00,'Alice'),(2,6727.00,'Bob'),(3,11270.00,'Carol'),(4,10000.00,'Dave'),(5,5000.00,'Eve'),(46,10.00,'Frank'),(17,310.00,'Abe'),(28,9000.00,'Mc\'Donald'),(9,9000.00,'MacGregor'),(10,20.00,'O\'Leery'),(11,9000.00,'Soverign'),(12,20.00,'Emilio'),(14,0.00,'L\'Chuck'),(15,0.00,'Nyx');
INSERT INTO `Stock` VALUES (1,1001,5,10),(3,3,2,100),(4,3,2,100),(5,3,3,100),(6,3,3,100),(7,3,1,90),(8,55,4,100),(9,3,2,100),(10,3,1,100),(11,55,1,100),(12,124,2,1000),(13,125,3,1500),(27,125,46,1000),(28,124,15,1000),(29,1001,15,5);
INSERT INTO `SellOrder` VALUES (1,1,10.23),(2,5,32.56),(5,13,2500.00),(7,27,0.45),(8,29,19.00);
