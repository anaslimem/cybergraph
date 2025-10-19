# CyberGraph

A Neo4j-based threat intelligence knowledge graph that ingests indicators of compromise from AlienVault OTX and models relationships between threat campaigns and security indicators. The system enables security analysts to identify attack patterns, discover threat correlations, and perform graph-based threat hunting.

## Overview

CyberGraph automates the collection and storage of threat intelligence data by fetching pulses (threat reports) from AlienVault's Open Threat Exchange and structuring them as a graph database. This approach allows for sophisticated relationship queries that reveal connections between different threat actors, malware families, and attack infrastructure.

## Features

- Automated threat intelligence ingestion from AlienVault OTX API
- Graph-based data model connecting threat campaigns with indicators of compromise
- Support for multiple indicator types: IP addresses, domains, URLs, file hashes, and hostnames
- Configurable search parameters for targeted threat intelligence gathering
- Relationship mapping between pulses and their associated indicators
- Query templates for threat detection and analysis

## Architecture

The system consists of three main components:

- **OTX Client**: Interfaces with the AlienVault OTX API to fetch threat intelligence pulses and their associated indicators
- **Neo4j Connector**: Manages database connections and handles the insertion of nodes and relationships into the graph
- **Data Pipeline**: Orchestrates the flow of data from OTX to Neo4j, including transformation and validation

### Data Model

``` mermaid
(Pulse) -[:CONTAINS]-> (Indicator)
```

**Pulse Node Properties:**
- `name`: Threat report title

**Indicator Node Properties:**
- `value`: The actual indicator (e.g., IP address, domain, hash)
- `type`: Classification (IPv4, domain, FileHash-MD5, FileHash-SHA256, URL, hostname)

## Prerequisites

- Python 3.12 or higher
- Neo4j Database (local instance or cloud service)
- AlienVault OTX API key

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/anaslimem/cybergraph.git
cd cybergraph
```

### 2. Create Virtual Environment

```bash
python3 -m venv .venv
source .venv/bin/activate
```

### 3. Install Dependencies

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### 4. Configure Environment Variables

Create a `.env` file in the project root:

```env
OTX_API_KEY=your_otx_api_key_here
NEO4J_URI=bolt+s://your-instance.databases.neo4j.io:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=your_neo4j_password_here
```

**Configuration Notes:**
- Obtain an OTX API key from [AlienVault OTX] (https://otx.alienvault.com/)
- For local Neo4j instances, use `bolt://localhost:7687`
- For Neo4j Aura (cloud), use `bolt+s://` protocol with your instance URI

## Usage

### Running the Data Ingestion Pipeline

```bash
cd src
python main.py
```

The script will:
1. Connect to AlienVault OTX and search for threat pulses 
2. Fetch detailed information for each pulse including all indicators
3. Insert pulse nodes and indicator nodes into Neo4j
4. Create relationships between pulses and their indicators

### Customizing Search Parameters

Edit `src/main.py` to modify the search keyword and result limit:

```python
pulses = fetch_pulses(keyword="ransomware", max_results=5)
```

Available keywords: `malware`, `ransomware`, `apt`, `phishing`, `botnet`, etc.

## Querying the Graph

### Basic Queries

**Count all nodes by type:**
```cypher
MATCH (n) 
RETURN labels(n) as NodeType, count(*) as Count
```

**List all pulses with their indicator counts:**
```cypher
MATCH (p:Pulse)-[:CONTAINS]->(i:Indicator)
RETURN p.name as ThreatCampaign, count(i) as IndicatorCount
ORDER BY IndicatorCount DESC
```

**Find indicators by type:**
```cypher
MATCH (i:Indicator {type: "domain"})
RETURN i.value as Domain
LIMIT 20
```

**Search for a specific indicator:**
``` cypher
MATCH (p:Pulse)-[:CONTAINS]->(i:Indicator {value: "example.com"})
RETURN p.name as RelatedThreats, i.type as IndicatorType
```

### Advanced Analysis

**Find pulses sharing common indicators:**
``` cypher
MATCH (p1:Pulse)-[:CONTAINS]->(i:Indicator)<-[:CONTAINS]-(p2:Pulse)
WHERE p1.name < p2.name
RETURN p1.name, p2.name, count(i) as SharedIndicators
ORDER BY SharedIndicators DESC
```

**Identify all indicators from a specific threat campaign:**
``` cypher 
MATCH (p:Pulse {name: "Sony Malware"})-[:CONTAINS]->(i:Indicator)
RETURN i.value, i.type
```

## Project Structure

``` bash

cybergraph/
├── .env                    # Environment configuration (not tracked in git)
├── LICENSE                 # Project license
├── README.md              # Project documentation
├── requirements.txt       # Python dependencies
├── data/
│   ├── processed/         # Processed data files
│   └── raw/              # Raw data files
└── src/
    ├── __init__.py       # Package initialization
    ├── config.py         # Configuration management
    ├── main.py           # Data ingestion pipeline
    ├── neo4j_connector.py # Neo4j database interface
    ├── otx_client.py     # OTX API client
    ├── transform.py      # Data transformation utilities
    └── queries/
        ├── detect_cluster.cql      # Cluster detection queries
        └── threat_relations.cql    # Relationship analysis queries
```

## Dependencies

- **py2neo** (2021.2.4): Neo4j driver for Python
- **OTXv2** (1.5.12): AlienVault OTX API client
- **python-dotenv** (1.1.1): Environment variable management

## Security Considerations

- Never commit the `.env` file to version control
- Rotate API keys periodically
- Use SSL/TLS connections for Neo4j (bolt+s:// protocol)
- Implement rate limiting when fetching large datasets from OTX
- Validate and sanitize all external data before insertion

## Contributing

Contributions are welcome. Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Commit your changes with descriptive messages
4. Submit a pull request with a clear description of changes

## License

This project is licensed under the terms of MIT licence .

## Author

Anas Limem

## Acknowledgments

- AlienVault OTX for providing open threat intelligence data
- Neo4j for the graph database platform
