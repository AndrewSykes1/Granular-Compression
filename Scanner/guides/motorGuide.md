# Motor Control Guide

We utillize 2 motor drivers in our experiment, each with different methods of communication. As such it is nescessary to have an understanding on their utilization which is described below. Note Murphy's Law of Motor Drivers, anything that can go wrong with Motor Drivers will. Assure that all instances of serial objects are properly closed before attempting to interact with a motor in a program. Additionally, assure other programs that may utilize them are closed in order to prevent COM overlap.

## Cospley Control Amps
We use the **STP-075-07 Copley Controls** stepping motor drive. It may be manually controlled in Cospley Motion Explorer (CME) which is a free program that may be downloaded online from the manufacturer. 

### Formats
The general form for all messages to be written directly to the register of the driver is the following:<br>
[node ID][<.>axis letter][command code][command specific parameters]\<CR>

<u>**Meaning**</u><br>
[node ID] - Optional, used for drives on multi-drop networks.<br>
[<.>axis letter] - Optional, describes which axis to rotate the motor on<br>
[command code] - Specification of the type of action you want to perform, (s -> Set), (g -> Get), (c -> Copy), (r -> Reset), (t -> Trajectory), (i -> Register) <br>
[command specific paramter] - Parameters to feed into a specific command to save to serial object <br>
\<CR> - Carriage return, i.e. delimitter

In practice the main thing we care to utilize is setters, getters, and trajectories. Those maintain the following usage:<br>
[node ID][<.>axis letter] s [memory bank][parameter ID][value]\<CR><br>
[node ID][<.>axis letter] g [memory bank][parameter ID][value]\<CR><br>
[node ID][<.>axis letter] t [command code]\<CR><br>
Though to reset the drive, simply use the command: r

<u>**Meaning**</u><br>
[memory bank] - Identifies which memory bank to set parameteer in, f=flash memory, r=RAM memory<br>
[parameter ID] - Identifies the parameter to set, so essentially your command
[value] - The new value to set for the parameter specified by the command 


### Examples
Set position loop proportional gain to 1200 in RAM:
s r0x30 1200 <br>
Read value of position loop proportional gain: g r0x30 <br>
Initiate a move: t 1<br>
Attempt homing sequence: t 2<br>

## Applied Motion Products

We utilize the **5000-126 ST5-S** motor driver. It may be manually controlled using ST Configurator via Q Programmer, both programs available for download via their manufacturer.

### Formats
The format for the ST5-S is signficantly more simple than the STP. Simply pass in: [Command Name][Param Value]<br>

<u>**Meaning**</u><br>
[Command Name] - The 2 letter character combination coorilating to the action desired<br>
[Param Value] - The value to set the commands memory location to<br>

### Examples
Set acceleration rate to 100: AC100<br>
Begin communication: HR

