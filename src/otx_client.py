from OTXv2 import OTXv2
import os,sys

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from src.config import OTX_API_KEY

otx = OTXv2(OTX_API_KEY)

def fetch_pulses(keyword, max_results) -> list:
    """
    Fetch threat intelligence pulses from OTX based on a keyword.
    :param keyword: The keyword to search for in pulses.
    :param max_results: Maximum number of pulses to return.
    :return: List of pulses matching the keyword with full indicator data.
    """
    # First, search for pulses
    search_results = otx.search_pulses(query=keyword, max_results=max_results)
    pulse_list = search_results.get("results", [])
    
    # Fetch full details for each pulse 
    detailed_pulses = []
    for pulse in pulse_list:
        pulse_id = pulse.get("id")
        if pulse_id:
            try:
                # Get full pulse details including indicators
                full_pulse = otx.get_pulse_details(pulse_id)
                detailed_pulses.append(full_pulse)
            except Exception as e:
                print(f"Warning: Could not fetch details for pulse {pulse_id}: {e}")
                continue
    
    return detailed_pulses