-- process.lua complet pour Tilemaker
-- Génère les couches pour le Bénin avec routes, bâtiments, eau, localités et POI

-- Définir les couches de sortie
node_keys = { "amenity", "shop", "tourism", "place" }

-- ==============================
-- Traitement des nodes (points)
-- ==============================
function node_function(node)
    local place = node:Find("place")
    local name = node:Find("name")

    -- Localités
    if place ~= "" then
        node:Layer("place", false)
        node:Attribute("place", place)
        if name ~= "" then
            node:Attribute("name", name)
            node:Attribute("name:latin", name)
        end

        -- Définir min/max zoom selon le type de place
        if place == "city" then
            node:MinZoom(4)
            node:MaxZoom(14)
        elseif place == "town" then
            node:MinZoom(6)
            node:MaxZoom(14)
        elseif place == "village" then
            node:MinZoom(10)
            node:MaxZoom(14)
        elseif place == "hamlet" then
            node:MinZoom(12)
            node:MaxZoom(14)
        end
    end

    -- Points d'intérêt (amenities, shops, tourism)
    local amenity = node:Find("amenity")
    local shop = node:Find("shop")
    local tourism = node:Find("tourism")

    if amenity ~= "" or shop ~= "" or tourism ~= "" then
        node:Layer("poi", false)
        if amenity ~= "" then node:Attribute("amenity", amenity) end
        if shop ~= "" then node:Attribute("shop", shop) end
        if tourism ~= "" then node:Attribute("tourism", tourism) end
        if name ~= "" then
            node:Attribute("name", name)
            node:Attribute("name:latin", name)
        end
        node:MinZoom(13)
    end
end

-- =============================
-- Traitement des ways (lignes/polygones)
-- =============================
function way_function(way)
    local highway = way:Find("highway")
    local waterway = way:Find("waterway")
    local natural = way:Find("natural")
    local landuse = way:Find("landuse")
    local leisure = way:Find("leisure")
    local building = way:Find("building")
    local name = way:Find("name")

    -- Routes et chemins
    if highway ~= "" then
        way:Layer("transportation", false)
        way:Attribute("highway", highway)
        if name ~= "" then
            way:Attribute("name", name)
            way:Attribute("name:latin", name)
        end

        -- Définir min/max zoom selon le type de route
        if highway == "motorway" or highway == "motorway_link" then
            way:MinZoom(5)
            way:MaxZoom(14)
        elseif highway == "trunk" or highway == "trunk_link" then
            way:MinZoom(5)
            way:MaxZoom(14)
        elseif highway == "primary" or highway == "primary_link" then
            way:MinZoom(7)
            way:MaxZoom(14)
        elseif highway == "secondary" or highway == "secondary_link" then
            way:MinZoom(9)
            way:MaxZoom(14)
        elseif highway == "tertiary" or highway == "tertiary_link" then
            way:MinZoom(10)
            way:MaxZoom(14)
        elseif highway == "residential" or highway == "unclassified" or highway == "service" then
            way:MinZoom(11)
            way:MaxZoom(14)
        elseif highway == "track" or highway == "path" or highway == "footway" then
            way:MinZoom(13)
            way:MaxZoom(14)
        end
    end

    -- Cours d'eau (rivières, canaux, etc.)
    if waterway ~= "" then
        way:Layer("waterway", false)
        way:Attribute("waterway", waterway)
        if name ~= "" then
            way:Attribute("name", name)
            way:Attribute("name:latin", name)
        end

        if waterway == "river" then
            way:MinZoom(8)
        elseif waterway == "stream" then
            way:MinZoom(10)
        else
            way:MinZoom(12)
        end
        way:MaxZoom(14)
    end

    -- Plans d'eau (lacs, réservoirs)
    if natural == "water" or landuse == "reservoir" then
        way:Layer("water", true)
        if natural == "water" then
            way:Attribute("natural", "water")
        else
            way:Attribute("landuse", "reservoir")
        end
        if name ~= "" then
            way:Attribute("name", name)
            way:Attribute("name:latin", name)
        end
        way:MinZoom(0)
        way:MaxZoom(14)
    end

    -- Espaces verts (parcs, forêts)
    if leisure == "park" then
        way:Layer("park", true)
        way:Attribute("leisure", "park")
        if name ~= "" then
            way:Attribute("name", name)
            way:Attribute("name:latin", name)
        end
        way:MinZoom(10)
        way:MaxZoom(14)
    end

    -- Forêts et bois
    if landuse == "forest" or natural == "wood" then
        way:Layer("park", true)
        if landuse == "forest" then
            way:Attribute("landuse", "forest")
        else
            way:Attribute("natural", "wood")
        end
        if name ~= "" then
            way:Attribute("name", name)
            way:Attribute("name:latin", name)
        end
        way:MinZoom(8)
        way:MaxZoom(14)
    end

    -- Autres landuse
    if landuse ~= "" and landuse ~= "forest" and landuse ~= "reservoir" then
        way:Layer("landuse", true)
        way:Attribute("landuse", landuse)
        way:MinZoom(10)
        way:MaxZoom(14)
    end

    -- Bâtiments
    if building ~= "" then
        way:Layer("building", true)
        way:Attribute("building", building)
        way:MinZoom(13)
        way:MaxZoom(14)
    end
end

-- ==================================
-- Traitement des relations
-- ==================================
function relation_function(relation)
    local boundary = relation:Find("boundary")
    local admin_level = relation:Find("admin_level")
    local name = relation:Find("name")

    -- Limites administratives
    if boundary == "administrative" and admin_level ~= "" then
        relation:Layer("boundary", false)
        relation:Attribute("boundary", "administrative")
        relation:Attribute("admin_level", admin_level)
        if name ~= "" then
            relation:Attribute("name", name)
            relation:Attribute("name:latin", name)
        end

        -- Zoom levels selon le niveau administratif
        local level = tonumber(admin_level)
        if level <= 4 then
            relation:MinZoom(0)
        elseif level <= 6 then
            relation:MinZoom(4)
        else
            relation:MinZoom(8)
        end
        relation:MaxZoom(14)
    end
end
