-------------------------------------------------
-- preset constants
-------------------------------------------------


-------------------------------------------------
---Constant Values used for GetV function
-------------------------------------------------
V_OWNER = 0            -- Returns the Homunculus owner’s ID
V_POSITION = 1         -- Returns the current location’s x,y coordinates
V_TYPE = 2             -- Defines an object (Not implemented yet)
V_MOTION = 3           -- Returns the current action
V_ATTACKRANGE = 4      -- Returns the attack range (Not implemented yet; temporarily set as 1 cell)
V_TARGET = 5           -- Returns the target of an attack or skill
V_SKILLATTACKRANGE = 6 -- Returns the skill attack range (Not implemented yet)
V_HOMUNTYPE = 7        -- Returns the type of Homunculus
V_HP = 8               -- Current HP amount of a Homunculus or its owner
V_SP = 9               -- Current SP amount of a Homunculus or its owner
V_MAXHP = 10           -- The maximum HP of a Homunculus or its owner
V_MAXSP = 11           -- The maximum SP of a Homunculus or its owner
---------------------------------	


--------------------------
--- V_MOTION（GetV(V_MOTION, id)）
--------------------------
MOTION_STAND = 0       -- Standing
MOTION_MOVE = 1        -- Movement
MOTION_ATTACK = 2      -- Attack
MOTION_DEAD = 3        -- Dead
MOTION_DAMAGE = 4      -- Taking damage
MOTION_BENDDOWN = 5    -- Pick up item, set trap
MOTION_SIT = 6         -- Sitting down
MOTION_SKILL = 7       -- Used a skill
MOTION_CASTING = 8     -- Casting a skill
MOTION_ATTACK2 = 9     -- Attack
MOTION_TOSS = 12       -- Toss (spear boomerang / aid potion)
MOTION_COUNTER = 13    -- Counter-attack
MOTION_PERFORM = 16    -- Performance
MOTION_PERFORM2 = 17   -- Performance
MOTION_JUMP_UP = 19    -- TaeKwon Kid Leap — rising
MOTION_JUMP_FALL = 20  -- TaeKwon Kid Leap — falling
MOTION_SOULLINK = 23   -- Soul linker link skill
MOTION_TUMBLE = 25     -- Tumbling / TK Kid Leap landing
MOTION_BIGTOSS = 28    -- Heavier toss (slim / acid demo)
MOTION_DESPERADO = 38  -- Desperado
MOTION_XXXXXX = 39     -- Unknown
MOTION_FULLBLAST = 42  -- Full Blast
--------------------------


--------------------------------------------
-- V_HOMUNTYPE
--------------------------------------------

LIF = 1              -- Lif
AMISTR = 2           -- Amistr
FILIR = 3            -- Filir
VANILMIRTH = 4       -- Vanilmirth
LIF2 = 5
AMISTR2 = 6
FILIR2 = 7
VANILMIRTH2 = 8
LIF_H = 9            -- Advanced Lif
AMISTR_H = 10        -- Advanced Amistr
FILIR_H = 11         -- Advanced Filir
VANILMIRTH_H = 12    -- Advanced Vanilmirth
LIF_H2 = 13
AMISTR_H2 = 14
FILIR_H2 = 15
VANILMIRTH_H2 = 16

--------------------------------------------


--------------------------
-- return values for RGetMsg (id), GetResMsg (id)
--------------------------
NOME_CMD = 0 -- No Command  生命体好像没有

MOVE_CMD = 1 -- Move    移动      msg[1,134,306]
-- {Command Number}

STOP_CMD = 2 -- Stop  生命体好像没有
-- {x coordinate, y coordinate}

ATTACT_OBJET_CMD = 3 -- Attack   攻击   msg[3,110256278]

ATTACK_AREA_CMD = 4  -- Area Attack  生命体好像没有
-- {x coordinate, y coordinate}

PATROL_CMD = 5 -- Patrol  巡逻 生命体好像没有
-- {x coordinate, y coordinate}

HOLD_CMD = 6         -- Mark  生命体好像没有

SKILL_OBJECT_CMD = 7 -- Use Skill    使用技能    msg[7,5,8009,110256278]
-- {Selected Level, Type, Target ID}

SKILL_AREA_CMD = 8 -- Use Area Attack Skill
-- {Selected Level, Type, x coordinate, y coordinate}

FOLLOW_CMD = 9 -- Follow Its Owner  alt + t
--------------------------


--------------------------
-- SUPPORT SKILLS
--------------------------
HLIF_HEAL = 8001
HLIF_AVOID = 8002
HLIF_CHANGE = 8004
HAMI_CASTLE = 8005
HAMI_DEFENCE = 8006
HAMI_BLOODLUST = 8008
HFLI_FLEET = 8010
HFLI_SPEED = 8011
HVAN_CHAOTIC = 8014
MH_GOLDENE_FERSE = 8032
MH_STEINWAND = 8033
MH_ANGRIFFS_MODUS = 8035
MH_GRANITIC_ARMOR = 8040
MH_MAGMA_FLOW = 8039
MH_OVERED_BOOST = 8023
MH_LIGHT_OF_REGENE = 8022
MH_SILENT_BREEZE = 8026
MH_PAIN_KILLER = 8021
--------------------------

--------------------------
-- ATTACK SKILLS
--------------------------
HFLI_MOON = 8009
--------------------------


-------------------------------------------------
-- custom constants
-------------------------------------------------

--------------------------
---res code
--------------------------

---[
---  SUCCESS = 1, -- 节点 成功. 
---  RUNNING = 0, -- 节点 运行中. 
---  FAILURE = -1 -- 节点 运行中. 
--]
NodeStates = {
    SUCCESS = 1, -- 节点 成功
    RUNNING = 0, -- 节点 运行中
    FAILURE = -1 -- 节点 运行中
}

--------------------------



--------------------------
--- runtime
--------------------------

SCREEN_MAX_DISTANCE = 16 -- 超过多少给生命体拉回来

IDLE_FOLLOW_DISTANCE = 3 -- 空闲跟随距离

--------------------------
