-- Fichier: ctld_module.lua (Classes complètes et mises à jour)

-- 1. Définition du namespace global 'ctld'
ctld = ctld or {}

-- ====================================================================================================
-- CLASSE ctld.utils
-- ====================================================================================================

local utils = {}
ctld.utils = utils
if not ctld.utils.marks then ctld.utils.marks = {}; end

function ctld.utils.drawQuad(coalitionId, vec3Points1To4, message)
    local coalitionId = coalitionId or 2
    local markId = ctld.utils.getNextUniqId()

    -- Color
    local tableColor = { 0, 0, 255, 0.4 }  --blue  by default
    if coalitionId == 1 then
        tableColor = { 1, 0, 0, 0.4 }      --red  % of (r,g,b,alpha)    red
    elseif coalitionId == 2 then
        tableColor = { 0, 0, 255, 0.4 }    --blue  % of (r,g,b,alpha)   blue
    elseif coalitionId == 0 then
        tableColor = { 2, 173, 33, 0.4 }   --green  % of (r,g,b,alpha)  neutral
    elseif coalitionId == -1 then
        tableColor = { 247, 179, 30, 0.4 } --orange  % of (r,g,b,alpha) All
    end

    local tableFillColor = { 0, 0, 255, 0.4 } --tableColor
    local lineType = 1                        --solid
    local message = message or ""
    ctld.utils.marks[markId] = message

    --trigger.action.quadToAll(number coalition , number id , vec3 point1 , vec3 point2 , vec3 point3 , vec3 point4 , table color , table fillColor , number lineType , boolean readOnly, string message)
    trigger.action.quadToAll(coalitionId, markId,
        vec3Points1To4[1], vec3Points1To4[2], vec3Points1To4[3], vec3Points1To4[4],
        tableColor, tableFillColor, lineType, true, message)

    --[[-example ------------------------------------------------------------
local heliName = "h1-1"
local triggerUnitObj = Unit.getByName(heliName)
local vec3StartPoint = triggerUnitObj:getPosition().p
local vec3EndPoint = {x = vec3StartPoint.x+1000,z=vec3StartPoint.z+1000,y=vec3StartPoint.y}
ctld.utils.drawQuad(coalitionId, vec3Points1To4, message)
]] --
end

--------------------------------------------------------------------------------------------------------
-- Calculates the absolute coordinates (x, y, heading, altitude) of a target point
-- based on a reference point and a relative offset, respecting the DCS coordinate system
-- (X=North, Y=East) and magnetic declination.
---------------------------------------------------------------------------------------------
-- @param refX X coordinate (North) of the reference point.
-- @param refY Y coordinate (East) of the reference point.
-- @param refHeading True/Geographic Heading of the reference unit in degrees.
-- @param refAltitude Altitude of the reference unit.
-- @param offsetAngleInDegrees Angle of the offset relative to the reference heading (0 = directly ahead).
-- @param offsetDistance Distance of the offset.
-- @param offsetHeading True/Geographic Heading for the final point.
-- @param offsetAltitude Altitude difference to add to the reference altitude.
-- @param magneticDeclinationInDegrees Magnetic Declination (subtract from True Heading to get Magnetic Heading).
--
-- @return x Absolute X coordinate (North) of the target point.
-- @return y Absolute Y coordinate (East) of the target point.
-- @return magneticHeadingInDegrees Magnetic Heading of the target point in degrees.
-- @return altitude Absolute altitude of the target point.
---
function ctld.utils.getRelativeCoords(
    refX, refY, refHeading, refAltitude,
    offsetAngleInDegrees, offsetDistanceInMeters,
    offsetHeadingInDegrees, offsetAltitudeInMeters,
    magneticDeclinationInDegrees
)
    -------------------------------------------------------------------------
    -- 1. Convert reference heading (radians → degrees)
    --    refHeading is a DCS true heading in radians, clockwise, 0 = North.
    -------------------------------------------------------------------------
    local refHeadingDeg = math.deg(refHeading)

    -------------------------------------------------------------------------
    -- 2. Compute the world angle used to project the new position.
    --    offsetAngleInDegrees is relative to the aircraft's heading.
    -------------------------------------------------------------------------
    local worldAngleDeg = refHeadingDeg + offsetAngleInDegrees

    -- Convert to radians for math.sin/cos (DCS uses clockwise headings)
    local worldAngleRad = math.rad(worldAngleDeg)

    -------------------------------------------------------------------------
    -- 3. Compute position deltas using DCS Cartesian coordinates:
    --    X axis = South/North, positive to the North.
    --    Y axis (vec3.z) = West/East, positive to the East.
    -------------------------------------------------------------------------
    local dx = math.cos(worldAngleRad) * offsetDistanceInMeters
    local dy = math.sin(worldAngleRad) * offsetDistanceInMeters

    local newX = refX + dx
    local newY = refY + dy

    -------------------------------------------------------------------------
    -- 4. Compute the object's final magnetic heading.
    --
    --    refHeadingDeg            = reference TRUE heading
    --    + offsetHeadingInDegrees = rotation relative to the reference
    --    - magneticDeclination    = convert true → magnetic
    -------------------------------------------------------------------------
    local magneticHeadingDeg =
        refHeadingDeg +
        offsetHeadingInDegrees -
        magneticDeclinationInDegrees

    -- Normalize to 0–360°
    magneticHeadingDeg = (magneticHeadingDeg % 360 + 360) % 360

    -------------------------------------------------------------------------
    -- 5. Compute altitude
    -------------------------------------------------------------------------
    local newAltitude = refAltitude + offsetAltitudeInMeters

    return newX, newY, magneticHeadingDeg, newAltitude
