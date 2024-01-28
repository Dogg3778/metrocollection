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
	headlights = FindLights("HL")
	taillights = FindLights("TL")

	fwd = false
	SwitchLights(T, ON)
	SwitchLights(H, OFF)

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

function SwitchLights(light, state)
	if state == OFF then
		if light == H then
			for i=1, #headlights do
				SetLightEnabled(headlights[i], false)
			end
		end
		if light == T then
			for i=1, #taillights do
				SetLightEnabled(taillights[i], false)
			end
		end
	elseif state == ON then
		if light == H then
			for i=1, #headlights do
				SetLightEnabled(headlights[i], true)
			end
		end
		if light == T then
			for i=1, #taillights do
				SetLightEnabled(taillights[i], true)
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
	--get speed
	t = t + 1
	a = GetInt("Speed")
	if GetPlayerInteractShape() == FindShape("seat") and InputPressed("interact") then
		SetPlayerVehicle(FindVehicle("seat"))
	end
	if FindVehicle("seat") == GetPlayerVehicle() then
		AttachCameraTo(FindShape("seat"))
		SetCameraOffsetTransform(Transform(Vec(0.3, 1, 1.3), QuatEuler(90, 0, 0)))
		UiMakeInteractive()
	end
	if t%30 == 0 then
		if s > 0 and a < 99 and fwd then
			if a+s>99 then
				SetInt("Speed", 99)
			else
				SetInt("Speed", a + s)
			end
		elseif s < 0 and a > 0 and fwd then
			if a+s<0 then
				SetInt("Speed", 0)
			else
				SetInt("Speed", a + s)
			end
		end
	end
	if fwd then
		if openR then
			RemoveTag(pinRA, "B")
			RemoveTag(pinRB, "B")
			SetTag(pinRA, "A")
			SetTag(pinRB, "A")
		end
		if openL then
			SetTag(pinLA, "A")
			RemoveTag(pinLA, "B")
			SetTag(pinLB, "A")
			RemoveTag(pinLB, "B")
		end
		if block then
			SetTag(pinLB, "B")
			SetTag(pinLA, "B")
			SetTag(pinRA, "B")
			SetTag(pinRB, "B")
			RemoveTag(pinLB, "A")
			RemoveTag(pinLA, "A")
			RemoveTag(pinRA, "A")
			RemoveTag(pinRB, "A")
		end
	else
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
end

