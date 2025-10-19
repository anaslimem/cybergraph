from py2neo import Graph, Node, Relationship
import os,sys

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from src.config import NEO4J_URI, NEO4J_USER, NEO4J_PASSWORD

# Initialize graph connection 
_graph = None

def get_graph():
    """Get or create the Neo4j graph connection."""
    global _graph
    if _graph is None:
        _graph = Graph(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD))
    return _graph

def insert_indicator(pulse_name, indicator, type_):
    """
    Insert an indicator node into the Neo4j database.

    :param pulse_name: Name of the pulse the indicator belongs to.
    :param indicator: The indicator value (e.g., IP address, domain).
    :param type_: Type of the indicator (e.g., 'IPv4', 'domain').
    """
    graph = get_graph()
    
    # Create nodes with primary labels
    pulse = Node("Pulse", name=pulse_name)
    ind = Node("Indicator", value=indicator, type=type_)
    
    # Merge nodes 
    graph.merge(pulse, "Pulse", "name")
    graph.merge(ind, "Indicator", "value")
    
    # Create relationship
    rel = Relationship(pulse, "CONTAINS", ind)
    graph.merge(rel)
    
    print(f"Inserted: {pulse_name} -> {indicator} ({type_})")  