end

--------------------------------------------------------------------------------------------------------
-- Return a Vec2 point relative to  a reference point (position & heading DCS)
function ctld.utils.GetRelativeVec2Coords(refVec2Point, refHeadingInRadians, distanceFromRef,
                                          angleInDegreesFromRefHeading)
    -- absolue Heading in radians
    local absoluteHeadingInRadians = refHeadingInRadians + math.rad(angleInDegreesFromRefHeading)
    -- in DCS : x = Nord (+), z = Est (+)
    local dx = math.cos(absoluteHeadingInRadians) * distanceFromRef -- displacement North/South
    local dy = math.sin(absoluteHeadingInRadians) * distanceFromRef -- displacement Est/West

    local newCoords = {
        x = refVec2Point.x + dx,
        y = refVec2Point.y + dy,
    }
    return newCoords
end

--------------------------------------------------------------------------------------------------------
--- Returns magnetic variation of given DCS point (vec2 or vec3).
-- borrowed from mist
function ctld.utils.getNorthCorrectionInRadians(caller, vec2OrVec3Point) --gets the correction needed for true north (magnetic variation)
    if vec2OrVec3Point == nil then
        if env and env.error then
            env.error("ctld.utils.getNorthCorrectionInRadians()." .. tostring(caller) .. ": Invalid point provided.")
        end
        return 0
    end

    local point = ctld.utils.deepCopy("ctld.utils.getNorthCorrectionInRadians()", vec2OrVec3Point)
    if not point.z then --Vec2; convert to Vec3
        point.z = point.y
        point.y = 0
    end
    local lat, lon = coord.LOtoLL(point)
    local north_posit = coord.LLtoLO(lat + 1, lon)
    return math.atan(north_posit.z - point.z, north_posit.x - point.x)
end

--------------------------------------------------------------------------------------------------------
--- @function ctld.utils:getHeadingInRadians
-- @-- borrowed from mist
---@param unitObject any
---@param rawHeading boolean (true=geographic/false=magnetic)
---@return integer       --- @--return "magneticHeading : "..tostring(math.deg(ctld.utils.getHeadingInRadians(triggerUnitObj, false)))..", geographicHeading : "..tostring(math.deg(ctld.utils.getHeadingInRadians(triggerUnitObj, true)))
function ctld.utils.getHeadingInRadians(caller, unitObject, rawHeading) --rawHeading: boolean (true=geographic/false=magnetic)
    if not unitObject then
        if env and env.error then
            env.error("ctld.utils.getHeadingInRadians()." .. tostring(caller) .. ": Invalid unit object provided.")
        end
        return 0
    end
    rawHeading = rawHeading or false
    local unitpos = unitObject:getPosition()
    if unitpos then
        local HeadingInRadians = math.atan(unitpos.x.z, unitpos.x.x)
        if not rawHeading then
            HeadingInRadians = HeadingInRadians +
                ctld.utils.getNorthCorrectionInRadians("ctld.utils.getHeadingInRadians()", unitpos.p)
        end
        if HeadingInRadians < 0 then
            HeadingInRadians = HeadingInRadians + 2 * math.pi -- put heading in range of 0 to 2*pi
        end
        return HeadingInRadians
    end
    return 0
end

--------------------------------------------------------------------------------------------------------
--- Converts a Vec2 to a Vec3.
-- @-- borrowed from mist
-- @tparam Vec2 vec the 2D vector
-- @param y optional new y axis (altitude) value. If omitted it's 0.
function ctld.utils.makeVec3FromVec2OrVec3(caller, vec, y)
    if not vec then
        if env and env.error then
            env.error("ctld.utils.makeVec3FromVec2OrVec3()." .. tostring(caller) .. ": Invalid vector provided.")
        end
        return nil
    end
    if not vec.z then
        if vec.alt and not y then
            y = vec.alt
        elseif not y then
            y = 0
        end
        return { x = vec.x, y = y, z = vec.y }
    else
        return { x = vec.x, y = vec.y, z = vec.z } -- it was already Vec3, actually.
    end
end

--------------------------------------------------------------------------------------------------------
--- Converts a Vec3 to a Vec2.
-- @tparam Vec3 vec the 3D vector
-- @return vector converted to Vec2
function ctld.utils.makeVec2FromVec3OrVec2(caller, vec)
    if vec == nil then
        if env and env.error then
            env.error("ctld.utils.makeVec2FromVec3OrVec2()." .. tostring(caller) .. ": Invalid vector provided.")
        end
        return nil
    end
    if vec.z then
        return { x = vec.x, y = vec.z }
    else
        return { x = vec.x, y = vec.y } -- it was actually already vec2.
    end
end

--------------------------------------------------------------------------------------------------------
--- @function ctld.utils:rotateVec3
-- Calcule l'offset cartésien absolu en appliquant la rotation du cap de l'appareil.
-- (Conçu pour le format de données : relative = {x, y, z})
function ctld.utils.rotateVec3(relativeVec, headingDeg)
    local x_rel = relativeVec.x
    local z_rel = relativeVec.z
    -- y_rel n'est pas utilisé dans le calcul de rotation, mais sera dans le retour
    local y_rel = relativeVec.y or 0

    -- Vérification des données (X et Z sont obligatoires)
    if x_rel == nil or z_rel == nil then
        local msg = "CTLD.utils:rotateVec3: Missing X or Z component in relative position data."
        if env and env.error then
            env.error(msg)
            -- Lève une erreur qui sera capturée par pcall (si appelé)
            error(msg)
        else
            error(msg)
        end
    end

    local headingRad = math.rad(headingDeg)
    local cos_h = math.cos(headingRad)
    local sin_h = math.sin(headingRad)

    local x_rot = (z_rel * sin_h) + (x_rel * cos_h)
    local z_rot = (z_rel * cos_h) - (x_rel * sin_h)

    return { x = x_rot, y = y_rel, z = z_rot }
