MAX_SPEED = 18
DOOR_SPEED = 1
DOOR_STRENGTH = 9999

OPEN = 1
CLOSE = 2
ON = 1
OFF = 2

L = 1
R = 2
W = 1

a = 0 -- speed
b = 0 -- current limit
c = 0 -- next limit
s = 0 -- current state
t = 0

H = 1
T = 2

allowR = false

CLOSE_THRESHOLD = 0.1

function init()


	snd = LoadSound("MOD/menu/tool-select.ogg")
	
	if GetString("savegame.mod.weather") == "" then
		SetString("savegame.mod.weather", "sunny")
	end

	train = GetString("savegame.mod.weather")
	SetTag(FindShape("seat"), "interact", "Control")


	doorsL = FindShapes("left")
	doorsR = FindShapes("right")
	timer = 0
	counter = 0

	openL = false
	openR = false
	moveDoors(CLOSE, L)
	moveDoors(CLOSE, R)

	pinLA = FindShape("pinLA")
	pinRA = FindShape("pinRA")
	trigLA = FindTrigger("trigLA")
	trigRA = FindTrigger("trigRA")
	pinLB = FindShape("pinLB")
	pinRB = FindShape("pinRB")
	trigLB = FindTrigger("trigLB")
	trigRB = FindTrigger("trigRB")

	Played = false
	Closed = false
end

--moving ALL doors
function moveDoors(dir, side)
	if dir == CLOSE then
		if side == L then
			openL = false
			for i=1, #doorsL do
				local doorMotor = GetShapeJoints(doorsL[i])
				for j=1, #doorMotor do
					local min, max = GetJointLimits(doorMotor[j])
					SetJointMotorTarget(doorMotor[j], min, DOOR_SPEED, DOOR_STRENGTH)
				end
			end
		elseif side == R then
			openR = false
			for i=1, #doorsR do
				local doorMotor = GetShapeJoints(doorsR[i])
				for j=1, #doorMotor do
					local min, max = GetJointLimits(doorMotor[j])
					SetJointMotorTarget(doorMotor[j], min, DOOR_SPEED, DOOR_STRENGTH)
				end
			end
		end
	elseif dir == OPEN then
		if side == L then
			openL = true
			for i=1, #doorsL do
				local doorMotor = GetShapeJoints(doorsL[i])
				for j=1, #doorMotor do
					local min, max = GetJointLimits(doorMotor[j])
					SetJointMotorTarget(doorMotor[j], max, DOOR_SPEED, DOOR_STRENGTH)
				end
			end
		elseif side == R then
			openR = true
			for i=1, #doorsR do
				local doorMotor = GetShapeJoints(doorsR[i])
				for j=1, #doorMotor do
					local min, max = GetJointLimits(doorMotor[j])
					SetJointMotorTarget(doorMotor[j], max, DOOR_SPEED, DOOR_STRENGTH)
				end
			end
		end
	end
end

function check_a()
	cla = 0
	cra = 0
	ba = 0
	outer=FindShapes("A", true)
	outerb=FindShapes("B", true)
	for i=1, #outer do
		if IsShapeInTrigger(trigLA, outer[i]) then
			cla = cla + 1
		end
		if IsShapeInTrigger(trigRA, outer[i]) then
			cra = cra + 1
		end
	end
	for i=1, #outerb do
		if IsShapeInTrigger(trigLA, outerb[i]) then
			ba = ba + 1
		end
		if IsShapeInTrigger(trigRA, outerb[i]) then
			ba = ba + 1
		end
	end
end

function check_b()
	clb = 0
	crb = 0
	bb = 0
	outer=FindShapes("A", true)
	outerb=FindShapes("B", true)
	for i=1, #outer do
		if IsShapeInTrigger(trigLB, outer[i]) then
			clb = clb + 1
		end
		if IsShapeInTrigger(trigRB, outer[i]) then
			crb = crb + 1
		end
	end
	for i=1, #outerb do
		if IsShapeInTrigger(trigLB, outerb[i]) then
			bb = bb + 1
		end
		if IsShapeInTrigger(trigRB, outerb[i]) then
			bb = bb + 1
		end
	end
end

function tick()
	check_a()
	check_b()
	if cla>0 and ba==0 then
		moveDoors(OPEN, L)
		SetTag(pinLB, "A")
		RemoveTag(pinLB, "B")
	end
	if clb>0 and bb==0 then
		moveDoors(OPEN, L)
		SetTag(pinLA, "A")
		RemoveTag(pinLA, "B")
	end
	if ba>0 then
		SetTag(pinLB, "B")
		SetTag(pinRB, "B")
		RemoveTag(pinLB, "A")
		RemoveTag(pinRB, "A")
		moveDoors(CLOSE, R)
		moveDoors(CLOSE, L)
	end
	if bb>0 then
		SetTag(pinLA, "B")
		SetTag(pinRA, "B")
		RemoveTag(pinLA, "A")
		RemoveTag(pinRA, "A")
		moveDoors(CLOSE, R)
		moveDoors(CLOSE, L)
	end
	if cra>0 and ba==0 then
		moveDoors(OPEN, R)
		SetTag(pinRB, "A")
		RemoveTag(pinRB, "B")
	end
	if crb>0 and bb==0 then
		moveDoors(OPEN, R)
		SetTag(pinRA, "A")
		RemoveTag(pinRA, "B")
	end
end