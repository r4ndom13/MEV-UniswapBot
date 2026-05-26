"""Detects and handles player interactions with ruins and items."""
import pygame
from settings import TILE_SIZE, TILE_RUIN, TILE_ITEM

INTERACT_RADIUS = TILE_SIZE + 4   # pixels from player centre to tile centre

RUIN_MESSAGES = [
    "Ruínas antigas... símbolos estranhos nas pedras.",
    "Uma inscrição apagada pelo tempo. O que dizia?",
    "Pedras cobertas de musgo. Alguém viveu aqui.",
]

_ruin_msg_idx = 0


def check_interaction(player, tilemap, event_key):
    """Call every frame with E key event. Returns a message string or None."""
    global _ruin_msg_idx
    if not event_key:
        return None

    px, py = player.center
    # Sample a few points around the player
    probe_offsets = [
        (0, -TILE_SIZE), (0, TILE_SIZE),
        (-TILE_SIZE, 0), (TILE_SIZE, 0),
    ]
    for ox, oy in probe_offsets:
        tile, coord = tilemap.tile_at_pixel(px + ox, py + oy)
        if tile == TILE_RUIN and coord in tilemap.active_ruins:
            msg = RUIN_MESSAGES[_ruin_msg_idx % len(RUIN_MESSAGES)]
            _ruin_msg_idx += 1
            return msg
        if tile == TILE_ITEM and coord in tilemap.active_items:
            tilemap.active_items.discard(coord)
            col, row = coord
            tilemap.grid[row][col] = 0          # replace with grass
            tilemap.redraw_tile(col, row)
            return "Você encontrou uma pluma sagrada! (+1)"
    return None