end

--------------------------------------------------------------------------------------------------------
-- Add 2 position vectors (Vec3) of DCS.
function ctld.utils.addVec3(vec1, vec2)
    return {
        -- Use or 0 to avoid 'nil'
        x = (vec1.x or 0) + (vec2.x or 0),
        y = (vec1.y or 0) + (vec2.y or 0),
        z = (vec1.z or 0) + (vec2.z or 0),
    }
end

--------------------------------------------------------------------------------------------------------
--- Vector substraction.
-- @tparam Vec3 vec1 first vector
-- @tparam Vec3 vec2 second vector
-- @treturn Vec3 new vector, vec2 substracted from vec1.
function ctld.utils.subVec3(caller, vec1, vec2)
    if vec1 == nil or vec2 == nil then
        if env and env.error then
            env.error("ctld.utils.subVec3()." .. tostring(caller) .. ": Both input values cannot be nil.")
        end
        return nil
    end
    return { x = vec1.x - vec2.x, y = vec1.y - vec2.y, z = vec1.z - vec2.z }
end

--------------------------------------------------------------------------------------------------------
--- Vector dot product.
-- @tparam Vec3 vec1 first vector
-- @tparam Vec3 vec2 second vector
-- @treturn number dot product of given vectors
function ctld.utils.multVec3(caller, vec1, vec2)
    if vec1 == nil or vec2 == nil then
        if env and env.error then
            env.error("ctld.utils.multVec3()." .. tostring(caller) .. ": Both input values cannot be nil.")
        end
        return 0
    end
    return vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z
end

--------------------------------------------------------------------------------------------------------
--- Returns the center of a zone as Vec3.
-- @-- borrowed from mist
-- @tparam string|table zone trigger zone name or table
-- @treturn Vec3 center of the zone
function ctld.utils.zoneToVec3(caller, zone, gl)
    if zone == nil then
        if env and env.error then
            env.error("ctld.utils.zoneToVec3()." .. tostring(caller) .. ": Invalid zone provided.")
        end
        return nil
    end

    local new = {}
    if type(zone) == 'table' then
        if zone.point then
            new.x = zone.point.x
            new.y = zone.point.y
            new.z = zone.point.z
        elseif zone.x and zone.y and zone.z then
            new = ctld.utils.deepCopy("ctld.utils.zoneToVec3()", zone)
        end
        return new
    elseif type(zone) == 'string' then
        zone = trigger.misc.getZone(zone)
        if zone then
            new.x = zone.point.x
            new.y = zone.point.y
            new.z = zone.point.z
        end
    end
    if new.x and gl then
        new.y = land.getHeight({ x = new.x, y = new.z })
    end
    return new
end

--------------------------------------------------------------------------------------------------------
--- Vector magnitude
-- @tparam Vec3 (3D with x,y,z)vec vector
-- @treturn number magnitude of vector vec
function ctld.utils.vec3Mag(caller, vec3)
    if vec3 == nil or vec3.x == nil or vec3.y == nil or vec3.z == nil then
        if env and env.error then
            env.error("ctld.utils.vec3Mag()." .. tostring(caller) .. ": Invalid vector provided.")
        end
        return 0
    end

    return (vec3.x ^ 2 + vec3.y ^ 2 + vec3.z ^ 2) ^ 0.5
end

--------------------------------------------------------------------------------------------------------
--- Returns distance in meters between two points.
-- @-- borrowed from mist
-- @tparam Vec2|Vec3 point1 first point
-- @tparam Vec2|Vec3 point2 second point
-- @treturn number distance between given points.
function ctld.utils.get2DDist(caller, point1, point2)
    if point1 == nil or point2 == nil then
        if env and env.error then
            env.error("ctld.utils.get2DDist()." .. tostring(caller) .. ": Both input values cannot be nil.")
        end
        return 0
    end
    if not point1 then
        log:warn("ctld.utils.get2DDist()  1st input value is nil")
    end
    if not point2 then
        log:warn("ctld.utils.get2DDist()  2nd input value is nil")
    end
    point1 = ctld.utils.makeVec3FromVec2OrVec3("ctld.utils.get2DDist()", point1)
    point2 = ctld.utils.makeVec3FromVec2OrVec3("ctld.utils.get2DDist()", point2)
    return ctld.utils.vec3Mag("ctld.utils.get2DDist()", { x = point1.x - point2.x, y = 0, z = point1.z - point2.z })
end

--------------------------------------------------------------------------------------------------------
--- Simple rounding function.
-- @-- borrowed from mist
-- From http://lua-users.org/wiki/SimpleRound
-- use negative idp for rounding ahead of decimal place, positive for rounding after decimal place
-- @tparam number num number to round
-- @param idp
function ctld.utils.round(caller, num, idp)
    if num == nil or type(num) ~= "number" then
        if env and env.error then
            env.error("ctld.utils.round()." .. tostring(caller) .. ": Invalid number provided.")
        end
        return 0
    end
    local mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

