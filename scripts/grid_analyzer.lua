local AsyncChunkScanner = {}

-- Local funcs
local math_floor = math.floor
local math_abs = math.abs
local math_max = math.max


-- Convert tile coordinates to chank coordinates
local function position_to_chunk(pos)
  return math_floor(pos.x / 32), math_floor(pos.y / 32)
end

-- Chunk unique key generation (a bit faster)
local function get_chunk_key(cx, cy)
  return (cx + 32768) * 65536 + (cy + 32768)
end

local function chunk_area(cx, cy)
  local x1, y1 = cx * 32, cy * 32
  return { { x1, y1 }, { x1 + 32, y1 + 32 } }
end

-- Water collision check
local function is_colliding(surface, cx, cy, max_colliding_tiles)
  local area = chunk_area(cx, cy)
  local colliding = surface.count_tiles_filtered {
    area = area,
    collision_mask = { "water_tile" },
    limit = max_colliding_tiles
  }
  return colliding >= max_colliding_tiles
end

-- Chebishev distance (square)
local function distance_chebyshev(cx1, cx2, cy1, cy2)
  return math_max(math_abs(cx1 - cx2), math_abs(cy1 - cy2))
end

-- Euclidean distance (circle)
local function distance_euclidean(x1, x2, y1, y2)
  return (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)
end

