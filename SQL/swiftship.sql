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
(701, 101, 'Eren', 'Hyderabad', 'Box', 3.00, '2026-04-10', '2026-04-14'),
(702, 102, 'Naruto', 'Bengaluru', 'Envelope', 0.75, '2026-04-12', '2026-04-15'),
(703, 103, 'Luffy', 'Mumbai', 'Crate', 12.00, '2026-04-15', '2026-04-20'),
(704, 104, 'Ichigo', 'Chennai', 'Box', 5.00, '2026-04-18', '2026-04-22'),
(705, 105, 'Sasuke', 'Hyderabad', 'Envelope', 1.20, '2026-04-19', '2026-04-23'),
(706, 101, 'Goku', 'Delhi', 'Box', 6.00, '2026-04-20', '2026-04-25'),
(707, 102, 'Vegeta', 'Delhi', 'Crate', 10.00, '2026-04-21', '2026-04-26'),
(708, 103, 'Gojo', 'Bengaluru', 'Box', 2.80, '2026-04-22', '2026-04-27'),
(709, 104, 'Saitama', 'Mumbai', 'Envelope', 0.60, '2026-04-23', '2026-04-28'),
(710, 105, 'Itachi', 'Hyderabad', 'Box', 3.50, '2026-04-24', '2026-04-29');

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
(901, 701, 'Arjun', '2026-04-07', 'Successful'),
(902, 702, 'Rohit', '2026-04-16', 'Returned'),
(903, 703, 'Amit', '2026-04-18', 'Successful'),
(904, 704, 'Vijay', '2026-04-21', 'Returned'),
(905, 705, 'Karthik', '2026-04-25', 'Successful'),
(906, 706, 'Manoj', '2026-04-22', 'Returned'),
(907, 707, 'Deepak', '2026-04-28', 'Returned'),
(908, 708, 'Suraj', '2026-04-30', 'Returned'),
(909, 709, 'Nikhil', '2026-04-26', 'Successful'),
(910, 710, 'Rahul', '2026-04-29', 'Successful');

SELECT * FROM deliveryLogs;

-- 2. Delayed shipment query (shipments where ActualDeliveryDate > PromisedDate)

SELECT s.shipmentId, s.destinationCity, s.promisedDate, d.deliveryDate
FROM shipments s
JOIN deliveryLogs d 
ON s.shipmentId = d.shipmentId
where d.deliveryDate > s.promisedDate;

-- 3. Performance ranking (Successful vs Returned deliveries by each partner)

SELECT p.company, succ.sCount as successful, ret.rCount as returned
FROM partners p
LEFT JOIN (
	SELECT s.partnerId, COUNT(d.deliveryId) as sCount
    FROM shipments s
    JOIN deliveryLogs d ON d.shipmentId = s.shipmentId
    WHERE d.deliveryStatus = 'Successful'
    GROUP BY s.partnerId
) succ ON succ.partnerId = p.partnerId
LEFT JOIN (
	SELECT s.partnerId, COUNT(d.deliveryId) as rCount
    FROM shipments s
    JOIN deliveryLogs d ON d.shipmentId = s.shipmentId
    WHERE d.deliveryStatus = 'Returned'
    GROUP BY s.partnerId
) ret ON ret.partnerId = p.partnerId
ORDER BY p.company;

-- 4. The Zone filter (Most popular Destination City for orders placed in the last 30 days)

SELECT destinationCity, COUNT(shipmentId) as total
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