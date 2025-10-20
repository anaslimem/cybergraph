
// Query 1: Find Pulses Sharing Multiple Indicators

MATCH (p1:Pulse)-[:CONTAINS]->(i:Indicator)<-[:CONTAINS]-(p2:Pulse)
WHERE p1.name < p2.name
WITH p1, p2, count(DISTINCT i) as SharedIndicators, collect(DISTINCT i.value) as CommonIOCs
WHERE SharedIndicators >= 3
RETURN p1.name as Campaign1, 
       p2.name as Campaign2, 
       SharedIndicators, 
       CommonIOCs
ORDER BY SharedIndicators DESC;

// Query 2: Detect Indicator Clustering by Type

MATCH (p:Pulse)-[:CONTAINS]->(i:Indicator)
WITH i, count(DISTINCT p) as PulseCount, collect(DISTINCT p.name) as ThreatCampaigns
WHERE PulseCount > 1
RETURN i.type as IndicatorType,
       i.value as SharedIndicator,
       PulseCount,
       ThreatCampaigns
ORDER BY PulseCount DESC, i.type;

// Query 3: Find Dense Threat Clusters

MATCH (p1:Pulse)-[:CONTAINS]->(i:Indicator)<-[:CONTAINS]-(p2:Pulse)
WHERE p1 <> p2
WITH p1, p2, count(DISTINCT i) as SharedCount
WHERE SharedCount >= 2
WITH p1, collect({pulse: p2, shared: SharedCount}) as Connections
WHERE size(Connections) >= 2
RETURN p1.name as CentralCampaign,
       size(Connections) as ConnectedCampaigns,
       [c IN Connections | c.pulse.name] as RelatedThreats,
       [c IN Connections | c.shared] as SharedIndicatorCounts
ORDER BY ConnectedCampaigns DESC;

// Query 4: Identify High-Risk Indicators

MATCH (p:Pulse)-[:CONTAINS]->(i:Indicator)
WITH i, count(DISTINCT p) as CampaignCount, collect(DISTINCT p.name) as Campaigns
WHERE CampaignCount >= 2
RETURN i.value as HighRiskIndicator,
       i.type as Type,
       CampaignCount as SeenInCampaigns,
       Campaigns
ORDER BY CampaignCount DESC, i.type
LIMIT 50;

// Query 5: Domain/IP Infrastructure Clustering

MATCH (p:Pulse)-[:CONTAINS]->(i:Indicator)
WHERE i.type IN ['domain', 'IPv4', 'hostname']
WITH i, count(DISTINCT p) as UsageCount, collect(DISTINCT p.name) as UsedBy
WHERE UsageCount > 1
RETURN i.type as InfrastructureType,
       i.value as MaliciousInfrastructure,
       UsageCount,
       UsedBy
ORDER BY UsageCount DESC;

// Query 6: File Hash Clustering Analysis

MATCH (p:Pulse)-[:CONTAINS]->(i:Indicator)
WHERE i.type IN ['FileHash-MD5', 'FileHash-SHA256']
WITH i, count(DISTINCT p) as DistributionCount, collect(DISTINCT p.name) as Campaigns
WHERE DistributionCount > 1
RETURN i.type as HashType,
       i.value as MalwareHash,
       DistributionCount,
       Campaigns
ORDER BY DistributionCount DESC;

// Query 7: Complete Cluster Network Visualization

MATCH (p1:Pulse)-[:CONTAINS]->(i:Indicator)<-[:CONTAINS]-(p2:Pulse)
WHERE p1.name < p2.name
WITH p1, p2, count(i) as weight
WHERE weight >= 2
RETURN p1, p2, weight
ORDER BY weight DESC;
