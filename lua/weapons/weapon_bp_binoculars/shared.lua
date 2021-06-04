
if (SERVER) then
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight		= 5
	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= true
end

if ( CLIENT ) then
language.Add("weapon_bp_binoculars", "Binoculars")

SWEP.PrintName = "Binoculars"
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.ViewModelFlip = false

SWEP.WepSelectIcon = surface.GetTextureID("HUD/swepicons/util_binoculars") 
SWEP.DrawWeaponInfoBox	= false
SWEP.BounceWeaponIcon = false 

	SWEP.DrawAmmo			= false
	SWEP.ViewModelFOV	= 58
	SWEP.DrawCrosshair		= true
	local	w = ScrW()
	local	h = ScrH()
	local	centerX = w / 2
	local	centerY = h / 2
	function SWEP:DrawHUD()
		if(self:GetNWBool("zom")==true)then
		local zoom=self:GetNWInt("zoom")
				local center = Vector( centerX, centerY, 0 )
				local scale = Vector( 108-zoom, 108-zoom, 0 )
				local scale2 = Vector( 120-zoom, 120-zoom, 0 )
				local scale3 = Vector( 60-zoom, 60-zoom, 0 )
					self:DrawCircle(center,scale,false);
					self:DrawCircle(center,scale2,false);
					self:DrawCircle(center,scale3,false);
				local dist= math.Round(LocalPlayer():GetPos():Distance( LocalPlayer():GetEyeTraceNoCursor().HitPos ) / 12)
				draw.DrawText(dist.." ft", "HudSelectionText", centerX,centerY+135-zoom, Color(255, 220, 0, 255),1)
				if(LocalPlayer():GetEyeTraceNoCursor().Entity && IsValid((LocalPlayer():GetEyeTraceNoCursor().Entity)) && !(LocalPlayer():GetEyeTraceNoCursor().Entity:GetClass() == "player") )then
					local str=Localize( LocalPlayer():GetEyeTraceNoCursor().Entity:GetClass(), LocalPlayer():GetEyeTraceNoCursor().Entity:GetClass() )
					draw.DrawText(str, "HudSelectionText", centerX,centerY+120-zoom, Color(255, 220, 0, 255),1)
					self:DrawCircle(center,Vector( 55-zoom, 55-zoom, 0 ),true);
					self:DrawCircle(center,Vector( 56-zoom, 56-zoom, 0 ),true);
					self:DrawCircle(center,Vector( 57-zoom, 57-zoom, 0 ),true);
				end
				
					
		end
	end
	function SWEP:DrawCircle(center,scale,boolt)
				local segmentdist = 360 / ( 2 * math.pi * math.max( scale.x, scale.y ) / 2 )
					if(boolt)then
					surface.SetDrawColor( 255, 0, 0,70)
					else
					surface.SetDrawColor( 255, 220, 0,70)
					end
			 	for a = 0, 360 - segmentdist, segmentdist do
					surface.DrawLine( center.x + math.cos( math.rad( a ) ) * scale.x, center.y - math.sin( math.rad( a ) ) * scale.y, center.x + math.cos( math.rad( a + segmentdist ) ) * scale.x, center.y - math.sin( math.rad( a + segmentdist ) ) * scale.y )
				end
	end
end

SWEP.Category = "Half-Life 2 Beta Sweps" 

SWEP.Spawnable     			= true
SWEP.AdminSpawnable  		= true
 
SWEP.ViewModel		= "models/weapons/v_binocular5.mdl"
SWEP.WorldModel		= "models/weapons/w_binoculars.mdl"
SWEP.HoldType			= "slam"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic		= true

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo = false
SWEP.Secondary.Automatic = true

SWEP.IsZooming=false;
SWEP.DefaultZoom = 75;
SWEP.ZoomDistCurrent = SWEP.DefaultZoom;
SWEP.MaxZoom = 5; //in hl2 the fov is reverse,the less you set,the more you zoom

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW);
	self:Idle()
	return true
end

function SWEP:Initialize()
		self:SetWeaponHoldType(self.HoldType)
if (CLIENT) then return end
self.IsZooming=false;
self:SetNWBool("zom",self.IsZooming)
	
end 

function SWEP:Think()
if (CLIENT) then return end
		
	if(self.IsZooming==false)then
	self.Owner:DrawViewModel(true)
	else
	self.Owner:DrawViewModel(false)
	self.Owner:SetFOV( self.ZoomDistCurrent, 0 )
	end
end

function SWEP:Precache()
    util.PrecacheSound("binoculars/binoculars_zoomin.wav")
	util.PrecacheSound("binoculars/binoculars_zoommax.wav")
	util.PrecacheSound("binoculars/binoculars_zoomout.wav")
end

function SWEP:PrimaryAttack(ply)
if (CLIENT) then return end 
	self.IsZooming=true;
	self:SetNWBool("zom",self.IsZooming)
	if self.ZoomDistCurrent > self.MaxZoom then
		self:Zoom(1)
		self.Weapon:SetNextSecondaryFire(CurTime() + 0.5)
	else
	self.Owner:EmitSound( "1binoculars/binoculars_zoommax.wav" )
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	self.Weapon:SetNextSecondaryFire(CurTime() + 1)
      end
end

function SWEP:Holster()
if (CLIENT) then return end
self:RemoveZoom()
self:StopIdle()
return true;
end

function SWEP:Zoom(cont)
	self.ZoomDistCurrent = self.ZoomDistCurrent - cont
	self:SetNWInt("zoom",self.ZoomDistCurrent)
	self.Owner:SetFOV( self.ZoomDistCurrent, 0 )
	self.Owner:EmitSound( "1binoculars/binoculars_zoomin.wav" )
	self.Owner:SetDSP(55, false )
	self:SetHoldType("camera")
end

function SWEP:RemoveZoom()
self.Owner:SetFOV( 0, 0 )
self.ZoomDistCurrent = self.DefaultZoom
self.IsZooming=false;
self:SetNWBool("zom",self.IsZooming)
self:SetNWInt("zoom",self.ZoomDistCurrent)
self.Owner:SetDSP(0, false )
self.Owner:EmitSound( "1binoculars/binoculars_zoomout.wav" )
self:SetHoldType("slam")
end

function SWEP:SecondaryAttack(ply)
if (CLIENT) then return end
	if self.ZoomDistCurrent < (self.DefaultZoom)+1 then
	self:Zoom(-1)
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
	else
	self:RemoveZoom()
	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	self.Weapon:SetNextSecondaryFire(CurTime() + 1)
        end
end

function SWEP:Reload()
	
end

function SWEP:DoIdleAnimation()
	self:SendWeaponAnim( ACT_VM_IDLE )
end

function SWEP:DoIdle()
	self:DoIdleAnimation()

	timer.Adjust( "weapon_idle" .. self:EntIndex(), self:SequenceDuration(), 0, function()
		if ( !IsValid( self ) ) then timer.Destroy( "weapon_idle" .. self:EntIndex() ) return end

		self:DoIdleAnimation()
	end )
end

function SWEP:StopIdle()
	timer.Destroy( "weapon_idle" .. self:EntIndex() )
end

function SWEP:Idle()
	if ( CLIENT || !IsValid( self.Owner ) ) then return end
	timer.Create( "weapon_idle" .. self:EntIndex(), self:SequenceDuration() - 0.2, 1, function()
		if ( !IsValid( self ) ) then return end
		self:DoIdle()
	end )
end