-- Check if in the source repellent area (Don't trigger expansion here)
local function in_exclusion(cx, cy, exclusion)
  local ex = exclusion.x
  local ey = exclusion.y
  local er = exclusion.r
  return distance_euclidean(cx * 32 + 16, ex, cy * 32 + 16, ey) <= er * er
end


--- Stop specific scanner
function AsyncChunkScanner.stop_scan(scanner_id)
  if storage.scanners and storage.scanners[scanner_id] then
    storage.scanners[scanner_id].is_active = false
    storage.scanners[scanner_id] = nil
  end

  -- Remove tick subscription if no scanners left
  if storage.scanners and next(storage.scanners) == nil then
    script.on_nth_tick(1, nil)
  end
end

--- Stop all scanners
function AsyncChunkScanner.stop_all()
  storage.scanners = {}
  script.on_nth_tick(1, nil)
end

-- ============================================================================
-- 2. ON_TICK
-- ============================================================================

function AsyncChunkScanner.on_tick(event)
  -- Stop all if no storage
  if not storage.scanners then
    script.on_nth_tick(1, nil)
    return
  end

  -- Scanner counter
  local active_count = 0

  -- Loop through scanners in storage
  for scanner_id, state in pairs(storage.scanners) do
    if not state or not state.is_active then return end -- Paranoid check

    local surface = state.surface
    if not surface or not surface.valid then
      AsyncChunkScanner.stop_scan(scanner_id)
      return
    end

    local cx = state.current_cx
    local cy = state.current_cy
    local exclusion = state.exclusion
    local max_colliding_tiles = math.floor(state.settings.max_colliding_tiles_coefficient * 32 * 32)
    local current_score

    -- rendering.draw_rectangle{
    --   color = {0.5, 0.5, 0.5},
    --   width = 20,
    --   left_top = {cx * 32 + 3, cy * 32 + 3},
    --   right_bottom = {cx * 32 + 29, cy * 32 + 29},
    --   surface = surface,
    --   render_mode = "chart"
    -- }

    -- Proceed with the main calculation function
    if surface.is_chunk_generated({ cx, cy }) and
        not in_exclusion(cx, cy, exclusion) and
        not is_colliding(surface, cx, cy, max_colliding_tiles) then
      current_score = AsyncChunkScanner.process_single_chunk(state, cx, cy)
      if current_score ~= nil then
        if current_score == 1 then
          state.callback_fn(surface, state.force,
            state.settings.settler_group_min_size, state.settings.settler_group_max_size, cx, cy, current_score)
         AsyncChunkScanner.stop_scan(scanner_id)
        end
        if state.best_score == nil or current_score >= state.best_score then
          state.best_score = current_score
          state.best_cx = cx
          state.best_cy = cy
        end
      end
    end

    -- Moving pointer to the next chunk
    state.current_cy = state.current_cy + 1
    if state.current_cy > state.end_cy then
      state.current_cy = state.start_cy
      state.current_cx = state.current_cx + 1
      -- Finish
      if state.current_cx > state.end_cx then -- Reached the end of the scanning block
        if state.best_score then
          state.callback_fn(surface, state.force,
            state.settings.settler_group_min_size, state.settings.settler_group_max_size,
            state.best_cx, state.best_cy, state.best_score)
        end
        AsyncChunkScanner.stop_scan(scanner_id)
      end
    end

    active_count = active_count + 1
  end
  -- No scanners -- kill the subscription
  if active_count == 0 then
    script.on_nth_tick(1, nil)
  end
end

-- ============================================================================
-- 3. SINGLE CHUNK LOGIC
-- ============================================================================

-- Collecting entities
function AsyncChunkScanner.collect_entities(state, entities, group_id, current_step_chunks)
  for i = 1, #entities do
    local entity = entities[i]
    if entity.valid then
      local uid = entity.unit_number or entity.pointer
      local loc = state.object_locations[uid]

      if not loc then
        local cx, cy = position_to_chunk(entity.position)
        loc = { cx = cx, cy = cy }
        state.object_locations[uid] = loc

        local key = get_chunk_key(cx, cy)
        local chunk_data = state.grid_objects[key]
        if not chunk_data then
          chunk_data = { group_enemy = 0, group_player = 0 }
          state.grid_objects[key] = chunk_data
        end

        if group_id == 1 then
          chunk_data.group_enemy = chunk_data.group_enemy + 1
        else
          chunk_data.group_player = chunk_data.group_player + 1
        end
      end

      local key = get_chunk_key(loc.cx, loc.cy)
      local chunk_info = current_step_chunks[key]
      if not chunk_info then
        chunk_info = { cx = loc.cx, cy = loc.cy, count_biters = 0, count_player = 0 }
        current_step_chunks[key] = chunk_info
      end

      if group_id == 1 then
        chunk_info.count_biters = chunk_info.count_biters + 1
      else
        chunk_info.count_player = chunk_info.count_player + 1
      end
    end
  end
end

function AsyncChunkScanner.process_single_chunk(state, cx, cy)
  local surface = state.surface

  local self_key = get_chunk_key(cx, cy)
  local self_data = state.grid_objects[self_key]

  -- 1. Check current chunk -- no need to do anything if we know it is not empty
  if self_data and (self_data.group_enemy > 0 or self_data.group_player > 0) then
    return
  end

  -- 2. No data in cache, doing count_entities_filtered (limit=1)
  if not self_data then
    local chunk_area = {
      { cx * 32,       cy * 32 },
      { (cx + 1) * 32, (cy + 1) * 32 }
    }

    local has_enemies = surface.count_entities_filtered({ area = chunk_area, force = state.force, type = { "unit-spawner" }, limit = 1 }) >
        0
    local has_players = not has_enemies and
        (surface.count_entities_filtered({ area = chunk_area, force = "player", limit = 1 }) > 0)

    if has_enemies or has_players then
      state.grid_objects[self_key] = { group_enemy = has_enemies and 1 or 0, group_player = has_players and 1 or 0 }
      return
    end
  end

  -- 3. EMPTY CHUNK: proceed with 2 scans of the area (enemies and player)
  local center_x = cx * 32 + 16
  local center_y = cy * 32 + 16

  local entities_enemy = surface.find_entities_filtered({
    position = { center_x, center_y },
    radius = state.R_tiles,
    force = state.force,
    type = { "unit-spawner" }
  })

  -- Exit if no nests found (beyond the expansion radius)
  if #entities_enemy == 0 then
    return
  end

  local entities_player = surface.find_entities_filtered({
    position = { center_x, center_y },
    radius = state.R_tiles,
    force = "player"
  })

  local current_step_chunks = {}

  -- Fill chunk data
  AsyncChunkScanner.collect_entities(state, entities_enemy, 1, current_step_chunks)
  AsyncChunkScanner.collect_entities(state, entities_player, 2, current_step_chunks)

  -- Calculating score
  local base = 0
  local player = 0
  local friendly_base_influence_radius = state.settings.friendly_base_influence_radius
  local other_base_coefficient = state.settings.other_base_coefficient
  local neighbouring_base_chunk_coefficient = state.settings.neighbouring_base_chunk_coefficient
  local building_coefficient = state.settings.building_coefficient
  local neighbouring_chunk_coefficient = state.settings.neighbouring_chunk_coefficient

  for _, chunk_info in pairs(current_step_chunks) do
    local d = distance_chebyshev(cx, chunk_info.cx, cy, chunk_info.cy)
    if d <= friendly_base_influence_radius then
      base = base +
          chunk_info.count_biters * other_base_coefficient * (neighbouring_base_chunk_coefficient ^ d)
      player = player + chunk_info.count_player * building_coefficient * (neighbouring_chunk_coefficient ^ d)
    end
  end

  local score = 1 / (1 + base + player)
  return score
end

-- ============================================================================
-- 1. INIT AND START
-- ============================================================================

--- Start async scanner
function AsyncChunkScanner.start_scan(scanner_id, surface, start_cx, start_cy, end_cx, end_cy, exclusion, settings,
                                      force, callback_fn)
  -- Create a storage, if there is none
  storage.scanners = storage.scanners or {}

  -- Stop previous scan, if the same id has already been active
  if storage.scanners[scanner_id] then
    AsyncChunkScanner.stop_scan(scanner_id)
  end

  storage.scanners[scanner_id] = {
    surface = surface,
    scanner_id = scanner_id,
    settings = settings,
    R_chunks = settings.max_expansion_distance,
    R_tiles = settings.max_expansion_distance * 32,
    --types_enemy = types_enemy,
    --types_player = types_player,
    force = force or "enemy",

    -- Scan borders
    start_cx = start_cx,
    start_cy = start_cy,
    end_cx = end_cx,
    end_cy = end_cy,

    -- Current scan pointer coordinates
    current_cx = start_cx,
    current_cy = start_cy,

    exclusion = exclusion,

    -- Cach (saved between ticks)
    object_locations = {}, -- unit_number -> {cx, cy}
    grid_objects = {},     -- chunk_key -> {group_enemy = N, group_player = M}

    -- Keep the current best chunk
    best_cx = nil,
    best_cy = nil,
    best_score = nil,

    is_active = true,
    callback_fn = callback_fn
  }

  -- Subscribtion on ticks
  --log("on_tick type: " .. type(AsyncChunkScanner.on_tick))
  script.on_nth_tick(1, AsyncChunkScanner.on_tick)
end

return AsyncChunkScanner



-- function ChunkGridAnalyzer.new(surface, settings)
--   local self = setmetatable({}, ChunkGridAnalyzer)
--   self.surface = surface
--   self.settings = settings
--   self.R_chunks = settings.max_expansion_distance

--   self.friendly_base_influence_radius = settings.friendly_base_influence_radius
--   self.enemy_building_influence_radius = settings.enemy_building_influence_radius
--   self.other_base_coefficient = settings.other_base_coefficient
--   self.building_coefficient = settings.building_coefficient
--   self.neighbouring_base_chunk_coefficient = settings.neighbouring_base_chunk_coefficient
--   self.neighbouring_chunk_coefficient = settings.neighbouring_chunk_coefficient
--   self.max_colliding_tiles = math_floor(settings.max_colliding_tiles_coefficient * 32 * 32)


--   -- Точный радиус сканирования в тайлах для Factorio API
--   self.R_tiles = settings.max_expansion_distance * 32
--   self.enemy_force = "enemy"
--   self.player_force = "player"

--   self.types_biters = { "unit-spawner" }
--   --self.types_player = nil

--   -- Кэш 1: unit_number -> { cx = chunk_x, cy = chunk_y }
--   self.object_locations = {}

--   -- Кэш 2: chunk_key -> list of unit_numbers (объекты в конкретном чанке)
--   self.grid_objects = {}

--   return self
-- end

-- local function chunk_area(cx, cy)
--   local x1, y1 = cx * 32, cy * 32
--   return { { x1, y1 }, { x1 + 32, y1 + 32 } }
-- end

-- local function is_colliding(surface, cx, cy, max_colliding_tiles)
--   local area = chunk_area(cx, cy)
--   local colliding = surface.count_tiles_filtered {
--     area = area,
--     collision_mask = { "water_tile" },
--     limit = max_colliding_tiles
--   }
--   return colliding >= max_colliding_tiles
-- end

-- -- Чебышевское расстояние между центрами двух чанков (квадрат)
-- local function distance_chebyshev(cx1, cx2, cy1, cy2)
--   return math_max(math_abs(cx1 - cx2), math_abs(cy1 - cy2))
-- end

-- local function distance_euclidean(x1, x2, y1, y2)
--   return (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)
-- end

-- -- Кэширование сущности с сохранением её группы (тип 1 или тип 2)
-- function ChunkGridAnalyzer:get_entity_chunk_location(entity, group_id)
--   local uid = entity.unit_number or entity.pointer

--   if not self.object_locations[uid] then
--     local cx, cy = position_to_chunk(entity.position)
--     self.object_locations[uid] = { cx = cx, cy = cy, group_id = group_id }

--     local key = get_chunk_key(cx, cy)
--     local chunk_data = self.grid_objects[key]
--     if not chunk_data then
--       chunk_data = { group_biters = 0, group_player = 0 }
--       self.grid_objects[key] = chunk_data
--     end

--     if group_id == 1 then
--       chunk_data.group_biters = chunk_data.group_biters + 1
--     else
--       chunk_data.group_player = chunk_data.group_player + 1
--     end
--   end

--   local loc = self.object_locations[uid]
--   return loc.cx, loc.cy
-- end

-- -- Вспомогательная функция для одного вызова find_entities_filtered
-- function ChunkGridAnalyzer:find_enemy_entities(center_x, center_y, force)
--   return self.surface.find_entities_filtered({
--     position = { center_x, center_y },
--     radius = self.R_tiles,
--     force = force,
--     type = self.types_biters
--     --limit = 7
--   })
-- end

-- -- Вспомогательная функция для одного вызова find_entities_filtered
-- function ChunkGridAnalyzer:find_player_entities(center_x, center_y, force)
--   return self.surface.find_entities_filtered({
--     position = { center_x, center_y },
--     radius = self.R_tiles,
--     force = force
--     --limit = 7
--   })
-- end

-- -- Вспомогательная функция наполнения таблицы найденных чанков
-- function ChunkGridAnalyzer:collect_entities(entities, group_id, current_step_chunks)
--   for i = 1, #entities do
--     local entity = entities[i]
--     if entity.valid then
--       local ecx, ecy = self:get_entity_chunk_location(entity, group_id)
--       local key = get_chunk_key(ecx, ecy)

--       local chunk_info = current_step_chunks[key]
--       if not chunk_info then
--         chunk_info = { cx = ecx, cy = ecy, count_biters = 0, count_player = 0 }
--         current_step_chunks[key] = chunk_info
--       end

--       if group_id == 1 then
--         chunk_info.count_biters = chunk_info.count_biters + 1
--       else
--         chunk_info.count_player = chunk_info.count_player + 1
--       end
--     end
--   end
-- end

-- -- Обработка одного чанка (cx, cy)
-- function ChunkGridAnalyzer:process_chunk(cx, cy, process_callback)
--   if is_colliding(self.surface, cx, cy, self.max_colliding_tiles) then
--     return
--   end


--   local self_key = get_chunk_key(cx, cy)
--   local self_data = self.grid_objects[self_key]

--   -- 1. Быстрая проверка через кэш (если этот чанк УЖЕ попадал в радиус прошлых сканов)
--   if self_data and (self_data.group_biters > 0 or self_data.group_player > 0) then
--     return -- Чанк точно не пустой, выходим ДО сканирования!
--   end

--   -- 2. Если данных в кэше ЕЩЕ НЕТ, делаем ЕДИНОРАЗОВЫЙ точечный скан ТОЛЬКО этого чанка 32x32
--   if not self_data then
--     local chunk_area = {
--       { cx * 32,       cy * 32 },
--       { (cx + 1) * 32, (cy + 1) * 32 }
--     }

--     local has_type_biters = self.surface.count_entities_filtered({ area = chunk_area, force = "enemy", limit = 1 }) >
--         0
--     local has_type_player = not has_type_biters and
--         (self.surface.count_entities_filtered({ area = chunk_area, force = "player", limit = 1 }) > 0)

--     if has_type_biters or has_type_player then
--       -- Помечаем в кэше, что чанк не пустой, чтобы больше к нему не обращаться, и выходим!
--       self.grid_objects[self_key] = {
--         group_biters = has_type_biters and 1 or 0,
--         group_player = has_type_player and 1 or
--             0
--       }
--       return
--     end
--   end

--   local center_x = cx * 32 + 16
--   local center_y = cy * 32 + 16

--   -- 1. ДВА раздельных запроса API для разных типов
--   local entities_biters = self:find_enemy_entities(center_x, center_y, "enemy")
--   if #entities_biters == 0 then
--     return
--   end

--   local entities_player = self:find_player_entities(center_x, center_y, "player")

--   -- Сводная таблица по всем непустым чанкам в радиусе на текущем шаге
--   local current_step_chunks = {}

--   -- Наполняем данные для обоих типов
--   self:collect_entities(entities_biters, 1, current_step_chunks)
--   self:collect_entities(entities_player, 2, current_step_chunks)


--   -- 3. Выполняем оценку для пустого чанка
--   local base = 0
--   local player = 0
--   for _, chunk_info in pairs(current_step_chunks) do
--     local d = distance_chebyshev(cx, chunk_info.cx, cy, chunk_info.cy)
--     if d <= self.friendly_base_influence_radius then
--       base = base +
--           chunk_info.count_biters * self.other_base_coefficient * (self.neighbouring_base_chunk_coefficient ^ d)
--       player = player + chunk_info.count_player * self.building_coefficient * (self.neighbouring_chunk_coefficient ^ d)
--     end
--   end

--   process_callback(self.surface, cx, cy, 1 / (1 + base + player))
-- end

-- local function in_exclusion(cx, cy, exclusion)
--   local ex = exclusion.x
--   local ey = exclusion.y
--   local er = exclusion.r
--   return distance_euclidean(cx * 32 + 16, ex, cy * 32 + 16, ey) <= er * er
-- end

-- -- Сканирование области N x M чанков
-- function ChunkGridAnalyzer:scan_area(start_cx, start_cy, end_cx, end_cy, exclusion, process_callback)
--   for cx = start_cx, end_cx do
--     for cy = start_cy, end_cy do
--       if self.surface.is_chunk_generated({ cx, cy }) and not in_exclusion(cx, cy, exclusion) then
--         self:process_chunk(cx, cy, process_callback)
--       end
--     end
--   end
-- end

-- return ChunkGridAnalyzer
