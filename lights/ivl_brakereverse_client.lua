
local BRAKE_LIGHTS = {
	"brake_l",
	"brake_r"
}

local REVERSE_LIGHTS = {
	"reverse_l",
	"reverse_r"
}

function IVL.disableBrakeReverse(vehicle)
	
	IVL.setData(vehicle, "brake", false)
	IVL.setData(vehicle, "reverse", false)
	setVehicleCustomLightsPower(vehicle, BRAKE_LIGHTS, 0)
	setVehicleCustomLightsPower(vehicle, REVERSE_LIGHTS, 0)

	return true
end

function IVL.updateBrakeReverse(vehicle)
	
	local driver = getVehicleOccupant(vehicle)

	local reverseNew = false
	local brakeNew = false
	local brakeOld = IVL.getData(vehicle, "brake")
	local reverseOld = IVL.getData(vehicle, "reverse")
	
	local gear = getVehicleCurrentGear(vehicle)
	local engineState = getVehicleEngineState(vehicle)

	-- Turn on reverse light if in reverse gear
	reverseNew = engineState and (gear == 0)

	if driver then
		local accelerateControl = getPedControlState(driver, "accelerate")
		local brakeControl = getPedControlState(driver, "brake_reverse")

		-- Turn on braking lights if in a forwards gear and brake key is pressed
		-- or if in reverse gear and accelerate key is pressed
		brakeNew = engineState and
			((gear > 0 and brakeControl)
			or (gear == 0 and accelerateControl))
	end

	dxDrawText("gear: "..tostring(gear), 10, 15)
	
	if brakeOld ~= brakeNew then
		setVehicleCustomLightsPower(vehicle, BRAKE_LIGHTS, brakeNew and 1 or 0)
		setVehicleLightState(vehicle, 2, 1)
		setVehicleLightState(vehicle, 3, 1)
		IVL.setData(vehicle, "brake", brakeNew)
	end

	if reverseOld ~= reverseNew then
		setVehicleCustomLightsPower(vehicle, REVERSE_LIGHTS, reverseNew and 1 or 0)
		IVL.setData(vehicle, "reverse", reverseNew)
	end

	return true
end

addEventHandler("onClientVehicleStartExit", root,
	function(player, seat, door)
		if seat ~= 0 then return end

		IVL.disableBrakeReverse(source)
	end
)

addEventHandler("onClientVehicleExit", root,
	function(player, seat)
		if seat ~= 0 then return end

		IVL.disableBrakeReverse(source)
	end
)