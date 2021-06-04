if SERVER then
AddCSLuaFile( "shared.lua" )
	SWEP.Weight				= 1
	SWEP.AutoSwitchTo		= true
	SWEP.AutoSwitchFrom		= true
	SWEP.HoldType			= "pistol"
end

if CLIENT then

language.Add("weapon_bp_alyxgun", "Alyx Gun")

SWEP.PrintName = "Alyx Gun"
SWEP.Category 		= "Half-Life 2 Beta Sweps"
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.ViewModelFOV = 54
SWEP.ViewModelFlip = false
SWEP.HoldType		= "pistol"
SWEP.WepSelectIcon = surface.GetTextureID("HUD/swepicons/weapon_alyxgun_leak") 
SWEP.DrawWeaponInfoBox	= false
SWEP.BounceWeaponIcon = false 
end

SWEP.ViewModel		= "models/betaweapons_2020/c_alyx_gun.mdl"
SWEP.WorldModel		= "models/weapons/w_alex_gun.mdl"
SWEP.AnimPrefix		= "pistol"
SWEP.UseHands = true

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

game.AddAmmoType( { name = "bp_small" } )
if ( CLIENT ) then language.Add( "bp_small_ammo", "Small Rounds" ) end

SWEP.Primary.Recoil            = 2
SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 90
SWEP.Primary.Automatic		= true
SWEP.Primary.Delay		= 0.2
SWEP.Primary.Ammo		= "bp_small"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.Zoom = 0

function SWEP:Initialize()

end

function SWEP:Deploy()
	if(self.Zoom == 0) then
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW);
		self:SetNextPrimaryFire( CurTime() + self:SequenceDuration())
		self:SetNextSecondaryFire( CurTime() + self:SequenceDuration())
		self:NextThink( CurTime() + self:SequenceDuration() )
		self:Idle()
		self.Zoom = 0
		return true

	
	else
	if(self.Zoom == 1) then
	self.Weapon:SendWeaponAnim(ACT_VM_HAULBACK);
		self:SetNextPrimaryFire( CurTime() + self:SequenceDuration())
		self:SetNextSecondaryFire( CurTime() + self:SequenceDuration())
		self:NextThink( CurTime() + self:SequenceDuration() )
		self:Idle()
		self.Zoom = 1
		return true

		end
	end
end

function SWEP:Holster()
	self.Owner:SetFOV( 0, 0 )
	self.Zoom = 0

	return true
end

function SWEP:Holster( wep )
	if ( CLIENT ) then return end

	self:StopIdle()
	return true
end

function SWEP:Reload( )
	if ( self:Clip1() < self.Primary.ClipSize && self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
	if self:Clip1() <= 29 then
	if(self.Zoom == 0) then
			self.Weapon:DefaultReload(ACT_VM_RELOAD)
                self:EmitSound("weapons/1alyx_gun/alyxgun_reload.wav")
				self:Idle()
                self.Zoom = 0
	elseif self:Clip1() <= 29 then
		if(self.Zoom == 1) then
			self.Weapon:DefaultReload(ACT_VM_FIDGET)
                self:EmitSound("weapons/1alyx_gun/alyxgun_reload1.wav")
                self:Idle()
				self.Zoom = 1
					end
				end
			end
		end
	end
		
function SWEP:Think()
	if ( self.Owner:KeyReleased( IN_ATTACK ) || ( !self.Owner:KeyDown( IN_ATTACK ) && self.Sound ) ) then		
		self:Idle()
		end
	if ( self.Owner:KeyReleased( IN_ATTACK2 ) || ( !self.Owner:KeyDown( IN_ATTACK2 ) && self.Sound ) ) then		
		self:Idle()
		end
end

function SWEP:PrimaryAttack()
	if self:IsUnderWater() then return end
	if ( !self:CanPrimaryAttack() ) then return end

	    //Pistol Mode			
		if (self.Zoom == 0 || self:Clip1() < 1 ) then
			self:SetWeaponHoldType("pistol")
			self:ShootBullet( 10, 1, 0.01 )
			self.Weapon:SetNextPrimaryFire( CurTime() + 0.3 )
			self:EmitSound( Sound("weapons/1alyx_gun/alyx_gun_fire3.wav") )
			self:TakePrimaryAmmo( 1 )
			self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
			self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
		else
			//Smg Mode
			if (self.Zoom == 1 || self:Clip1() < 1 ) then
				self:SetWeaponHoldType("smg")
				self.Weapon:SetNextPrimaryFire( CurTime() + 0.09 )
				self:ShootBullet( 10, 1, 0.02 )
				self:EmitSound( Sound("weapons/1alyx_gun/alyx_gun_fire4.wav") )
				self:TakePrimaryAmmo( 1 )
				self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
				self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
			end
		end
	end

function SWEP:SecondaryAttack()
	if(self.Zoom == 0) then
		self:StopIdle()
		self.Weapon:SendWeaponAnim( ACT_VM_PULLBACK_HIGH )
		self:EmitSound("weapons/1alyx_gun/alyxgun_switch_single.wav")
		self.Zoom = 1
		self:SetNextPrimaryFire( CurTime() + self:SequenceDuration())
		self:SetNextSecondaryFire( CurTime() + self:SequenceDuration())
		self:NextThink( CurTime() + self:SequenceDuration() )
		self:SetHoldType("smg")
	else
		self:StopIdle()
		if(self.Zoom == 1) then
			self.Weapon:SendWeaponAnim( ACT_VM_PULLBACK_LOW )
			self:EmitSound("weapons/1alyx_gun/alyxgun_switch_burst.wav")
			self.Zoom = 0
			self:SetNextPrimaryFire( CurTime() + self:SequenceDuration())
			self:SetNextSecondaryFire( CurTime() + self:SequenceDuration())
			self:NextThink( CurTime() + self:SequenceDuration() )
			self:SetHoldType("pistol")
			end
		end
	end
	
function SWEP:IsUnderWater()
	if self:WaterLevel() < 3 then
		return false
	else
		if SERVER then
		return true
		end
	end
end
	
function SWEP:DoIdleAnimation()
	if (self.Zoom == 0) then self:SendWeaponAnim( ACT_VM_IDLE ) return end
	if (self.Zoom == 1) then self:SendWeaponAnim( ACT_VM_HITLEFT ) return end
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