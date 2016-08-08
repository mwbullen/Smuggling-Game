CREATE TABLE `REGIONS` (
	`REGIONID`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`NAME`	INTEGER NOT NULL UNIQUE
);
INSERT INTO `REGIONS` VALUES (1,'North America');
INSERT INTO `REGIONS` VALUES (2,'Europe');
INSERT INTO `REGIONS` VALUES (3,'South America');
INSERT INTO `REGIONS` VALUES (4,'Middle East');
INSERT INTO `REGIONS` VALUES (5,'Southeast Asia');
CREATE TABLE "REGIONTRAVELTIMES" (
	`POINT1`	INTEGER NOT NULL,
	`POINT2`	INTEGER NOT NULL,
	`BASETIME`	INTEGER NOT NULL,
	`REGIONTRAVELTIMEID`	INTEGER PRIMARY KEY AUTOINCREMENT,
	FOREIGN KEY(`POINT1`) REFERENCES `REGIONS`(`REGIONID`),
	FOREIGN KEY(`POINT2`) REFERENCES `REGIONS`(`REGIONID`)
);
INSERT INTO `REGIONTRAVELTIMES` VALUES (1,2,2,1);
INSERT INTO `REGIONTRAVELTIMES` VALUES (1,3,1,2);
INSERT INTO `REGIONTRAVELTIMES` VALUES (1,4,4,3);
INSERT INTO `REGIONTRAVELTIMES` VALUES (1,5,8,4);
INSERT INTO `REGIONTRAVELTIMES` VALUES (2,3,3,5);
INSERT INTO `REGIONTRAVELTIMES` VALUES (2,4,2,6);
INSERT INTO `REGIONTRAVELTIMES` VALUES (2,5,6,7);
INSERT INTO `REGIONTRAVELTIMES` VALUES (3,4,8,8);
INSERT INTO `REGIONTRAVELTIMES` VALUES (3,5,6,9);
INSERT INTO `REGIONTRAVELTIMES` VALUES (4,5,3,10);
CREATE TABLE `PLAYERSTATUS` (
	`CURRENTMONEY`	INTEGER NOT NULL DEFAULT 0
);
INSERT INTO `PLAYERSTATUS` VALUES (0);
CREATE TABLE "PERKS" (
	`PERKID`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`AGENTID`	INTEGER NOT NULL,
	`TYPE`	TEXT,
	`STRENGTH`	REAL,
	FOREIGN KEY(`AGENTID`) REFERENCES "AGENTS"(`AGENTID`)
);
CREATE TABLE "PASSPORTS" (
	`PASSPORTID`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`PERSONNAME`	TEXT NOT NULL UNIQUE,
	`HEAT`	INTEGER NOT NULL DEFAULT 0,
	`OWNED`	INTEGER NOT NULL DEFAULT 0,
	`PRICE`	INTEGER DEFAULT 0
);
CREATE TABLE "OPENCONTRACTS" (
	`OPENCONTRACTID`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`ORIGIN`	TEXT NOT NULL,
	`DESTINATION`	TEXT NOT NULL,
	`VALUE`	INTEGER DEFAULT 0,
	`DURATION`	INTEGER NOT NULL DEFAULT 1,
	`EXPIRATION`	INTEGER,
	`RISK`	INTEGER,
	FOREIGN KEY(`ORIGIN`) REFERENCES `CITIES`(`CITYID`),
	FOREIGN KEY(`DESTINATION`) REFERENCES `CITIES`(`CITYID`)
);
CREATE TABLE "JOBS" (
	`JOBID`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	`AGENTID`	INTEGER NOT NULL,
	`COMPLETE`	INT NOT NULL DEFAULT 0,
	`ORIGIN`	INTEGER NOT NULL,
	`DESTINATION`	INTEGER NOT NULL,
	`VALUE`	NUMERIC NOT NULL,
	`ETA`	INTEGER,
	`PASSPORTID`	INTEGER,
	`STARTTIME`	INTEGER NOT NULL,
	FOREIGN KEY(`AGENTID`) REFERENCES "AGENTS"(`AGENTID`),
	FOREIGN KEY(`PASSPORTID`) REFERENCES `PASSPORTS`(`PASSPORTID`)
);
CREATE TABLE "CITIES" (
	`CITYID`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`REGIONID`	INTEGER NOT NULL DEFAULT 1,
	`NAME`	TEXT NOT NULL DEFAULT 'NONE' UNIQUE,
	`SECURITY`	INTEGER,
	FOREIGN KEY(`REGIONID`) REFERENCES `REGIONS`(`REGIONID`)
);
INSERT INTO `CITIES` VALUES (1,1,'New York',8);
INSERT INTO `CITIES` VALUES (2,1,'Montreal',5);
INSERT INTO `CITIES` VALUES (3,1,'Miami',3);
INSERT INTO `CITIES` VALUES (4,1,'Mexico City',3);
INSERT INTO `CITIES` VALUES (5,1,'New Orleans',1);
INSERT INTO `CITIES` VALUES (6,2,'Paris',6);
INSERT INTO `CITIES` VALUES (7,2,'Amsterdam',6);
INSERT INTO `CITIES` VALUES (8,2,'Milan',4);
INSERT INTO `CITIES` VALUES (9,2,'Moscow',7);
INSERT INTO `CITIES` VALUES (10,2,'Prague',4);
INSERT INTO `CITIES` VALUES (11,3,'Bogota',3);
INSERT INTO `CITIES` VALUES (12,3,'Buenos Aires',2);
INSERT INTO `CITIES` VALUES (13,3,'Santiago',2);
INSERT INTO `CITIES` VALUES (14,3,'Quitos',3);
INSERT INTO `CITIES` VALUES (15,3,'Caracas',6);
INSERT INTO `CITIES` VALUES (16,4,'Dubai',8);
INSERT INTO `CITIES` VALUES (17,4,'Karachi',4);
INSERT INTO `CITIES` VALUES (18,4,'Kabul',8);
INSERT INTO `CITIES` VALUES (19,4,'Tehran',9);
INSERT INTO `CITIES` VALUES (20,4,'Riyadh',5);
INSERT INTO `CITIES` VALUES (21,5,'Singapore',8);
INSERT INTO `CITIES` VALUES (22,5,'Hanoi',3);
INSERT INTO `CITIES` VALUES (23,5,'Tokyo',6);
INSERT INTO `CITIES` VALUES (24,5,'Pyongyang',10);
INSERT INTO `CITIES` VALUES (25,5,'Taipei',2);
CREATE TABLE "AGENTS" (
	`AGENTID`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`AGENTNAME`	TEXT NOT NULL UNIQUE,
	`HEAT`	NUMERIC NOT NULL DEFAULT 0,
	`OWNED`	INTEGER NOT NULL DEFAULT 1,
	`PRICE`	INTEGER DEFAULT 0,
	`LEVEL`	INTEGER NOT NULL DEFAULT 1,
	`EXPERIENCE`	INTEGER NOT NULL DEFAULT 0,
	`MAXHEAT`	INTEGER DEFAULT 100,
	`CITYID`	INTEGER NOT NULL DEFAULT 1,
	`HEATZEROTIME`	INTEGER DEFAULT 0,
	`HEATLOSSPERMIN`	INTEGER DEFAULT 0,
	FOREIGN KEY(`CITYID`) REFERENCES `CITIES`(`CITYID`)
);
INSERT INTO `AGENTS` VALUES (1,'GHOST',0,1,0,1,0,100,1,NULL,NULL);
INSERT INTO `AGENTS` VALUES (2,'NIGHTHAWK',0,1,0,1,0,100,1,NULL,NULL);
INSERT INTO `AGENTS` VALUES (3,'RED FOX',0,1,0,1,0,100,1,NULL,NULL);
COMMIT;