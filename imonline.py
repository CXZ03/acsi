import pyautogui
import time
import random

#!/usr/bin/env python3
# Script to move the mouse every 10 seconds to prevent computer from sleeping
# You may need to install pyautogui: pip install pyautogui


# Prevent pyautogui from raising exceptions when mouse hits screen edge
pyautogui.FAILSAFE = False

try:
    print("Mouse movement script is running. Press Ctrl+C to stop.")
    
    while True:
        # Get current mouse position
        current_x, current_y = pyautogui.position()
        
        # Generate small random movements (-5 to 5 pixels)
        move_x = random.randint(-5, 5)
        move_y = random.randint(-5, 5)
        
        # Move mouse to new position
        pyautogui.moveRel(move_x, move_y)
        
        # Wait for 10 seconds
        time.sleep(10)
        
        # Move mouse back to prevent drifting too far
        pyautogui.moveTo(current_x, current_y)
        
except KeyboardInterrupt:
    print("\nScript stopped by user.")