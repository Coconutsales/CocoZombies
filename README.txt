#  _____                  ______________  _________ _____ _____ _____ 
# /  __ \                |___  /  _  |  \/  || ___ \_   _|  ___/  ___|
# | /  \/ ___   ___ ___     / /| | | | .  . || |_/ / | | | |__ \ `--. 
# | |    / _ \ / __/ _ \   / / | | | | |\/| || ___ \ | | |  __| `--. \
# | \__/\ (_) | (_| (_) |./ /__\ \_/ / |  | || |_/ /_| |_| |___/\__/ /
# \____/\___/ \___\___/ \_____/\___/\_|  |_/\____/ \___/\____/\____/ 
#                           ASCII by https://patorjk.com/software/taag/
#                                   
#                       CocoZOMBIES V1.3
#                                   
# Zombie Infection Simulation
# ORIGINAL CODE by Kevan Davis; August 16th, 2003
# Modified by John "Hardcorepawn" Gilbertson; September 25th, 2003
# 
# Cocozombies edit, based off Hardcorepawn's changes, January 2025
# By Coconutsales
# 
# ===============================================================================
# ================================== KEYBINDS: ==================================
# 
# Left Mouse Click = Small Bomb (8-16px)
# Right Mouse Click = Large Bomb (16-32px)
# s and S = Decrea[s]e and Increa[S]e simulation speed, in FPS (Minimum 1, Default 45, Maximum 144)
# Spacebar = Pause
# - and + = Decrease and Increase total population (Arbitrarily set to a max of 20,000 and min of 1,000)
# [ and ] = Decrease and Increase ZOMBIE population (Cannot be lower than 1, or higher than total population)
# d = Zombie [D]ecay toggle on / off (Default: ON. Note selection indicator bottom left) At default speed, alive zombies die in 28sec 
# r = [r]esets the simulation at currently set values
# R = Fully [R]esets the simulation at default values (Starting Zombie count, Population, Simulation Speed, Decay)
# 
# ==============================================================================
# ================================== CHANGES: ==================================
# 
# CocoZombies V1.3 1/9/2025
# Made Right Click create a 16-32px bomb (twice as big as Left Click)
# Made s and S adjust Simulation Speed (in FPS, Minimum 1, Default 45, Maximum 144)
# Added a pause button (Spacebar) You can still place bombs when paused! This just halts any NPC movement. 
# - Known visual error: Bombs will not leave behind Dead pixels until simulation is unpaused. This doesn't affect anything.
# - Utilized old "freeze" integer, redefined as a boolean named "pause"
# Resized to 600x600 because honestly, 1000x1000 was tooooo big. This feels like the sweet spot.
# MORE comments on stuff I am now understanding and didn't before (or just didn't get to yet)
# - I hope these comments help others understand the code in the future! :)
# - Better header comments
# Optimized code in a few places
# - Removed unused code for wall generation at origin (0,0) which was commented out and useless
# - Defined colors in Global instead of in Setup, reducing redundancy. The were initialized in Global already...
# - Prettier and more consistent formatting
# Reorganized User Interface
# - Resized Text to 12pt font
# 
# STILL TO-DO (new ideas since 1.2b)
# Implement zooming so monitors larger than 1080p don't struggle to see stuff
# Some sort method for controlling Zombies, by having them follow the mouse cursor
# Militarized Humans (Cops/Soldiers)
# - Would also eventually have support for controlling via mouse cursor. 
# - Would be a fantastic OFFENSE vs DEFENSE game mechanic! :D
# Some visual UI element to show current sim speed setting
# - more UI in general - will be useful when multiple weapon selections are possible 
# -- (using number row to change what weapons are bound to mouse clicks)
# ----------------------------------------------------------------------------------------
# CocoZombies V1.2b
# Non case-sensitive D keypress for Decay toggle
# ----------------------------------------------------------------------------------------
# CocoZombies V1.2 (First uploaded version)
# ALREADY CHANGED from 
# Hotkey for increase / decrease Zombie Population 
# - Increase: ] and Decrease: [
# - Minimum 1, maximum '20,000' (Max is the current population)
# - Made an iterative spawning statement for creating zombies
# -- previously hardcoded to spawn 4 zombies in sequence
# -- Allows easier adjustment of zombie starting population :)
# 
# Larger simulation window
# 
# Adjusted Human/Dead/Zombie counter positions
# 
# Replaced "num" variable with "popCount" which is calculated from a formula including two new variables, popMax and popMin
# 
# Fixed offset Bomb crater placement
# - Visual was offset from area of effect, causing walls to be destroyed to the top left of where you click but killing anything centered on the mouse
# - Original code had mouse position coords reduced by radius of the generated bomb, for some reason. (mouseX-radius, mouseY-radius)
# 
# Added hotkey and boolean to enable and disable zombie lifespan
# - 'enableDecay' by default set to false
# - Currently, while disabled, will kill zombies instantly when enabled as zombielife always counts down.
# 
# Changed reset hotkey to "r / R" from "z / Z"
# 
# Verbose comments
# 
# =================================================================================
# ================================== TO-DO LIST: ==================================
# 
# Set LMB to small bomb (same,) set RMB to NUKE
# - maybe on a "WMD enabled" toggle, so LMB and RMB by default can be small bomb and medium bomb   << DONE IN 1.3 (LMB/RMB)
# -- then WMD enabled can be Endothermic Bomb and Nuclear Bomb (large and XL) << Other weapon set selection to come soon
# 
# Other weapon toggles, like:
# - LMB for placing WALL, RMB for placing EMPTY
# - LMB for placing Humans, RMB for placing Zombies?
# 
# Map generation from a seed
# - allow for restarting the same generation
# - possibly enter a seed at some point
# 
# Make enableDecay properly track existing array entries for zombielife
# - Make it so that enabling from disabled doesn't instantly kill zombies if it has always been disabled << DONE IN 1.3
# -- Doesn't start counting until Enabled << DONE IN 1.3
# -- Maybe it counts UP? Higher count makes a slower zombie until death, or if decay disabled until a maximum?
# - Make it so you can enable and disable, and zombielife value only tracks while decay was enabled << DONE IN 1.3
# 
# Make a version where zombies follow the mouse? idk how << I have some ideas now :)
# 
