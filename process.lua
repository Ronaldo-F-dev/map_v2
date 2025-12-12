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
    -- Toutes les routes et chemins
    if object:match_tag("highway","motorway") or
       object:match_tag("highway","trunk") or
       object:match_tag("highway","primary") or
       object:match_tag("highway","secondary") or
       object:match_tag("highway","tertiary") or
       object:match_tag("highway","unclassified") or
       object:match_tag("highway","residential") or
       object:match_tag("highway","motorway_link") or
       object:match_tag("highway","trunk_link") or
       object:match_tag("highway","primary_link") or
       object:match_tag("highway","secondary_link") or
       object:match_tag("highway","tertiary_link") or
       object:match_tag("highway","service") or
       object:match_tag("highway","track") or
       object:match_tag("highway","path") or
       object:match_tag("highway","footway") then
        return true
    end
    -- Cours d'eau
    if object:match_tag("waterway","river") or
       object:match_tag("waterway","stream") or
       object:match_tag("waterway","canal") or
       object:match_tag("waterway","drain") then
        return true
    end
    -- Plans d'eau
    if object:match_tag("natural","water") or
       object:match_tag("landuse","reservoir") then
        return true
    end
    -- Espaces verts
    if object:match_tag("leisure","park") or
       object:match_tag("landuse","forest") or
       object:match_tag("natural","wood") then
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
