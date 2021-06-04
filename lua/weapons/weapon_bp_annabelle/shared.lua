if SERVER then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= true
	SWEP.AutoSwitchFrom		= true
	SWEP.HoldType			= "shotgun"
end

if CLIENT then
language.Add("weapon_bp_annabelle", "Annabelle")

SWEP.Category				= "Half-Life 2 Beta Sweps"
SWEP.PrintName				= "Annabelle"
SWEP.Slot					= 3
SWEP.SlotPos				= 4
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= true
SWEP.ViewModelFOV			= 60
SWEP.ViewModelFlip			= false
SWEP.WepSelectIcon			= surface.GetTextureID("HUD/swepicons/leak_shotgun") 
SWEP.DrawWeaponInfoBox		= false
SWEP.BounceWeaponIcon		= false 
SWEP.HoldType				= "shotgun"
end

SWEP.ViewModel      		= "models/weapons/v_annabell3.mdl"
SWEP.WorldModel   			= "models/weapons/w_annabelle.mdl"
SWEP.Spawnable      		= true
SWEP.AdminSpawnable			= true
SWEP.HoldType				= "shotgun"

game.AddAmmoType( { name = "bp_shotgun" } )
if ( CLIENT ) then language.Add( "bp_shotgun_ammo", "12 Gauge Ammo" ) end

SWEP.Primary.ClipSize		= 2					
SWEP.Primary.DefaultClip	= 6					
SWEP.Primary.Automatic		= false				
SWEP.Primary.Ammo			= "bp_shotgun"
SWEP.Primary.Sound			= Sound("weapons/1winchester/win_fire1.wav")
SWEP.Primary.Delay			= 2 	
SWEP.Primary.Recoil			= 3		
SWEP.Primary.Damage			= 20		
SWEP.Primary.NumShots		= 3		
SWEP.Primary.Cone			= 0.1

SWEP.Secondary.ClipSize		= -1					
SWEP.Secondary.DefaultClip	= -1					
SWEP.Secondary.Automatic	= false				
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.Delay		= 1.2
SWEP.Secondary.Recoil		= 5
SWEP.Secondary.Damage		= 12
SWEP.Secondary.NumShots		= 10
SWEP.Secondary.Cone			= 0.09

SWEP.ShellDelay				= 0.53

SWEP.ShotgunReloading		= true
SWEP.ShotgunFinish			= 0.5
SWEP.ShotgunBeginReload		= 0.5

-----------------------Main functions----------------------------
function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW);
		self:SetNextPrimaryFire( CurTime() + self:SequenceDuration())
		self:SetNextSecondaryFire( CurTime() + self:SequenceDuration())
		self:NextThink( CurTime() + self:SequenceDuration() )
		self:Idle()
	return true
end

function SWEP:Initialize()
self.Weapon:SetNetworkedBool( "reloading", false )
end

 
function SWEP:PrimaryAttack()
	
if self.Weapon:Clip1() == 0 then return end
bullet = {}
	bullet.Num    = 3
	bullet.Src    = self.Owner:GetShootPos()
	bullet.Dir    = self.Owner:GetAimVector()
	bullet.Spread = Vector(.02,.02,.02)
	bullet.Tracer = 1
	bullet.Force  = 10
	bullet.Damage = 20
self.Owner:FireBullets( bullet )

self.Owner:ViewPunch( Angle( -1,math.random(-1,1),0 ) )

self.Weapon:SetNextPrimaryFire(CurTime() + 2)
self.Weapon:SetNextSecondaryFire(CurTime() + 2)
self.Weapon:EmitSound("weapons/1winchester/win_fire1.wav")
self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
self:TakePrimaryAmmo( 1 )
self.Owner:SetAnimation( PLAYER_ATTACK1 )
end
 
function SWEP:SecondaryAttack()

if self:Clip1() <= 1 then 
if self.Weapon:Clip1() == 0 then return end
bullet = {}
	bullet.Num    = 3
	bullet.Src    = self.Owner:GetShootPos()
	bullet.Dir    = self.Owner:GetAimVector()
	bullet.Spread = Vector(.02,.02,.02)
	bullet.Tracer = 1
	bullet.Force  = 10
	bullet.Damage = 20
self.Owner:FireBullets( bullet )

self.Owner:ViewPunch( Angle( -1,math.random(-1,1),0 ) )

self.Weapon:SetNextPrimaryFire(CurTime() + 2)
self.Weapon:SetNextSecondaryFire(CurTime() + 2)
self.Weapon:EmitSound("weapons/1winchester/win_fire1.wav")
self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
self:TakePrimaryAmmo( 1 )
self.Owner:SetAnimation( PLAYER_ATTACK1 )
return end
bullet = {}
	bullet.Num    = 6
	bullet.Src    = self.Owner:GetShootPos()
	bullet.Dir    = self.Owner:GetAimVector()
	bullet.Spread = Vector(.04,.04,.04)
	bullet.Tracer = 1
	bullet.Force  = 10
	bullet.Damage = 20
self.Owner:FireBullets( bullet )

self.Owner:ViewPunch( Angle( -3,math.random(-1,1),0 ) )

self.Weapon:SetNextSecondaryFire(CurTime() + 2)
self.Weapon:EmitSound("weapons/1winchester/win_fire1.wav")
self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
self:TakePrimaryAmmo( 2 )
self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:Reload()
	
	if ( CLIENT ) then return end
	
	// Already reloading
	if ( self.Weapon:GetNetworkedBool( "reloading", false ) ) then return end
	
	// Start reloading if we can
	if ( self.Weapon:Clip1() < self.Primary.ClipSize && self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
		
		self.Weapon:SetNetworkedBool( "reloading", true )
		self.Weapon:SetVar( "reloadtimer", CurTime() + 0.4 )
		self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
		self.Owner:DoReloadEvent()
		end
	end
	
function SWEP:Think()

	if ( self.Weapon:GetNetworkedBool( "reloading", false ) ) then
	
		if ( self.Weapon:GetVar( "reloadtimer", 0 ) < CurTime() ) then
			
			// Finsished reload -
			if ( self.Weapon:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 ) then
				self.Weapon:SetNetworkedBool( "reloading", false )
				return
			end
			
			// Next cycle
			self.Weapon:SetVar( "reloadtimer", CurTime() + 0.4 ) 
			self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
			self.Weapon:EmitSound("weapons/1shotgun1/Shotgun_Reload" .. math.random( 1,2,3 ) .. ".wav")
                local AnimationTime = self.Owner:GetViewModel():SequenceDuration()
                self.ReloadingTime = CurTime() + AnimationTime
                self:SetNextPrimaryFire(CurTime() + AnimationTime)
                self:SetNextSecondaryFire(CurTime() + AnimationTime)

			
			// Add ammo
			self.Owner:RemoveAmmo( 1, self.Primary.Ammo, false )
			self.Weapon:SetClip1(  self.Weapon:Clip1() + 1 )
			
			// Finish filling, final pump
			if ( self.Weapon:Clip1() >= self.Primary.ClipSize || self.Owner:GetAmmoCount( self.Primary.Ammo ) <= 0 ) then
			self.Weapon:SendWeaponAnim( ACT_SHOTGUN_RELOAD_FINISH )
				self:SetNextPrimaryFire( CurTime() + self:SequenceDuration())
				self:SetNextSecondaryFire( CurTime() + self:SequenceDuration())
				self:NextThink( CurTime() + self:SequenceDuration() )
				self:Idle()
			else			
				end
			end
		end
	end

function SWEP:Holster( weapon )
	if ( CLIENT ) then return end

	self:StopIdle()
	
	return true
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