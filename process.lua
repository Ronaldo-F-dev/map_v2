-- process.lua complet pour Tilemaker
-- Génère les couches pour le Bénin avec routes, bâtiments, eau, localités et POI

-- Définir les clés à indexer
node_keys = { "amenity", "shop", "tourism", "place" }

-- ==============================
-- Traitement des nodes (points)
-- ==============================
function node_function()
    local place = Find("place")
    local name = Find("name")

    -- Localités
    if place ~= "" then
        Layer("place", false)
        Attribute("place", place)
        if name ~= "" then
            Attribute("name", name)
            Attribute("name:latin", name)
        end

        -- Définir min/max zoom selon le type de place
        if place == "city" then
            MinZoom(4)
        elseif place == "town" then
            MinZoom(6)
        elseif place == "village" then
            MinZoom(10)
        elseif place == "hamlet" then
            MinZoom(12)
        end
    end

    -- Points d'intérêt (amenities, shops, tourism)
    local amenity = Find("amenity")
    local shop = Find("shop")
    local tourism = Find("tourism")

    if amenity ~= "" or shop ~= "" or tourism ~= "" then
        Layer("poi", false)
        if amenity ~= "" then Attribute("amenity", amenity) end
        if shop ~= "" then Attribute("shop", shop) end
        if tourism ~= "" then Attribute("tourism", tourism) end
        if name ~= "" then
            Attribute("name", name)
            Attribute("name:latin", name)
        end
        MinZoom(13)
    end
end

-- =============================
-- Traitement des ways (lignes/polygones)
-- =============================
function way_function()
    local highway = Find("highway")
    local waterway = Find("waterway")
    local natural = Find("natural")
    local landuse = Find("landuse")
    local leisure = Find("leisure")
    local building = Find("building")
    local name = Find("name")
    local isClosed = IsClosed()

    -- Routes et chemins
    if highway ~= "" then
        Layer("transportation", false)
        Attribute("highway", highway)
        if name ~= "" then
            Attribute("name", name)
            Attribute("name:latin", name)
        end

        -- Définir min/max zoom selon le type de route
        if highway == "motorway" or highway == "motorway_link" then
            MinZoom(5)
        elseif highway == "trunk" or highway == "trunk_link" then
            MinZoom(5)
        elseif highway == "primary" or highway == "primary_link" then
            MinZoom(7)
        elseif highway == "secondary" or highway == "secondary_link" then
            MinZoom(9)
        elseif highway == "tertiary" or highway == "tertiary_link" then
            MinZoom(10)
        elseif highway == "residential" or highway == "unclassified" or highway == "service" then
            MinZoom(11)
        elseif highway == "track" or highway == "path" or highway == "footway" then
            MinZoom(13)
        end
    end

    -- Cours d'eau (rivières, canaux, etc.)
    if waterway ~= "" then
        Layer("waterway", false)
        Attribute("waterway", waterway)
        if name ~= "" then
            Attribute("name", name)
            Attribute("name:latin", name)
        end

        if waterway == "river" then
            MinZoom(8)
        elseif waterway == "stream" then
            MinZoom(10)
        else
            MinZoom(12)
        end
    end

    -- Plans d'eau (lacs, réservoirs)
    if (natural == "water" or landuse == "reservoir") and isClosed then
        Layer("water", true)
        if natural == "water" then
            Attribute("natural", "water")
        else
            Attribute("landuse", "reservoir")
        end
        if name ~= "" then
            Attribute("name", name)
            Attribute("name:latin", name)
        end
        MinZoom(0)
    end

    -- Espaces verts (parcs, forêts)
    if leisure == "park" and isClosed then
        Layer("park", true)
        Attribute("leisure", "park")
        if name ~= "" then
            Attribute("name", name)
            Attribute("name:latin", name)
        end
        MinZoom(10)
    end

    -- Forêts et bois
    if (landuse == "forest" or natural == "wood") and isClosed then
        Layer("park", true)
        if landuse == "forest" then
            Attribute("landuse", "forest")
        else
            Attribute("natural", "wood")
        end
        if name ~= "" then
            Attribute("name", name)
            Attribute("name:latin", name)
        end
        MinZoom(8)
    end

    -- Autres landuse
    if landuse ~= "" and landuse ~= "forest" and landuse ~= "reservoir" and isClosed then
        Layer("landuse", true)
        Attribute("landuse", landuse)
        MinZoom(10)
    end

    -- Bâtiments
    if building ~= "" and isClosed then
        Layer("building", true)
        Attribute("building", building)
        MinZoom(13)
    end
end

-- ==================================
-- Traitement des relations
-- ==================================
function relation_function()
    local boundary = Find("boundary")
    local admin_level = Find("admin_level")
    local name = Find("name")

    -- Limites administratives
    if boundary == "administrative" and admin_level ~= "" then
        Layer("boundary", false)
        Attribute("boundary", "administrative")
        Attribute("admin_level", admin_level)
        if name ~= "" then
            Attribute("name", name)
            Attribute("name:latin", name)
        end

        -- Zoom levels selon le niveau administratif
        local level = tonumber(admin_level)
        if level <= 4 then
            MinZoom(0)
        elseif level <= 6 then
            MinZoom(4)
        else
            MinZoom(8)
        end
    end
end
