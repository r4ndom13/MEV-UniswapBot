import random
from settings import (TILE_SIZE, MAP_COLS, MAP_ROWS,
                      TILE_GRASS, TILE_WATER, TILE_SAND,
                      TILE_TREE, TILE_RUIN, TILE_ITEM,
                      C_GRASS, C_GRASS2, C_WATER, C_WATER2,
                      C_SAND, C_TREE_DARK, C_TREE_MID, C_TREE_LIT,
                      C_TRUNK, C_RUIN, C_RUIN_OUT, C_ITEM)
import pygame

_RNG = random.Random(42)


def _build_map():
    grid = [[TILE_GRASS] * MAP_COLS for _ in range(MAP_ROWS)]

    # River running roughly vertically through centre-left
    river_x = 12
    for r in range(MAP_ROWS):
        jitter = _RNG.randint(-1, 1)
        river_x = max(3, min(MAP_COLS - 4, river_x + jitter))
        for w in range(4):
            grid[r][river_x + w] = TILE_WATER
        # Sandy banks
        if river_x > 0:
            grid[r][river_x - 1] = TILE_SAND
        if river_x + 4 < MAP_COLS:
            grid[r][river_x + 4] = TILE_SAND

    # Dense forest clusters (avoid river band)
    for _ in range(80):
        cr = _RNG.randint(1, MAP_ROWS - 2)
        cc = _RNG.randint(1, MAP_COLS - 2)
        if grid[cr][cc] != TILE_WATER:
            for dr in range(-2, 3):
                for dc in range(-2, 3):
                    r2, c2 = cr + dr, cc + dc
                    if 0 <= r2 < MAP_ROWS and 0 <= c2 < MAP_COLS:
                        if grid[r2][c2] == TILE_GRASS and _RNG.random() < 0.6:
                            grid[r2][c2] = TILE_TREE

    # Ruins (3 spots) — walkable but interactable
    ruins = []
    while len(ruins) < 3:
        r = _RNG.randint(2, MAP_ROWS - 3)
        c = _RNG.randint(2, MAP_COLS - 3)
        if grid[r][c] == TILE_GRASS:
            grid[r][c] = TILE_RUIN
            ruins.append((c, r))

    # Collectible items (5 spots)
    items = []
    while len(items) < 5:
        r = _RNG.randint(1, MAP_ROWS - 2)
        c = _RNG.randint(1, MAP_COLS - 2)
        if grid[r][c] == TILE_GRASS:
            grid[r][c] = TILE_ITEM
            items.append((c, r))

    return grid, ruins, items


def _tile_colour(tile, variant):
    if tile == TILE_WATER:
        return C_WATER if variant else C_WATER2
    if tile == TILE_SAND:
        return C_SAND
    return C_GRASS if variant else C_GRASS2


class TileMap:
    def __init__(self):
        self.grid, self.ruin_tiles, self.item_tiles = _build_map()
        self.pixel_w = MAP_COLS * TILE_SIZE
        self.pixel_h = MAP_ROWS * TILE_SIZE
        self._surface = self._bake_surface()
        # Track which interactables are still active
        self.active_ruins = set(self.ruin_tiles)
        self.active_items = set(self.item_tiles)

    # ------------------------------------------------------------------
    def _bake_surface(self):
        surf = pygame.Surface((self.pixel_w, self.pixel_h))
        for r in range(MAP_ROWS):
            for c in range(MAP_COLS):
                tile = self.grid[r][c]
                x, y = c * TILE_SIZE, r * TILE_SIZE
                variant = (r + c) % 2 == 0

                base_col = _tile_colour(tile, variant)
                pygame.draw.rect(surf, base_col, (x, y, TILE_SIZE, TILE_SIZE))

                if tile == TILE_TREE:
                    self._draw_tree(surf, x, y)
                elif tile == TILE_RUIN:
                    self._draw_ruin(surf, x, y)
                elif tile == TILE_ITEM:
                    self._draw_item(surf, x, y)

        return surf

    def _draw_tree(self, surf, x, y):
        cx, cy = x + TILE_SIZE // 2, y + TILE_SIZE // 2
        pygame.draw.circle(surf, C_TRUNK,   (cx, cy + 6), 5)
        pygame.draw.circle(surf, C_TREE_DARK, (cx, cy - 2), 16)
        pygame.draw.circle(surf, C_TREE_MID,  (cx - 4, cy - 5), 10)
        pygame.draw.circle(surf, C_TREE_LIT,  (cx + 3, cy - 6), 8)

    def _draw_ruin(self, surf, x, y):
        pygame.draw.rect(surf, C_RUIN, (x + 6, y + 6, TILE_SIZE - 12, TILE_SIZE - 12))
        pygame.draw.rect(surf, C_RUIN_OUT, (x + 6, y + 6, TILE_SIZE - 12, TILE_SIZE - 12), 2)
        # Cross detail
        mid = TILE_SIZE // 2
        pygame.draw.line(surf, C_RUIN_OUT, (x + mid, y + 8), (x + mid, y + TILE_SIZE - 8), 2)
        pygame.draw.line(surf, C_RUIN_OUT, (x + 8, y + mid), (x + TILE_SIZE - 8, y + mid), 2)

    def _draw_item(self, surf, x, y):
        cx, cy = x + TILE_SIZE // 2, y + TILE_SIZE // 2
        pygame.draw.polygon(surf, C_ITEM, [
            (cx, cy - 10), (cx + 8, cy + 6), (cx - 8, cy + 6)
        ])

    # ------------------------------------------------------------------
    def is_solid(self, pixel_x, pixel_y):
        c = int(pixel_x // TILE_SIZE)
        r = int(pixel_y // TILE_SIZE)
        if not (0 <= c < MAP_COLS and 0 <= r < MAP_ROWS):
            return True
        return self.grid[r][c] in (TILE_TREE, TILE_WATER)

    def tile_at_pixel(self, pixel_x, pixel_y):
        c = int(pixel_x // TILE_SIZE)
        r = int(pixel_y // TILE_SIZE)
        if 0 <= c < MAP_COLS and 0 <= r < MAP_ROWS:
            return self.grid[r][c], (c, r)
        return None, None

    # ------------------------------------------------------------------
    def draw(self, screen, camera_offset):
        screen.blit(self._surface, (-camera_offset[0], -camera_offset[1]))

    def redraw_tile(self, col, row):
        """Redraw a single tile onto the baked surface (after state change)."""
        x, y = col * TILE_SIZE, row * TILE_SIZE
        tile = self.grid[row][col]
        variant = (row + col) % 2 == 0
        pygame.draw.rect(self._surface, _tile_colour(tile, variant),
                         (x, y, TILE_SIZE, TILE_SIZE))