--------------------------------------------------------------------------------------------------------
--[[acc:
in DM: decimal point of minutes.
In DMS: decimal point of seconds.
position after the decimal of the least significant digit:
So:
42.32 - acc of 2.
]]
function ctld.utils.tostringLL(caller, lat, lon, acc, DMS)
    if lat == nil or lon == nil then
        if env and env.error then
            env.error("ctld.utils.tostringLL()." .. tostring(caller) .. ": Invalid latitude or longitude provided.")
        end
        return ""
    end
    local latHemi, lonHemi
    if lat > 0 then
        latHemi = 'N'
    else
        latHemi = 'S'
    end

    if lon > 0 then
        lonHemi = 'E'
    else
        lonHemi = 'W'
    end

    lat = math.abs(lat)
    lon = math.abs(lon)

    local latDeg = math.floor(lat)
    local latMin = (lat - latDeg) * 60

    local lonDeg = math.floor(lon)
    local lonMin = (lon - lonDeg) * 60

    if DMS then -- degrees, minutes, and seconds.
        local oldLatMin = latMin
        latMin = math.floor(latMin)
        local latSec = ctld.utils.round("ctld.utils.tostringLL()", (oldLatMin - latMin) * 60, acc)

        local oldLonMin = lonMin
        lonMin = math.floor(lonMin)
        local lonSec = ctld.utils.round("ctld.utils.tostringLL()", (oldLonMin - lonMin) * 60, acc)

        if latSec == 60 then
            latSec = 0
            latMin = latMin + 1
        end

        if lonSec == 60 then
            lonSec = 0
            lonMin = lonMin + 1
        end

        local secFrmtStr -- create the formatting string for the seconds place
        if acc <= 0 then -- no decimal place.
            secFrmtStr = '%02d'
        else
            local width = 3 + acc -- 01.310 - that's a width of 6, for example.
            secFrmtStr = '%0' .. width .. '.' .. acc .. 'f'
        end

        return string.format('%02d', latDeg) ..
            ' ' ..
            string.format('%02d', latMin) .. '\' ' .. string.format(secFrmtStr, latSec) .. '"' .. latHemi .. '	 '
            ..
            string.format('%02d', lonDeg) ..
            ' ' .. string.format('%02d', lonMin) .. '\' ' .. string.format(secFrmtStr, lonSec) .. '"' .. lonHemi
    else -- degrees, decimal minutes.
        latMin = ctld.utils.round("ctld.utils.tostringLL()", latMin, acc)
        lonMin = ctld.utils.round("ctld.utils.tostringLL()", lonMin, acc)

        if latMin == 60 then
            latMin = 0
            latDeg = latDeg + 1
        end

        if lonMin == 60 then
            lonMin = 0
            lonDeg = lonDeg + 1
        end

        local minFrmtStr -- create the formatting string for the minutes place
        if acc <= 0 then -- no decimal place.
            minFrmtStr = '%02d'
        else
            local width = 3 + acc -- 01.310 - that's a width of 6, for example.
            minFrmtStr = '%0' .. width .. '.' .. acc .. 'f'
        end

        return string.format('%02d', latDeg) .. ' ' .. string.format(minFrmtStr, latMin) .. '\'' .. latHemi .. '	 '
            .. string.format('%02d', lonDeg) .. ' ' .. string.format(minFrmtStr, lonMin) .. '\'' .. lonHemi
    end
end

--------------------------------------------------------------------------------------------------------
--- Returns MGRS coordinates as string.
-- @tparam string MGRS MGRS coordinates
-- @tparam number acc the accuracy of each easting/northing.
-- Can be: 0, 1, 2, 3, 4, or 5.
function ctld.utils.tostringMGRS(caller, MGRS, acc)
    if MGRS == nil or MGRS == "" or type(MGRS) ~= 'string' then
        if env and env.error then
            env.error("ctld.utils.tostringMGRS()." .. tostring(caller) .. ": Invalid MGRS coordinates provided.")
        end
        return ""
    end
    if acc == 0 then
        return MGRS.UTMZone .. ' ' .. MGRS.MGRSDigraph
    else
        return MGRS.UTMZone ..
            ' ' ..
            MGRS.MGRSDigraph ..
            ' ' ..
            string.format('%0' .. acc .. 'd',
                ctld.utils.round("ctld.utils.tostringMGRS()", MGRS.Easting / (10 ^ (5 - acc)), 0))
            ..
            ' ' ..
            string.format('%0' .. acc .. 'd',
                ctld.utils.round("ctld.utils.tostringMGRS()", MGRS.Northing / (10 ^ (5 - acc)), 0))
    end
end

--------------------------------------------------------------------------------------------------------
ctld.utils.UniqIdCounter = 0 -- Compteur statique pour les ID uniques
--- @function ctld.utils:getNextUniqId
-- Génère un ID unique incrémental, comme requis pour 'unitId' dans groupData.
function ctld.utils.getNextUniqId()
    ctld.utils.UniqIdCounter = ctld.utils.UniqIdCounter + 1
    return ctld.utils.UniqIdCounter
end

--- Converts angle in radians to degrees.
-- @param angle angle in radians
-- @return angle in degrees
function ctld.utils.radianToDegree(caller, angleInRadians)
    if angle == nil or type(angle) ~= "number" then
        if env and env.error then
            env.error("ctld.utils.toDegree()." .. tostring(caller) .. ": Invalid angle provided.")
        end
        return 0
    end
    return math.deg(angleInRadians)
end

--------------------------------------------------------------------------------------------------------
--- @function ctld.utils:normalizeHeading
-- Normalise a heading between 0 et 360 degrees.
function ctld.utils.normalizeHeadingInDegrees(caller, offsetHeadingInDegrees)
    if offsetHeadingInDegrees == nil then
        if env and env.error then
            env.error("CTLD.utils.normalizeHeadingInDegrees()." .. tostring(caller) .. ": Invalid heading provided.")
        end
        return 0
    end
    local result = offsetHeadingInDegrees % 360
    if result < 0 then
        result = result + 360
    end
    return result
