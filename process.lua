-- process.lua pour le Bénin
-- Inclut routes, bâtiments, localités et POI

-- Fonction qui décide si un nœud (point) doit être inclus
function filter_node(object)
    -- Localités
    if object:match_tag("place","city") or
       object:match_tag("place","town") or
       object:match_tag("place","village") or
       object:match_tag("place","hamlet") then
        return true
    end
    -- Points d'intérêt
    if object:match_tag("amenity") or object:match_tag("shop") or object:match_tag("tourism") then
        return true
    end
    return false
end

-- Fonction qui décide si une route ou chemin doit être incluse
function filter_way(object)
    -- Routes principales
    if object:match_tag("highway","primary") or
       object:match_tag("highway","secondary") or
       object:match_tag("highway","tertiary") or
       object:match_tag("highway","residential") then
        return true
    end
    -- Bâtiments
    if object:match_tag("building") then
        return true
    end
    return false
end

-- Relations (ex. limites administratives)
function filter_relation(object)
    -- Limites administratives (communes, départements)
    if object:match_tag("boundary","administrative") then
        return true
    end
    return false
end
