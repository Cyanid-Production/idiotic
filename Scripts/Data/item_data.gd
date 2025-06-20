class_name Item extends Resource

enum Type {MATERIAL, CONSUMABLE, WEAPON, AMMO}

@export var name_code : String
@export var id : String
@export var texture : Texture2D
@export var type : Type
@export_multiline var description_code : String
@export var model : Mesh
