import pygame
from settings import (PLAYER_SPEED, PLAYER_SIZE,
                      C_PLAYER, C_PLAYER_OUT, TILE_SIZE)


class Player:
    def __init__(self, start_col, start_row):
        cx = start_col * TILE_SIZE + TILE_SIZE // 2
        cy = start_row * TILE_SIZE + TILE_SIZE // 2
        half = PLAYER_SIZE // 2
        self.rect = pygame.Rect(cx - half, cy - half, PLAYER_SIZE, PLAYER_SIZE)
        self.facing = (0, 1)  # direction unit vector (for shadow/indicator)

    # ------------------------------------------------------------------
    def update(self, keys, tilemap):
        dx = dy = 0
        if keys[pygame.K_LEFT]  or keys[pygame.K_a]: dx = -1
        if keys[pygame.K_RIGHT] or keys[pygame.K_d]: dx =  1
        if keys[pygame.K_UP]    or keys[pygame.K_w]: dy = -1
        if keys[pygame.K_DOWN]  or keys[pygame.K_s]: dy =  1

        if dx or dy:
            self.facing = (dx, dy)

        self._move(dx * PLAYER_SPEED, 0, tilemap)
        self._move(0, dy * PLAYER_SPEED, tilemap)

    def _move(self, dx, dy, tilemap):
        self.rect.x += dx
        self.rect.y += dy
        if self._collides(tilemap):
            self.rect.x -= dx
            self.rect.y -= dy

    def _collides(self, tilemap):
        # Check all four corners of the player hitbox
        corners = [
            (self.rect.left  + 2, self.rect.top    + 2),
            (self.rect.right - 2, self.rect.top    + 2),
            (self.rect.left  + 2, self.rect.bottom - 2),
            (self.rect.right - 2, self.rect.bottom - 2),
        ]
        return any(tilemap.is_solid(px, py) for px, py in corners)

    # ------------------------------------------------------------------
    def draw(self, screen, camera):
        sx, sy = camera.world_to_screen(self.rect.x, self.rect.y)
        draw_rect = pygame.Rect(sx, sy, PLAYER_SIZE, PLAYER_SIZE)

        # Shadow
        pygame.draw.ellipse(screen, (0, 0, 0, 80),
                            (sx + 4, sy + PLAYER_SIZE - 6, PLAYER_SIZE - 8, 8))

        # Body (circle)
        cx, cy = draw_rect.centerx, draw_rect.centery
        pygame.draw.circle(screen, C_PLAYER, (cx, cy), PLAYER_SIZE // 2)
        pygame.draw.circle(screen, C_PLAYER_OUT, (cx, cy), PLAYER_SIZE // 2, 2)

        # Direction dot
        fx, fy = self.facing
        dot_x = cx + fx * (PLAYER_SIZE // 2 - 5)
        dot_y = cy + fy * (PLAYER_SIZE // 2 - 5)
        pygame.draw.circle(screen, C_PLAYER_OUT, (dot_x, dot_y), 4)

    @property
    def center(self):
        return self.rect.center
