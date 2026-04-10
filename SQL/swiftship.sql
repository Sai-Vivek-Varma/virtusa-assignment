CREATE DATABASE IF NOT EXISTS swiftship;
USE swiftship;

-- 1. Schema Design

CREATE TABLE partners(
	partnerId INT PRIMARY KEY,
    company VARCHAR(30) NOT NULL,
    contact VARCHAR(20),
    email VARCHAR(30) UNIQUE,
    isActive BOOLEAN DEFAULT TRUE
);

INSERT INTO partners (partnerId, company, contact, email) VALUES
(101, 'Blue Dart', '555-9001', 'bluedart@gmail.com'),
(102, 'DTDC', '555-9002', 'dtdc@gmail.com'),
(103, 'FedEx', '555-9003', 'fedex@gmail.com'),
(104, 'Ekart', '555-9004', 'ekart@gmail.com'),
(105, 'Shadowfax', '555-9005', 'shadowfax@gmail.com');

SELECT * FROM partners;

CREATE TABLE shipments(
	shipmentId INT PRIMARY KEY,
    partnerId INT,
    customer VARCHAR(20) NOT NULL,
    destinationCity VARCHAR(20) NOT NULL,
    packageType VARCHAR(10) NOT NULL,
    packageWeight DECIMAL(5, 2) NOT NULL,
    orderDate DATE NOT NULL,
    promisedDate DATE NOT NULL,
    FOREIGN KEY (partnerId) REFERENCES partners(partnerId)
);

INSERT INTO shipments VALUES
(7001, 101, 'Arisu', 'Bengaluru', 'Box', 2.50, '2026-03-20', '2026-03-24'),
(7002, 102, 'Zoro', 'Hyderabad', 'Envelope', 0.50, '2026-03-25', '2026-03-28'),
(7003, 101, 'Levi', 'Hyderabad', 'Crate', 15.00, '2026-04-01', '2026-04-04'),
(7004, 103, 'Mikasa', 'Mumbai', 'Box', 4.25, '2026-04-02', '2026-04-06'),
(7005, 104, 'Tanjiro', 'Chennai', 'Box', 4.50, '2026-04-03', '2026-04-06');

SELECT * FROM shipments;

CREATE TABLE deliveryLogs(
	deliveryId INT PRIMARY KEY,
    shipmentId INT,
    riderName VARCHAR(20),
    deliveryDate DATE NOT NULL,
    deliveryStatus ENUM('Successful', 'Returned', 'In Transit') NOT NULL,
    FOREIGN KEY (shipmentId) REFERENCES shipments(shipmentId)
);

INSERT INTO deliveryLogs VALUES
(9001, 7001, 'Ramesh', '2026-03-23', 'Successful'),
(9002, 7002, 'Suresh', '2026-03-30', 'Returned'),
(9003, 7003, 'Ravi', '2026-04-05', 'Successful'),
(9004, 7004, 'Kiran', '2026-04-05', 'Successful'),
(9005, 7005, 'Sanjay', '2026-04-08', 'In Transit');

SELECT * FROM deliveryLogs;

-- 2. Delayed shipment query (shipments where ActualDeliveryDate > PromisedDate)

SELECT s.shipmentId, s.destinationCity, s.promisedDate, d.deliveryDate
FROM shipments s
JOIN deliveryLogs d 
ON s.shipmentId = d.shipmentId
where d.deliveryDate > s.promisedDate;

-- 3. Performance ranking (Successful vs Returned deliveries by each partner)

SELECT p.company, succ.sCount AS successful, ret.rCount AS returned
FROM partners p
LEFT JOIN (
	SELECT s.partnerId, COUNT(d.deliveryId) AS sCount
    FROM shipments s
    JOIN deliveryLogs d ON d.shipmentId = s.shipmentId
    WHERE d.deliveryStatus = 'Successful'
    GROUP BY s.partnerId
) succ ON succ.partnerId = p.partnerId
LEFT JOIN (
	SELECT s.partnerId, COUNT(d.deliveryId) AS rCount
    FROM shipments s
    JOIN deliveryLogs d ON d.shipmentId = s.shipmentId
    WHERE d.deliveryStatus = 'Returned'
    GROUP BY s.partnerId
) ret ON ret.partnerId = p.partnerId
ORDER BY p.company;

-- 4. The Zone filter (Most popular Destination City for orders placed in the last 30 days)

SELECT destinationCity, COUNT(shipmentId) AS total
FROM shipments
WHERE orderDate >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY destinationCity
ORDER BY total DESC
limit 1;

-- 5. Partner Scorecard (Rank partners showing which company has the fewest delays)

SELECT 
    p.company,
    t.totalShipments,
    d.totalDelays
FROM partners p
LEFT JOIN (
    SELECT partnerId, COUNT(shipmentId) AS totalShipments
    FROM shipments
    GROUP BY partnerId
) t ON t.partnerId = p.partnerId
LEFT JOIN (
    SELECT s.partnerId, COUNT(d.deliveryId) AS totalDelays
    FROM shipments s
    JOIN deliveryLogs d ON s.shipmentId = d.shipmentId
    WHERE d.deliveryDate > s.promisedDate
    GROUP BY s.partnerId
) d ON d.partnerId = p.partnerId
ORDER BY d.totalDelays ASC;