from settings import SCREEN_W, SCREEN_H


class Camera:
    """Tracks a target rect and produces a world-to-screen offset."""

    def __init__(self, map_pixel_w, map_pixel_h):
        self.map_w = map_pixel_w
        self.map_h = map_pixel_h
        self.x = 0
        self.y = 0

    def update(self, target_rect):
        # Centre the camera on the target
        self.x = target_rect.centerx - SCREEN_W // 2
        self.y = target_rect.centery - SCREEN_H // 2
        # Clamp so we never show outside the map
        self.x = max(0, min(self.x, self.map_w - SCREEN_W))
        self.y = max(0, min(self.y, self.map_h - SCREEN_H))

    @property
    def offset(self):
        return (self.x, self.y)

    def world_to_screen(self, wx, wy):
        return wx - self.x, wy - self.y
