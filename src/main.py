from otx_client import fetch_pulses
from neo4j_connector import insert_indicator

pulses = fetch_pulses(keyword="ransomware", max_results=5)

print(f"Fetched {len(pulses)} pulses from OTX")

if not pulses:
    print("No pulses found! Check your OTX API key or search keyword.")
else:
    inserted_count = 0
    for pulse in pulses:
        pulse_name = pulse.get("name", "Unnamed Pulse")
        indicators = pulse.get("indicators", [])
        print(f"\nProcessing pulse: {pulse_name} ({len(indicators)} indicators)")
        
        for ind in indicators:
            indicator_value = ind.get("indicator")
            indicator_type = ind.get("type")
            if indicator_value and indicator_type:
                insert_indicator(pulse_name, indicator_value, indicator_type)
                inserted_count += 1
            else:
                print(f"Skipping invalid indicator: {ind}")
    
    print(f"\n Data insertion complete. Inserted {inserted_count} indicators.")
