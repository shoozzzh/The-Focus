local wand = EntityGetParent( GetUpdatedEntityID() )
local root = EntityGetRootEntity( wand )
local psp_comp = EntityGetFirstComponentIncludingDisabled( root, "PlatformShooterPlayerComponent" )
local ctrl_comp = EntityGetFirstComponent(root, "ControlsComponent")
local ab_comp = EntityGetFirstComponentIncludingDisabled( wand, "AbilityComponent" )
if not psp_comp or not ctrl_comp or not ab_comp then return end
if ComponentGetValue2( ctrl_comp, "mButtonDownRightClick" ) or InputIsJoystickButtonDown( 0, 26 ) then
    if ComponentGetValue2( ab_comp, "mNextFrameUsable" ) <= GameGetFrameNum() then
        ComponentSetValue2( psp_comp, "mForceFireOnNextUpdate", true )
        GlobalsSetValue( "___is_rclick_casting", "1" )
        return
    end
end
GlobalsSetValue( "___is_rclick_casting", "0" )