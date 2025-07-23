class_name Item extends Resource

enum Type {ITEM}

@export var name_code : String
@export var id : String
@export var texture : Texture2D
@export var type : Type
@export var consumable : bool
@export var use_effect : Dictionary
@export_multiline var description_code : String
@export var model : Mesh
@export var sound : AudioStream
