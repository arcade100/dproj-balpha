extends Node2D

func _ready() -> void:
	$Core/CoreMenu.purchased_item.connect($CanvasLayer/InventoryUI.update_inventory_ui)
	$CanvasLayer/InventoryUI.update_inventory_ui("")
	$Player.player_dead.connect($CanvasLayer/InventoryUI/DeathScreen.show)
	$Player.inventory_item_equipped.connect($CanvasLayer/InventoryUI.update_selected_item)
	$Player.inventory_updated.connect($CanvasLayer/InventoryUI.update_inventory_ui)
