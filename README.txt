#  _____                  ______________  _________ _____ _____ _____ 
# /  __ \                |___  /  _  |  \/  || ___ \_   _|  ___/  ___|
# | /  \/ ___   ___ ___     / /| | | | .  . || |_/ / | | | |__ \ `--. 
# | |    / _ \ / __/ _ \   / / | | | | |\/| || ___ \ | | |  __| `--. \
# | \__/\ (_) | (_| (_) |./ /__\ \_/ / |  | || |_/ /_| |_| |___/\__/ /
# \____/\___/ \___\___/ \_____/\___/\_|  |_/\____/ \___/\____/\____/ 
#                           ASCII by https://patorjk.com/software/taag/
#                                   
#                       CocoZOMBIES V1.2b
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
# - and + || Decrease and Increase total simulation population (Arbitrarily set to a max of 20,000 and min of 1,000)
# [ and ] || Decrease and Increase ZOMBIE population (Cannot be lower than 1, or higher than max population)
# d || Zombie [D]ecay toggle on / off (Default: OFF) Currently, when on, zombies will "die" within 28 seconds of being created. This might be adjustable in the future.
#     Currently, if false, zombie lifespan is still counted, leading to mass extinction if you enable Decay
# r || [R]esets the simulation and generates a new map. Previously set ZomPop and Population is remembered.
# 
# ==============================================================================
# ================================== CHANGES: ==================================
# 
# 
# CocoZombies V1.2b
# Non case-sensitive D keypress for Decay toggle
# 
# CocoZombies V1.2
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
# - maybe on a "WMD enabled" toggle, so LMB and RMB by default can be small bomb and medium bomb
# -- then WMD enabled can be Endothermic Bomb and Nuclear Bomb (large and XL)
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
# - Make it so that enabling from disabled doesn't instantly kill zombies if it has always been disabled
# -- Doesn't start counting until Enabled
# -- Maybe it counts UP? Higher count makes a slower zombie until death, or if decay disabled until a maximum?
# - Make it so you can enable and disable, and zombielife value only tracks while decay was enabled
# 
# Make a version where zombies follow the mouse? idk how
# 
