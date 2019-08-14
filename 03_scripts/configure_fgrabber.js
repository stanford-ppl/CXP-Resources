// --------------------------------------------------------------------------------
// -- CustomLogic - Configure Frame-Grabber (script example)
// --------------------------------------------------------------------------------
// --        File: customlogic_functions.tcl
// --        Date: 2019-04-11
// --         Rev: 0.2
// --      Author: PP
// --------------------------------------------------------------------------------
// -- 0.1, 2018-11-15, PP, Initial release
// -- 0.2, 2019-04-11, PP, Added Pixel LUT 8-bit and Pixel Threshold examples
// --------------------------------------------------------------------------------

for (var grabber of grabbers) {
	// Write to the Control Register "Scratchpad"
    grabber.InterfacePort.set("CustomLogicControlAddress", 0x0000);
	grabber.InterfacePort.set("CustomLogicControlData", "1234567890");
	
	// Read from the Control Register "Scratchpad"
    grabber.InterfacePort.set("CustomLogicControlAddress", 0x0000);
	var scratchpad = grabber.InterfacePort.get("CustomLogicControlData");
	console.log("Control Register Scratchpad value is: " + scratchpad);

	// Disable Frame-to-Line bypass
    grabber.InterfacePort.set("CustomLogicControlAddress", 0x0001);
	grabber.InterfacePort.set("CustomLogicControlData", 0x00000002);
	
	// Enable Memory Traffic Generator reference design
    grabber.InterfacePort.set("CustomLogicControlAddress", 0x0002);
	grabber.InterfacePort.set("CustomLogicControlData", 0x00000001);
	
	// Generate a Memento Event
    grabber.InterfacePort.set("CustomLogicControlAddress", 0x0003);
	grabber.InterfacePort.set("CustomLogicControlData", 0x7E577E57);
	
	// Program Pixel LUT 8-bit
    grabber.InterfacePort.set("CustomLogicControlAddress", 0x0004);
	grabber.InterfacePort.set("CustomLogicControlData", 0x00000001); 	// Activate programming
	grabber.InterfacePort.set("CustomLogicControlAddress", 0x0005); 	// LUT coefficient address
	var i;
	for (i=255; i>=0; --i) {
		grabber.InterfacePort.set("CustomLogicControlData", i); 		// Write 256 coefficients into the LUT (inverse luminance set)
	}
	grabber.InterfacePort.set("CustomLogicControlAddress", 0x0004);
	grabber.InterfacePort.set("CustomLogicControlData", 0x00000200); 	// Disable LUT bypass
	
	// Program Pixel Threshold
    grabber.InterfacePort.set("CustomLogicControlAddress", 0x0006);
	grabber.InterfacePort.set("CustomLogicControlData", 0x0000007F); 	// Set the threshold level
	grabber.InterfacePort.set("CustomLogicControlData", 0x00000200); 	// Disable Pixel Threshold bypass
}