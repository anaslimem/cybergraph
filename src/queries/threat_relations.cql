
// Query 1: Campaign Overview Statistics

MATCH (p:Pulse)-[:CONTAINS]->(i:Indicator)
WITH p, count(i) as TotalIndicators, 
     collect(DISTINCT i.type) as IndicatorTypes,
     size(collect(DISTINCT i.type)) as TypeDiversity
RETURN p.name as Campaign,
       TotalIndicators,
       TypeDiversity,
       IndicatorTypes
ORDER BY TotalIndicators DESC;

// Query 2: Find All Indicators for a Specific Campaign

MATCH (p:Pulse {name: 'Sony Malware'})-[:CONTAINS]->(i:Indicator)
RETURN i.value as Indicator,
       i.type as Type
ORDER BY i.type, i.value;

// Query 3: Reverse Lookup - Find Campaigns from Indicator

MATCH (p:Pulse)-[:CONTAINS]->(i:Indicator)
WHERE i.value = 'example.com' OR i.value CONTAINS 'example'
RETURN p.name as ThreatCampaign,
       i.value as MatchedIndicator,
       i.type as IndicatorType;

// Query 4: Indicator Type Distribution

MATCH (i:Indicator)
WITH i.type as IndicatorType, count(i) as Count
RETURN IndicatorType, Count
ORDER BY Count DESC;

// Query 5: Find Related Campaigns Through Common Indicators

MATCH (p1:Pulse {name: 'Sony Malware'})-[:CONTAINS]->(i:Indicator)<-[:CONTAINS]-(p2:Pulse)
WITH p2, count(DISTINCT i) as CommonIndicators, collect(DISTINCT i.value) as SharedIOCs
RETURN p2.name as RelatedCampaign,
       CommonIndicators,
       SharedIOCs
ORDER BY CommonIndicators DESC;

// Query 6: Multi-Hop Threat Relationships

MATCH path = (p1:Pulse)-[:CONTAINS]->(:Indicator)<-[:CONTAINS]-(p2:Pulse)
             -[:CONTAINS]->(:Indicator)<-[:CONTAINS]-(p3:Pulse)
WHERE p1.name = 'Sony Malware' AND p1 <> p3 AND p2 <> p3
WITH p1, p3, count(DISTINCT p2) as IntermediateCampaigns
RETURN p1.name as StartCampaign,
       p3.name as ConnectedCampaign,
       IntermediateCampaigns as ConnectionStrength
ORDER BY IntermediateCampaigns DESC
LIMIT 20;

// Query 7: Identify Isolated vs Connected Campaigns

MATCH (p:Pulse)
OPTIONAL MATCH (p)-[:CONTAINS]->(i:Indicator)<-[:CONTAINS]-(other:Pulse)
WHERE p <> other
WITH p, count(DISTINCT other) as ConnectedCampaigns
RETURN p.name as Campaign,
       CASE 
         WHEN ConnectedCampaigns = 0 THEN 'Isolated'
         WHEN ConnectedCampaigns <= 2 THEN 'Weakly Connected'
         WHEN ConnectedCampaigns <= 5 THEN 'Moderately Connected'
         ELSE 'Highly Connected'
       END as ConnectionStatus,
       ConnectedCampaigns
ORDER BY ConnectedCampaigns DESC;

// Query 8: Temporal Analysis - Most Recent Threats

MATCH (p:Pulse)-[:CONTAINS]->(i:Indicator)
WITH p, count(i) as IndicatorCount
RETURN p.name as Campaign,
       IndicatorCount
ORDER BY p.name DESC
LIMIT 10;

// Query 9: Build Attack Pattern Profile

MATCH (p:Pulse)-[:CONTAINS]->(i:Indicator)
WITH p, i.type as IndicatorType, count(i) as TypeCount
ORDER BY p.name, TypeCount DESC
WITH p, collect({type: IndicatorType, count: TypeCount}) as Profile
RETURN p.name as Campaign,
       Profile,
       reduce(total = 0, x IN Profile | total + x.count) as TotalIndicators;

