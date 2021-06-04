if SERVER then
AddCSLuaFile( "shared.lua" )
end

if CLIENT then
language.Add("weapon_bp_hmg1", "HMG1")

SWEP.PrintName = "HMG1"
SWEP.Slot = 3
SWEP.SlotPos = 4
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.ViewModelFOV = 55
SWEP.ViewModelFlip = false

SWEP.WepSelectIcon = surface.GetTextureID("HUD/swepicons/weapon_hmg1") 
SWEP.DrawWeaponInfoBox	= false
SWEP.BounceWeaponIcon = false 
end

SWEP.Category 		= "Half-Life 2 Beta Sweps"
SWEP.PrintName		= "HMG1"	

SWEP.ViewModelFOV	= 55
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_hng.mdl"
SWEP.WorldModel		= "models/weapons/w_hmg.mdl"
SWEP.HoldType		= "crossbow"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

game.AddAmmoType( { name = "bp_large" } )
if ( CLIENT ) then language.Add( "bp_large_ammo", "Large Rounds" ) end

SWEP.Primary.Recoil            = 2
SWEP.Primary.ClipSize		= 50
SWEP.Primary.DefaultClip	= 150
SWEP.Primary.Automatic		= true
SWEP.Primary.Delay		= 0.2
SWEP.Primary.Ammo		= "bp_large"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"

SWEP.Zoom = 0

function SWEP:Initialize()
		self:SetWeaponHoldType(self.HoldType)
	end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW);
	self:SetNextPrimaryFire( CurTime() + self:SequenceDuration())
	self:SetNextSecondaryFire( CurTime() + self:SequenceDuration())
	self:NextThink( CurTime() + self:SequenceDuration() )
	self:Idle()
	return true
end

function SWEP:Holster()
	self.Owner:SetFOV( 0, 0.25 )
	self.Owner:ConCommand("pp_mat_overlay \"\"");//", "");
	timer.Stop( "Overlay" )
	timer.Destroy( "Overlay" )
	self:StopIdle()
	self.Zoom = 0
	self:SetWeaponHoldType("crossbow")
	return true
end

function SWEP:Reload()
	if self:DefaultReload( ACT_VM_RELOAD ) then 
		if(SERVER) then
			self.Owner:SetFOV( 0, 0.25 )
			self.Owner:ConCommand("pp_mat_overlay \"\"");//", "");
			self.Owner:DrawViewModel(true)
			timer.Stop( "Zoomie" )
			timer.Stop( "BringTheNoise" )
			timer.Stop( "ByeBye" )
			timer.Stop( "Overlay" )
			timer.Destroy( "Zoomie" )
			timer.Destroy( "BringTheNoise" )
			timer.Destroy( "ByeBye" )
			timer.Destroy( "Overlay" )
			self.Zoom = 0
		end
		self:SetHoldType("crossbow")
		self:SetNextPrimaryFire( CurTime() + self:SequenceDuration())
		self:SetNextSecondaryFire( CurTime() + self:SequenceDuration())
		self:NextThink( CurTime() + self:SequenceDuration() )
		self:Idle()
		self:EmitSound(Sound("weapons/1smg2/smg2_reload.wav")) 
	end
end

function SWEP:Think()
	if ( self.Owner:KeyReleased( IN_ATTACK ) || ( !self.Owner:KeyDown( IN_ATTACK ) && self.Sound ) ) then		
		self:Idle()
		end
end

function SWEP:PrimaryAttack()

	if ( !self:CanPrimaryAttack() ) then return end

	if (self.Zoom == 0 || self:Clip1() < 2 ) then
		self:ShootBullet( 20, 1, 0.05 )
		self.Weapon:SetNextPrimaryFire( CurTime() + 0.08 )
		self:EmitSound( Sound("weapons/hmg1_9.wav") )
		self:TakePrimaryAmmo( 1 )
		self.Owner:ViewPunch( Angle( math.Rand(-0.4,-0.2) * self.Primary.Recoil, math.Rand(-0.2,0.2) *self.Primary.Recoil, 0 ) )
	else
		self.Weapon:SetNextPrimaryFire( CurTime() + 0.08 )
		self:ShootBullet( 20, 1, 0.02 )
		self:EmitSound( Sound("weapons/hmg1_9.wav") )
		self:TakePrimaryAmmo( 1 )
		self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.2) * self.Primary.Recoil, math.Rand(-0.2,0.2) *self.Primary.Recoil, 0 ) )
	     end
	
       end

function SWEP:SecondaryAttack()

	if(self.Zoom == 0) then
		self:SetHoldType("ar2")
		if(SERVER) then
			self:StopIdle()
			timer.Create( "Zoomie", 0.6, 1, function() self.Owner:SetFOV( 35, 0.30 ) end )
			timer.Create( "ByeBye", 0.6, 1, function() self.Owner:DrawViewModel(false) end )
			timer.Create( "Overlay", 0.6, 1, function() self.Owner:ConCommand("pp_mat_overlay effects/scope03.vmt"); end )//", "effects/scope03.vmt"); end )			
			self:SendWeaponAnim( ACT_VM_ATTACH_SILENCER )
		end
		timer.Create( "BringTheNoise", 0.6, 1, function() self:EmitSound("Weapon_AR2.Special1") end )
        self.Zoom = 1
	else
		self:SetHoldType("crossbow")
        if(SERVER) then
			self.Owner:SetFOV( 0, 0.30 )
			timer.Stop( "Zoomie" )
			timer.Stop( "BringTheNoise" )
			timer.Stop( "ByeBye" )
			timer.Stop( "Overlay" )
			timer.Destroy( "Zoomie" )
			timer.Destroy( "BringTheNoise" )
			timer.Destroy( "ByeBye" )
			timer.Destroy( "Overlay" )
			self:SendWeaponAnim( ACT_VM_DETACH_SILENCER )
			self.Owner:ConCommand("pp_mat_overlay \"\"");//", "");
			self.Owner:DrawViewModel(true)
			self:Idle()
		end
		self:EmitSound("Weapon_AR2.Special2")
        self.Zoom = 0
	end
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