end

--------------------------------------------------------------------------------------------------------
--- @function ctld.utils:polarToCartesian
-- Convertit une distance (rho), un angle (theta) et un cap de référence (headingDeg)
-- en coordonnées cartésiennes absolues (x, z) de la carte DCS.
-- @param distance number La distance au point de référence.
-- @param relativeAngle number L'angle relatif au point de référence (0 = devant, 90 = droite).
-- @param headingDeg number Le cap absolu de l'appareil (point de référence).
-- @return table L'offset cartésien absolu { x, y=0, z }.
function ctld.utils.polarToCartesian(distance, relativeAngle, headingDeg)
    local absoluteAngle = headingDeg + relativeAngle
    local angleRad = math.rad(absoluteAngle)

    -- Correction du facteur distance (20m -> 10m)
    local dist = (distance or 0) * 2

    -- X (Nord/Sud, l'axe de référence du cap 0°) : Utilise COS
    local x_rot = dist * math.cos(angleRad)

    -- Z (Est/Ouest) : Utilise SIN. La trigonométrie standard sin(angle) augmente CCW.
    -- Nous ne touchons pas au signe car la trigonométrie de DCS peut être non standard.
    local z_rot = dist * math.sin(angleRad)

    return { x = x_rot, y = 0, z = z_rot }
end

--------------------------------------------------------------------------------------------------------
--- Converts kilometers per hour to meters per second.
-- @param kmph speed in km/h
-- @return speed in m/s
function ctld.utils.kmphToMps(caller, kmph)
    if kmph == nil or type(kmph) ~= "number" then
        if env and env.error then
            env.error("ctld.utils.kmphToMps()." .. tostring(caller) .. ": Invalid speed provided.")
        end
        return 0
    end
    return kmph / 3.6
end

--------------------------------------------------------------------------------------------------------
--- Builds a ground waypoint from a point definition.
-- No longer accepts path
function ctld.utils.buildWP(caller, point, overRideForm, overRideSpeed)
    if point == nil then
        if env and env.error then
            env.error("ctld.utils.buildWP()." .. tostring(caller) .. ": Invalid point provided.")
        end
        return nil
    end

    local wp = {}
    wp.x = point.x

    if point.z then
        wp.y = point.z
    else
        wp.y = point.y
    end
    local form, speed

    if point.speed and not overRideSpeed then
        wp.speed = point.speed
    elseif type(overRideSpeed) == 'number' then
        wp.speed = overRideSpeed
    else
        wp.speed = ctld.utils.kmphToMps("ctld.utils.buildWP()", 20)
    end

    if point.form and not overRideForm then
        form = point.form
    else
        form = overRideForm
    end

    if not form then
        wp.action = 'Cone'
    else
        form = string.lower(form)
        if form == 'off_road' or form == 'off road' then
            wp.action = 'Off Road'
        elseif form == 'on_road' or form == 'on road' then
            wp.action = 'On Road'
        elseif form == 'rank' or form == 'line_abrest' or form == 'line abrest' or form == 'lineabrest' then
            wp.action = 'Rank'
        elseif form == 'cone' then
            wp.action = 'Cone'
        elseif form == 'diamond' then
            wp.action = 'Diamond'
        elseif form == 'vee' then
            wp.action = 'Vee'
        elseif form == 'echelon_left' or form == 'echelon left' or form == 'echelonl' then
            wp.action = 'EchelonL'
        elseif form == 'echelon_right' or form == 'echelon right' or form == 'echelonr' then
            wp.action = 'EchelonR'
        else
            wp.action = 'Cone' -- if nothing matched
        end
    end

    wp.type = 'Turning Point'

    return wp
end

--------------------------------------------------------------------------------------------------------
function ctld.utils.getUnitsLOS(caller, unitset1, altoffset1, unitset2, altoffset2, radius)
    --log:info("$1, $2, $3, $4, $5", unitset1, altoffset1, unitset2, altoffset2, radius)
    if unitset1 == nil or unitset2 == nil or altoffset1 == nil or altoffset2 == nil or radius == nil then
        if env and env.error then
            env.error("ctld.utils.getUnitsLOS()." .. tostring(caller) .. ": parameters sets cannot be nil.")
        end
        return {}
    end

    radius = radius or math.huge
    local unit_info1 = {}
    local unit_info2 = {}

    -- get the positions all in one step, saves execution time.
    for unitset1_ind = 1, #unitset1 do
        local unit1 = Unit.getByName(unitset1[unitset1_ind])
        if unit1 then
            local lCat = Object.getCategory(unit1)
            if ((lCat == 1 and unit1:isActive()) or lCat ~= 1) and unit1:isExist() == true then
                unit_info1[#unit_info1 + 1] = {}
                unit_info1[#unit_info1].unit = unit1
                unit_info1[#unit_info1].pos = unit1:getPosition().p
            end
        end
    end

    for unitset2_ind = 1, #unitset2 do
        local unit2 = Unit.getByName(unitset2[unitset2_ind])
        if unit2 then
            local lCat = Object.getCategory(unit2)
            if ((lCat == 1 and unit2:isActive()) or lCat ~= 1) and unit2:isExist() == true then
                unit_info2[#unit_info2 + 1] = {}
                unit_info2[#unit_info2].unit = unit2
                unit_info2[#unit_info2].pos = unit2:getPosition().p
            end
        end
    end

    local LOS_data = {}
    -- now compute los
    for unit1_ind = 1, #unit_info1 do
        local unit_added = false
        for unit2_ind = 1, #unit_info2 do
            if radius == math.huge or (ctld.utils.vec3Mag("ctld.utils.getUnitsLOS()", ctld.utils.subVec3("ctld.utils.getUnitsLOS()", unit_info1[unit1_ind].pos, unit_info2[unit2_ind].pos)) < radius) then -- inside radius
                local point1 = {
                    x = unit_info1[unit1_ind].pos.x,
                    y = unit_info1[unit1_ind].pos.y + altoffset1,
                    z =
                        unit_info1[unit1_ind].pos.z
                }
                local point2 = {
                    x = unit_info2[unit2_ind].pos.x,
                    y = unit_info2[unit2_ind].pos.y + altoffset2,
                    z =
                        unit_info2[unit2_ind].pos.z
                }
                if land.isVisible(point1, point2) then
                    if unit_added == false then
                        unit_added = true
                        LOS_data[#LOS_data + 1] = {}
                        LOS_data[#LOS_data].unit = unit_info1[unit1_ind].unit
                        LOS_data[#LOS_data].vis = {}
                        LOS_data[#LOS_data].vis[#LOS_data[#LOS_data].vis + 1] = unit_info2[unit2_ind].unit
                    else
                        LOS_data[#LOS_data].vis[#LOS_data[#LOS_data].vis + 1] = unit_info2[unit2_ind].unit
                    end
                end
            end
        end
    end

    return LOS_data
end

--------------------------------------------------------------------------------------------------------
-- same as getGroupPoints but returns speed and formation type along with vec2 of point}
function ctld.utils.getGroupRoute(caller, groupIdent, task)
    if groupIdent == nil then
        if env and env.error then
            env.error("ctld.utils.getGroupRoute()." .. tostring(caller) .. ": Invalid group identifier provided.")
        end
        return nil
    end
    -- refactor to search by groupId and allow groupId and groupName as inputs
    local gpId = groupIdent
    if mist.DBs.MEgroupsByName[groupIdent] then
        gpId = mist.DBs.MEgroupsByName[groupIdent].groupId
    else
        log:error("ctld.utils.getGroupRoute()." .. tostring(caller) .. '$1 not found in mist.DBs.MEgroupsByName',
            groupIdent)
    end

    for coa_name, coa_data in pairs(env.mission.coalition) do
        if type(coa_data) == 'table' then
            if coa_data.country then --there is a country table
                for cntry_id, cntry_data in pairs(coa_data.country) do
                    for obj_cat_name, obj_cat_data in pairs(cntry_data) do
                        if obj_cat_name == "helicopter" or obj_cat_name == "ship" or obj_cat_name == "plane" or obj_cat_name == "vehicle" then                       -- only these types have points
                            if ((type(obj_cat_data) == 'table') and obj_cat_data.group and (type(obj_cat_data.group) == 'table') and (#obj_cat_data.group > 0)) then --there's a group!
                                for group_num, group_data in pairs(obj_cat_data.group) do
                                    if group_data and group_data.groupId == gpId then                                                                                -- this is the group we are looking for
                                        if group_data.route and group_data.route.points and #group_data.route.points > 0 then
                                            local points = {}

                                            for point_num, point in pairs(group_data.route.points) do
                                                local routeData = {}
                                                if env.mission.version > 7 and env.mission.version < 19 then
                                                    routeData.name = env.getValueDictByKey(point.name)
                                                else
                                                    routeData.name = point.name
                                                end
                                                if not point.point then
                                                    routeData.x = point.x
                                                    routeData.y = point.y
                                                else
                                                    routeData.point = point
                                                        .point --it's possible that the ME could move to the point = Vec2 notation.
                                                end
                                                routeData.form = point.action
                                                routeData.speed = point.speed
                                                routeData.alt = point.alt
                                                routeData.alt_type = point.alt_type
                                                routeData.airdromeId = point.airdromeId
                                                routeData.helipadId = point.helipadId
                                                routeData.type = point.type
                                                routeData.action = point.action
                                                if task then
                                                    routeData.task = point.task
                                                end
                                                points[point_num] = routeData
                                            end

                                            return points
                                        end
                                        log:error('Group route not defined in mission editor for groupId: $1', gpId)
                                        return
                                    end --if group_data and group_data.name and group_data.name == 'groupname'
                                end     --for group_num, group_data in pairs(obj_cat_data.group) do
                            end         --if ((type(obj_cat_data) == 'table') and obj_cat_data.group and (type(obj_cat_data.group) == 'table') and (#obj_cat_data.group > 0)) then
                        end             --if obj_cat_name == "helicopter" or obj_cat_name == "ship" or obj_cat_name == "plane" or obj_cat_name == "vehicle" or obj_cat_name == "static" then
                    end                 --for obj_cat_name, obj_cat_data in pairs(cntry_data) do
                end                     --for cntry_id, cntry_data in pairs(coa_data.country) do
            end                         --if coa_data.country then --there is a country table
        end                             --if coa_name == 'red' or coa_name == 'blue' and type(coa_data) == 'table' then
    end                                 --for coa_name, coa_data in pairs(mission.coalition) do
end

--------------------------------------------------------------------------------------------------------
--- Returns the groupId for a given unit.
function ctld.utils.getGroupId(caller, _unitId)
    if _unitId == nil then
        if env and env.error then
            env.error("ctld.utils.getGroupId()." .. tostring(caller) .. ": Invalid unit provided.")
        end
        return nil
    end

    return _unitId:getGroup():getID()
end

--------------------------------------------------------------------------------------------------------
--- Spawns a static object to the game world.
-- Borrowed from mist.dynAddStatic
-- @todo write good docs
-- @tparam table staticObj table containing data needed for the object creation
function ctld.utils.dynAddStatic(caller, n)
    if n == nil then
        if env and env.error then
            env.error("ctld.utils.dynAddStatic()." .. tostring(caller) .. ": Invalid static object data provided.")
        end
        return false
    end
    --local newObj = mist.utils.deepCopy(n)
    local newObj = ctld.utils.deepCopy("ctld.utils.dynAddStatic()", n)
    --log:warn(newObj)
    if newObj.units and newObj.units[1] then -- if its mist format
        for entry, val in pairs(newObj.units[1]) do
            if newObj[entry] and newObj[entry] ~= val or not newObj[entry] then
                newObj[entry] = val
            end
        end
    end
    --log:info(newObj)

    local cntry = newObj.country
    if newObj.countryId then
        cntry = newObj.countryId
    end

    local newCountry = ''

    for countryId, countryName in pairs(country.name) do
        if type(cntry) == 'string' then
            cntry = cntry:gsub("%s+", "_")
            if tostring(countryName) == string.upper(cntry) then
                newCountry = countryName
            end
        elseif type(cntry) == 'number' then
            if countryId == cntry then
                newCountry = countryName
            end
        end
    end

    if newCountry == '' then
        log:error("Country not found: $1", cntry)
        return false
    end

    if newObj.clone or not newObj.groupId then
        newObj.groupId = ctld.utils.getNextUniqId()
    end

    if newObj.clone or not newObj.unitId then
        newObj.unitId = ctld.utils.getNextUniqId()
    end

    newObj.name = newObj.name or newObj.unitName

    if newObj.clone or not newObj.name then
        newObj.name = (newCountry .. ' static ' .. tostring(newObj.unitId))
    end

    if not newObj.dead then
        newObj.dead = false
    end

    if not newObj.heading then
        newObj.heading = math.rad(math.random(360))
    end

    if newObj.categoryStatic then
        newObj.category = newObj.categoryStatic
    end
    if newObj.mass then
        newObj.category = 'Cargos'
    end

    if newObj.shapeName then
        newObj.shape_name = newObj.shapeName
    end

    if not newObj.shape_name then
        log:info('shape_name not present')
        -- if mist.DBs.const.shapeNames[newObj.type] then
        --     newObj.shape_name = mist.DBs.const.shapeNames[newObj.type]
        -- end
    end
    if newObj.x and newObj.y and newObj.type and type(newObj.x) == 'number' and type(newObj.y) == 'number' and type(newObj.type) == 'string' then
        --log:warn(newObj)
        coalition.addStaticObject(country.id[newCountry], newObj)

        return newObj
    end
    log:error("Failed to add static object due to missing or incorrect value. X: $1, Y: $2, Type: $3", newObj.x,
        newObj.y, newObj.type)
    return false
end

--------------------------------------------------------------------------------------------------------
--- Returns GroundUnitsListNames for a given coalition
function ctld.utils.getGroundUnitsListNames(caller, coalitionId)
    if coalitionId == nil then
        if env and env.error then
            env.error("ctld.utils.getGroundUnitsListNames()." .. tostring(caller) .. ": Invalid coalition ID provided.")
        end
        return {}
    end
    local UnitsListNames = {}
    for i, v in ipairs(coalition.getGroups(coalitionId, Group.Category.GROUND)) do
        local groupUnits = v:getUnits()
        for ii, vv in ipairs(groupUnits) do
            UnitsListNames[#UnitsListNames + 1] = vv:getName()
        end
    end
    return UnitsListNames
end

--------------------------------------------------------------------------------------------------------
--Gets the average position of a group of units (by name)
function ctld.utils.getAvgPos(caller, unitNames)
    if unitNames == nil or #unitNames == 0 then
        if env and env.error then
            env.error("ctld.utils.getAvgPos()." .. tostring(caller) .. ": Invalid unit names provided.")
        end
        return nil
    end

    local avgX, avgY, avgZ, totNum = 0, 0, 0, 0
    for i = 1, #unitNames do
        local unit
        if Unit.getByName(unitNames[i]) then
            unit = Unit.getByName(unitNames[i])
        elseif StaticObject.getByName(unitNames[i]) then
            unit = StaticObject.getByName(unitNames[i])
        end
        if unit and unit:isExist() == true then
            local pos = unit:getPosition().p
            if pos then -- you never know O.o
                avgX = avgX + pos.x
                avgY = avgY + pos.y
                avgZ = avgZ + pos.z
                totNum = totNum + 1
            end
        end
    end
    if totNum ~= 0 then
        return { x = avgX / totNum, y = avgY / totNum, z = avgZ / totNum }
    end
end

--------------------------------------------------------------------------------------------------------
--- Creates a deep copy of a object.
-- @-- borrowed from mist
-- Usually this object is a table.
-- See also: from http://lua-users.org/wiki/CopyTable
-- @param object object to copy
-- @return copy of object
function ctld.utils.deepCopy(caller, object)
    local lookup_table = {}
    if object == nil then
        if env and env.error then
            env.error("ctld.utils.deepCopy()." .. tostring(caller) .. ": Attempt to deep copy a nil object.")
        end
        return nil
    end
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

--------------------------------------------------------------------------------------------------------
--- return table as a lua script string
function ctld.utils.tableShowScript(caller, tblObj, tblName)
    if tblObj == nil then
        if env and env.error then
            env.error("ctld.utils.tableShowScript(): Attempt to show a nil table.")
        end
        return "nil"
    end
    if tblName == nil then
        tblName = "tbl"
    end

    local tScript = "local " .. tblName .. " = " .. ctld.utils.tableShow("ctld.utils.tableShowScript()", tblObj)
    return tScript
end

--------------------------------------------------------------------------------------------------------
--- Returns table in a easy readable string representation.
-- borrowed from mist
-- this function is not meant for serialization because it uses
-- newlines for better readability.
-- @param tbl table to show
-- @param loc
-- @param indent
-- @param tableshow_tbls
-- @return human readable string representation of given table
function ctld.utils.tableShow(caller, tbl, loc, indent, tableshow_tbls) --based on serialize_slmod, this is a _G serialization
    if tbl == nil then
        if env and env.error then
            env.error("ctld.utils.tableShow()." .. tostring(caller) .. ": Attempt to show a nil table.")
        end
        return "nil"
    end

    tableshow_tbls = tableshow_tbls or {} --create table of tables
    loc = loc or ""
    indent = indent or ""
    if type(tbl) == 'table' then --function only works for tables!
        tableshow_tbls[tbl] = loc
        local tbl_str = {}
        --tbl_str[#tbl_str + 1] = indent .. '{\n'
        tbl_str[#tbl_str + 1] = '{\n'

        for ind, val in pairs(tbl) do
            if type(ind) == "number" then
                tbl_str[#tbl_str + 1] = indent
                tbl_str[#tbl_str + 1] = loc .. '['
                tbl_str[#tbl_str + 1] = tostring(ind)
                tbl_str[#tbl_str + 1] = '] = '
            else
                tbl_str[#tbl_str + 1] = indent
                tbl_str[#tbl_str + 1] = loc .. '['
                tbl_str[#tbl_str + 1] = ctld.utils.basicSerialize("ctld.utils.tableShow()", ind)
                tbl_str[#tbl_str + 1] = '] = '
            end

            if ((type(val) == 'number') or (type(val) == 'boolean')) then
                tbl_str[#tbl_str + 1] = tostring(val)
                tbl_str[#tbl_str + 1] = ',\n'
            elseif type(val) == 'string' then
                tbl_str[#tbl_str + 1] = ctld.utils.basicSerialize("ctld.utils.tableShow()", val)
                tbl_str[#tbl_str + 1] = ',\n'
            elseif type(val) == 'nil' then -- won't ever happen, right?
                tbl_str[#tbl_str + 1] = 'nil,\n'
            elseif type(val) == 'table' then
                if tableshow_tbls[val] then
                    tbl_str[#tbl_str + 1] = tostring(val) .. ' already defined: ' .. tableshow_tbls[val] .. ',\n'
                else
                    --tableshow_tbls[val] = loc .. '[' .. ctld.utils.basicSerialize("ctld.utils.tableShow()", ind) .. ']'
                    --tbl_str[#tbl_str + 1] = tostring(val) .. ' '
                    --[[
                    tbl_str[#tbl_str + 1] = ctld.utils.tableShow(val,
                    loc .. '[' .. ctld.utils.basicSerialize("ctld.utils.tableShow()", ind) .. ']',
                    indent .. '    ',
                    tableshow_tbls) ]] --
                    tbl_str[#tbl_str + 1] = ctld.utils.tableShow(val, loc, indent .. '    ')
                    tbl_str[#tbl_str + 1] = ',\n'
                end
            elseif type(val) == 'function' then
                if debug and debug.getinfo then
                    local fcnname = tostring(val)
                    local info = debug.getinfo(val, "S")
                    if info.what == "C" then
                        tbl_str[#tbl_str + 1] = string.format('%q', fcnname .. ', C function') .. ',\n'
                    else
                        if (string.sub(info.source, 1, 2) == [[./]]) then
                            tbl_str[#tbl_str + 1] = string.format('%q',
                                fcnname ..
                                ', defined in (' ..
                                info.linedefined .. '-' .. info.lastlinedefined .. ')' .. info.source) .. ',\n'
                        else
                            tbl_str[#tbl_str + 1] = string.format('%q',
                                    fcnname ..
                                    ', defined in (' .. info.linedefined .. '-' .. info.lastlinedefined .. ')') ..
                                ',\n'
                        end
                    end
                else
                    tbl_str[#tbl_str + 1] = 'a function,\n'
                end
            else
                tbl_str[#tbl_str + 1] = 'unable to serialize value type ' ..
                    ctld.utils.basicSerialize("ctld.utils.tableShow()", type(val)) .. ' at index ' .. tostring(ind)
            end
        end
        --string.sub("Hello, World!", -6, -1)
        if string.sub(table.concat(tbl_str), - #indent - 2, -1) == '{\n' then
            trigger.action.outText(string.sub(table.concat(tbl_str), - #indent - 2, -1), 10)
            for i = 1, #indent do
                tbl_str[#tbl_str] = nil
            end
            tbl_str[#tbl_str + 1] = '{}'
        else
            tbl_str[#tbl_str + 1] = indent .. '}'
        end
        return table.concat(tbl_str)
    end
end

--======================================================================================================
--- Serializes the give variable to a string.
-- borrowed from slmod
-- @param var variable to serialize
-- @treturn string variable serialized to string
function ctld.utils.basicSerialize(caller, var)
    if var == nil then
        if env and env.error then
            env.error("ctld.utils.basicSerialize()." .. tostring(caller) .. ": Attempt to serialize a nil variable.")
        end
        return "nil"
    else
        if ((type(var) == 'number') or
                (type(var) == 'boolean') or
                (type(var) == 'function') or
                (type(var) == 'table') or
                (type(var) == 'userdata')) then
            return tostring(var)
        elseif type(var) == 'string' then
            var = string.format('%q', var)
            return var
        end
    end
end
