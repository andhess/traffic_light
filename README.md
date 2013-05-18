##AboutT

This project was part of a lab done in with the Digital Logic class at Washington University in St. Louis.  My lab partner and I defined and then implemented the finite state machine in traffic_light_fsm.vhd.  We also built a test unit to make sure it behaved properly in test_traffic_light_fsm.vhd.  trafficController.xpf is an interface we created, it is just an xml file.


## Finite State Machine
The traffic light has the following features and functions:
* Red, yellow, and green lights for the North/South direction
* Red, yellow, and green lights for the East/West direction
* Walk and don't walk lights for both North/South and East/West
* A button input to toggle between day and night mode
* A button input to request to walk across (for both N/S and E/W)
* Day mode: cycles through red, green, yellow as expected
* Night mode: Flashing yellow light
* Walk requests: The walk light (white) will turn on when it is safe for someone to cross