function draw()
	if FindVehicle("seat") == GetPlayerVehicle() then
		UiAlign("center top")
		UiFont("DSEG7.ttf", 25)
		UiButtonImageBox("MOD/controller/box-arrows.png", 6, 6)
		UiButtonHoverColor(1,1,1)
		UiButtonImageBox("MOD/controller/EMPTINESS.png", 6, 6)
		UiPush()
			UiTranslate(1215, 900)
			if allowR and not block and a == 0 and fwd then
				UiImage("MOD/controller/box-LED-W.png")
			else
				UiImage("MOD/controller/box-LED-0.png")
			end
		UiPop()
		UiPush()
			UiTranslate(790, 900)
			if allowL and not block and a == 0 and fwd then
				UiImage("MOD/controller/box-LED-W.png")
			else
				UiImage("MOD/controller/box-LED-0.png")
			end
		UiPop()
		UiPush()
			UiButtonImageBox("MOD/controller/box-arrows.png", 6, 6)
			UiTranslate(UiCenter(), UiHeight()-40)
			if UiTextButton("", UiWidth(), 40) then
				PlaySound(snd)
				SetPlayerVehicle(0)
			end
		UiPop()
		UiPush()
			UiTranslate(880, 811)
			UiImage("MOD/controller/81-720/spd-bg.png")
			UiPush()
				UiTranslate(math.floor(a/2*5)+1, 0)
				UiImage("MOD/controller/81-720/spd-R.png")
			UiPop()
			UiPush()
				UiAlign("left")
				UiTranslate(-125, 20)
				UiImageBox("MOD/controller/81-720/spd-G.png", math.ceil(a/2*5), 20, 0, 0)
			UiPop()
			UiPush()
				UiTranslate(math.floor(a/2*5)+1, 40)
				UiImage("MOD/controller/81-720/spd-Y.png")
			UiPop()
		UiPop()
		UiPush()
			UiTranslate(UiCenter(), UiHeight()-279)
			UiImage("MOD/controller/81-720/control.png")
			UiTranslate(101-UiCenter(), 0)
			UiPush()
				UiAlign("center middle")
				UiTranslate(0, 120)
				UiPush()
					if fwd then
						UiRotate(45)
					else
						UiRotate(-45)
					end
					UiImage("MOD/controller/81-720/hand_rev.png")
				UiPop()
				UiImage("MOD/controller/81-720/reverser_top.png")
				if UiTextButton("", 90, 130) then
					if fwd then
						SwitchLights(H, OFF)
						SwitchLights(T, ON)
						fwd = false
					else
						fwd = true
						SwitchLights(T, OFF)
						SwitchLights(H, ON)
					end
				end
			UiPop()
			UiTranslate(926, 52)
			UiPush()
				UiAlign("")
				UiColor(0.2, 0.2, 0.2)
				UiText("88")
				UiColor(0.5, 1, 0)
				if a < 10 then
					UiText(string.format("%02d", a))
				else
					UiText(a)
				end
			UiPop()
		UiPop()
		UiPush()
			UiTranslate(UiCenter()+3, UiHeight()-148)
			if block then
				UiColor(1, 2, 1)
				UiButtonPressColor(1, 2, 1)
				moveDoors(CLOSE, L)
				moveDoors(CLOSE, R)
			else
				UiButtonPressColor(1, 2, 1)
				UiColor(1, 1, 1)
			end
			if UiImageButton("MOD/controller/btn_G.png") then
				block = not block
			end
			UiColor(1, 1, 1)
			UiPush()
				UiTranslate(92, 0)
				if allowR then
					UiButtonPressColor(0.5, 0.5, 0.5)
					UiColor(2, 2, 2)
				else
					UiButtonPressColor(2, 2, 2)
					UiColor(1, 1, 1)
				end
				if UiImageButton("MOD/controller/btn_W.png") then
					allowR = true
					allowL = false
				end
				UiColor(1, 1, 1)
				UiTranslate(158, -1)
				if UiImageButton("MOD/controller/btn_B.png") and allowR and not block and a == 0 then
					moveDoors(OPEN, R)
				end
			UiPop()
			UiPush()
				UiTranslate(-92, 0)
				if allowL then
					UiButtonPressColor(0.5, 0.5, 0.5)
					UiColor(2, 2, 2)
				else
					UiButtonPressColor(2, 2, 2)
					UiColor(1, 1, 1)
				end
				if UiImageButton("MOD/controller/btn_W.png") then
					allowR = false
					allowL = true
				end
				UiColor(1, 1, 1)
				UiTranslate(-79, -1)
				if UiImageButton("MOD/controller/btn_B.png") and allowL and not block and a == 0 then
					moveDoors(OPEN, L)
				end
			UiPop()
			UiPush()
				UiButtonImageBox("MOD/controller/EMPTINESS.png")
				UiTranslate(-255, -23)
				if UiTextButton("", 90, 25) then
					s = 0
				end
				UiPush()
				UiTranslate(0, 25)
				if UiTextButton("", 90, 25) then
					s = -1
				end
				UiTranslate(0, 25)
				if UiTextButton("", 90, 25) then
					s = -2
				end
				UiTranslate(0, 25)
				if UiTextButton("", 90, 25) then
					s = -3
				end
				UiTranslate(0, 25)
				if UiTextButton("", 90, 25) then
					s = -4
				end
				UiPop()
				UiPush()
				if not(openL or openR) then
					UiTranslate(0, -25)
					if UiTextButton("", 90, 25) then
						s = 1
					end
					UiTranslate(0, -25)
					if UiTextButton("", 90, 25) then
						s = 2
					end
					UiTranslate(0, -25)
					if UiTextButton("", 90, 25) then
						s = 3
					end
					UiTranslate(0, -25)
					if UiTextButton("", 90, 25) then
						s = 4
					end
				end
				UiPop()
				if InputPressed("up") and s < 4 and not openL and not openR or s < 0 then
					s = s + 1
				end
				if InputPressed("down") and s > -4 then
					s = s - 1
				end
				UiTranslate(-21, -25*s)
				UiImage("MOD/controller/81-720/hand.png")
			UiPop()
		UiPop()
	end
end