import pygame
import sys

from settings import (SCREEN_W, SCREEN_H, FPS, TITLE, C_BG,
                      TILE_SIZE, MAP_COLS, MAP_ROWS, TILE_TREE)
from world.tilemap import TileMap
from world.camera import Camera
from entities.player import Player
from entities.interaction import check_interaction


# Starting tile — find first open grass spot near top-left
def _find_start(tilemap):
    for r in range(2, MAP_ROWS):
        for c in range(2, MAP_COLS):
            if tilemap.grid[r][c] == 0:
                return c, r
    return 2, 2


class Game:
    def __init__(self):
        pygame.init()
        self.screen = pygame.display.set_mode((SCREEN_W, SCREEN_H))
        pygame.display.set_caption(TITLE)
        self.clock = pygame.time.Clock()

        self.tilemap = TileMap()
        sc, sr = _find_start(self.tilemap)
        self.player = Player(sc, sr)
        self.camera = Camera(self.tilemap.pixel_w, self.tilemap.pixel_h)

        self.font_sm = pygame.font.SysFont("monospace", 14, bold=False)
        self.font_md = pygame.font.SysFont("monospace", 18, bold=True)

        self.message = ""
        self.message_timer = 0
        self.items_collected = 0

    # ------------------------------------------------------------------
    def run(self):
        while True:
            dt = self.clock.tick(FPS)
            self._handle_events()
            self._update()
            self._draw()
            pygame.display.flip()

    # ------------------------------------------------------------------
    def _handle_events(self):
        interact = False
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    pygame.quit()
                    sys.exit()
                if event.key == pygame.K_e:
                    interact = True

        msg = check_interaction(self.player, self.tilemap, interact)
        if msg:
            self.message = msg
            self.message_timer = 180  # frames
            if "pluma" in msg:
                self.items_collected += 1

    def _update(self):
        keys = pygame.key.get_pressed()
        self.player.update(keys, self.tilemap)
        self.camera.update(self.player.rect)
        if self.message_timer > 0:
            self.message_timer -= 1

    # ------------------------------------------------------------------
    def _draw(self):
        self.screen.fill(C_BG)
        self.tilemap.draw(self.screen, self.camera.offset)
        self.player.draw(self.screen, self.camera)
        self._draw_ui()

    def _draw_ui(self):
        # HUD: items collected
        hud = self.font_sm.render(
            f"Plumas: {self.items_collected}/5   [WASD] Mover   [E] Interagir   [ESC] Sair",
            True, (240, 240, 200))
        bg = pygame.Surface((hud.get_width() + 16, hud.get_height() + 8))
        bg.set_alpha(160)
        bg.fill((0, 0, 0))
        self.screen.blit(bg, (8, 8))
        self.screen.blit(hud, (16, 12))

        # Interaction message
        if self.message_timer > 0:
            alpha = min(255, self.message_timer * 4)
            msg_surf = self.font_md.render(self.message, True, (255, 240, 160))
            msg_surf.set_alpha(alpha)
            mx = SCREEN_W // 2 - msg_surf.get_width() // 2
            my = SCREEN_H - 70
            bg2 = pygame.Surface((msg_surf.get_width() + 20, msg_surf.get_height() + 12))
            bg2.set_alpha(int(alpha * 0.6))
            bg2.fill((0, 0, 0))
            self.screen.blit(bg2, (mx - 10, my - 6))
            self.screen.blit(msg_surf, (mx, my))

        # Win condition
        if self.items_collected >= 5:
            win = self.font_md.render("Você coletou todas as plumas sagradas!  Parabéns!", True, (255, 220, 50))
            wx = SCREEN_W // 2 - win.get_width() // 2
            wy = SCREEN_H // 2 - win.get_height() // 2
            bg3 = pygame.Surface((win.get_width() + 24, win.get_height() + 16))
            bg3.set_alpha(200)
            bg3.fill((30, 60, 20))
            self.screen.blit(bg3, (wx - 12, wy - 8))
            self.screen.blit(win, (wx, wy))
