local entity_id = GetUpdatedEntityID()
local ssound_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "AudioLoopComponent", "spinning_sound" )
ComponentSetValue2( ssound_comp, "m_volume", 2 )